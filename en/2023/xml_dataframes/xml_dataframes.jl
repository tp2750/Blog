#=
# XML DataFrames
2023-10-31

# Example data sets

* Ec numbers on enzymes https://www.enzyme-database.org/downloads.php
* Octet frd files
* Html tables
* Container files from momentum.
* Xml readerfile (tecan)
* mzXml (mass spec)

# Principles

The idea is to find XPaths that correspond to columns.
Similar to the output of `xmlstarlet el`

# Tools

## xmllint

prettyprint, xpath

xmllint enzyme-data.xml | less

## xmlstarlet

* xmlstarlet el enzyme-data.xml | less: all elements
* xmlstarlet fo enzyme-data.xml | less: prettyprint



=#

import EzXML

x1 = EzXML.readxml("enzyme-data.xml")

for e in eachelement(x1.root)
    @show e, e.name, attributes(e)
end

for n in eachnode(x1.root)
    @show n, n.name#, attributes(n)
end

# stream
reader = open(EzXML.StreamReader, "enzyme-data.xml")
i = 0
while (item = iterate(reader)) != nothing && i < 20
    @show reader.type, reader.name, reader.depth
    i += 1
end
close(reader)

function xml_elements(File = "enzyme-data.xml"; max=20)
    res = []
    reader = open(EzXML.StreamReader, File)
    i = 0
    while (item = iterate(reader)) != nothing && i < max && max > 0
        if reader.type == 1 ## "READER_ELEMENT"
            @show reader.type, reader.name, reader.depth, length(reader.content)
            i += 1
            push!(res, [reader.type, reader.name, reader.depth])
        end
    end
    close(reader)
    res
end

xml_elements()

# get all XPaths (xmlstarlet el enzyme-data.xml | sort -g | uniq -c )
function xml_paths(File = "enzyme-data.xml"; max=20)
    path = []
    paths = Dict()
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
            paths[xpath] = get(paths,xpath,0)+1
        end
    end
    close(reader)
    paths
end

xml_paths(;max=Inf) # 1.6 sec vs 2 sec cli

map(x->x.content, findall("mysqldump/database/table_structure/field" , x1))
map(x->x.content, findall("mysqldump/database/table_data/row/field" , x1))
countattributes.(findall("mysqldump/database/table_data/row/field" , x1))
(attributes.(findall("mysqldump/database/table_data/row/field" , x1))[1])[1].content
