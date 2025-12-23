# example: https://maucejo.github.io/StructuralVibration.jl/solvers/direct_time_solvers.html#differentialequations.jl-solvers

using StructuralVibration

# 4.1 Data preparation
L = 1.       # Length m
b = 0.03
h = 0.01
S = b*h      # Cross-section area [m²]
I = b*h^3/12 # Second moment of area [m⁴]
E = 2.1e11   # Young's modulus [Pa]
ρ = 7850.    # Density [kg/m³]

# Initialization of the data types
beam = Beam(L, S, I, E, ρ)

# Mesh definition
oned_mesh = OneDMesh(beam, 0., 20, :SS)

# Construction of K and M
Kfe, Mfe = assembly(beam, oned_mesh)

# Application of the BCs
Kbc = apply_bc(Kfe, oned_mesh)
Mbc = apply_bc(Mfe, oned_mesh)
nddl = size(Kbc, 1)

# Calculation of the damping matrix
Cbc = rayleigh_damping_matrix(Kbc, Mbc, 1e-4, 5e-4)

# 4.2 Problem solution
# Time vector
t = 0.:1e-5:1.
nt = length(t)

# Initial conditions
x0 = 1e-3ones(nddl)
v0 = zeros(nddl)
u0 = (x0, v0)

# Direct time problem - Generalized-alpha method
prob = DirectTimeProblem(Kbc, Mbc, Cbc, u0, t)
ga_res = solve(prob) # 4.6 sec
u_gα = ga_res.u
du_gα = ga_res.du

# To avoid name conflicts
import OrdinaryDiffEqTsit5 as Odet
import OrdinaryDiffEqRosenbrock as Oder

# First-order ODE function
function ode_solve!(du, u, p, t)
    A = p[1].Ac

    du .= A*u
end

u0 = [x0; v0]
css = ss_model(Kbc, Mbc, Cbc)
prob_ode = Odet.ODEProblem(ode_solve!, u0, (t[1], t[end]), (css,))
sol_ode = Odet.solve(prob_ode, Odet.AutoTsit5(Oder.Rosenbrock23())) # 1.7 sec
u_ode = sol_ode(t)[1:nddl, :]

# Second-order ODE function
function sde_solve!(ddu, du, u, p, t)
    M = p[1]
    K = p[2]
    C = p[3]

    ddu .= M\(-C*du .- K*u)
end

prob_sde = Odet.SecondOrderODEProblem(sde_solve!, v0, x0, (t[1], t[end]), (Mbc, Kbc, Cbc))
sol_sde = Odet.solve(prob_sde, Odet.AutoTsit5(Oder.Rosenbrock23())) # 1.2 sec
u_sde = sol_sde(t)[nddl+1:2*nddl, :]

## Checking the solutions:

# Pick the first solution: ga_res

using Plots
plot(
    plot(t, ga_res.u[20,:], label="y Element 20"),
    plot(t, ga_res.du[20,:], label="v Element 20"),
    plot(ga_res.u[:,50000], label="0.5 sec"),
    layout=(3,1)
)

# Counting by hand gives: 23Hz
# The "shape" plot shows that each elem is in opposite phase to the next.
# This suggests, we should do a higher discretization.

# Plot shape half a period apart.
# Period = 1/ 23Hz = 0.043478 sec
# dt os 1E-5 s, so a period is 0.043478 s / 1E-5s = 4347.8 steps
# check:
plot([
    ga_res.u[:,50000] ga_res.u[:,50000 + 4348] ga_res.u[:,50000 + 2*4348] ga_res.u[:,50000 + 3*4348]
    ]  , label="0.5 sec")

# Eigenfrequencies:
modefreq(beam, 2000.)[1]/2pi

# 9-element Vector{Float64}:
#    23.45330616617638
#    93.81322466470552
#   211.07975549558745
#   375.25289865882206
#   586.3326541544095
#   844.3190219823498
#  1149.2120021426426
#  1501.0115946352882
#  1899.7177994602869

# Obs:
# julia> modefreq(beam, 2000.)[2]/pi
# 9-element Vector{Float64}:
#  1.0
#  2.0
#  3.0
#  4.0
#  5.0
#  6.0
#  7.0
#  8.0
#  9.0


# FFTW
# last 

## Things to check:
# [ ] plot modes half a period apart at time points of maximal amplitude
## [ ] find time of maximal amplitude head 5.0 sec
# [ ] Use FFW to "measure" eigenspectrum and compare to `modefreq`
# [ ] Do this with String as well
# [ ] Does it work at audible frequencies?

