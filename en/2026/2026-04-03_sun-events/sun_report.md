# Sun Report

````julia
using SolarPosition, Dates, TimeZones, DataFrames, DataFramesMeta, ShiftedArrays, TimeZoneFinder, PrettyTables


obs = Observer(55.741635, 12.371448)
tz_cph = TimeZone("Europe/Copenhagen", TimeZones.Class(:LEGACY))
tp = DateTime("2026-04-03T12:00:00")
zdt = ZonedDateTime(tp, tz_cph)

import DataFrames.DataFrame

function DataFrame(e::TransitSunriseSunset{T}) where T <: Union{ZonedDateTime, DateTime}
    DataFrame(sunrise = e.sunrise, transit = e.transit, sunset = e.sunset)
end

import Base./
function /(::Any, ::Missing) missing end
function /(::Missing, ::Any) missing end

function all_sun_events(year = 2026, obs=Observer(55.741635, 12.371448) , tz = timezone_at(obs.latitude, obs.longitude) )  ## TimeZone("Europe/Copenhagen", TimeZones.Class(:LEGACY)))
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
                :day_length_hours = (:sunset .- :sunrise) ./ Dates.Hour(1),
                :night_after_hours = (ShiftedArrays.lead(:sunrise) .- :sunset)./Dates.Hour(1),
                )
    @transform!(df,
                :("day-night") = abs.(:day_length_hours .- :night_after_hours),
                :("day/night") = abs.(:day_length_hours ./ :night_after_hours),
                :("day-day_minutes") = abs.(ShiftedArrays.lead(:day_length_hours) .- :day_length_hours)*60,
                :date = Date.(:date)
                )
    df
end

function sun_events(year::Int = 2026, obs::Observer=Observer(55.741635, 12.371448) ,  tz = timezone_at(obs.latitude, obs.longitude) )
    s = all_sun_events(year, obs, tz)
    vcat(
        hcat(DataFrame(event = "Longest day"), DataFrame(last(sort(s, :day_length_hours)))),
        hcat(DataFrame(event = "Shortest day"), DataFrame(first(sort(s, :day_length_hours)))),
        hcat(DataFrame(event = ["Equinox", "Equinox"]), DataFrame(first(sort(s, "day-night"),2))),

    )
end

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


function sun_events(year::Int, name::String; country="")
    location =  get_location(name; country = country)
    nrow(location) == 0 && error("Could not find location")
    res = first(location)
    @transform(sun_events(year, Observer(parse(Float64,res.lat), parse(Float64,res.lng))), :location = name, :lat = parse(Float64,res.lat), :long = parse(Float64,res.lng))
end
````

````
sun_events (generic function with 5 methods)
````

# Ballerup

````julia
pretty_table(sun_events(2026,"ballerup")[:,[1,2,6,7,8,9,10,11,12,14]], backend=:markdown)
````

````
uri = "http://api.geonames.org/searchJSON?q=ballerup&maxRows=10&username=tp2750&country="
| **event**<br>`String` | **date**<br>`Date` | **day**<br>`Int64` | **sunup**<br>`Float64` | **sundown**<br>`Float64` | **midday**<br>`Float64` | **day\_length\_hours**<br>`Float64` | **night\_after\_hours**<br>`Float64?` | **day-night**<br>`Float64?` | **day-day\_minutes**<br>`Float64?` |
|----------------------:|-------------------:|-------------------:|-----------------------:|-------------------------:|------------------------:|------------------------------------:|--------------------------------------:|----------------------------:|-----------------------------------:|
|           Longest day |         2026-06-21 |                172 |                4.42861 |                  21.9831 |                 13.2058 |                             17.5544 |                               6.44972 |                     11.1047 |                                0.1 |
|          Shortest day |         2026-12-21 |                355 |                8.63861 |                  15.6475 |                 12.1433 |                             7.00889 |                               16.9994 |                     9.99056 |                          0.0166667 |
|               Equinox |         2026-09-25 |                268 |                7.02389 |                  19.0314 |                 13.0372 |                             12.0075 |                                12.025 |                      0.0175 |                            4.58333 |
|               Equinox |         2026-03-17 |                 76 |                6.34806 |                  18.2997 |                 12.3144 |                             11.9517 |                                12.005 |                   0.0533333 |                               4.65 |

````

# Sommerhus

````julia
pretty_table(sun_events(2026,"solsbæk")[:,[1,2,6,7,8,9,10,11,12,14]], backend=:markdown)
````

````
uri = "http://api.geonames.org/searchJSON?q=solsb%C3%A6k&maxRows=10&username=tp2750&country="
| **event**<br>`String` | **date**<br>`Date` | **day**<br>`Int64` | **sunup**<br>`Float64` | **sundown**<br>`Float64` | **midday**<br>`Float64` | **day\_length\_hours**<br>`Float64` | **night\_after\_hours**<br>`Float64?` | **day-night**<br>`Float64?` | **day-day\_minutes**<br>`Float64?` |
|----------------------:|-------------------:|-------------------:|-----------------------:|-------------------------:|------------------------:|------------------------------------:|--------------------------------------:|----------------------------:|-----------------------------------:|
|           Longest day |         2026-06-21 |                172 |                 4.3425 |                  22.3144 |                 13.3286 |                             17.9719 |                               6.03194 |                       11.94 |                                0.1 |
|          Shortest day |         2026-12-21 |                355 |                  8.945 |                  15.5864 |                 12.2658 |                             6.64139 |                               17.3669 |                     10.7256 |                          0.0166667 |
|               Equinox |         2026-09-25 |                268 |                7.14778 |                  19.1514 |                 13.1597 |                             12.0036 |                               12.0311 |                      0.0275 |                            4.83333 |
|               Equinox |         2026-03-17 |                 76 |                6.47444 |                  18.4197 |                 12.4369 |                             11.9453 |                               12.0089 |                   0.0636111 |                            4.93333 |

````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

