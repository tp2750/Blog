# Writing a PR for PubChemCrawler
TP 2020-06-09

# Problem: PC only has get_cid, not get_cids

This is described in issue: https://github.com/JuliaHealth/PubChemCrawler.jl/issues/25

# Solution

Add a `get_cids` function that returns a vector.

# Plan

- [X] Write Issue 
  https://github.com/JuliaHealth/PubChemCrawler.jl/issues/25
- [X] Check if there is a contribution guide
  Did not find one
- [X] Fork PubChemCrawler
  https://github.com/tp2750/PubChemCrawler.jl
- [X] Make branch
  git checkout -b "get_cids-issue25"
- [ ] run test
  FAILS!
- [x] add get_cids. get_cid = only \cirk get_cids
- [ ] write tests
- [x] write documentation. Same docstring. See https://stackoverflow.com/questions/72024086/one-docstring-for-multiple-functions-in-julia
- [ ] add option cas_number to get_cids (and get_cid)
- [ ] Create pull request closing #25

# Log

## Dev the fork

``` julia
julia> using Revise

(2025-06-09_PubChemCrawler_p...) pkg> dev ../../../../../Forks/PubChemCrawler.jl/

julia> using PubChemCrawler

```

## Run test befor edits

Tests fail!

``` julia
PubChemCrawler.jl: Error During Test at /home/tp/github/tp2750/Forks/PubChemCrawler.jl/test/runtests.jl:34
  Got exception outside of a @test
  Request headers do not match

....
      
Test Summary:     | Error  Total  Time
PubChemCrawler.jl |     1      1  2.5s
ERROR: LoadError: Some tests did not pass: 0 passed, 0 failed, 1 errored, 0 broken.
in expression starting at /home/tp/github/tp2750/Forks/PubChemCrawler.jl/test/runtests.jl:34
ERROR: Package PubChemCrawler errored during testing

```

It appears to be line 38:

``` julia
    cid_estriol = playback(() -> get_cid(;name="estriol"), "estriol_cid.bson")
```

This cals get_cid and saves the result for later playback.

Updating julia

``` julia
tp@ace7900:~/github/tp2750/Blog/en/2025/2025-06-09_PubChemCrawler_pr_get_cids$ juliaup update
```

I'm also not able to run the test in the fork folder:

``` julia
tp@ace7900:~/github/Forks/PubChemCrawler.jl$ julia --project=.
(PubChemCrawler) pkg> test PubChemCrawler
    Testing Running tests...
PubChemCrawler.jl: Error During Test at /home/tp/github/tp2750/Forks/PubChemCrawler.jl/test/runtests.jl:34
  Got exception outside of a @test
  Request headers do not match


      ...

Test Summary:     | Error  Total  Time
PubChemCrawler.jl |     1      1  2.5s
ERROR: LoadError: Some tests did not pass: 0 passed, 0 failed, 1 errored, 0 broken.
in expression starting at /home/tp/github/tp2750/Forks/PubChemCrawler.jl/test/runtests.jl:34
ERROR: Package PubChemCrawler errored during testing
```


# Pull request

## get_cids
https://github.com/JuliaHealth/PubChemCrawler.jl/pull/26

This PR adds a new function: get_cids that always returns a vector of CIDs.

This fixes #25

``` julia
julia> get_cids(name="2-nonenal")

3-element Vector{Int64}:
 5283335
   17166
 5354833
```

It preserves the behaviour of get_cid:

``` julia
julia> get_cid(name="ethanol")
702

julia> get_cid(name="2-nonenal")
ERROR: ArgumentError: Collection has multiple elements, must contain exactly 1 element
```


