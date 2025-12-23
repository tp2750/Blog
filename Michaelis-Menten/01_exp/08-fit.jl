## Solve double exponential analytically

using DifferentialEquations, DataFrames, Plots, DataFramesMeta, ForwardDiff, Symbolics
import LinearAlgebra

function exp2!(du,u,p,t)
    du[1] = p[1]*u[1]
    du[2] = p[2]*u[2]
end
u0    = [2.,1.]
tspan = [0., 1.]
p     = [1.01, 1.5]
prob  = ODEProblem(exp2!, u0, tspan, p)
sol   = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)

## take solution with k= [1.01, 1.5], A=  [2.,1.] as target
target = @transform(DataFrame(sol), target = :value1 .- :value2)

## Observe the difference between the solutions 
function obs_exp2(u)
    map(x -> x[1] - x[2], u)
end

## Analytical solution:
f1(t) = u0[1] * exp(p[1]*t)
f2(t) = u0[2] * exp(p[2]*t)
target_fun(x,y) = x-y

## Plot solution
plot(plot(sol; title="Numerical"), plot(sol.t, obs_exp2(sol.u)),
     @with(target, plot(:timestamp, [f1.(:timestamp), f2.(:timestamp)], title="Analytical")),
     @with(target, plot(:timestamp, target_fun.(f1.(:timestamp) , f2.(:timestamp))))
     )

## Analytical max:
## 0 = df1 - df2
## t = log(p[2]u0[2]/(p[1]u0[1])/(p[1]-p[2])
## The following does not work, but I would like it to
if false
    @variables t p1 p2 u1 u2
    f(t,p,u) = u * exp(p*t)
    t_fun2 = f(t,p1,u1) - f(t, p2,u2) ## not    t_fun(t) = f(t,p1,u1) - f(t, p2,u2)
    Dt = Differential(t)
    Dt_fun = Dt(t_fun2) ## Differential(t)(u1*exp(p1*t) - (u2*exp(p2*t)))
    expand_derivatives(Dt_fun) ## p1*u1*exp(p1*t) - (p2*u2*exp(p2*t))
    Symbolics.solve_for(Equation(t_fun2, 0),t) ## failsS ymbolics can only solve linear equations :-(
    Symbolics.solve_for(Equation(t_fun2, 0),t; check=false) # returns nothing
    ## we really want
    Symbolics.solve_for(Equation(Dt_fun, 0),t) ## Symbolics can only solve linear equations :-(
end

## Michaelis-Menten
using DifferentialEquations, DataFrames, Plots, DataFramesMeta, ForwardDiff, Symbolics
using DiffEqFlux, Catalyst
using Latexify

## Define problem
mm = @reaction_network begin
  k1, S + E --> SE
  k2, SE --> S + E
  k3, SE --> P + E
end k1 k2 k3

latexify(mm)

p = [0.00166,0.0001,0.1] # [k1,k2,k3]
tspan = [0. , 100.]
u0 = [300., 100., 0. ,0.]  # [S,E,SE,P]
op = ODEProblem(mm, u0, tspan, p)

## Solve
sol   = solve(op, Tsit5(), reltol=1e-8, abstol=1e-8)

## plot
plot(sol)

## Define Product as target
bind_target = @transform(DataFrame(sol), target = :"S(t)" + :"SE(t)")

## Alternative:
bind_target_fun(v;w=[1,0,1,0]) = LinearAlgebra.dot(v,w) ## [S,E,SE,P]


bind_target_vect = map(bind_target_fun, sol.u)
bind_target_df = DataFrame(timestamp=sol.t, target = bind_target_vect)

plot(plot(sol), @with(bind_target, plot(:timestamp, :target)), @with(bind_target_df, plot(:timestamp, :target)))

## Looks more like octet: SE
se_target_fun(v;w=[0,0,1,0]) = LinearAlgebra.dot(v,w) ## [S,E,SE,P]
se_target_df = DataFrame(timestamp=sol.t, target = map(se_target_fun, sol.u))

plot(plot(sol),@with(bind_target_df, plot(:timestamp, :target)), @with(se_target_df, plot(:timestamp, :target)))

## Look at octet data
using XLSX

dat1 = DataFrame(XLSX.readtable("exp1_dat.xlsx", 1)...)
dat = @subset(DataFrame(timestamp=Float64.(dat1.timestamp), target = Float64.(dat1.target)), :timestamp .<= 600)

plot(plot(sol),@with(bind_target_df, plot(:timestamp, :target)), @with(se_target_df, plot(:timestamp, :target)),
     @with dat plot(:timestamp, :target)
     )

## The octet binding curve looks a lot like the SE curve
## Note: We need offsets as it starts in 0,0 but does not end in 600,0

