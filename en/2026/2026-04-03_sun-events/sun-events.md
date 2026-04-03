# Sun events
TP 2026-04-03

For a given position on Earth, what are the:

  - sortest / longest day / night
  - earliest / latest sunrise / sunset
  - sortest / lognest time between sunrises / sunsets
  - when is solar noon closest to 12:00 (w/wo summertime)

- in UTC and in local time

Streach goals:
- find time-zone from position
- find position from location name

# Julia implementation

## SolarPosition
https://github.com/JuliaAstro/SolarPosition.jl
https://discourse.julialang.org/t/ann-solarposition-jl/134263/12?u=tp2750

- https://juliaastro.org/SolarPosition.jl/dev/#Sunrise-and-Sunset-Calculations
- https://juliaastro.org/SolarPosition.jl/dev/utilities/#Sunrise,-Sunset,-and-Solar-Noon

``` julia
using SolarPosition, Dates, TimeZones, DataFrames, DataFramesMeta, ShiftedArrays


obs = Observer(55.741635, 12.371448)
tz_cph = TimeZone("Europe/Copenhagen", TimeZones.Class(:LEGACY))
tp = DateTime("2026-04-03T12:00:00")
zdt = ZonedDateTime(tp, tz_cph)

events = transit_sunrise_sunset(obs, zdt)

julia> fieldnames(typeof(events))
(:transit, :sunrise, :sunset)

DataFrame(sunrise = events.sunrise, transit = events.transit, sunset = events.sunset)

1×3 DataFrame
 Row │ sunrise                    transit                    sunset                    
     │ ZonedDat…                  ZonedDat…                  ZonedDat…                 
─────┼─────────────────────────────────────────────────────────────────────────────────
   1 │ 2026-04-03T06:36:30+02:00  2026-04-03T13:13:46+02:00  2026-04-03T19:52:18+02:00

# Tempest says: 6:36, 19:51
# So not exactly the same

# Default algorithm is SPA(): https://github.com/JuliaAstro/SolarPosition.jl/blob/main/src/Utilities/srt.jl#L66
# only SPA is currently supported: https://github.com/JuliaAstro/SolarPosition.jl/blob/31baad6abf66c433037a25d66aaf6156d8cc37f5/src/Utilities/spa.jl#L44
# Try some others:

import DataFrames.DataFrame

function DataFrame(e::TransitSunriseSunset{T}) where T <: Union{ZonedDateTime, DateTime}
    DataFrame(sunrise = e.sunrise, transit = e.transit, sunset = e.sunset)
end

DataFrame(events)

DataFrame( transit_sunrise_sunset(obs, zdt, PSA()))
DataFrame( transit_sunrise_sunset(obs, zdt, NOAA()))
DataFrame( transit_sunrise_sunset(obs, zdt, Walraven()))
DataFrame( transit_sunrise_sunset(obs, zdt, USNO()))
DataFrame( transit_sunrise_sunset(obs, zdt, SPA()))

# They all fail except  transit_sunrise_sunset(obs, zdt, SPA())

import Base./
function /(::Any, ::Missing) missing end
function /(::Missing, ::Any) missing end

function all_sun_events(year = 2026, obs=Observer(55.741635, 12.371448) , tz =  TimeZone("Europe/Copenhagen", TimeZones.Class(:LEGACY)))
    dfs = DataFrame[]
    ndays = isleapyear(year) ? 366 : 365
    for d in 0:ndays-1
        tp = ZonedDateTime(DateTime(year,1,1,12) + Dates.Day(d), tz)
        push!(dfs,  hcat(DataFrame(date = tp - Dates.Hour(12)), DataFrame(transit_sunrise_sunset(obs, tp))))
    end
    df = reduce(vcat, dfs)
    @transform!(df,
                :day = 1:nrow(df),
                :sunup = (:sunrise .- :date) ./ Dates.Hour(1),
                :sundown = (:sunset .- :date) ./ Dates.Hour(1),
                :midday =  (:transit .- :date) ./ Dates.Hour(1),
                :day_length_hours = (:sunset .- :sunrise)./Dates.Hour(1),
                :night_after_hours = (ShiftedArrays.lead(:sunrise) .- :sunset)./Dates.Hour(1),
#                :sunset_sunset_hours = (:sunset .- ShiftedArrays.lag(:sunset))./Dates.Hour(1),    
#                :sunrise_sunrise_hours = (:sunrise .- ShiftedArrays.lag(:sunrise))./Dates.Hour(1),
                )
    @transform!(df,
                :("day-night") = abs.(:day_length_hours .- :night_after_hours),
                :("day/night") = abs.(:day_length_hours ./ :night_after_hours),
                :("day-day_minutes") = abs.(ShiftedArrays.lead(:day_length_hours) .- :day_length_hours)*60,
                :date = Date.(:date)
                )
    df
end

function sun_events(year = 2026, obs=Observer(55.741635, 12.371448) , tz =  TimeZone("Europe/Copenhagen", TimeZones.Class(:LEGACY)))
    s = all_sun_events(year, obs, tz)
    vcat(
        hcat(DataFrame(event = "Longest day"), DataFrame(last(sort(s, :day_length_hours)))),
        hcat(DataFrame(event = "Shortest day"), DataFrame(first(sort(s, :day_length_hours)))),
        hcat(DataFrame(event = ["Equinox", "Equinox"]), DataFrame(first(sort(s, "day-night"),2))),
        
    )
end

sun_events()

s1 = all_sun_events()

findmin(s1.day_length_hours) # (7.006666666666667, 355)
findmax(s1.day_length_hours) # (17.556944444444444, 172)


s1 = all_sun_events()

s2 = all_sun_events(2026, Observer(55.741635, 12.371448), tz"UTC")

findmin(s2.day_length_hours) # (7.006666666666667, 355)
findmax(s2.day_length_hours) # (17.556944444444444, 172)

julia> s1[172,:]
DataFrameRow
 Row │ sunrise                    transit                    sunset                     day_length_hours 
     │ ZonedDat…                  ZonedDat…                  ZonedDat…                  Float64          
─────┼───────────────────────────────────────────────────────────────────────────────────────────────────
 172 │ 2026-06-21T04:25:37+02:00  2026-06-21T13:12:19+02:00  2026-06-21T21:59:02+02:00           17.5569

julia> s2[172,:]
DataFrameRow
 Row │ sunrise                    transit                    sunset                     day_length_hours 
     │ ZonedDat…                  ZonedDat…                  ZonedDat…                  Float64          
─────┼───────────────────────────────────────────────────────────────────────────────────────────────────
 172 │ 2026-06-21T02:25:37+00:00  2026-06-21T11:12:19+00:00  2026-06-21T19:59:02+00:00           17.5569



findmax(dropmissing(s1).sunset_sunset) # (24.03638888888889, 35)
findmax(dropmissing(s2).sunset_sunset) # (24.03638888888889, 35)

findmin(dropmissing(s1).sunset_sunset) # (23.955833333333334, 263)
findmin(dropmissing(s2).sunset_sunset) # (23.955833333333334, 263)

findmin(dropmissing(s1).sunrise_sunrise_hours) # (23.95638888888889, 76) # Forårsjævndøgn?
findmax(dropmissing(s1).sunrise_sunrise_hours) # (24.03527777777778, 303)

findmin(dropmissing(s2).sunrise_sunrise_hours) # same as s1
findmax(dropmissing(s2).sunrise_sunrise_hours) # same as s1

julia> s1[[35,76, 172,263,303, 355],:]
6×6 DataFrame
 Row │ sunrise                    transit                    sunset                     day_length_hours  sunset_sunset_hours  sunrise_sunrise_hours 
     │ ZonedDat…                  ZonedDat…                  ZonedDat…                  Float64           Float64?             Float64?              
─────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ 2026-02-04T07:58:35+01:00  2026-02-04T12:24:23+01:00  2026-02-04T16:50:56+01:00           8.8725               24.0358                23.9672
   2 │ 2026-03-17T06:20:52+01:00  2026-03-17T12:18:50+01:00  2026-03-17T18:17:57+01:00          11.9514               24.0339                23.9567
   3 │ 2026-06-21T04:25:37+02:00  2026-06-21T13:12:19+02:00  2026-06-21T21:59:02+02:00          17.5569               24.0039                24.0028
   4 │ 2026-09-20T06:51:44+02:00  2026-09-20T13:03:58+02:00  2026-09-20T19:15:01+02:00          12.3881               23.9561                24.0322
   5 │ 2026-10-30T07:12:12+01:00  2026-10-30T11:54:10+01:00  2026-10-30T16:35:17+01:00           9.38472              23.9631                24.035
   6 │ 2026-12-21T08:38:21+01:00  2026-12-21T12:08:34+01:00  2026-12-21T15:38:45+01:00           7.00667              24.0072                24.0094

findmin(dropmissing(s1).night_after_hours) # (6.446944444444444, 170)
findmax(dropmissing(s1).night_after_hours) # (17.001666666666665, 354)

findmin(dropmissing(s1).day_night) # (0.4121164591706696, 354)
findmax(dropmissing(s1).day_night) # (2.7232969968546685, 171)

findmin(abs.(1 .-dropmissing(s1).day_night)) # (0.0014553014553014831, 267)
findmax(abs.(1 .-dropmissing(s1).day_night)) # (1.7232969968546685, 171)

# Jævndøgn
julia> s1[sortperm(abs.(1 .-dropmissing(s1).day_night))[1:4],:]
4×8 DataFrame
 Row │ sunrise                    transit                    sunset                     day_length_hours  night_after_hours  sunset_sunset_hours  sunrise_sunrise_hours  day_night 
     │ ZonedDat…                  ZonedDat…                  ZonedDat…                  Float64           Float64?           Float64?             Float64?               Float64?  
─────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ 2026-09-24T06:59:28+02:00  2026-09-24T13:02:33+02:00  2026-09-24T19:04:29+02:00           12.0836            11.9486              23.9564                24.0322   1.0113
   2 │ 2026-03-16T06:23:28+01:00  2026-03-16T12:19:07+01:00  2026-03-16T18:15:55+01:00           11.8742            12.0825              24.0342                23.9567   0.982757
   3 │ 2026-03-17T06:20:52+01:00  2026-03-17T12:18:50+01:00  2026-03-17T18:17:57+01:00           11.9514            12.005               24.0339                23.9567   0.995534
   4 │ 2026-09-23T06:57:32+02:00  2026-09-23T13:02:54+02:00  2026-09-23T19:07:06+02:00           12.1594            11.8728              23.9561                24.0322   1.02414

julia> sortperm(abs.(1 .-dropmissing(s1).day_night))[1:4]
4-element Vector{Int64}:
 267
  75
  76
 266

sort(s1, "day-night")

julia> sort(s1, "day-night")
365×8 DataFrame
 Row │ sunrise                    transit                    sunset                     day    day_length_hours  night_after_hours  day-night        day/night      
     │ ZonedDat…                  ZonedDat…                  ZonedDat…                  Int64  Float64           Float64?           Float64?         Float64?       
─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ 2026-09-25T07:01:24+02:00  2026-09-25T13:02:12+02:00  2026-09-25T19:01:51+02:00    268          12.0075            12.025          0.0175           0.998545
   2 │ 2026-03-17T06:20:52+01:00  2026-03-17T12:18:50+01:00  2026-03-17T18:17:57+01:00     76          11.9514            12.005          0.0536111        0.995534
   3 │ 2026-03-18T06:18:15+01:00  2026-03-18T12:18:33+01:00  2026-03-18T18:20:00+01:00     77          12.0292            11.9275         0.101667         1.00852
   4 │ 2026-09-24T06:59:28+02:00  2026-09-24T13:02:33+02:00  2026-09-24T19:04:29+02:00    267          12.0836            11.9486         0.135            1.0113
   5 │ 2026-09-26T07:03:21+02:00  2026-09-26T13:01:51+02:00  2026-09-26T18:59:13+02:00    269          11.9311            12.1014         0.170278         0.985929


```

