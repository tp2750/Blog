# Example:
# Free response
# https://maucejo.github.io/StructuralVibration.jl/solvers/direct_time_solvers.html#free-response

using StructuralVibration
using Plots
using LinearAlgebra
# System parameters
M = Diagonal([2., 1.])
K = [6. -2.; -2. 4.]
ξ = 0.05

ω, Φ = eigenmode(K, M)
C = modal_damping_matrix(M, ω, ξ, Φ)

# Time vector
t = 0.:1e-2:30.

# Initial conditions
x0 = [0.2, 0.1]
v0 = zeros(2)
u0 = (x0, v0)

# External forces
F_free = zeros(2, length(t))

# Direct time problem
prob_free = DirectTimeProblem(K, M, C, F_free, u0, t)
x_free_gα = solve(prob_free).u
x_free_cd = solve(prob_free, CentralDiff()).u
x_free_rk = solve(prob_free, RK4()).u

# Modal time problem
prob_free_modal =  FreeModalTimeProblem(K, M, ξ, u0, t)
x_free_modal = solve(prob_free_modal).u

# julia> plot(t,x_free_modal[1,:])
# julia> plot(t,x_free_modal[2,:])

# single pull:
x0 = [0.2, 0.]
v0 = zeros(2)
u0 = (x0, v0)

# External forces
F_free = zeros(2, length(t))

# Direct time problem
prob_free = DirectTimeProblem(K, M, C, F_free, u0, t)
x_free_gα = solve(prob_free).u
x_free_cd = solve(prob_free, CentralDiff()).u
x_free_rk = solve(prob_free, RK4()).u

# Modal time problem
prob_free_modal =  FreeModalTimeProblem(K, M, ξ, u0, t)
x_free_modal = solve(prob_free_modal).u

# this works
x_free_rk = solve(prob_free, RK4()).u
plot(t,x_free_rk[1,:])
