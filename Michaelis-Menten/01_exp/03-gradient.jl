using DifferentialEquations, DataFrames, Plots, DataFramesMeta
import ForwardDiff

## 2 exponentials
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

## Plot solution
plot(plot(sol), plot(sol.t, obs_exp2(sol.u)))


## wrapper function for solving
function solve_exp2(k = [1.01, 1.5];A = [2.,1.])
    u0    = A
    tspan = [0., 1.]
    p     = k
    prob  = ODEProblem(exp2!, u0, tspan, p)
    sol   = solve(prob, Tsit5(), reltol=1e-8, abstol=1e-8)
    sol
end

## Factory function for loss
function make_loss(solver, A, target)
    function loss_fun(p)
        ## target: timestamp, target
        sol =  solver(p; A=A)
        sol1 = sol(target.timestamp)
        probe = obs_exp2(sol1.u)
        loss = sum(abs2, probe .- target.target)
        return loss, sol
    end
    loss_fun
end

my_loss = make_loss(solve_exp2, [2.,1.], target)

l1, s1 = my_loss([1.01, 1.5]) ; l1
l1, s1 = my_loss([1.01, 1.51]) ; l1

## DiffEqFlux.sciml_train uses this:
p = [1.01, 1.50]
@time ForwardDiff.gradient(x -> first(my_loss(x)), p) ## 3.8 sec

ForwardDiff.gradient(first ∘ my_loss , [2.,2.])
first(my_loss([2.,2.]))

struct Gradients
    x::Float64
    y::Float64
    value::Float64
    gradient::Vector{Float64}
end


function get_gradient(loss; p_grid = (0.:.1:1., 0.:.1:1.))
    my_gradient = Gradients[]
    my_fun(x) = first(loss(x))
    for x = p_grid[1]
        for y = p_grid[2]
            @debug "x=$x, y=$y"
            p = [x,y]
            grad =  ForwardDiff.gradient(my_fun, p)
            push!(my_gradient, Gradients(x,y,my_fun(p),grad))
        end
    end
    my_gradient
end

@time g1 = get_gradient(my_loss)
@time g2 = get_gradient(my_loss; p_grid = (0.:.1:2., 0.:.1:2.)); ## fast after first run

function plot_gradient(dat::Vector{Gradients}; scaler_fun = x -> x)
    x = map(x -> x.x, dat)
    y = map(x -> x.y, dat)
    vals = map(x -> x.value, dat)
    grads = map(x -> x.gradient, dat)
    u = map(x -> scaler_fun(x[1]), grads)
    v = map(x -> scaler_fun(x[2]), grads)
    quiver(x,y,quiver=(u,v)) ## , line_z = vals, color=:blues)
    plot!(x,y,vals, color = :blues)
end

plot_gradient(g2; scaler_fun = x -> x/1000)

function plot_loss(loss; p_grid = (0.:.1:2., 0.:.1:2.), scale_fun = identity, fill=false)
    x = p_grid[1]
    y = p_grid[2]
    f(x,y) = scale_fun(first(loss([x,y])))
    contour(x,y,f, fill=fill)
    
end

plot_loss(my_loss)
plot_loss(my_loss;  p_grid = (0.:.1:2., 0.:.1:2.),scale_fun = log)
plot_loss(my_loss;  p_grid = (0.:.05:2., 0.:.05:2.), scale_fun = log)
@time plot_loss(my_loss;  p_grid = (0.:.01:2., 0.:.01:2.), scale_fun = log) ## 7 sec
@time plot_loss(my_loss;  p_grid = (0.:.01:2., 0.:.01:2.), scale_fun = identity) ## 7 sec
@time plot_loss(my_loss;  p_grid = (0.:.01:2., 0.:.01:2.), scale_fun = x -> max(log(x), -10))
@time plot_loss(my_loss;  p_grid = (0.:.01:2., 0.:.01:2.), scale_fun = sqrt)
@time plot_loss(my_loss;  p_grid = (0.:.01:2., 0.:.01:2.), scale_fun = x -> min(x,1))

import DiffEqFlux

p = [1.0, 1.50]
@time DiffEqFlux.sciml_train(my_loss, p) ## 0.1 sec after compilation

p = [0., 0.]
@time DiffEqFlux.sciml_train(my_loss, p) ## 0.1 sec after compilation

@time plot_loss(my_loss;  p_grid = (-2.:.01:2., -2.:.01:2.), scale_fun = log) ## 36 s
@time plot_loss(my_loss;  p_grid = (-4.:.1:2., -4.:.1:2.), scale_fun = log) ## 36 s
@time plot_loss(my_loss;  p_grid = (-4.:.1:2., -4.:.1:2.), scale_fun =  x -> min(x,1)) ## 36 s
@time plot_loss(my_loss;  p_grid = (-4.:.01:2., -4.:.01:2.), scale_fun =  x -> min(x,1)) ## 90 s
@time plot_loss(my_loss;  p_grid = (-4.:.01:2., -4.:.01:2.), scale_fun =  log) ## 90 s
@time plot_loss(my_loss;  p_grid = (-4.:.01:2., -4.:.01:2.), scale_fun = x -> max(log(x), -30)) ## 90 s

p = [1., 1.]
@time DiffEqFlux.sciml_train(my_loss, p) ## 0.1 sec after compilation

@time plot_loss(my_loss;  p_grid = (-4.:.01:2., -4.:.01:2.), scale_fun = x -> max(log(x), -30))
# savefig("log_truncated.png")

@time plot_loss(my_loss;  p_grid = (-4.:.01:2., -4.:.01:2.), scale_fun = x -> max(log(x), -10)) ## 70s

