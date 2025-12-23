## Based on input from KADT

using DifferentialEquations, Catalyst, Plots, DataFrames, DataFramesMeta, CSV, XLSX
import ForwardDiff
using DiffEqFlux

## Define problem
oct = @reaction_network begin
    k₁,  E + S --> ES
    k₋₁,    ES --> S + E
    k₂,     ES --> P + E
    k₃,  E + P --> EP
    k₋₃,    EP --> E + P
    k₄, E2 + S --> E2S
    k₋₄,    E2S --> E2 + S
end k₁ k₋₁ k₂ k₃ k₋₃ k₄ k₋₄

p = [
0.001041931,
0.051562688,
0.033310674,
0.000249023,
0.014455221,
1.04809E-06,
0.050004185
] ## k1 km1 k2 k3 km3 k4 km4   k₋₁ k₋₃ k₋₄ k₁ k₂ k₃ k₄

u0 = [6.795103189,1.94311044,0,0,0,0,0] ## E, S, ES, P EP E2 E2S
tspan = [0., 600.]

op = ODEProblem(oct, u0, tspan, p)

sol   = solve(op, Tsit5(), reltol=1e-8, abstol=1e-8)

## dat = DataFrame(CSV.File("exp1_dat.csv"))
dat1 = DataFrame(XLSX.readtable("exp1_dat.xlsx", 1)...)
dat = @subset(DataFrame(timestamp=Float64.(dat1.timestamp), target = Float64.(dat1.target)), :timestamp .<= 600)

## Solver function.
function solve_octet(k; rm=oct, u0=u0, tspan=tspan)
    op = ODEProblem(rm, u0, tspan, k)
    sol   = solve(op, Tsit5(), reltol=1e-8, abstol=1e-8)
    sol
end

target_fun(x ; w = [0.2, 2, -0.2, 2, 0, 2]) =  sum(x[2:7] .* w) ## S, ES, P, EP, E2 E2S

function make_loss(solver, rm, u0, tspan, target_df, target_fun)
    function loss_fun(p)
        sol = solver(p; rm =rm, u0=u0, tspan=tspan)
        sol1 = sol(target_df.timestamp)
        probe = target_fun.(sol1.u)
        loss = sum(abs2, probe .- target_df.target)
        return loss, sol
    end
    deepcopy(loss_fun)
end

my_loss = make_loss(solve_octet, oct, u0, tspan, dat, target_fun)

## Check loss
my_loss(p) |> first ## 0.8

@time res = DiffEqFlux.sciml_train(my_loss, p, maxiters=500)

# u: 7-element Vector{Float64}:
#  -2.617585199938983e-12
#  -2.82760475994093
#   2.8175525839168594
#   0.4052083315978829
#  -2.781607372298246
#   1.04809e-6
#   0.050004185

my_loss(res.u) |> first ##  13.8

## Plot target_fun and data
s1 = DataFrame(sol)
s1 = @transform(s1, @byrow :target_val = target_fun([1,:"S(t)",:"ES(t)",:"P(t)",:"EP(t)",:"E2(t)",:"E2S(t)"]))

@with(dat, plot(:timestamp, :target))
@with(s1, plot!(:timestamp, :target_val))

function plot_sol(res; target= dat)
    s1 = DataFrame(solve_octet(res.u))
    s1 = @transform(s1, @byrow :target_val = target_fun([1,:"S(t)",:"ES(t)",:"P(t)",:"EP(t)",:"E2(t)",:"E2S(t)"]))    
    @with(target, plot(:timestamp, :target))
    @with(s1, plot!(:timestamp, :target_val))
end

## found "solution"
s2 =  DataFrame(solve_octet(res.u))
s2 = @transform(s2, @byrow :target_val = target_fun([1,:"S(t)",:"ES(t)",:"P(t)",:"EP(t)",:"E2(t)",:"E2S(t)"]))
@with(s2, plot!(:timestamp, :target_val)) ## Not very good.


@time res4 = DiffEqFlux.sciml_train(my_loss, p,BFGS(initial_stepnorm=0.0001), maxiters=5000) ## 6 sec
# julia> res4.u
# 7-element Vector{Float64}:
#  0.00109377937188105
#  0.051116143808051635
#  0.047009995634907396
#  0.0027906973803837175
#  0.14024343090053196
#  1.04809e-6
#  0.050004185


