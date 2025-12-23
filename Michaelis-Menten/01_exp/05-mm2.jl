## Fix k2 relative to k1 as in Michaelis Menten appriximation

using DifferentialEquations, Catalyst, Plots, DataFrames, DataFramesMeta
import ForwardDiff
using DiffEqFlux

## Define problem
mm = @reaction_network begin
  k1, S + E --> SE
  k2, SE --> S + E
  k3, SE --> P + E
end k1 k2 k3


p = [0.00166,0.0001,0.1] # [k1,k2,k3]
tspan = [0. , 100.]
u0 = [300., 100., 0. ,0.]  # [S,E,SE,P]
op = ODEProblem(mm, u0, tspan, p)

## Solve
sol   = solve(op, Tsit5(), reltol=1e-8, abstol=1e-8)

## plot
plot(sol)

## Define Product as target
target = @transform(DataFrame(sol), target = :"P(t)")

## Solver function. k2 as 6% k1
function solve_mm2(k =  [0.00166,0.1]; rm=mm, u0=u0, tspan=tspan)
    k2 = [k[1], 0.060240963855421686*k[1], k[2]]
    op = ODEProblem(rm, u0, tspan, k2)
    sol   = solve(op, Tsit5(), reltol=1e-8, abstol=1e-8)
    sol
end

get_prod(v) = v[4] ## same as x -> getindex(x,4)

## loss factory
function make_loss(solver, rm, u0, tspan, target)
    function loss_fun(p)
        sol = solver(p; rm =rm, u0=u0, tspan=tspan)
        sol1 = sol(target.timestamp)
        probe = get_prod.(sol1.u)
        loss = sum(abs2, probe .- target.target)
        return loss, sol
    end
    deepcopy(loss_fun)
end

## Make loss function
my_loss2 = make_loss(solve_mm2, mm, u0, tspan, target)

## Check loss
my_loss2([0.00166,0.1]) |> first ## 4E-26
my_loss2([0.0016,0.1]) |> first ## 147

## It is very similar to 04-mm.jl results and timing. Also warnings.
@time DiffEqFlux.sciml_train(my_loss2, [0.00166,0.1], maxiters=500)

@time res = DiffEqFlux.sciml_train(my_loss2, [0.1,0.1], maxiters=500)

@time DiffEqFlux.sciml_train(my_loss2, [0.1,0.1],BFGS(initial_stepnorm=0.001), maxiters=5000) 
@time DiffEqFlux.sciml_train(my_loss2, [0.001,0.1],BFGS(initial_stepnorm=0.001), maxiters=5000) ## No warnings

## Try SE + P +S as target:
tg2 =  @transform(DataFrame(sol), all = :"P(t)" + :"SE(t)" + :"E(t)" + :"S(t)", prods =  :"P(t)" + :"SE(t)" + :"S(t)")
