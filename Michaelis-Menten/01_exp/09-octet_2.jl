using DifferentialEquations, DataFrames, Plots, DataFramesMeta, ForwardDiff, Symbolics
import LinearAlgebra
using DiffEqFlux, Catalyst, XLSX
using Latexify

## Define problem
mm = @reaction_network begin
  k1, S + E --> SE
  k2, SE --> S + E
  k3, SE --> P + E
end k1 k2 k3

## bind_obs1(sol_u, y0; w=[1,0,1,0]) = map(x -> LinearAlgebra.dot(x, w), sol_u) .+ y0 ## obs_function
bind_obs(sol_u, y0; w=[0.2, 0, 2., -0.2]) = map(x -> LinearAlgebra.dot(x, w), sol_u) .+ y0 ## S E SE P ## From Kasper

function make_funs(reaction_model, obs_function, parameters, data; neg_penalty = 1.0E8, y0_penalty = 1.0E1, u0_penalty = [0., 0., 1.E3, 1.E3]) ## set kw penalties to 0 for no penalty
    p_iter = 1:numparams(reaction_model)
    u_iter = 1+numparams(reaction_model) : numparams(reaction_model) + numspecies(reaction_model)
    p0 = parameters[p_iter]
    u0 = parameters[u_iter]
    tspan = extrema(data.timestamp)
    function solver(p; model = deepcopy(reaction_model), u0 = u0, tspan = tspan)
        odeproblem = ODEProblem(model, u0, tspan, p)
        solve(odeproblem, Tsit5(), reltol=1e-8, abstol=1e-8)
    end
    function loss_function(pus)
        p = pus[p_iter] ## 1:numparams(reaction_model)
        u0 = pus[u_iter] ## 1+numparams(reaction_model) : numparams(reaction_model) + numspecies(reaction_model)
        y0 = pus[end]
        sol = solver(p)
        sol1 = sol(data.timestamp) ## get relevant timepoints
        probe = obs_function(sol1.u, y0) ## map(target_fun, sol1.u) .+ y0
        neg_loss = ifelse.(pus .< 0, neg_penalty .* pus.^2, 0) |> sum ## 1E3*x^2        
        loss = sum(abs2, probe .- data.target) + neg_loss + y0_penalty * y0^2 + sum(u0_penalty .* u0.^2)
        return loss, sol
    end
    function callback_function(pu, loss, sol) ## parametrs, return values from loss function
        glob_iter[1] += 1.
        iter = glob_iter[1]
        grad_norm = sum(abs2,ForwardDiff.gradient(first ∘ loss_function , pu))
        display("$iter. Loss: $loss, GradNorm: $grad_norm, Parameters: $pu")
        push!(glob_loss, loss)
        push!(glob_grad_norm, grad_norm)
        p = pu[p_iter]
        u = pu[u_iter]
        y0 = pu[end]
        plt = plot(plot(1:iter, log10.(glob_loss), label="Log Loss"),
                   plot(1:iter, log10.(glob_grad_norm), label="Log Gradient"),
                   plot(data.timestamp, [obs_function(sol(data.timestamp).u, y0), data.target], label=["model" "data"]), 
                   bar(p, label="p"), bar([u;y0], label="u, y0"),
                   plot(sol))
        display(plt)
        false
    end
    (deepcopy(loss_function), deepcopy(callback_function))
end

dat1 = DataFrame(XLSX.readtable("exp1_dat.xlsx", 1)...)
dat = @subset(DataFrame(timestamp=Float64.(dat1.timestamp), target = Float64.(dat1.target)), :timestamp .< 600)


pus0= [[0.0066,0.0001,0.05] ; [.5, .5, 0., 0.]; 0.]
loss, cb = make_funs(mm, bind_obs, pus0, dat) ;
loss_y0, cb = make_funs(mm, bind_obs, pus0, dat; y0_penalty=0.0, u0_penalty=[0.,0.,0.,0.]) ;