## Conclusions
* It is fine to work with timezoned data. The lengths of nigths, days etc are the same as in tz"UTC".
* Longest day:  2026-06-21
* Shortest day: 2026-12-21
* Equinox: 2026-09-25, 2026-03-17



``` julia
julia> sort(s1, "day_length_hours")[[1,end],:]
2×13 DataFrame
 Row │ date                       sunrise                    transit                    sunset                     day    sunup    sundown  midday   day_length_hours  night_after_hours  day-night  day/night  day-day_minutes 
     │ ZonedDat…                  ZonedDat…                  ZonedDat…                  ZonedDat…                  Int64  Float64  Float64  Float64  Float64           Float64?           Float64?   Float64?   Float64?        
─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ 2026-12-21T00:00:00+01:00  2026-12-21T08:38:21+01:00  2026-12-21T12:08:34+01:00  2026-12-21T15:38:45+01:00    355  8.63917  15.6458  12.1428           7.00667           17.0017       9.995   0.412116        0.0166667
   2 │ 2026-06-21T00:00:00+02:00  2026-06-21T04:25:37+02:00  2026-06-21T13:12:19+02:00  2026-06-21T21:59:02+02:00    172  4.42694  21.9839  13.2053          17.5569             6.44694     11.11    2.7233          0.0833333

julia> sort(s1, "day-night")[1:2,:]
2×13 DataFrame
 Row │ date                       sunrise                    transit                    sunset                     day    sunup    sundown  midday   day_length_hours  night_after_hours  day-night  day/night  day-day_minutes 
     │ ZonedDat…                  ZonedDat…                  ZonedDat…                  ZonedDat…                  Int64  Float64  Float64  Float64  Float64           Float64?           Float64?   Float64?   Float64?        
─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ 2026-09-25T00:00:00+02:00  2026-09-25T07:01:24+02:00  2026-09-25T13:02:12+02:00  2026-09-25T19:01:51+02:00    268  7.02333  19.0308  13.0367           12.0075             12.025  0.0175      0.998545          4.58333
   2 │ 2026-03-17T00:00:00+01:00  2026-03-17T06:20:52+01:00  2026-03-17T12:18:50+01:00  2026-03-17T18:17:57+01:00     76  6.34778  18.2992  12.3139           11.9514             12.005  0.0536111   0.995534          4.66667

```

