using DifferentialEquations, Catalyst, Plots, DataFrames, DataFramesMeta
import ForwardDiff
using DiffEqFlux

## https://github.com/SciML/Catalyst.jl#readme
## https://catalyst.sciml.ai/stable/tutorials/basic_examples/#Example:-Michaelis-Menten-Enzyme-Kinetics

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

## Solver function
function solve_mm(k =  [0.00166,0.0001,0.1]; rm=mm, u0=u0, tspan=tspan)
    op = ODEProblem(rm, u0, tspan, k)
    sol   = solve(op, Tsit5(), reltol=1e-8, abstol=1e-8)
    sol
end

get_prod(v) = v[4]

## loss factory
function make_loss(solver, rm, u0, tspan, target)
    function loss_fun(p)
        sol = solver(p; rm =rm, u0=u0, tspan=tspan) ## solve_mm
        sol1 = sol(target.timestamp)
        probe = get_prod.(sol1.u)
        loss = sum(abs2, probe .- target.target)
        return loss, sol
    end
    loss_fun
end

## Make loss function
my_loss = make_loss(solve_mm, mm, u0, tspan, target)

## Check loss
my_loss([0.00166,0.0001,0.1]) |> first ## 4E-26
my_loss([0.00166,0.000,0.1]) |> first ## .1

## Check gradient
ForwardDiff.gradient(first ∘ my_loss , [0.00166,0.0001,0.1])

## Solve. It complains but finds the right solution
p = [0.00166,0.0001,0.1]
@time DiffEqFlux.sciml_train(my_loss, p)
@time DiffEqFlux.sciml_train(my_loss, [0.00166,0.0001,0.1], maxiters=500)

@time res = DiffEqFlux.sciml_train(my_loss, [0.1,0.1,0.1], maxiters=500)
sum(abs2,  [0.00166,0.0001,0.1] .- res.u) ## 2E-23

## Plot parameter space
ll1(x,y) = log(first(my_loss([x,y,0.1])))

contour(0.:.0001:.002,0.:.00001:.0002,ll1) ## Keep k3 Almost vertical contours

ll2(x,y) = log(first(my_loss([x,0.0001,y])))

@time contour(0.:.0001:.002,0.:.01:.2,ll2) ## Keep k2 Much more interesting. 0.8sec
@time contour(0.:.0001:.002,0.:.001:.2,ll2) ## Keep k2 Much more interesting 8 sec 
@time contour(0.:.00005:.002,0.:.0005:.2,ll2) ## Keep k2 Much more interesting 33 sec

l2(x,y) = first(my_loss([x,0.0001,y]))
 contour(0.:.0001:.002,0.:.01:.2,l2, zaxis=:log)
@time contour(0.:.00005:.002,0.:.0005:.2,l2,  zaxis=:log)

ll3(x,y) = log(first(my_loss([0.0016,x,y])))
contour(0.:.0001:.002,0.:.01:.2,ll3)
l3(x,y) = log(first(my_loss([0.0016,x,y])))
contour(0.:.0001:.002,0.:.01:.2,l3,  zaxis=:log)

## Fit with ADAM:
DiffEqFlux.sciml_train(my_loss,  [0.1,0.1,0.1], ADAM(0.1), maxiters=500) ## complains less but does not find the right one
p = [0.00166,0.0001,0.1] # [k1,k2,k3]
a2 = DiffEqFlux.sciml_train(my_loss, p, ADAM(0.1), maxiters=500) ##  complains less but does not find the right one. Not even when starting at the solution :-(

## look at solution:
@time res = DiffEqFlux.sciml_train(my_loss, [0.1,0.1,0.1], maxiters=500) ## 7 sec
lo1 = my_loss(res.u)
fieldnames(typeof(lo1[2])) ## (:u, :u_analytic, :errors, :t, :k, :prob, :alg, :interp, :dense, :tslocation, :destats, :retcode)
lo1[2].:retcode ## :Success


## ADAM solution:

a2loss = my_loss(a2.u);
a2loss[2].retcode ## :Success :-(

## TODO: This migt be stiff:
## https://diffeqflux.sciml.ai/stable/examples/stiff_ode_fit/

## ADAM works with smaller steps
a3 = DiffEqFlux.sciml_train(my_loss, p, ADAM(0.0001), maxiters=500)
my_loss(a3.u) |> first ## 1E-3

a4 = DiffEqFlux.sciml_train(my_loss, p, ADAM(0.00001), maxiters=500)
my_loss(a4.u) |> first ## 1E-7
ForwardDiff.gradient(first ∘ my_loss , a4.u)

@time a5 = DiffEqFlux.sciml_train(my_loss, p, ADAM(0.000001), maxiters=500) ## 2 sec
my_loss(a5.u) |> first ## 1E-11
ForwardDiff.gradient(first ∘ my_loss , a5.u)

@time a6 = DiffEqFlux.sciml_train(my_loss,  [0.1,0.1,0.1], ADAM(0.000001), maxiters=500) ## 3 sec and wrong
my_loss(a6.u) |> first ## 165266.0184462175

@time a7 = DiffEqFlux.sciml_train(my_loss,  [0.1,0.1,0.1], ADAM(0.00000001), maxiters=500) ## 3.7 sec but wrong
my_loss(a7.u) |> first ## 


## BFGS options

@time DiffEqFlux.sciml_train(my_loss, [0.0016,0.0001,0.1],BFGS(initial_stepnorm=0.001), maxiters=100) # 1s

## This does not complian. So it is the ADAM part of the sciml_train that complains
@time DiffEqFlux.sciml_train(my_loss, [0.001,0.001,0.01],BFGS(initial_stepnorm=0.00001), maxiters=500) ## Now it complian
@time DiffEqFlux.sciml_train(my_loss, [0.1,0.1,0.1],BFGS(initial_stepnorm=0.001), maxiters=5000) ## complains but finds the right thing

