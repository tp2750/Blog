# Time points
TP 2026-04-03

# Objective
When have I leved for 2^30 seconds or 1E4 days?

In general, when have t = B^n time units elapsed for
* B in 2, 10
* n >= 2
* time units in sec (human), day(earth), month (moon), year (sun)
where t < 150 years

# R implementation
`{lubridate}` has `duration()` for this: https://lubridate.tidyverse.org/reference/duration.html

``` r
library(lubridate)
library(plyr)

when <- function(x, unit = "seconds", from=now()){
    as.Date(from) + lubridate::duration(x, unit)
}

duration(2^30 , "seconds") / dyears(1)

r1 <- ddply(expand.grid(n = 1:2, b = c(2, 10), unit = c("seconds", "days", "months", "years")), .(n, b, unit), transform,text = sprintf("%s^%s %s", b, n, unit), years =  duration(b^n, unit) / dyears(1))
r1 <- plyr::arrange(r1, unit, b, n)
subset(r1, years > 5 & years < 150)


time_points <- function(from = now()) {
    r1 <- ddply(expand.grid(b = c(2, 10), n = 1:32, unit = c("seconds", "days", "weeks","months")), .(b, n, unit), transform,text = sprintf("%s^%s = %s %s", b, n, b^n, unit), years =  duration(b^n, unit) / dyears(1))
    r1 <- plyr::arrange(r1, years) # plyr::arrange(r1, unit, b, n)
    r2 <- transform(subset(r1, years > 5 & years < 150), when = from + duration(b^n, unit))
    r2
}

> time_points(from = as.Date("1970-09-11"))
    b  n    unit                      text      years                when
65  2  6  months           2^6 = 64 months   5.333333 1976-01-11 00:00:00
66  2 11    days          2^11 = 2048 days   5.607118 1976-04-20 00:00:00
67 10  2  months         10^2 = 100 months   8.333333 1979-01-10 18:00:00
68  2 28 seconds  2^28 = 268435456 seconds   8.506206 1979-03-14 21:24:16
69  2  9   weeks           2^9 = 512 weeks   9.812457 1980-07-04 00:00:00
70  2  7  months          2^7 = 128 months  10.666667 1981-05-12 00:00:00
71  2 12    days          2^12 = 4096 days  11.214237 1981-11-28 00:00:00
72  2 29 seconds  2^29 = 536870912 seconds  17.012413 1987-09-15 18:48:32
73 10  3   weeks         10^3 = 1000 weeks  19.164956 1989-11-10 00:00:00
74  2 10   weeks         2^10 = 1024 weeks  19.624914 1990-04-27 00:00:00
75  2  8  months          2^8 = 256 months  21.333333 1992-01-11 00:00:00
76  2 13    days          2^13 = 8192 days  22.428474 1993-02-14 00:00:00
77 10  4    days         10^4 = 10000 days  27.378508 1998-01-27 00:00:00
78 10  9 seconds      10^9 = 1e+09 seconds  31.688088 2002-05-20 01:46:40
79  2 30 seconds 2^30 = 1073741824 seconds  34.024825 2004-09-19 13:37:04
80  2 11   weeks         2^11 = 2048 weeks  39.249829 2009-12-11 00:00:00
81  2  9  months          2^9 = 512 months  42.666667 2013-05-12 00:00:00
82  2 14    days         2^14 = 16384 days  44.856947 2015-07-21 00:00:00
83  2 31 seconds 2^31 = 2147483648 seconds  68.049650 2038-09-29 03:14:08
84  2 12   weeks         2^12 = 4096 weeks  78.499658 2049-03-12 00:00:00
85 10  3  months        10^3 = 1000 months  83.333333 2054-01-10 12:00:00
86  2 10  months        2^10 = 1024 months  85.333333 2056-01-11 00:00:00
87  2 15    days         2^15 = 32768 days  89.713895 2060-05-29 00:00:00
88  2 32 seconds 2^32 = 4294967296 seconds 136.099301 2106-10-18 06:28:16

```

## Report



# Julia implementation

