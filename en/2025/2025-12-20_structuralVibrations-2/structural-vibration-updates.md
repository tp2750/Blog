# Errors found in StructuralVibration

# Beam
## Error in docstring. M -> m
Documentation says (? Beam)

``` julia
Fields

    •  L: Length [m]
    •  M: Linear mass density [kg/m]
    •  D: Bending stiffness [N.m²]
```

But

``` julia
julia> beam.M
ERROR: FieldError: type Beam has no field `M`, available fields: `L`, `m`, `D`
```

