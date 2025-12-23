using Plots

struct Tone{T}
    frequency::T
    phase::T
    amplitude::T    
end

function render(t::Tone)
    x -> t.amplitude*sin((2pi * t.frequency)*x + t.phase)
end

function plot_tone(t::Tone)
    f1 = render(t)
    s = 0:0.00001:0.01
    plot(s,f1.(s))
end
plot_tone(Tone(400,0,1))


function tone(freq, phase, amplitude)
    x -> amplitude*sin(2pi*freq*x + phase)
end

function plot_tone(t::T) where T<:Function
    s = 0:0.00001:0.01
    plot(s,t.(s))
end

plot_tone(tone(400,pi/4,1))

struct Tone2
    fun::Function
end

function tone2(freq, phase, amplitude)
    Tone2(tone(freq, phase, amplitude))
end

function plot_tone(t::Tone2) 
    s = 0:0.00001:0.01
    plot(s,t.fun.(s))
end

plot_tone(tone2(400,pi/2,1))

import Base.+

function +(t1::Tone2, t2::Tone2)
    Tone2(x -> t1.fun(x) + t2.fun(x))
end

plot_tone(tone2(400,0,1) + tone2(400,0,1))
plot_tone(tone2(400,0,1) + tone2(410,pi/2,1))
