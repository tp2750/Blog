using StructuralVibration
using Plots

# Model: string
# https://maucejo.github.io/StructuralVibration.jl/models/#example
# Dimensions
L = 1.
d = 3e-2

# Section features
S = π*d^2/4

# Tension for string
T = 5000.

# Material
ρ = 7800.

# Computation parameters
 x = [0.1, 0.9]

strings = Strings(L, S, T, ρ)

# Computation of the natural frequencies
ω_strings, k_strings = modefreq(strings, 300.) # 19 eigenfrequencies to match FE later

# Computation of the corresponding mode shapes
ϕ_strings = modeshape(strings, k_strings, x, :CC)

# OBS: ω_strings ./ k_strings == 30.114212136
ω_strings ./ k_strings

plot(ϕ_strings[1,:])

# Hammer
# https://maucejo.github.io/StructuralVibration.jl/models/excitation.html#hammer-impact
# Drop the hammer. Use initial displacement

# FF Finite Element Model
# https://maucejo.github.io/StructuralVibration.jl/models/index.html#fe-model

# Mesh definition
oned_mesh = OneDMesh(strings, 0., 20, :CC)

# Construction of K and M
Kfe, Mfe = assembly(strings, oned_mesh)

# Application of the BCs
Kbc = apply_bc(Kfe, oned_mesh)
Mbc = apply_bc(Mfe, oned_mesh)

# Computation ofthe eigenmodes of the structure
ωfe, Φfe = eigenmode(Kbc, Mbc)

# Calculation of the damping matrix
Cray = rayleigh_damping_matrix(Kbc, Mbc, 1., 1.)
Cmodal = modal_damping_matrix(Mbc, ωfe, 0.01, Φfe)

# # Solver
# Needs: stiffness matrix, mass matrix, dampening matrix, external forcing matric
# https://maucejo.github.io/StructuralVibration.jl/solvers/direct_time_solvers.html#api

# Modify  https://maucejo.github.io/StructuralVibration.jl/solvers/direct_time_solvers.html#free-response
t = 0.:1e-2:30.

K, M, C = Kbc, Mbc, Cray

# pull middle node
x0 = [zeros(9); .1; zeros(9)]  # 19
v0 = zeros(19)
u0 = (x0, v0)

# No force
F = zeros(19, length(t))

# Direct time problem
prob_free = DirectTimeProblem(Kbc, Mbc, Cray, F, u0, t)

res = solve(prob_free, RK4())

## Errors.
# Asked:   asked: https://discourse.julialang.org/t/ann-structuralvibration-jl/127978/4?u=tp2750

# Fixed dimention errors
# But solution diverges:
# julia> res.u[10,1:10]
# 10-element Vector{Float64}:
#   0.1
#  -5.1220191892647094e8
#  -7.405743195815883e26
#  -1.1339234439845852e45
#  -1.7362163531766005e63
#  -2.6584221545676286e81
#  -4.070465261381088e99
#  -6.232526845159753e117
#  -9.542985477403952e135
#  -1.461182183156861e154

# Try smaller pull

# pull middle node
x0 = [zeros(9); 1.E-6; zeros(9)]  # 19
v0 = zeros(19)
u0 = (x0, v0)

# No force
F = zeros(19, length(t))

# Direct time problem
prob_free = DirectTimeProblem(Kbc, Mbc, Cray, F, u0, t)

res = solve(prob_free, RK4())

# julia> res.u[10,1:10]
# 10-element Vector{Float64}:
#     1.0e-6
#  -145.69236188634753
#     1.3938052957805617e18
#     2.4701130868950244e34
#     4.176221300171367e50
#     7.046077590267964e66
#     1.1886922316591889e83
#     2.005345039155227e99
#     3.3830518388526437e115
#     5.70726697682235e131

# Try force in stead
x0 = [zeros(9); 0.; zeros(9)]  # 19
v0 = zeros(19)
u0 = (x0, v0)

# No force
F = zeros(19, length(t))
# Pick
 F[10,10] = 0.00001

# Direct time problem
prob_free = DirectTimeProblem(Kbc, Mbc, Cray, F, u0, t)

res = solve(prob_free, RK4())

