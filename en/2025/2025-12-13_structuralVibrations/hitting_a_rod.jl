# 2025-12-14
# The string in "hitting-a-string" is divergent. try hitting a rod

# Try all in the example:
# https://maucejo.github.io/StructuralVibration.jl/models/#example
using StructuralVibration


# Dimensions
L = 1.
d = 3e-2

# Section features
S = π*d^2/4
Iz = π*d^4/64
IG = 2Iz
J = IG

# Tension for string
T = 5000.

# Material
E = 2.1e11
ν = 0.33
G = E/(1 - 2*ν)
ρ = 7800.

# Computation parameters
x = [0.1, 0.9]

# Initialization of the data types
bar = Bar(L, S, E, ρ)
rod = Rod(L, IG, J, G, ρ)
strings = Strings(L, S, T, ρ)
beam = Beam(L, S, Iz, E, ρ)


# Computation of the natural frequencies
ω_bar, k_bar = modefreq(bar, 10_000.)
ω_rod, k_rod = modefreq(rod, 10_000.)
ω_strings, k_strings = modefreq(strings, 100.)
ω_beam, k_beam = modefreq(beam, 2000.)

# Computation of the corresponding mode shapes
ϕ_bar = modeshape(bar, k_bar, x, :CC)
ϕ_rod = modeshape(rod, k_rod, x, :FF)
ϕ_strings = modeshape(strings, k_strings, x, :CC)
ϕ_beam = modeshape(beam, k_beam, x, :SS)

using Plots
plot(ϕ_beam[1,:])

# Solve using FEM example https://maucejo.github.io/StructuralVibration.jl/models/index.html#example-4

# Mesh definition
mesh_bar = OneDMesh(bar, 0., 20, :CC)
mesh_rod = OneDMesh(rod, 0., 20, :FF)
mesh_strings = OneDMesh(strings, 0., 20, :CC)
mesh_beam = OneDMesh(beam, 0., 20, :SS)

# Construction of K and M
Kfe_bar, Mfe_bar = assembly(bar, mesh_bar)
Kfe_rod, Mfe_rod = assembly(rod, mesh_rod)
Kfe_strings, Mfe_strings = assembly(strings, mesh_strings)
Kfe_beam, Mfe_beam = assembly(beam, mesh_beam)

# Application of the BCs
Kbc_bar = apply_bc(Kfe_bar, mesh_bar)
Mbc_bar = apply_bc(Mfe_bar, mesh_bar)
Kbc_rod = apply_bc(Kfe_rod, mesh_rod)
Mbc_rod = apply_bc(Mfe_rod, mesh_rod)
Kbc_strings = apply_bc(Kfe_strings, mesh_strings)
Mbc_strings = apply_bc(Mfe_strings, mesh_strings)
Kbc_beam = apply_bc(Kfe_beam, mesh_beam)
Mbc_beam = apply_bc(Mfe_beam, mesh_beam)


# Calculation of the damping matrix
Cray_bar = rayleigh_damping_matrix(Kbc_bar, Mbc_bar, 1., 1.)
Cray_rod = rayleigh_damping_matrix(Kbc_rod, Mbc_rod, 1., 1.)
Cray_strings = rayleigh_damping_matrix(Kbc_strings, Mbc_strings, 1., 1.)
Cray_beam = rayleigh_damping_matrix(Kbc_beam, Mbc_beam, 1., 1.)

# Solve
#  Example: 
# # Solver
# Needs: stiffness matrix, mass matrix, dampening matrix, external forcing matric
# https://maucejo.github.io/StructuralVibration.jl/solvers/direct_time_solvers.html#api

# Modify  https://maucejo.github.io/StructuralVibration.jl/solvers/direct_time_solvers.html#free-response

t = 0.:1e-2:30.

# pull middle node
x0 = [zeros(19);[.1, .1]; zeros(19)]  # 40
v0 = zeros(40)
u0 = (x0, v0)

# No force
F = zeros(40, length(t))

# Direct time problem
prob_free = DirectTimeProblem(Kbc_beam, Mbc_beam, Cray_beam, F, u0, t)

res = solve(prob_free, RK4())

# beam also divergent:

#  res.u[20,1:10]
# 10-element Vector{Float64}:
#   0.1
#  -8.303166567309722e18
#  -7.033191614596523e48
#  -7.095917557917564e78
#  -7.649547330856349e108
#  -8.540122613456272e138
#  -9.740525405808392e168
#  -1.12666424431888e199
#  -1.315631919676945e229

## Try a state space method
# Build: https://maucejo.github.io/StructuralVibration.jl/models/#example-5
ss_beam = ss_model(Kbc_beam, Mbc_beam, Cray_beam)

# Solve:
u0 = [x0; v0]
prob_ss_free_beam = StateSpaceTimeProblem(ss_beam, F, u0, t)

res = solve(prob_ss_free_beam, RK4())

# also divergent:
# julia> res.u[20,1:10]
# 10-element Vector{Float64}:
#   0.1
#  -3.117122251740529e21
#  -3.929110693347362e55
#  -6.086774459072431e89
#  -9.835197511260231e123
#  -1.6050703104107753e158
#  -2.6258701798524314e192
#  -4.2986663518944607e226
#  -7.038431154401771e260
#  -1.1525115073422108e295
