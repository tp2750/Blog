struct Pulse
    func::Function
    ## TODO: assert that pulse is 1-periodic
end

pulse(f::Function; freq=1,phase=0) = Pulse(t -> f(freq*t + phase))
pulse(p::Pulse; freq=1,phase=0) = Pulse(t -> p.func(freq*t + phase))


struct Tone
    pulse::Pulse
    frequency::Float32
    phase::Float32
    duration::Float32
end

cospow(x;a=1, b=1, φ=0) = cospi(2*(x^a) + φ)^b
sin2pi(x) = sinpi(2x)


using Plots

s = range(0,1,length=100)

plot(
    plot(s,cospow.(s, φ=.5)),
    plot(s,cospow.(s,b=7)),
    plot(s,cospow.(s,b=7, a=3)),
    plot(s,cospow.(s,b=7, a=3, φ=.5)),
    plot(s,cospow.(s,b=7, a=3, φ=.5) .+ cospow.(s,b=7, a=3)),
)

plot(
    plot(s,sin2pi.(s .- .25)),
    plot(s,sin2pi.(4*s .- .25)),
)

@recipe function f(p::Pulse)
    @series begin
        seriestype --> :line
        label --> ""
        x = range(0,1,length=100) ## tot fix x-axes
        y = p.func.(x)
    end
end

p1 = Pulse(sin2pi)

plot(p1)

plot(Pulse(sinpi))

import Base.(+)
import Base.(*)

(+)(x::Pulse,y::Pulse) = Pulse(t -> x.func(t) + y.func(t))
(*)(x::Pulse,y::Pulse) = Pulse(t -> x.func(t) * y.func(t))
(*)(x::T,y::Pulse) where T <: Real = Pulse(t -> x * y.func(t))


p2 = pulse(sin2pi, freq=2, phase=0)    

plot(plot(p1), plot(p2), plot(p1+p2))

p3 = p1 + p2

plot(plot(p1), plot(p2), plot(p3), plot(pulse(p3, phase=.5)))
