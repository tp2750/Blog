# Playing with PubChemCrawler.jl
TP 2025-06-07

# Purpose

- Document examples
- Improve package documentations

Here I concentrate on Compounds.

# Plan

- [ ] explore xrefs (single, multiple)
- [ ] output formats
- [ ] test examples in docs
- [ ] read contribution guide
- [ ] add fixes to docs

# Links

- [PubChemCrawler.jl](https://github.com/JuliaHealth/PubChemCrawler.jl)
- [PubChem REST documentation](https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest)
  - [Querying ("input")](https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest#section=Input)
  - [Output ("operations")](https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest#section=Operations)
    - [Xrefs](https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest#section=XRefs)
  - [Format ("output")](https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest#section=Output)

## Glossary

* PUG: [Power User Gateway](https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest)
* CID: [Compound ID](https://pmc.ncbi.nlm.nih.gov/articles/PMC4702940/)

# Mental model

PubChem has several [Sections](https://pubchem.ncbi.nlm.nih.gov/docs/data-organization): 
* Substances
* Compounds
* Proteins
* Genes
* Pathways
* Taxonomies
* Cell Lines
* Patents
* Literature

Here I focus on Compound.

Querying the pubchem API has 2 steps:

1. Find the CID ("Compound ID")
2. Query the CID for data

This is reflected in the PubChemCrawler.jl package in the functions:

1. `get_cid` to find CIDs based on query criteria
2. `get_for_cids` to get data on one or more CIDs


# PubChem REST API

The PubChem REST API is described here: https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest

The first specific example given is this (I added JSON as output): 

```
curl -s https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/2244/property/MolecularFormula,InChIKey/JSON | jq
{
  "PropertyTable": {
    "Properties": [
      {
        "CID": 2244,
        "MolecularFormula": "C9H8O4",
        "InChIKey": "BSYNRYMUTXBXSQ-UHFFFAOYSA-N"
      }
    ]
  }
}
```

The query and output can be combined in a single query:

```
curl -s https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/aspirin/property/MolecularFormula,InChIKey/JSON | jq

  "PropertyTable": {
    "Properties": [
      {
        "CID": 2244,
        "MolecularFormula": "C9H8O4",
        "InChIKey": "BSYNRYMUTXBXSQ-UHFFFAOYSA-N"
      }
    ]
  }
}

```


## PubChemCrawler.jl API

Here's the same example using [PubChemCrawler.jl](https://github.com/JuliaHealth/PubChemCrawler.jl):

The PubChemCrawler.g API splits it in 2: first find the CID and then get the data.
This is good practice, as the lookup on name may fail.
I'm not sure it the lookup on name can return multiple compound IDs.

``` julia
julia> using PubChemCrawler, JSON3

julia> asp_id = get_cid(name = "aspirin")
2244

julia> get_for_cids(2244, properties="MolecularFormula,InChIKey", output = "JSON") |> JSON3.read |> Dict |> print
Dict{Symbol, Any}(:PropertyTable => {
   "Properties": [
                   {
                                   "CID": 2244,
                      "MolecularFormula": "C9H8O4",
                              "InChIKey": "BSYNRYMUTXBXSQ-UHFFFAOYSA-N"
                   }
                 ]
})

```

### Problem: multiple CIDs

The following query returns multiple CIDs:

```
curl https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/2-nonenal/cids/JSON
{
  "IdentifierList": {
    "CID": [
      5283335,
      17166,
      5354833
    ]
  }
}
```

This fails in PubChemCrawler:

``` julia
julia> get_cid(name = "2-nonenal")
ERROR: ArgumentError: extra characters after whitespace in "5283335\n17166\n5354833"

```

The problem is that get_cid tries to parse to an Int: https://github.com/JuliaHealth/PubChemCrawler.jl/blob/e0a2100704f3a9beb189fb896fefc798e60a94d7/src/query.jl#L16



# Xrefs

The pubchem API to query xrefs is described here: ["Operations"](https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest#section=Operations)

## PUG API

https://pubchem.ncbi.nlm.nih.gov/docs/pug-rest-tutorial#section=By-Cross-Reference-XRef

Find CS numbers by CID:

``` 
curl -s https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/2244/xrefs/RN/JSON
{
  "InformationList": {
    "Information": [
      {
        "CID": 2244,
        "RN": [
          "11126-35-5",
          "156865-15-5",
          "200-064-1",
          "50-78-2",
          "921943-73-9",
          "97781-16-3",
          "98201-60-6",
          "99512-66-0"
        ]
      }
    ]
  }
}

```

Find CIDs by CAS number:

```
curl -s https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/xref/RN/50-78-2/cids/JSON
{
  "IdentifierList": {
    "CID": [
      2244,
      67252,
      3434975,
      12280114
    ]
  }
}

```

## PubChemCrawler

Get the CAS-numbers of a given CID (CAS number is xref "RN" in PubChem).

``` julia
julia> using PubChemCrawler, JSON3
julia> get_for_cids(2244, xrefs="RN", output="JSON") |> JSON3.read |> print
{
   "InformationList": {
                         "Information": [
                                          {
                                             "CID": 2244,
                                              "RN": [
                                                      "11126-35-5",
                                                      "156865-15-5",
                                                      "200-064-1",
                                                      "50-78-2",
                                                      "921943-73-9",
                                                      "97781-16-3",
                                                      "98201-60-6",
                                                      "99512-66-0"
                                                    ]
                                          }
                                        ]
                      }
}

```

I don't think PubChemCrawler can do a lookup by CAS umber

But we can look up the names returned above:

``` julia
julia> using PubChemCrawler, CSV, DataFrames
julia> get_for_cids([
             2244,
             67252,
             3434975,
             12280114
           ], properties="Title") |> Base.Fix2(CSV.read,DataFrame)
4×2 DataFrame
 Row │ CID       Title                
     │ Int64     String31             
─────┼────────────────────────────────
   1 │     2244  Aspirin
   2 │    67252  2-Ethoxybenzoic acid
   3 │  3434975  Acetylsalicylate
   4 │ 12280114  Aspirin CD3


```

# TODO

- [ ] get_cids return vector of CIDs
- [ ] look up by xref
  - in particular CAS number ("RN")
- [ ] output as DataFrame. Submodule
- [ ] JSON3 submodule
- [ ] Periodic Table

## get_cid(;xref)

# With PR #26

https://github.com/tp2750/PubChemCrawler.jl

``` julia
julia> get_cids(name="2-nonenal")

3-element Vector{Int64}:
 5283335
   17166
 5354833

julia> cids = get_cids(cas_number="50-99-7")
10-element Vector{Int64}:
      206
     5793
    24749
    64689
    79025
   107526
   439357
  6971003
  6992084
 12444646
```

