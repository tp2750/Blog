using DifferentialEquations, DataFrames, Plots

function solve_exp()
    f(u,p,t) = 1.01*u
    u0 = 1/2
    tspan = (0.0,1.0)
    prob = ODEProblem(f,u0,tspan)
    sol = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)
    sol
end

res1 = solve_exp()

DataFrame(res1)

plot(res1)

function solve_exp(a, A)
    function my_fun!(du, u, p, t)
        du[1] = p[1] * u[1]
    end
    u0 = [A]
    tspan = (0.0,1.0)
    p = [a]
    prob = ODEProblem(my_fun!, u0, tspan,p)
    solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)
end

res2 = solve_exp(1.01,.5)

DataFrame(res2)

plot(res2)

## Type pirate!
function DataFrame(sol::T, range; ufield=1) where T <: ODESolution
    res = sol(range).u
    if typeof(res) <: Vector{Vector{Float64}}
        res = map(x -> x[ufield], res)
    end
    DataFrame(t = range, u=res)
end

DataFrame(res1, 0:.1:1.) == DataFrame(res2, 0:.1:1.)

dat1 = DataFrame(res1, 0:.1:1.)

## Optimize
using DiffEqFlux, GalacticOptim

## First try sciml_train:
function fit_exp(dat)
    p = [1.02]
    function loss(a_vect)
        a = a_vect[1]
        sol = solve_exp(a,0.5)
        sol_df = DataFrame(sol, dat.t; ufield=1)
        loss = sum(abs2, (dat.u .- sol_df.u))
        return loss, sol
    end
    DiffEqFlux.sciml_train(loss, p, adtype = GalacticOptim.AutoForwardDiff())
end
fit_exp(dat1) ## this fails!

function loss_exp(a_vect; dat=res1)
    a = a_vect[1]
    sol = solve_exp(a,0.5)
    sol_df = DataFrame(sol, dat.t; ufield=1)
    loss = sum(abs2, (dat.u .- sol_df.u))
    return loss, sol
end
    
l1, s1 = loss_exp(1.02); l1
l1, s1 = loss_exp(1.01); l1
l1, s1 = loss_exp(1.0); l1

