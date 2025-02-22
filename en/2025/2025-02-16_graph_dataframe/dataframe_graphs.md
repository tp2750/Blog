# DataFrame Graphs
2025-02-16

# Obejctive
I want to explore an organizational graph.
The data is in the form of a DataFrame where employees are identified by ther "initials" and each employee has a direct manager (also identified by initials).
The top manager is her own manager.
The DataFrame also contains other meta data like department names.

I want to answer questions like.

* How many employees are under a given manager
  - directly in his "department"
  - recursively as all employees in the part of the organization headed by him.
* What is the "reporting line" between two given employees: the sortest path between them.
* What is the "organizational level" of a given employee
* Given an employee and a manager, is the employee in the part of the organization headed by the manager.
* Plot organizational diagrams with information like: name, initials, department names, nmer of employees per department etc.

These are all graph questions, so it is natural to try to use graph tools to answer them.


# GraphDataFrameBridge.jl
The package [GraphDataFrameBridge.jl](https://github.com/JuliaGraphs/GraphDataFrameBridge.jl) looks like it is working in this direction.

Example from https://github.com/JuliaGraphs/GraphDataFrameBridge.jl

``` julia
using DataFrames
using Graphs
using MetaGraphs
using GraphDataFrameBridge
# using CSV
# using Plots
using GLMakie, GraphMakie
using GraphMakie.NetworkLayout

df = DataFrame(Dict("start" => ["a", "b", "a", "d"],
                    "finish" => ["b", "c", "e", "e"],
                    "weights" => 1:4,
                    "extras" => 5:8))

mg = MetaGraph(df, :start, :finish) # undirected grapgh

mdg = MetaDiGraph(df, :start, :finish) # directed graph

mgw = MetaGraph(df, :start, :finish, # undirected graph with weights
                weight=:weights,
                edge_attributes=:extras)

graphplot(mdg, arrow_show=true, layout=Spectral(), nlabels = string.(vertices(mdg)))
graphplot(mg, arrow_show=true, nlabels = string.(vertices(mdg))) ## ; layout=Stress())


```

# My ideas
Generate a Graph from the DataFrame and make functions to tranlate sub-graphs to sub dataframes.
Perhaps keep the DataFrame and Graph in a single struct an operate on the struct.
This could make a nice interface.

I think GraphvizDotLang.jl will be good for vizualization

# Packages to check
* https://juliagraphs.org/Graphs.jl/stable/first_steps/plotting/
* https://github.com/JuliaGraphs/GraphDataFrameBridge.jl
* https://jhidding.github.io/GraphvizDotLang.jl/dev/#Tutorial
* https://github.com/MakieOrg/GraphMakie.jl?tab=readme-ov-file
