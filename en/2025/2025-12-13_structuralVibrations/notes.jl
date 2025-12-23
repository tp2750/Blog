# I guess this is how it works:
# Pick a model
# Pick an exitation
# compute mass matrix etc
# solve the ODE system

using StructuralVibration

# Model: string
# https://maucejo.github.io/StructuralVibration.jl/models/#example
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

# Hammer
# https://maucejo.github.io/StructuralVibration.jl/models/excitation.html#hammer-impact
# Time parameters
Δt = 1e-5
t = 0.:Δt:0.05

# Excitation parameters
F0 = 1.
tstart = 0.01
k = 9.7
θ = 6e-4

# Initialize Hammer type
hammer = Hammer(F0, tstart, k, θ)

# Compute the excitation
F_hammer = excitation(hammer, t)


# FF Finite Element Model
# https://maucejo.github.io/StructuralVibration.jl/models/index.html#fe-model

# Dimensions
L = 1.
d = 3e-2

# Section features
S = π*d^2/4
Iz = π*d^4/64

# Material
E = 2.1e11
ρ = 7800.

# Computation parameters
fmax = 2000.

# Initialization of the data types
beam = Beam(L, S, Iz, E, ρ)

# Mesh definition
oned_mesh = OneDMesh(beam, 0., 20, :CC)

# Construction of K and M
Kfe, Mfe = assembly(beam, oned_mesh)

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

K, M, C = Kfe, Mfe, Cray
# Time vector
t = 0.:1e-2:30.

# Initial conditions
x0 = [0.2, 0.1]
v0 = zeros(2)
u0 = (repeat([.2], inner=42), repeat([.1], inner=42) ) # (x0, v0)

# External forces
F_free = zeros(42, length(t))

# Direct time problem
prob_free = DirectTimeProblem(K, M, C, F_free, u0, t)
x_free_gα = solve(prob_free).u
x_free_cd = solve(prob_free, CentralDiff()).u
x_free_rk = solve(prob_free, RK4()).u

# Modal time problem
prob_free_modal =  FreeModalTimeProblem(K, M, ξ, u0, t)
x_free_modal = solve(prob_free_modal).u
