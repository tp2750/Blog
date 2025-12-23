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