## try fitting by hand
function my_fit(p,u0,tspan; mm=mm, dat=dat)
    op = ODEProblem(mm, u0, tspan, p)
    sol   = solve(op, Tsit5(), reltol=1e-8, abstol=1e-8)    
    plot(plot(sol), plot(sol.t, map(se_target_fun, sol.u)),
     @with dat plot(:timestamp, :target)
         )
end

function solve_mm(p; rm=mm, u0=u0, tspan=tspan)
    op = ODEProblem(rm, u0, tspan, p)
    solve(op, Tsit5(), reltol=1e-8, abstol=1e-8)
end

function make_loss(solver, rm, u0, tspan, target_df, target_fun)
    ## TODO: try deepcopy all arguments to see if @code_warntype is then more happy
    function loss_fun(pu)
        p = pu[1:3]
        u0 = pu[4:7]
        sol = solver(p; rm =rm, u0=u0, tspan=tspan)
        sol1 = sol(target_df.timestamp) ## get relevant timepoints
        probe = map(target_fun, sol1.u)
        loss = sum(abs2, probe .- target_df.target)
        return loss, sol
    end
    deepcopy(loss_fun)
end

pu0 = [[0.00166,0.0001,0.05] ; [10., 3., 0. ,0.]]
loss1 = make_loss(solve_mm, mm, pu0, [0., 600.], dat, se_target_fun)

loss1(pu0) |> first

@time res = DiffEqFlux.sciml_train(loss1, pu0, maxiters=500)
sum(abs2,ForwardDiff.gradient(first ∘ loss1 , res.u))

## Add callback to follow loss and gradient
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
function cb(pu, loss, sol) ## parametrs, return values from loss function
    glob_iter[1] += 1.
    iter = glob_iter[1]
    grad_norm = sum(abs2,ForwardDiff.gradient(first ∘ loss1 , pu))
    display("$iter. Loss: $loss, GradNorm: $grad_norm, pu: $pu")
    push!(glob_loss, loss)
    push!(glob_grad_norm, grad_norm)
    p = pu[1:3]
    u = pu[4:7]
    plt = plot(plot(1:iter, log10.(glob_loss), label="Log Loss"),
               plot(1:iter, log10.(glob_grad_norm), label="Log Gradient"),
               plot(dat.timestamp, [map(se_target_fun,sol(dat.timestamp).u), dat.target], label=["model" "data"]),
               bar(p, label="p"), bar(u, label="u"),
               plot(sol))
    display(plt)
    false
end

@time res = DiffEqFlux.sciml_train(loss1, pu0 , NelderMead(), maxiters=5000, cb=cb)
# u: 7-element Vector{Float64}:
#   0.0008258543465346468
#   0.253731544303701
#   0.015951368012511975
#   4.160091052520244
#  52.640172840498224
#   0.18985995957770063
#   5.641466049964641

glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(loss1, pu0 , NelderMead(), maxiters=100, cb=cb)

glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]

@time res = DiffEqFlux.sciml_train(loss1, pu0 , NelderMead(), maxiters=200, cb=cb)

@time res = DiffEqFlux.sciml_train(loss1, res.u , ADAM(0.001), maxiters=200, cb=cb)

@time res = DiffEqFlux.sciml_train(loss1, res.u , BFGS(initial_stepnorm=1E-12), maxiters=200, cb=cb) ## gives E >>S

@time res = DiffEqFlux.sciml_train(loss1, res.u , NelderMead(), maxiters=200, cb=cb) ## Gives S>>E
## This captures the inital part well, but not the tail

## Target function: S + SE : bind_target_fun
pu0 = [[0.001, 0.05, .033];[1., 1., 0., 0.]]
loss2 = make_loss(solve_mm, mm, pu0, [0., 600.], dat, bind_target_fun)
loss2(pu0) |> first

glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]

@time res = DiffEqFlux.sciml_train(loss2, pu0 , NelderMead(), maxiters=200, cb=cb) ## not working


## normalize dat t0 start at 0,0
dat0 = @transform(dat, target = :target .- dat.target[1])


pu0 = [[0.00166,0.0001,0.05] ; [10., .3, 0. ,0.]]
loss3 = make_loss(solve_mm, mm, pu0, [0., 600.], dat0, bind_target_fun)
loss3(pu0) |> first

glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]

@time res = DiffEqFlux.sciml_train(loss3, pu0 , NelderMead(), maxiters=200, cb=cb) ## solution flat
@time res = DiffEqFlux.sciml_train(loss3, pu0 , ADAM(0.001), maxiters=200, cb=cb) ## 

