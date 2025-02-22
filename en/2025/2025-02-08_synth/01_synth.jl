using PortAudio

## Discover devices
PortAudio.devices()
dev = "pulse"

# Static vector
S = 8192
x = cos.(2pi*(1:2S)*440/S) # A440 tone for 2 seconds

PortAudioStream(dev, dev; samplerate=S) do stream
    write(stream, x)
end

# Streams
## https://docs.julialang.org/en/v1/manual/networking-and-streams/

stream = PortAudioStream(dev, dev; samplerate=S)
    write(stream, x)

close(stream)

## makie
using GLMakie

sin1(x; h = 1) = sin(x*2pi*h)

f = Figure()
sl1 = Slider(f[2,1], range = 200:800)
ax1 = Axis(f[1,1], title = "$(sl1.value[]) Hz")

x = 0:.00001:.01
y = @lift sin1.(x, h=$(sl1.value))
lines!(ax1, x, y)

f

## SliderGrid
using GLMakie

sin1(x; h = 1) = sin(x*2pi*h)

f = Figure()
sg = SliderGrid(f[3,1], (label="Hz", range = 200:800), tellheight=false)
ax1 = Axis(f[1,1])

x = 0:.00001:.01
y = @lift sin1.(x, h=$(sg.sliders[1].value))
lines!(ax1, x, y)

f

using PortAudio
dev = "pulse"
S = 8192
t = 1:2S
# s = cos.(2pi*(t)*440/S) # A440 tone for 2 seconds
s = @lift sin.(2pi*t*$(sg.sliders[1].value)/S)

stream = PortAudioStream(dev, dev; samplerate=S)
write(stream, s[])

# Stream it



using GLMakie

sin1(x; h = 1) = sin(x*2pi*h)

f = Figure()
sg = SliderGrid(f[2,1], (label="Hz", range = 200:800), tellheight=false)
ax1 = Axis(f[1,1])

x = 0:.00001:.01
y = @lift sin1.(x, h=$(sg.sliders[1].value))
lines!(ax1, x, y)

f

using PortAudio
dev = "pulse"
S = 8192
t = 1:2S
# s = cos.(2pi*(t)*440/S) # A440 tone for 2 seconds
s = @lift sin.(2pi*t*$(sg.sliders[1].value)/S)

stream = PortAudioStream(dev, dev; samplerate=S)

t=0
while true
    s = @lift sin(2pi*t*$(sg.sliders[1].value)/S)
    write(stream, [s[]])
end

## test stream
dev = "pulse"
S = 8192
stream = PortAudioStream(dev, dev; samplerate=S)
t=0
#while true
    s = sin.(2pi*(1:S)*440/S)
    write(stream, s)
#end

# iterator
## https://discourse.julialang.org/t/custom-iterator-simple-example/28212
## https://aleph-zero-heroes.info/posts/julia_iterators/
mutable struct Tone
    h::Float64
    S::Float64
end

import Base.iterate
function Base.iterate(t::Tone)
    return (0., 1)
end
function Base.iterate(t::Tone, state)
    if state > length(t)
        return nothing
    end
    return (sin(2pi*(state)*t.h/t.S), state + 1)
end
Base.IteratorSize(Tone) = Base.HasLength() 
import Base.length
Base.length(t::Tone) = Int(t.S) # 1s

dev = "pulse"
S = 8192
stream = PortAudioStream(dev, dev; samplerate=S)
write(stream, Tone(440,S)) ## still not working

collect(Tone(440,8192)) ## fails

for f in Tone(440,8) # works
    println(f)
end


