# RDKit
TP 2025-07-05

# Introduction

[RDKit](https://www.rdkit.org/docs/index.html) is a python package for chemistry.

The purpose of this post is to see how much of [RDKit Cookbook](https://www.rdkit.org/docs/Cookbook.html) we can do in Julia.

## Julia packages

* [RDKitMinimalLib.jl](https://github.com/eloyfelix/RDKitMinimalLib.jl). RDKitMinimalLib wrapper for the Julia programming language 
* [MolecularGraph.jl](https://github.com/mojaie/MolecularGraph.jl). Graph-based molecule modeling toolkit for cheminformatics 

## Installing RDKit

```
$ python3 -m venv rdkit
$ . ./rdkit/bin/activate
(rdkit) python -m pip install rdkit
```

# RDKit Cookbook

The [RDKit Cookbook](https://www.rdkit.org/docs/Cookbook.html) provides example recipes of how to carry out particular tasks using the RDKit functionality from Python (cited from website). 

## [Drawing Molecules](https://www.rdkit.org/docs/Cookbook.html#drawing-molecules-jupyter)

### Python: 

``` python
from rdkit import Chem

# Test in a kinase inhibitor
mol = Chem.MolFromSmiles("C1CC2=C3C(=CC=C2)C(=CN3C1)[C@H]4[C@@H](C(=O)NC4=O)C5=CNC6=CC=CC=C65")
# Default
mol

```

This does not show in terminal.
To draw to file:

``` python
from rdkit.Chem import Draw
img = Draw.MolToFile(mol, "img/python/p1.png")
```

### Julia

The [Molecular graph basics](https://mojaie.github.io/MolecularGraph.jl_notebook/molecular_graph_basics.html) notebook covers this well:

``` julia
using MolecularGraph
mol = smilestomol("C1CC2=C3C(=CC=C2)C(=CN3C1)[C@H]4[C@@H](C(=O)NC4=O)C5=CNC6=CC=CC=C65")
```

Let's try and plot:

``` julia

```