# Obs: eign is LinearAlgebra.eigen https://github.com/maucejo/StructuralVibration.jl/blob/40388cdf42eeb24caf15031f955f96bb34d4ef18/src/models/FEmodel.jl#L242

# 10x higher frequency:
# julia> modefreq(Beam(L, S/10, I, E, ρ/10), 2000.)[1]/2pi
# 2-element Vector{Float64}:
#  234.53306166176384
#  938.1322466470554
# julia> modefreq(Beam(L/4, S, I, E, ρ), 5000.)[1]/2pi
# 3-element Vector{Float64}:
#   375.25289865882206
#  1501.0115946352882
#  3377.276087929399

"""
   Pick a structure at the middle
   Solve using generalized alpha method
"""
function pick_ga(m; d = 1E-3, bc = :SS, elements = 20)
    oned_mesh = OneDMesh(m, 0., elements, bc)
    
    # Construction of K and M
    Kfe, Mfe = assembly(m, oned_mesh)
    
    # Application of the BCs
    Kbc = apply_bc(Kfe, oned_mesh)
    Mbc = apply_bc(Mfe, oned_mesh)
    nddl = size(Kbc, 1)
    
    # Calculation of the damping matrix
    Cbc = rayleigh_damping_matrix(Kbc, Mbc, 1e-4, 5e-4)
    
    # 4.2 Problem solution
    # Time vector
    t = 0.:1e-5:1.
        nt = length(t)
    
    # Initial conditions
    x0 = d*ones(nddl)
    # x0 = zeros(nddl) ## 1e-3ones(nddl)
    # x0[div(nddl,2)] = d # pick middle element
    v0 = zeros(nddl)
    u0 = (x0, v0)
    
    # Direct time problem - Generalized-alpha method
    prob = DirectTimeProblem(Kbc, Mbc, Cbc, u0, t)
    solve(prob) # 4.6 sec
end

s2 = pick_ga(beam; elements = 40) # higher resultion - same result
plot(
    plot(t, s2.u[20,:], label="y Element 20"),
    plot(t, s2.du[20,:], label="v Element 20"),
    plot(s2.u[:,50000], label="0.5 sec"),
    layout=(3,1)
)

s3 = pick_ga(Beam(L, S/10, I, E, ρ/10); d=1E-3)
plot(
    plot(t, s3.u[20,:], label="y Element 20"),
    plot(t, s3.du[20,:], label="v Element 20"),
    plot(s3.u[:,50000], label="0.5 sec"),
    layout=(3,1)
)

plot(
    plot(t[1:10000], s3.u[20,1:10000], label="y Element 20"),
    plot(t[1:10000], s3.du[20,1:10000], label="v Element 20"),
    plot(s3.u[:,5000], label="0.05 sec"),
    layout=(3,1)
)

# play
using WAV
wavwrite(s3.du[20,1:10000], "beam_1_10_10.wav", Fs=1E5) # too short to hear


s4 = pick_ga(Beam(L/4, S, I, E, ρ); d=1E-3)
plot(
    plot(t, s4.u[20,:], label="y Element 20"),
    plot(t, s4.du[20,:], label="v Element 20"),
    plot(s4.u[:,5000], label="0.05 sec"),
    layout=(3,1)
)

# String
T = 5000.
strings = Strings(L, S, T, ρ)

modefreq(Strings(L, S, T, ρ), 2000.)[1]/2pi

# The parameters for the nylon string chosen are [8] [9] [10]:
# • L = 0.65 m
# • µ = 0.000582 kg m−1
# • T = 60 N
# Diameter: d = 0.69 mm = 6.9 × 10−4m # p 30
L = .65
d = 6.9E-4
# Section features
S = π*d^2/4
# Tension for string
T = 60.
# Material
ρ = 0.000582 /S


modefreq(Strings(L, S, T, ρ), 2000.)[1]/2pi
8-element Vector{Float64}:
  246.98511502612902
  493.97023005225805
  740.9553450783872
  987.9404601045161
 1234.9255751306453
 1481.9106901567743
 1728.895805182903
 1975.8809202090322

s5 = pick_ga(Strings(L, S, T, ρ); d=1E-2, bc = :CC)
plot(
    plot(t[100:10000], s5.u[10,100:10000], label="y Element 10"),
    plot(t[100:10000], s5.du[19,100:10000], label="v Element 20"),
    plot(s5.u[:,10000], label="0.5 sec"),
    layout=(3,1)
)
