# Writing a chemicals database based on CAS Common Chemistry
2022-05-15

## Background

At work, I need chemicals and their propertiles (like molecular mass).
the CAS Common Chemistry database is a good resource for that.

I asked on Julia discouse if there is already an interface: 
https://discourse.julialang.org/t/cas-common-chemistry/76429

## Ideas

* Retrieve entries
* Use Unitful for units
* Cache data locally using database (SQLite, Postgres)
* Translation to be able to look up chemicals in Danish
* Location of chemicals
* Saftey-information

## Links

* CAS Common Chemistry seach: https://commonchemistry.cas.org/
* CAS API: https://commonchemistry.cas.org/api-overview
  License is [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/)
* Simple ORM https://github.com/JuliaData/Strapping.jl
* Octo.jl: SQL DSL
* SQLstore: store a dataframe https://gitlab.com/aplavin/SQLStore.jl
* SQLdf: query a dataframe using SQL https://github.com/viraltux/SQLdf.jl
* More on loading tables to dataframes:
  - https://stackoverflow.com/questions/59854265/import-julia-dataframe-into-ms-sql-server-database
  - https://selectfrom.dev/simple-sql-connection-in-julia-5894dced7476
* Python example: https://ualibweb.github.io/UALIB_ScholarlyAPI_Cookbook/content/scripts/python/python_casc.html

# Development

## First session: experiment
2022-05-15
Work in:
~/github/tp2750/CasCommonChemistry/Experiment

### Use JSON or JSON3?
* https://github.com/JuliaIO/JSON.jl
* https://github.com/quinnj/JSON3.jl

https://discourse.julialang.org/t/ann-json3-jl-yet-another-json-package-for-julia/25625/

I'll got with JSON first

### Temporary environment
Installing JSON in my default environemnt: precompile 391 packages.

Using julia --project=.: precompile: 

## Plotting the images in the repl
* https://github.com/simonschoelly/KittyTerminalImages.jl (Needs Kitty. Not working on windows)
* https://github.com/lobingera/Rsvg.jl
* https://github.com/JuliaImages/ImageInTerminal.jl
* https://github.com/eschnett/SixelTerm.jl

It is probably better to just use OpenSmiles.jl: https://github.com/caseykneale/OpenSMILES.jl

## Get molecular mass
Apparently there is not always a moculular mass
But see https://ualibweb.github.io/UALIB_ScholarlyAPI_Cookbook/content/scripts/python/python_casc.html
Eg "water" is missing molecular mass.

Should we fall back to computing it ourselves?

https://github.com/rafaqz/UnitfulMoles.jl

MolecularGraphs.jl can do it based on inChi:
https://github.com/mojaie/MolecularGraph.jl

standardweight(wm)[1]

## Units

Unitful

# Struct

mwp: 

struct CasRecord
uri::String
rn::String
name::String
image::String ## or MIME("image/svg+xml")
inchi::String ## or InChi
inchiKey::String
smile::String
canonicalSmile::String
molecularFormula::String
molecularMass::Float64
experimentalProperties::Vector{Dict{String,Any}} ## or Property
propertyCitations::Vector{Dict{String,String}}
synonyms::Vector{String}
replacedRns::Vector{String}

todo: add version. Currently 1

## InChi
https://en.wikipedia.org/wiki/International_Chemical_Identifier

Could be it's own structure

# PkgTemplates
julia> using PkgTemplates
t = Template(; 
    user="tp2750",
    dir=".",
    authors="Thomas A Poulsen",
    julia=v"1.7.2",
    plugins=[
        License(; name="GPL-2.0+"),
        Git(),
        GitHubActions(), 
        Codecov(),
        Documenter{GitHubActions}(),
        Develop(),
    ],
  )
t("CasRecords")