``` julia
using Dates, DataFrames, DataFramesMeta, Printf


julia> DateTime("2000-01-01") + Dates.Second(1)
2000-01-01T00:00:01


julia> vec(collect(Iterators.product([2,10], 1:2)))
4-element Vector{Tuple{Int64, Int64}}:
 (2, 1)
 (10, 1)
 (2, 2)
 (10, 2)

julia> crossjoin(DataFrame(b = [2,10]), DataFrame(n = 1:2))
4×2 DataFrame
 Row │ b      n     
     │ Int64  Int64 
─────┼──────────────
   1 │     2      1
   2 │     2      2
   3 │    10      1
   4 │    10      2

day = 60*60*24 # sec ddays(1) / dseconds(1) == (60*60*24)
week = day*7 # sec (same as R: dweeks(1) / dseconds(1) == 60*60*24*7 
year = day*365.25 # sec  (same as R: dyears(1) / dseconds(1) == 60*60*24*365.25
month = year/12 # sec == 30.4375 day. R: dyears(1) /12 == dmonths(1)

seconds(s) = s
days(s) = s * day
weeks(s) = s * week
months(s) = s * month
years(s) = s * year


crossjoin(DataFrame(b = [2,10]), DataFrame(n = 1:2), DataFrame(unit = ["seconds", "days", "weeks", "months"]))

d1 = crossjoin(DataFrame(b = [2,10]), DataFrame(n = 1:2), DataFrame(unit = [seconds, days, weeks, months]))
d2 = crossjoin(DataFrame(b = [2,10]), DataFrame(n = 1:2), DataFrame(unit = [second, day, week, month]))

@transform(d1, :years = :b.^:n)

transform(d1, [:b,:n,:unit] => ByRow((b,n,u) -> u(b^n)/year) => :years)

function time_points( from = now())
    d1 = crossjoin(DataFrame(b = [2,10]), DataFrame(n = 1:32), DataFrame(unit = [seconds, days, weeks, months]))
    transform!(d1,
               [:b,:n,:unit] => ByRow((b,n,u) -> u(b^n)/year) => :years,
               )
    @subset!(d1, :years .> 5 .&& :years .< 150)
    sort!(d1, [:years])
    transform!(d1,
               [:b,:n,:unit] => ByRow((b,n,u) -> DateTime(from) + Dates.Second(u(b^n))) => :when,
               [:b,:n,:unit] => ByRow((b,n,u) -> @sprintf("%s^%s = %s %s", b,n,b^n,String(Symbol(u)))) => :text,
               )
end


julia> t_dates = time_points("1970-09-11")
24×6 DataFrame
 Row │ b      n      unit      years      when                 text                      
     │ Int64  Int64  Function  Float64    DateTime             String                    
─────┼───────────────────────────────────────────────────────────────────────────────────
   1 │     2      6  months      5.33333  1976-01-11T00:00:00  2^6 = 64 months
   2 │     2     11  days        5.60712  1976-04-20T00:00:00  2^11 = 2048 days
   3 │    10      2  months      8.33333  1979-01-10T18:00:00  10^2 = 100 months
   4 │     2     28  seconds     8.50621  1979-03-14T21:24:16  2^28 = 268435456 seconds
   5 │     2      9  weeks       9.81246  1980-07-04T00:00:00  2^9 = 512 weeks
   6 │     2      7  months     10.6667   1981-05-12T00:00:00  2^7 = 128 months
   7 │     2     12  days       11.2142   1981-11-28T00:00:00  2^12 = 4096 days
   8 │     2     29  seconds    17.0124   1987-09-15T18:48:32  2^29 = 536870912 seconds
   9 │    10      3  weeks      19.165    1989-11-10T00:00:00  10^3 = 1000 weeks
  10 │     2     10  weeks      19.6249   1990-04-27T00:00:00  2^10 = 1024 weeks
  11 │     2      8  months     21.3333   1992-01-11T00:00:00  2^8 = 256 months
  12 │     2     13  days       22.4285   1993-02-14T00:00:00  2^13 = 8192 days
  13 │    10      4  days       27.3785   1998-01-27T00:00:00  10^4 = 10000 days
  14 │    10      9  seconds    31.6881   2002-05-20T01:46:40  10^9 = 1000000000 seconds
  15 │     2     30  seconds    34.0248   2004-09-19T13:37:04  2^30 = 1073741824 seconds
  16 │     2     11  weeks      39.2498   2009-12-11T00:00:00  2^11 = 2048 weeks
  17 │     2      9  months     42.6667   2013-05-12T00:00:00  2^9 = 512 months
  18 │     2     14  days       44.8569   2015-07-21T00:00:00  2^14 = 16384 days
  19 │     2     31  seconds    68.0497   2038-09-29T03:14:08  2^31 = 2147483648 seconds
  20 │     2     12  weeks      78.4997   2049-03-12T00:00:00  2^12 = 4096 weeks
  21 │    10      3  months     83.3333   2054-01-10T12:00:00  10^3 = 1000 months
  22 │     2     10  months     85.3333   2056-01-11T00:00:00  2^10 = 1024 months
  23 │     2     15  days       89.7139   2060-05-29T00:00:00  2^15 = 32768 days
  24 │     2     32  seconds   136.099    2106-10-18T06:28:16  2^32 = 4294967296 seconds

```

