# # String example
# Based on 
# https://maucejo.github.io/StructuralVibration.jl/solvers/direct_time_solvers.html#differentialequations.jl-solvers
# Parameters for guitar string from  https://www.eurecom.fr/publication/8193/download/sec-publi-8193.pdf 

## Asked about dampening https://discourse.julialang.org/t/ann-structuralvibration-jl/127978/15?u=tp2750

using StructuralVibration


"""
   Pick a structure. Solve using generalized alpha method
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
    #    Cbc = rayleigh_damping_matrix(Kbc, Mbc, 1e-4, 5e-4)
    mf = modefreq(m, 10000.)[1]
    Cbc = rayleigh_damping_matrix(Kbc, Mbc, mf[1], mf[2], 1, 2)
    
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
    (; t, res=solve(prob)) # 4.6 sec
end



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


modefreq(Strings(L, S, T, ρ), 1000.)[1]/2pi
# 4-element Vector{Float64}:
#  246.98511502612902
#  493.97023005225805
#  740.9553450783872
#  987.9404601045161

t,s1 = pick_ga(Strings(L, S, T, ρ); d=1E-2, bc = :CC, elements = 20)

# (t = 0.0:1.0e-5:1.0, res =   StructuralVibration.DirectTimeSolution{Float64}
#     u: 19×100001 Matrix{Float64} [0.01, 0.01, 0.01, 0.01, 0.01]...
#     du: 19×100001 Matrix{Float64} [0.0, 0.0, 0.0, 0.0, 0.0]...
#     ddu: 19×100001 Matrix{Float64} [-1.5691528380771137e6, 420453.2360393165, -112660.10608015256, 30187.18828129456, -8088.647045024554]...
# )


using Plots
plot(
    plot(t, s1.u[10,:], label="y(t) Element 10"),
    plot(t[100:5000], s1.u[19,100:5000], label="y(t) e 10 @ (0.01-0.05s)"),
    plot(t[100:5000], s1.du[19,100:5000], label="v(t) e 10 @ (0.01-0.05s)"),
    plot([s1.u[:,400] s1.u[:,600]], label=["0.004s" "0.006s"]),
    layout=(4,1)
)


# t,s100 = pick_ga(Strings(L, S, T, ρ); d=1E-2, bc = :CC, elements = 100)

# using Plots
# plot(
#     plot(t, s100.u[50,:], label="y(t) Element 50"),
#     plot(t[100:5000], s100.u[50,100:5000], label="y(t) e 50 @ (0.01-0.05s)"),
#     plot([s100.u[:,400] s100.u[:,600]], label=["0.004s" "0.006s"]),
#     layout=(3,1)
# )

# play
using WAV
wavwrite(s1.du[10,1:100000]./(maximum(s1.du[10,1:100000])), "s247.wav", Fs=1E5) #
