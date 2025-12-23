using DifferentialEquations, DataFrames, Plots, DataFramesMeta

## Problem has 2 exponential functions as solution
function exp2!(du,u,p,t)
    du[1] = p[1]*u[1]
    du[2] = p[2]*u[2]
end
u0    = [2.,1.]
tspan = [0., 1.]
p     = [1.01, 1.5]
prob  = ODEProblem(exp2!, u0, tspan, p)
sol   = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)

## Observe the difference between the solutions 
function obs_exp2(u)
    map(x -> x[1] - x[2], u)
end

plot(sol)
plot(plot(sol), plot(sol.t, obs_exp2(sol.u)))

DataFrame(sol)

## wrapper function for solving
function solve_exp2(A = [2.,1.], k = [1.01, 1.5])
    u0    = A
    tspan = [0., 1.]
    p     = k
    prob  = ODEProblem(exp2!, u0, tspan, p)
    sol   = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)
    sol
end

## take solution with k= [1.01, 1.5], A=  [2.,1.] as target
target = @transform(DataFrame(sol), target = :value1 .- :value2)

## Define loss function with only k (vector) as parameter
function loss_exp2(k; A=[2.,1.], target=target)
    ## target: timestamp, target
    sol =  solve_exp2(A, k)
    sol1 = sol(target.timestamp)
    probe = obs_exp2(sol1.u)
    loss = sum(abs2, probe .- target.target)
    return loss, sol
end

l1, s1 = loss_exp2([1.01, 1.5]  , A=[2.,1.], target = target) ; l1
l1, s1 = loss_exp2([1.01, 1.51] , A=[2.,1.], target = target) ; l1
l1, s1 = loss_exp2([1.01, 1.5]  , A=[2.,2.], target = target) ; l1

## DiffEqFlux.sciml_train uses this:
p = [1.01, 1.50]
ForwardDiff.gradient(x -> first(loss_exp2(x)), p)
## [2E-9, -2E-9]

##  DiffEqFlux.sciml_train works!
DiffEqFlux.sciml_train(loss_exp2, p)

## a bit off still find the right one
p=[1.,1.]
r1 = DiffEqFlux.sciml_train(loss_exp2, p)

## this finds decaying solution
p=[0.,0.]
r1 = DiffEqFlux.sciml_train(loss_exp2, p) ## finds a decresing solution.
l1, s1 = loss_exp2(r1.u,A=[2.,1.], target= target) ; l1

r2 = solve_exp2([2.,1.], r1.u)

plot(plot(r2), plot(r2.t, obs_exp2(r2.u)), plot(target.timestamp, target.target))
## Gradient is zero
ForwardDiff.gradient(x -> first(loss_exp2(x)), r1.u)
## [3.5E-9, -6.8E-10]

p=[.01,.01]
r1 = DiffEqFlux.sciml_train(loss_exp2, p) ## still the decreasing solution
##  [-0.5, -1.9]

p = [20,20]
DiffEqFlux.sciml_train(loss_exp2, p) ## fails

p = [2,2]
DiffEqFlux.sciml_train(loss_exp2, p) ## fails