my_loss(res4.u) |> first ##  0.48

s4 =  DataFrame(solve_octet(res4.u))
s4 = @transform(s4, @byrow :target_val = target_fun([1,:"S(t)",:"ES(t)",:"P(t)",:"EP(t)",:"E2(t)",:"E2S(t)"]))

@with(dat, plot!(:timestamp, :target))
@with(s4, plot!(:timestamp, :target_val)) ## Not very good.

sum(abs2,ForwardDiff.gradient(first ∘ my_loss , p)) #1E8
sum(abs2,ForwardDiff.gradient(first ∘ my_loss , res4.u)) #7E-17

## TODO: fit last part of experiment using same parameters but different initial conditions.

## TODO : try log-transform loss

## Log loss
function make_logloss(solver, rm, u0, tspan, target_df, target_fun)
    function loss_fun(p)
        sol = solver(p; rm =rm, u0=u0, tspan=tspan)
        sol1 = sol(target_df.timestamp)
        probe = target_fun.(sol1.u)
        loss = log10(max(sum(abs2, probe .- target_df.target), 0.4))
        return loss, sol
    end
    deepcopy(loss_fun)
end

logloss = make_logloss(solve_octet, oct, u0, tspan, dat, target_fun)

@time res5 = DiffEqFlux.sciml_train(logloss, p) ## max 0.5 # 100s

# julia> res5.u
# 7-element Vector{Float64}:
#   0.0029192104704410444
#   0.4061684460756921
#  -4.55210304556203e-5
#   0.10711375870618728
#  -0.7259652442688068
#   1.04809e-6
#   0.050004185

@time res6 = DiffEqFlux.sciml_train(logloss, p,BFGS(initial_stepnorm=0.0001), maxiters=5000) ## max 0.5 # 50 sec no warnings

@time res7 = DiffEqFlux.sciml_train(logloss, p,BFGS(initial_stepnorm=0.0001), maxiters=5000) ## max 0.4 # 57

my_loss(res7.u) |> first ## 0.48129136934495054

@time res8 = DiffEqFlux.sciml_train(my_loss, 2. *p,BFGS(initial_stepnorm=0.0001), maxiters=5000)
my_loss(res8.u) |> first ##  0.48
sum(abs2,ForwardDiff.gradient(first ∘ my_loss , res8.u)) #6E-17

@time res9 = DiffEqFlux.sciml_train(my_loss, .1 *p,BFGS(initial_stepnorm=0.0001), maxiters=5000) ## 320 sec
my_loss(res9.u) |> first ##  13
sum(abs2,ForwardDiff.gradient(first ∘ my_loss , res9.u)) # 1E16

@time resA = DiffEqFlux.sciml_train(my_loss, p,BFGS(initial_stepnorm=1E-8), maxiters=5000) ## == res4

@time resB = DiffEqFlux.sciml_train(my_loss, .5*p,BFGS(initial_stepnorm=1E-8), maxiters=5000) ## 7 sec
my_loss(resB.u) |> first ## .3 New best!
sum(abs2,ForwardDiff.gradient(first ∘ my_loss , resB.u)) # 2E-19
plot_sol(resB)

@time resC = DiffEqFlux.sciml_train(my_loss, .2*p,BFGS(initial_stepnorm=1E-8), maxiters=5000) ## 6.5 sec
my_loss(resC.u) |> first ## .48 but not res4
sum(abs2,ForwardDiff.gradient(first ∘ my_loss , resC.u)) # 2E-17
plot_sol(resC)

@time resD = DiffEqFlux.sciml_train(my_loss, .1*p,BFGS(initial_stepnorm=1E-8), maxiters=5000) ## complains 95 sec
my_loss(resD.u) |> first ## 13
sum(abs2,ForwardDiff.gradient(first ∘ my_loss , resD.u)) # 5
plot_sol(resD) # very bad

