import EzXML
import XML

include("xml-functions.jl")

f1 = "pandas1.xml"
xml_path_list(f1)

f2 = "pandas2.xml"
xml_path_list(f2)

f3 = "pandas3.xml"
xml_path_list(f3)

julia> xml_list1(f1)
data : 
data/row : 
data/row/index : 
data/row/shape : 
data/row/degrees : 
data/row/sides : 
data/row : 
data/row/index : 
data/row/shape : 
data/row/degrees : 
data/row/sides : 
data/row : 
data/row/index : 
data/row/shape : 
data/row/degrees : 
data/row/sides : 

julia> map(x->x.content,(findall("/data/row/index", EzXML.readxml("pandas1.xml"))))
3-element Vector{String}:
 "0"
 "1"
 "2"

julia> map(x->x.content,(findall("/data/row/sides", EzXML.readxml("pandas1.xml"))))
3-element Vector{String}:
 "4.0"
 ""
 "3.0"

julia> xml_list1(f2)
data : 
data/row (["index", "shape", "degrees", "sides"]) : /data/row[1]/@index, /data/row[1]/@shape, /data/row[1]/@degrees, /data/row[1]/@sides
data/row (["index", "shape", "degrees"]) : /data/row[1]/@index, /data/row[1]/@shape, /data/row[1]/@degrees
data/row (["index", "shape", "degrees", "sides"]) : /data/row/@index, /data/row/@shape, /data/row/@degrees, /data/row/@sides

julia> map(x->x.content,(findall("/data/row/@index", EzXML.readxml("pandas2.xml"))))
3-element Vector{String}:
 "0"
 "1"
 "2"

julia> map(x->x.content,(findall("/data/row/@sides", EzXML.readxml("pandas2.xml"))))
2-element Vector{String}:
 "4.0"
 "3.0"

## OBS! This is not good!

function get_cont(x)
    isnothing(x) && return missing
    isnothing(x.content) && return missing
    x.content
end

julia> get_cont.(findall("/data/row/@sides", EzXML.readxml("pandas2.xml")))
2-element Vector{String}:
 "4.0"
 "3.0"

# still wrong length
