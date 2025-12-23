using GalacticOptim, Optim, BlackBoxOptim, Plots

## Example from Galactic optim tutorial:
using GalacticOptim, Optim
rosenbrock(x,p) =  (p[1] - x[1])^2 + p[2] * (x[2] - x[1]^2)^2
x0 = zeros(2)
p  = [1.0,100.0]

## plot
contour(-3.:.01:3., -3.:.01:3., (x,y) -> rosenbrock([x,y], p))

contour(-3.:.01:3., -3.:.01:3., (x,y) -> log(rosenbrock([x,y], p)), title="Logplot")



## NelderMead
prob = OptimizationProblem(rosenbrock,x0,p)
sol = solve(prob,NelderMead())

rosenbrock(sol.u,p) ## 3E-9

## BBO
using BlackBoxOptim
prob = OptimizationProblem(rosenbrock, x0, p, lb = [-1.0,-1.0], ub = [1.0,1.0])
sol = solve(prob,BBO_adaptive_de_rand_1_bin_radiuslimited())

## BFGS
f = OptimizationFunction(rosenbrock, GalacticOptim.AutoForwardDiff())
prob = OptimizationProblem(f, x0, p)
sol = solve(prob,BFGS())

rosenbrock(sol.u,p) ## 7E-21


## constrained
prob = OptimizationProblem(f, x0, p, lb = [-1.0,-1.0], ub = [1.0,1.0])
sol = solve(prob, Fminbox(GradientDescent()))
rosenbrock(sol.u,p) ## 1E-16


## Large example: https://galacticoptim.sciml.ai/stable/tutorials/rosenbrock/
using GalacticOptim, Optim, Test, Random

rosenbrock(x, p) =  (p[1] - x[1])^2 + p[2] * (x[2] - x[1]^2)^2
x0 = zeros(2)
_p  = [1.0, 100.0]

f = OptimizationFunction(rosenbrock, GalacticOptim.AutoForwardDiff())
l1 = rosenbrock(x0, _p)
prob = OptimizationProblem(f, x0, _p)
sol = solve(prob, SimulatedAnnealing())
@test 10*sol.minimum < l1

Random.seed!(1234)
prob = OptimizationProblem(f, x0, _p, lb=[-1.0, -1.0], ub=[0.8, 0.8])
sol = solve(prob, SAMIN())
@test 10*sol.minimum < l1

using CMAEvolutionStrategy
sol = solve(prob, CMAEvolutionStrategyOpt())
@test 10*sol.minimum < l1

rosenbrock(x, p=nothing) =  (1 - x[1])^2 + 100 * (x[2] - x[1]^2)^2

l1 = rosenbrock(x0)
prob = OptimizationProblem(rosenbrock, x0)
sol = solve(prob, NelderMead())
@test 10*sol.minimum < l1

cons= (x,p) -> [x[1]^2 + x[2]^2]
optprob = OptimizationFunction(rosenbrock, GalacticOptim.AutoForwardDiff();cons= cons)

prob = OptimizationProblem(optprob, x0)

sol = solve(prob, ADAM(0.1), maxiters = 1000)
@test 10*sol.minimum < l1

sol = solve(prob, BFGS())
@test 10*sol.minimum < l1

sol = solve(prob, Newton())
@test 10*sol.minimum < l1

sol = solve(prob, Optim.KrylovTrustRegion())
@test 10*sol.minimum < l1

prob = OptimizationProblem(optprob, x0, lcons = [-Inf], ucons = [Inf])
sol = solve(prob, IPNewton())
@test 10*sol.minimum < l1

prob = OptimizationProblem(optprob, x0, lcons = [-5.0], ucons = [10.0])
sol = solve(prob, IPNewton())
@test 10*sol.minimum < l1

prob = OptimizationProblem(optprob, x0, lcons = [-Inf], ucons = [Inf], lb = [-500.0,-500.0], ub=[50.0,50.0])
sol = solve(prob, IPNewton())
@test sol.minimum < l1