## Add callback to follow loss and gradient
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
function cb(p, loss, sol) ## parametrs, return values from loss function
    glob_iter[1] += 1.
    iter = glob_iter[1]
    grad_norm = sum(abs2,ForwardDiff.gradient(first ∘ my_loss , p))
    display("$iter. Loss: $loss, GradNorm: $grad_norm")
    push!(glob_loss, loss)
    push!(glob_grad_norm, grad_norm)
    plt = plot(plot(1:iter, log10.(glob_loss), label="Log Loss"), plot(1:iter, log10.(glob_grad_norm), label="Log Gradient"), bar(p, label="p"))
    display(plt)
    false
end

@time resB = DiffEqFlux.sciml_train(my_loss, .5*p,BFGS(initial_stepnorm=1E-8), maxiters=5000, cb=cb)


glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time resD = DiffEqFlux.sciml_train(my_loss, .6*p,BFGS(initial_stepnorm=1E-12), maxiters=5000, cb=cb) ## 0.3

glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time resE = DiffEqFlux.sciml_train(my_loss, .6*p, ADAM(1E-3), cb = cb, maxiters=1000)


glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time resE = DiffEqFlux.sciml_train(my_loss, p, NelderMead(), cb = cb, maxiters=1000) ## 0.48


glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time resE = DiffEqFlux.sciml_train(my_loss, .1*p, NelderMead(), cb = cb, maxiters=1000) ## 0.3 good!
plot_sol(resE) ## ok

p2 = [  0.0012843014637966546,
  0.10715060225306935,
  0.021334181306386896,
  7.378880391900628e-6,
 -0.00498719157780196,
 -0.02322787631921273,
 -0.07035638825016073,
]

## use p2 as new start
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time resF = DiffEqFlux.sciml_train(my_loss, p2,BFGS(initial_stepnorm=1E-12), maxiters=5000, cb=cb) 
plot_sol(resF) ## ok

p3 = [0.001, 0.1, 0.02, 0,0,0,0]
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time resG = DiffEqFlux.sciml_train(my_loss, p3,BFGS(initial_stepnorm=1E-12), maxiters=5000, cb=cb) 
plot_sol(resG) ## Similar

p = [0.1, 0.1, 0.1, 0,0,0,0]
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(my_loss, p,BFGS(initial_stepnorm=1E-12), maxiters=5000, cb=cb) 
plot_sol(res) ## like res4

p = [0.0001, 0.0001, 0.0001, 0,0,0,0]
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(my_loss, p, NelderMead(), maxiters=5000, cb=cb) 
plot_sol(res) ## like res4

p = [0.0001, 0.0001, 0.0001, 0,0,0,0]
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(my_loss, p, ADAM(1.E-2), maxiters=5000, cb=cb)  ## Fails

## p2 
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(my_loss, p2, ADAM(1.E-2), maxiters=5000, cb=cb) ## Fails


glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time resF = DiffEqFlux.sciml_train(my_loss, p2,BFGS(initial_stepnorm=1E-12), maxiters=5000, cb=cb) 
plot_sol(resF) ## ok

p3 = [
  0.0012842187120961717,
  0.10714150284177974,
  0.021334241968313964,
  7.379357491350552e-6,
 -0.004986990637723569,
 -0.02322787631921273,
 -0.07035638825016073,
]

using BlackBoxOptim
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(my_loss, p3,BBO(), maxiters=5000, cb=cb) 
plot_sol(res) ## 

p0 = [
0.001041931,
0.051562688,
0.033310674,
0.000249023,
0.014455221,
1.04809E-06,
0.050004185
] ## k1 km1 k2 k3 km3 k4 km4   k₋₁ k₋₃ k₋₄ k₁ k₂ k₃ k₄

p = circshift(p0,1)
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(my_loss, p, NelderMead(), maxiters=5000, cb=cb) 
plot_sol(res) ## 15.6 loss. bad

p = circshift(p0,2)
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(my_loss, p, NelderMead(), maxiters=5000, cb=cb) 
plot_sol(res) ## 


glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time resE = DiffEqFlux.sciml_train(my_loss, .1*p0, NelderMead(), cb = cb, maxiters=1000) ## 0.3 good! ## still some gradient.
plot_sol(resE) ## ok

glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time resE = DiffEqFlux.sciml_train(my_loss, .1*p0, NelderMead(), cb = cb, maxiters=1000, lb=[0.,0.,0.,0.,0.,0.,0.]) 
plot_sol(resE) ## ok