## TimeZoneFinder
https://github.com/tpgillam/TimeZoneFinder.jl

] add TimeZoneFinder
julia> timezone_at(52.5061, 13.358)
Europe/Berlin (UTC+1/UTC+2)

## Geo Locations
https://www.geonames.org/search.html?q=solsb%C3%A6k&country=
https://github.com/JuliaGeo/GADM.jl?tab=readme-ov-file


API documentation here:
- https://www.geonames.org/export/web-services.html
- https://www.geonames.org/export/geonames-search.html
- Example: "http://api.geonames.org/searchJSON?q=london&maxRows=10&username=demo (replace demo by username)

``` julia
using HTTP, JSON

function get_location(name, geonamesuser = get(ENV, "GEONAMES_USER", ""), maxrows=10; country="")
    url = "http://api.geonames.org"
    q= HTTP.escapeuri(name)
    uri = "$url/searchJSON?q=$q&maxRows=$maxrows&username=$geonamesuser&country=$country"
    @show(uri)
    r1 = HTTP.get(uri)
    b1 = r1.body
    j1 = JSON.parse(b1)
    try
        return(vcat(DataFrame.(j1.geonames)..., cols=:union))
    catch e
        return(j1.geonames)
    end
        
end

using Literate
Literate.markdown("sun_report.jl", execute=true)

```

## AstroLib

## GMT

https://www.generic-mapping-tools.org/GMTjl_doc/documentation/modules/solar.html


# R implementation
https://stackoverflow.com/questions/68592914/how-to-calculate-sunrise-and-sunset-in-julia:

Python has suntime, R has suntimes

# Python implementation