function con2_c(x,p)
    [x[1]^2 + x[2]^2, x[2]*sin(x[1])-x[1]]
end

optprob = OptimizationFunction(rosenbrock, GalacticOptim.AutoForwardDiff();cons= con2_c)
prob = OptimizationProblem(optprob, x0, lcons = [-Inf,-Inf], ucons = [Inf,Inf])
sol = solve(prob, IPNewton())
@test 10*sol.minimum < l1

cons_circ = (x,p) -> [x[1]^2 + x[2]^2]
optprob = OptimizationFunction(rosenbrock, GalacticOptim.AutoForwardDiff();cons= cons_circ)
prob = OptimizationProblem(optprob, x0, lcons = [-Inf], ucons = [0.25^2])
sol = solve(prob, IPNewton())
@test sqrt(cons(sol.minimizer,nothing)[1]) ≈ 0.25 rtol = 1e-6

optprob = OptimizationFunction(rosenbrock, GalacticOptim.AutoZygote())
prob = OptimizationProblem(optprob, x0)
sol = solve(prob, ADAM(), maxiters = 1000, progress = false)
@test 10*sol.minimum < l1

prob = OptimizationProblem(optprob, x0, lb=[-1.0, -1.0], ub=[0.8, 0.8])
sol = solve(prob, Fminbox())
@test 10*sol.minimum < l1

prob = OptimizationProblem(optprob, x0, lb=[-1.0, -1.0], ub=[0.8, 0.8])
@test_broken @test_nowarn sol = solve(prob, SAMIN())
@test 10*sol.minimum < l1

using NLopt
prob = OptimizationProblem(optprob, x0)
sol = solve(prob, Opt(:LN_BOBYQA, 2))
@test 10*sol.minimum < l1

sol = solve(prob, Opt(:LD_LBFGS, 2))
@test 10*sol.minimum < l1

prob = OptimizationProblem(optprob, x0, lb=[-1.0, -1.0], ub=[0.8, 0.8])
sol = solve(prob, Opt(:LD_LBFGS, 2))
@test 10*sol.minimum < l1

sol = solve(prob, Opt(:G_MLSL_LDS, 2), nstart=2, local_method = Opt(:LD_LBFGS, 2), maxiters=10000)
@test 10*sol.minimum < l1

# using MultistartOptimization
# sol = solve(prob, MultistartOptimization.TikTak(100), local_method = NLopt.LD_LBFGS)
# @test 10*sol.minimum < l1

# using QuadDIRECT
# sol = solve(prob, QuadDirect(); splits = ([-0.5, 0.0, 0.5],[-0.5, 0.0, 0.5]))
# @test 10*sol.minimum < l1

using Evolutionary
sol = solve(prob, CMAES(μ =40 , λ = 100),abstol=1e-15)
@test 10*sol.minimum < l1

using BlackBoxOptim
prob = GalacticOptim.OptimizationProblem(optprob, x0, lb=[-1.0, -1.0], ub=[0.8, 0.8])
sol = solve(prob, BBO())
@test 10*sol.minimum < l1

## Symbolic example https://galacticoptim.sciml.ai/stable/tutorials/symbolic/

using ModelingToolkit, GalacticOptim

@variables x y
@parameters a b
loss = (a - x)^2 + b * (y - x^2)^2
@named sys = OptimizationSystem(loss,[x,y],[a,b])

u0 = [
    x=>1.0
    y=>2.0
]
p = [
    a => 6.0
    b => 7.0
]

prob = OptimizationProblem(sys,u0,p,grad=true,hess=true)
solve(prob,Newton()) ## 6, 36

p = [1. , 100.]
prob = OptimizationProblem(sys,u0,p,grad=true,hess=true)
solve(prob,Newton()) ## 1.0, 1.0 very fast

