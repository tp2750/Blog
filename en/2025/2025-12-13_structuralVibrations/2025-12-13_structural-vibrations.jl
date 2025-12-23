using StructuralVibration
using WAV
# using GLMakie
using Plots

# # Test colored noise
# See https://maucejo.github.io/StructuralVibration.jl/models/excitation.html#sec-colored-noise


# Time parameters
Δt = 1e-4
t = 0.:Δt:10.
nt = length(t)
fs = 1/Δt

# Excitation parameters
F0 = 1.
tstart = 0.
duration = 10.
σ = 1.

# Initialize ColoredNoise type
exc_white = ColoredNoise(F0, tstart, duration, σ, color = :white)
exc_pink = ColoredNoise(F0, tstart, duration, σ, color = :pink)
exc_blue = ColoredNoise(F0, tstart, duration, σ, color = :blue)
exc_brown = ColoredNoise(F0, tstart, duration, σ, color = :brown)
exc_purple = ColoredNoise(F0, tstart, duration, σ, color = :purple)

# Compute the spectrum of the colored noise
## OBS: rfftfreq no fount. FFTW.jl?
## See https://juliamath.github.io/AbstractFFTs.jl/stable/api/
freq = rfftfreq(nt, fs)
S_white = rfft(excitation(exc_white, t))
S_pink = rfft(excitation(exc_pink, t))
S_blue = rfft(excitation(exc_blue, t))
S_brown = rfft(excitation(exc_brown, t))
S_purple = rfft(excitation(exc_purple, t))


# # String
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

# https://maucejo.github.io/StructuralVibration.jl/solvers/#example
# Structural parameters
m = 1.
f0 = 1.

# Time vector
t = 0.:0.01:10.

# Initial conditions
u0 = [1., -2.]

# Undamped system
sdof_nd = Sdof(m, f0, 0.)
prob_nd = SdofFreeTimeProblem(sdof_nd, u0, t)
x_nd = solve(prob_nd).u

# Underdamped system
sdof_ud = Sdof(m, f0, 0.1)
prob_ud = SdofFreeTimeProblem(sdof_ud, u0, t)
x_ud = solve(prob_ud).u

# Critically damped system
sdof_cd = Sdof(m, f0, 1.)
prob_cd = SdofFreeTimeProblem(sdof_cd, u0, t)
x_cd = solve(prob_cd).u

# Overdamped system
sdof_od = Sdof(m, f0, 1.2)
prob_od = SdofFreeTimeProblem(sdof_od, u0, t)
x_od = solve(prob_od).u;

# ## Try solve the string
# Looks like it is FEM solver:
## https://maucejo.github.io/StructuralVibration.jl/models/#example-4
# # Dimensions
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
oned_mesh = OneDMesh(beam, 0., 20, :SS)

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

# See MWE and question here:   asked: https://discourse.julialang.org/t/ann-structuralvibration-jl/127978/4?u=tp2750
