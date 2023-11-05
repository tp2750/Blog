abstract type DBTBL end

struct Event <: DBTBL
    name::String
    description::String
    year::Int
    month::Int
    day::Int
    time::String
end

struct Topic <: DBTBL
    name::String
    description::String
    parent_topic::Topic
end