## Fit s0 as well
function make_loss4(solver, rm, u0, tspan, target_df, target_fun)
    ## TODO: try deepcopy all arguments to see if @code_warntype is then more happy
    function loss_fun(pus)
        p = pus[1:3]
        u0 = pus[4:7]
        s0 = pus[8]
        sol = solver(p; rm =rm, u0=u0, tspan=tspan)
        sol1 = sol(target_df.timestamp) ## get relevant timepoints
        probe = map(target_fun, sol1.u) .+ s0
        loss = sum(abs2, probe .- target_df.target)
        return loss, sol
    end
    deepcopy(loss_fun)
end

function cb4(pu, loss, sol) ## parametrs, return values from loss function
    glob_iter[1] += 1.
    iter = glob_iter[1]
    grad_norm = sum(abs2,ForwardDiff.gradient(first ∘ loss4 , pu))
    display("$iter. Loss: $loss, GradNorm: $grad_norm, pu: $pu")
    push!(glob_loss, loss)
    push!(glob_grad_norm, grad_norm)
    p = pu[1:3]
    u = pu[4:7]
    s0 = pu[8]
    plt = plot(plot(1:iter, log10.(glob_loss), label="Log Loss"),
               plot(1:iter, log10.(glob_grad_norm), label="Log Gradient"),
               plot(dat.timestamp, [map(bind_target_fun,sol(dat.timestamp).u) .+ s0, dat.target], label=["model" "data"]),
               bar(p, label="p"), bar([u;s0], label="u, s"),
               plot(sol))
    display(plt)
    false
end

pus0 = [[0.0066,0.0001,0.05] ; [.5, .5, 0., 0.]; 0.]
loss4 = make_loss4(solve_mm, mm, pus0, [0., 600.], dat, bind_target_fun)
loss4(pus0) |> first

glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(loss4, pus0 , NelderMead(), maxiters=200, cb=cb4) 
@time res = DiffEqFlux.sciml_train(loss4, pus0 , ADAM(1.0E-3), maxiters=200, cb=cb4) 
@time res = DiffEqFlux.sciml_train(loss4, res.u, ADAM(1.0E-3), maxiters=200, cb=cb4) 
@time res = DiffEqFlux.sciml_train(loss4, res.u, ADAM(1.0E-3), maxiters=500, cb=cb4)  ## This is looking good, but still not concave enough at high t

## Produce loss and callback functions together to keep consistency.
## Model: reaction-model, observation-function (sol.u \dot w) + y0
## Parameters, p, u, y0
## output: loss_function(parameters), callback_function(parameters, loss_val, sol)

bind_obs1(sol_u, y0; w=[1,0,1,0]) = map(x -> LinearAlgebra.dot(x, w), sol_u) .+ y0 ## obs_function


function make_funs(reaction_model, obs_function, parameters, data)
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
        probe = obs_function(sol1.u, y0) ## map(target_fun, sol1.u) .+ s0
        neg_loss = ifelse.(pus .< 0, -1.0E3 .* pus, 0) |> sum
        loss = sum(abs2, probe .- data.target)
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


pus0= [[0.0066,0.0001,0.05] ; [.5, .5, 0., 0.]; 0.]
loss5, cb5 = make_funs(mm, bind_obs1, pus0, dat) ;

loss5(pus0) |> first

glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(loss5, pus0 , NelderMead(), maxiters=100, cb=cb5) 
@time res = DiffEqFlux.sciml_train(loss5, pus0 , ADAM(1.0E-3), maxiters=100, cb=cb5) 
# u: 8-element Vector{Float64}:
#   0.009232858486403438
#  -0.013444159899084379
#   0.11552110513896466
#   0.5179195677758568
#   0.5077415052428064
#  -0.2124594854772102
#   0.0
#   0.08266903310496426

@time res = DiffEqFlux.sciml_train(loss5, pus0 , ADAM(1.0E-3), maxiters=1000, cb=cb5) 


# u: 8-element Vector{Float64}:
#   0.0674702750069941
#  -0.03720216887136334
#   0.227490012470405
#   0.5057010665529137
#   0.424620651038851
#  -0.37947339639071376
#   0.0
#   0.110499683159913

## constrain parameters to be non-negative.


lowerbounds = [0.,0.,0.,0.,0.,0.,0.,0.]
upperbounds = [10.,10.,10.,11.,10.,10.,10.,10.]
glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(loss5, pus0 , NelderMead(), maxiters=200, cb=cb5; lower_bounds = lowerbounds, upper_bounds = upperbounds) 
@time res = DiffEqFlux.sciml_train(loss5, pus0 , ADAM(1.0E-3), maxiters=200, cb=cb5; lower_bounds = lowerbounds, upper_bounds = upperbounds) 
@time res = DiffEqFlux.sciml_train(loss5, res.u , ADAM(1.0E-3), maxiters=200, cb=cb5; lower_bounds = lowerbounds, upper_bounds = upperbounds) 
@time res = DiffEqFlux.sciml_train(loss5, res.u , BFGS(initial_stepnorm=1E-8), maxiters=200, cb=cb5; lower_bounds = lowerbounds, upper_bounds = upperbounds) 