loss(pus0) |> first


glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]

    @time res = DiffEqFlux.sciml_train(loss, pus0 , NelderMead(), maxiters=500, cb=cb) 
    @time res = DiffEqFlux.sciml_train(loss, res.u , BFGS(initial_stepnorm=1E-8), maxiters=500, cb=cb)
    @time res = DiffEqFlux.sciml_train(loss, res.u , ADAM(1.0E-3), maxiters=500, cb=cb) 
    @time res = DiffEqFlux.sciml_train(loss, res.u , BFGS(initial_stepnorm=1E-8), maxiters=500, cb=cb)
if false
    @time res = DiffEqFlux.sciml_train(loss, res.u , ADAM(1.0E-3), maxiters=500, cb=cb) 
    @time res = DiffEqFlux.sciml_train(loss, res.u , BFGS(initial_stepnorm=1E-8), maxiters=500, cb=cb)
    @time res = DiffEqFlux.sciml_train(loss, res.u , NelderMead(), maxiters=500, cb=cb) 
    @time res = DiffEqFlux.sciml_train(loss, res.u , BFGS(initial_stepnorm=1E-8), maxiters=500, cb=cb)
    @time res = DiffEqFlux.sciml_train(loss, res.u , ADAM(1.0E-3), maxiters=5000, cb=cb) 
    @time res = DiffEqFlux.sciml_train(loss, res.u , BFGS(initial_stepnorm=1E-8), maxiters=500, cb=cb)


    loss(res.u) |> first

end
## Converged
# u: 8-element Vector{Float64}:
#  1.110122043275467
#  0.014817044426112362
#  0.006096795139737617
#  0.2847284033463887
#  0.19976053759292905
#  3.7155100231309884e-18
#  4.518843615889103
#  1.1234746060017948

# @time res = DiffEqFlux.sciml_train(loss, res.u , ADAM(1.0E-3), maxiters=100, cb=cb) 

# ## Can BFGS doe it alone?
# @time res = DiffEqFlux.sciml_train(loss, pus0 , BFGS(initial_stepnorm=1E-8), maxiters=500, cb=cb)
## yes
# u: 8-element Vector{Float64}:
#   1.1112216848594025
#   0.014684826542798011
#   0.006077519953472056
#   0.2835513239372994
#   0.19910725018217149
#  -8.858370365450603e-5
#  36.584285935537906
#   7.536296696964731


# ## Can ADAM?
# @time res = DiffEqFlux.sciml_train(loss, pus0 , ADAM(1.0E-3), maxiters=500, cb=cb) 
# ## Goes in the right direction, but is very slow to converge when close

## relax y0

if false
    @time res = DiffEqFlux.sciml_train(loss_y0, pus0 , BFGS(initial_stepnorm=1E-8), maxiters=500, cb=cb)
    @time res = DiffEqFlux.sciml_train(loss_y0, res.u , ADAM(1.0E-3), maxiters=5000, cb=cb) 
    @time res = DiffEqFlux.sciml_train(loss_y0, res.u , BFGS(initial_stepnorm=1E-8), maxiters=500, cb=cb)
end

# u: 8-element Vector{Float64}:
#   1.1113451995644656
#   0.014670008762474098
#   0.006075366871085608
#   0.28341919812389627
#   0.1990338489674992
#  -8.868423013632939e-9
#   4.421761491200212
#   1.1037618382743897

##  neg_penalty = 1.0E8, y0_penalty = 1.0E1, u0_penalty = [0., 0., 1.E3, 1.E3]
# u: 8-element Vector{Float64}:
#   2.3123240822325126
#   0.0007987867980660914
#   0.0031802743435903865
#   0.25039543675844683
#   0.23340070126812937
#  -3.386128087956819e-9
#  -2.7691835861282643e-9
#   0.13846056478293553

## TODO: try P weight as free parameter, and perhaps SE, and perhaps S