# res.u[10,1:20]
# 20-element Vector{Float64}:
#       0.0
#       0.0
#       0.0
#       0.0
#       0.0
#       0.0
#       0.0
#       0.0
#       0.0
#       1.6439682831369473e-8
#  -14302.471356663247
#      -9.47257983016019e16
#       1.0173230715790258e29
#       6.097003194885e43
#       6.195074952480529e57
#       6.011804518734295e71
#       5.817216341813234e85
#       5.627832221986687e99
#       5.4445396034382895e113

# Try the other damping

# Try force in stead
x0 = [zeros(9); 0.; zeros(9)]  # 19
v0 = zeros(19)
u0 = (x0, v0)

# No force
F = zeros(19, length(t))
# Pick
 F[10,10] = 0.00001

# Direct time problem
prob_free = DirectTimeProblem(Kbc, Mbc, Cmodal, F, u0, t)

res = solve(prob_free, RK4())

# Slower but still divergent
 res.u[10,1:20]

# 20-element Vector{Float64}:
#   0.0
#   0.0
#   0.0
#   0.0
#   0.0
#   0.0
#   0.0
#   0.0
#   0.0
#   5.179614452715307e-10
#  -0.09379398090909108
#  -9.087630867780963e7
#  -8.804906743690875e16
#  -8.53097841633926e25
#  -8.265572238138535e34
#  -8.008423077596212e43
#  -7.759274051692171e52
#  -7.517876269261101e61
#  -7.283988582358862e70
#  -7.057377345364182e79

## Comment: it is numerical:
## https://discourse.julialang.org/t/ann-structuralvibration-jl/127978/11?u=tp2750
## Here are realistinc parameter:
#  https://www.eurecom.fr/publication/8193/download/sec-publi-8193.pdf 
## p(t) = ρ0c0/4π ∂uR(x, tr)/∂t
## It also has string parameters for guitar string:
# Parameters for a nylon string B3 (247 Hz)
# The parameters for the nylon string chosen are [8] [9] [10]:
# • L = 0.65 m
# • µ = 0.000582 kg m−1
# • T = 60 N
# Diameter: d = 0.69 mm = 6.9 × 10−4m # p 30

# Note also from https://www.eurecom.fr/publication/8193/download/sec-publi-8193.pdf the acoustic pressure (sound) contribution from a string element is proportional to the *speed* of the element:
## p(t) = ρ0c0/4π ∂uR(x, tr)/∂t



# Model: string
# https://maucejo.github.io/StructuralVibration.jl/models/#example
# Dimensions
L = .65
d = 6.9E-4

# Section features
S = π*d^2/4

# Tension for string
T = 60.

# Material
ρ = 0.000582 /S

# Computation parameters
 x = [0., 0.65/2, .65]

strings = Strings(L, S, T, ρ)


# Computation of the natural frequencies
ω_strings, k_strings = modefreq(strings, 2pi*500.) 

ω_strings/2pi # 246.985 lowest eigne frequence

# Computation of the corresponding mode shapes
ϕ_strings = modeshape(strings, k_strings, x, :CC)


# FEM
oned_mesh = OneDMesh(strings, 0., 10, :CC)

# Construction of K and M
Kfe, Mfe = assembly(strings, oned_mesh)

# Application of the BCs
Kbc = apply_bc(Kfe, oned_mesh)
Mbc = apply_bc(Mfe, oned_mesh)

# Computation ofthe eigenmodes of the structure
ωfe, Φfe = eigenmode(Kbc, Mbc)

ωfe/2pi
# 247.239 is lowest eigenfrequency

# Calculation of the damping matrix
Cray = rayleigh_damping_matrix(Kbc, Mbc, 1., 1.)
Cmodal = modal_damping_matrix(Mbc, ωfe, 0.01, Φfe)

# # Solver
# Needs: stiffness matrix, mass matrix, dampening matrix, external forcing matric
# https://maucejo.github.io/StructuralVibration.jl/solvers/direct_time_solvers.html#api

# Modify  https://maucejo.github.io/StructuralVibration.jl/solvers/direct_time_solvers.html#free-response
t = 0.:1e-2:30.

K, M, C = Kbc, Mbc, Cray

# pull middle node
x0 = [zeros(4); .1; zeros(4)]  # 19
v0 = zeros(9)
u0 = (x0, v0)

# No force
F = zeros(9, length(t))

# Direct time problem
prob_free = DirectTimeProblem(Kbc, Mbc, Cray, F, u0, t)

res = solve(prob_free, GeneralizedAlpha())
res = solve(prob_free, RK4())