# u: 8-element Vector{Float64}:
#   0.4460432786253007
#  -0.16703719497099098
#   0.2258875932936925
#   0.46058779403189787
#   0.4151401650155544
#  -0.40792295837259274
#   0.0
#   0.19031359744609583

@time res = DiffEqFlux.sciml_train(loss5, res.u , BFGS(initial_stepnorm=1E-8), maxiters=200, cb=cb5; lower_bounds = lowerbounds, upper_bounds = upperbounds) 

# u: 8-element Vector{Float64}:
#   0.39080374032473925
#  -0.03307525973156427
#   0.06340973544280347
#   5.788448918723675
#   5.878520715025558
#  -5.856609246641341
#   0.0
#   0.19874617878919834

r1 = deepcopy(res)

@time res = DiffEqFlux.sciml_train(loss5, res.u , BFGS(initial_stepnorm=1E-8), maxiters=200, cb=cb5; lower_bounds = lowerbounds, upper_bounds = upperbounds) 

## Converged!
# "1024. Loss: 0.04687198786226679, GradNorm: 5.6281127030835435e-19, Parameters: [0.39074094707332735, -0.03306717914879697, 0.06340124970394942, 5.787040557065021, 5.877075965200074, -5.855160561614914, 0.0, 0.19874482243838568]"
#   4.567125 seconds (38.16 M allocations: 2.258 GiB, 9.54% gc time)
# u: 8-element Vector{Float64}:
#   0.39074094707332735
#  -0.03306717914879697
#   0.06340124970394942
#   5.787040557065021
#   5.877075965200074
#  -5.855160561614914
#   0.0
#   0.19874482243838568

r2 = res ## Converged!

@time res = DiffEqFlux.sciml_train(loss5, res.u , ADAM(1.0E-3), maxiters=200, cb=cb5; lower_bounds = lowerbounds, upper_bounds = upperbounds) 
@time res = DiffEqFlux.sciml_train(loss5, res.u , BFGS(initial_stepnorm=1E-8), maxiters=200, cb=cb5; lower_bounds = lowerbounds, upper_bounds = upperbounds) 

pus1 = [0.3907395822704838, 0.033066813571501534, 0.0634007827268863, 5.787131900737535, 5.877167921401063, 5.855252350941217, 0.0, 0.1987448156786397]
@time res = DiffEqFlux.sciml_train(loss5, pus1 ,  NelderMead(), maxiters=200, cb=cb5; lower_bounds = lowerbounds, upper_bounds = upperbounds) 


function make_funs(reaction_model, obs_function, parameters, data; pos = false)
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
        probe = obs_function(sol1.u, y0) ## map(target_fun, sol1.u) .+ s0
        neg_loss = 0
        if pos            
            neg_loss = ifelse.(pus .< 0, -1.0E3 .* pus, 0) |> sum
        end
        loss = sum(abs2, probe .- data.target) + neg_loss
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

pus0= [[0.0066,0.0001,0.05] ; [.5, .5, 0., 0.]; 0.]
loss6, cb6 = make_funs(mm, bind_obs1, pus0, dat; pos = true) ;

loss6(pus0) |> first

glob_loss = Float64[]
glob_grad_norm = Float64[]
glob_iter = [0]
@time res = DiffEqFlux.sciml_train(loss6, pus0 , NelderMead(), maxiters=100, cb=cb6) 
@time res = DiffEqFlux.sciml_train(loss6, res.u , NelderMead(), maxiters=200, cb=cb6)
@time res = DiffEqFlux.sciml_train(loss6, res.u , ADAM(1.0E-3), maxiters=200, cb=cb6)
@time res = DiffEqFlux.sciml_train(loss6, res.u , ADAM(1.0E-3), maxiters=2000, cb=cb6)
@time res = DiffEqFlux.sciml_train(loss6, res.u , BFGS(initial_stepnorm=1E-8), maxiters=200, cb=cb6)

# "2740. Loss: 1.1418011341928447, GradNorm: 127549.27786386514, Parameters: [0.012911134923315222, 0.002115808012739311, 0.007931150959821226, 0.40625235494754564, 0.6610292149732139, 0.007324146068179329, 0.0027962304670390765, 0.14909601747519277]"
# 330.683865 seconds (2.89 G allocations: 107.676 GiB, 6.63% gc time, 0.04% compilation time)
# u: 8-element Vector{Float64}:
#  0.012911134923315222
#  0.002115808012739311
#  0.007931150959821226
#  0.40625235494754564
#  0.6610292149732139
#  0.007324146068179329
#  0.0027962304670390765
#  0.14909601747519277

