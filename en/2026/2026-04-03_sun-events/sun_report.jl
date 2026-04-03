# # Sun Report

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

# # Ballerup

pretty_table(sun_events(2026,"ballerup")[:,[1,2,6,7,8,9,10,11,12,14]], backend=:markdown)



# # Sommerhus

pretty_table(sun_events(2026,"solsbæk")[:,[1,2,6,7,8,9,10,11,12,14]], backend=:markdown) 

