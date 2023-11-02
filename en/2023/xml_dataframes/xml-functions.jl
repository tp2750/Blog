import EzXML
import XML

# ## From https://github.com/JuliaComputing/XML.jl/blob/main/benchmarks/suite.jl
# r=open(EzXML.StreamReader, f1)
# [r.name for x in r if x == EzXML.READER_ELEMENT] 
# close(r)



function xml_path_list(File = "enzyme-data.xml"; max=20)
    path = []
    paths = []
    reader = open(EzXML.StreamReader, File)
    i = 0
    while (item = iterate(reader)) != nothing && max > 0 && i < max
        if reader.type == 1 ## "READER_ELEMENT"
            i += 1
            #@show reader.type, reader.name, reader.depth
            d = reader.depth + 1
            n = reader.name
            if d > length(path)
                push!(path, n)
            else
                path[d] = n
            end
            xpath = join(path[1:d],"/")
            if length(paths) == 0
                push!(paths, [xpath,1])
            elseif last(paths)[1] == xpath
                (paths[end])[2] += 1
            else
                push!(paths, [xpath,1])
            end
        end
    end
    close(reader)
    paths
end
function xml_list1(File; Max = 20)
    path = []
    i = 0
    reader = open(EzXML.StreamReader, File)
    while (item = iterate(reader)) != nothing && Max > 0 && i < Max
        @debug EzXML.nodetype(reader), EzXML.nodedepth(reader),  EzXML.hasnodecontent(reader),  EzXML.nodename(reader)
        if reader.type == EzXML.READER_ELEMENT
            i += 1
            @debug EzXML.nodename.(EzXML.attributes(EzXML.expandtree(reader)))
            d = EzXML.nodedepth(reader) + 1
            n = EzXML.nodename(reader)
            a = EzXML.nodename.(EzXML.attributes(EzXML.expandtree(reader)))
            a_string = length(a) == 0 ? "" : " ($a)"
            p1 = "$n$a_string"
            if d > length(path)
                push!(path, p1)
            else
                path[d] = p1
            end
            xpath = join(path[1:d],"/")
            println(xpath *  " : " * join(EzXML.nodepath.(EzXML.attributes(EzXML.expandtree(reader))),", "))
            
        end
    end
end

function xml_paths1(File; Max = 20)
    doc = XML.read(File, XML.LazyNode)
    for n in doc
        @show XML.tag(n), XML.depth(n), XML.attributes(n), XML.value(n) # Depths i missing
    end
end

function get_cont(x)
    isnothing(x.content) && return missing
    x.content
end
