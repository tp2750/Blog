using SQLite
using DataFrames
include("eventdb.jl")

EVENTDB=EVENTDB2=SQLite.DB("eventdb.sl3")

drop_eventdb(db=EVENTDB2)
create_eventdb(;db=EVENTDB2)

create_topic("language:english","Root of terms in English","topic"; db=EVENTDB2)
create_topic("computer","Computer related","language:english"; db=EVENTDB2)
create_topic("software","Software related","computer"; db=EVENTDB2)
create_topic("programming language","Programming languages","software"; db=EVENTDB2)
create_topic("R","R Programming languages","programming language"; db=EVENTDB2)
create_topic("python","python Programming languages","programming language"; db=EVENTDB2)
create_topic("numpy","Numpy python package","python"; db=EVENTDB2)
create_topic("pandas","Pandas python package","python"; db=EVENTDB2)
create_topic("julia","julia Programming languages","programming language"; db=EVENTDB2)

create_reference("https://cran.r-project.org/src/base/","CRAN releases"; db=EVENTDB2)
create_reference("https://en.wikipedia.org/wiki/History_of_Python","Python releases"; db=EVENTDB2)
create_reference("https://julialang.org/downloads/oldreleases/","Julia releases"; db=EVENTDB2)
create_reference("https://julialang.org/blog/2012/02/why-we-created-julia/","Julia vision"; db=EVENTDB2)

add_event("R 1.0.0","R 1.0.0 realease", 2000, 2, 29,"","R","https://cran.r-project.org/src/base/"; db=EVENTDB2)
add_event("R 2.0.0","R 2.0.0 realease", 2004, 10, 4,"","R","https://cran.r-project.org/src/base/"; db=EVENTDB2)
add_event("R 3.0.0","R 3.0.0 realease", 2013, 4, 3,"","R","https://cran.r-project.org/src/base/"; db=EVENTDB2)
add_event("R 4.0.0","R 4.0.0 realease", 2020, 4, 24,"","R","https://cran.r-project.org/src/base/"; db=EVENTDB2)
add_event("R 4.3.0","R 4.3.0 realease", 2023, 4, 21,"","R","https://cran.r-project.org/src/base/"; db=EVENTDB2)

add_event("python 1.0","python 1.0 release", 1994, 1, 26,"","python","https://en.wikipedia.org/wiki/History_of_Python"; db=EVENTDB2)
add_event("python 2.0","python 2.0 release", 2000, 10, 16,"","python","https://en.wikipedia.org/wiki/History_of_Python"; db=EVENTDB2)
add_event("python 3.0","python 3.0 release", 2008, 12, 3,"","python","https://en.wikipedia.org/wiki/History_of_Python"; db=EVENTDB2)
add_event("python 3.12","python 3.12 release", 2023, 10, 2,"","python","https://en.wikipedia.org/wiki/History_of_Python"; db=EVENTDB2)

add_event("julia 1.0.0","julia 1.0.0 release", 2018, 8, 9,"","julia","https://julialang.org/downloads/oldreleases/"; db=EVENTDB2)
add_event("julia 1.9.0","julia 1.9.0 release", 2023, 5, 8,"","julia","https://julialang.org/downloads/oldreleases/"; db=EVENTDB2)
add_event("Why We Created Julia","Julia vision", 2012, 2, 14,"","julia","https://julialang.org/blog/2012/02/why-we-created-julia/"; db=EVENTDB2)
