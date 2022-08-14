using Pkg
Pkg.activate(".")
using SmoothingSplines
using RDatasets
## using Gadfly
using Plots
using RCall
using LinearAlgebra

cars = dataset("datasets","cars")
X = map(Float64,convert(Array,cars[!,:Speed]))
Y = map(Float64,convert(Array,cars[!,:Dist]))

spl = fit(SmoothingSpline, X, Y, 250.0) # λ=250.0
Ypred = predict(spl) # fitted vector
#plot(layer(x=X, y=Y, Geom.point),
#	layer(x=X, y=Ypred, Geom.line, 	Theme(default_color=colorant"red")))

predict(spl, 20.0) # 59.82139857976935
## Not the same as R, but tests how that we need to normalize X or 0..1

X0 = (X .- minimum(X))/(maximum(X) - minimum(X))
f2 = fit(SmoothingSpline, X0, Y, 0.1112206)
x1 = X0[findfirst(X .== 20)]
predict(f2, x1) ## 60.67392878307307 Now we match R: 60.67389 up to 1E-4 as in the tests

dump(f2)


## wikipedia https://en.wikipedia.org/wiki/Smoothing_spline

## A = Δᵀ W⁻¹ Δ
## {\displaystyle \Delta _{ii}=1/h_{i}}, Δ i , i + 1 = − 1 / h i − 1 / h i + 1 {\displaystyle \Delta _{i,i+1}=-1/h_{i}-1/h_{i+1}} {\displaystyle \Delta _{i,i+1}=-1/h_{i}-1/h_{i+1}}, Δ i , i + 2 = 1 / h i + 1 {\displaystyle \Delta _{i,i+2}=1/h_{i+1}} 

function AWD(X::Vector{T}) where T
    ## for now assume all X are different
    ## see https://en.wikipedia.org/wiki/Smoothing_spline#Derivation_of_the_cubic_smoothing_spline
    @assert !any(diff(X) .== 0)    
    n = length(X)
    @assert n > 2
    W = zeros(T, (n-2,n-2))
    h = diff(X)
    W[1,1] = (h[1] + h[2])/3
    for i in 2:n-2
        W[i,i] = (h[i] + h[i+1])/3
        W[i-1,i] = h[i]/6
        W[i,i-1] = h[i]/6
    end
    Δ = zeros(T, (n-2,n))
    for i in 1:n-2
        Δ[i,i] = 1/h[i]
        Δ[i,i+1] = -1/h[i] - 1/h[i+1]
        Δ[i,i+2] = 1/h[i+1]
    end
    A = transpose(Δ) * inv(W) * Δ
    (;A = A, W = W, Δ = Δ)
end

x1 = unique(X)
AWD(x1)

function sp(X, Y, λ )
    (A,W,Δ) = AWD(X)
    n = length(X)
    id = Matrix{typeof(X[1])}(I,n,n)
    Yhat = inv(id .+ λ .* A) * Y
    Yhat
end

function DoF(X, Y, λ)
    (A,W,Δ) = AWD(X)
    n = length(X)
    id = Matrix{typeof(X[1])}(I,n,n)
    tr(inv(id .+ λ .* A))
end

y1 = sin.(x1) + 0.1 * rand(length(x1))

yhat = sp(x1,y1,1)

plot(plot(x1,y1), plot(x1, yhat))

# # Compare to SmoothingSpline and R::smooth.spline

x = collect(0:.025:1);
y = sin.(x*6) .+ 0.2*rand(length(x));

scatter(x,y)

ssR = R"smooth.spline($x,$y)"
ssR_yhat = rcopy(R"predict($ssR, $x)$y")

ss1 = fit(SmoothingSpline, x, y, 0.0002077284);
ss1_yhat = predict(ss1)

plot!(x, ss1_yhat, color="green")

plot!(x, ssR_yhat, color="red")

mean(abs.(ss1_yhat .- ssR_yhat)) ## 6.4E-7

sp_yhat = sp(x,y,0.0002077284)

plot!(x, sp_yhat, color="black")

mean(abs.(sp_yhat .- ss1_yhat)) ## 8.33E-15
isapprox(sp_yhat, ss1_yhat) ## true!

DoF(x,y,0.0002077284) ## 8.566916491968442, R: 8.56739

