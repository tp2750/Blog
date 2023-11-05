using SQLite
using DataFrames
include("eventdb.jl")

EVENTDB=SQLite.DB("eventdb.sl3")

topics()
events()
relations()
subtopics("programming language")
subtopic_events("programming language")
subtopic_events(1)