So we can do it, but R (with lubridate) has a rather nice interface.

I can cosider adding the duration funtions to [TidierDates.jl](https://github.com/TidierOrg/TidierDates.jl) - the julia port of [lubridate](https://lubridate.tidyverse.org/).

``` julia
using XLSX
writetable("my_dates.xlsx", t_dates)
fam = ["ane" => "1970-03-10",
       "thomas" => "1970-09-11",
       "andreas" => "1998-08-07",
       "joakim" => "2001-05-06",]

foreach(fam) do (n,d)
#    @show n,d
    t = time_points(d)
    f = @sprintf("%s_dates.xlsx", n)
    println(f)
    writetable(f,t, sheetname = n, overwrite= true)
end

```

## Report

``` julia
# # Notable Dates
using Dates, DataFrames, DataFramesMeta, Printf, Literate, PrettyTables

day = 60*60*24 # sec ddays(1) / dseconds(1) == (60*60*24)
week = day*7 # sec (same as R: dweeks(1) / dseconds(1) == 60*60*24*7 
year = day*365.25 # sec  (same as R: dyears(1) / dseconds(1) == 60*60*24*365.25
month = year/12 # sec == 30.4375 day. R: dyears(1) /12 == dmonths(1)

seconds(s) = s
days(s) = s * day
weeks(s) = s * week
months(s) = s * month
years(s) = s * year

function time_points( from = now())
    d1 = crossjoin(DataFrame(b = [2,10]), DataFrame(n = 1:32), DataFrame(unit = [seconds, days, weeks, months]))
    transform!(d1,
               [:b,:n,:unit] => ByRow((b,n,u) -> u(b^n)/year) => :years,
               )
    @subset!(d1, :years .> 5 .&& :years .< 150)
    sort!(d1, [:years])
    transform!(d1,
               [:b,:n,:unit] => ByRow((b,n,u) -> DateTime(from) + Dates.Second(u(b^n))) => :when,
               [:b,:n,:unit] => ByRow((b,n,u) -> @sprintf("%s^%s = %s %s", b,n,b^n,String(Symbol(u)))) => :text,
               )
end

# # Ane: 1970-03-10

pretty_table(time_points("1970-03-10")[:,[:text,:when,:years]], backend=:markdown, column_labels=["Time", "When", "Years"])


# # Thomas: 1970-09-11

pretty_table(time_points("1970-09-11")[:,[:text,:when,:years]], backend=:markdown, column_labels=["Time", "When", "Years"])


pretty_table(time_points("1970-09-11")[:,[:text,:when,:years]], backend=:markdown, column_labels=["Time", "When", "Years"])

# # Andreas: 1998-08-07

pretty_table(time_points("1998-08-07")[:,[:text,:when,:years]], backend=:markdown, column_labels=["Time", "When", "Years"])

# # Joakim: 2001-05-06

pretty_table(time_points("2001-05-06")[:,[:text,:when,:years]], backend=:markdown, column_labels=["Time", "When", "Years"])


```

Then process:

``` julia
julia> Literate.markdown("fam.jl", execute=true)

```

And convert to html:

``` bash
pandoc fam.md -o fam.html
```
