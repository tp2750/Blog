# Sound
TP 2024-06-09

[Sound.jl](https://github.com/JeffFessler/Sound.jl) is a package by Jeff Fessler that wraps PortAudio in a nice interface.

It is used in his class with Philip Derbesy: [ENGN 100, Section 430: Music Signal Processing](https://web.eecs.umich.edu/~fessler/course/100/) at University of Michigan.

(None of them are at juliacon 2024)

``` julia
(2024-06-09_Sound) pkg> dev /home/tp/.julia/dev/alsa_plugins_jll
(2024-06-09_Sound) pkg> add PortAudio
(2024-06-09_Sound) pkg> add Sound
# Test from https://jefffessler.github.io/Sound.jl/dev/
using Sound
S = 8192 # sampling rate in Hz
x = 0.6 * cos.(2π*(1:S÷2)*440/S)
y = 0.7 * sin.(2π*(1:S÷2)*660/S)
sound(x, S) # monophonic
sound([x y], S) # stereo
soundsc([x y], S) # scale to maximum volume
```

This does not work out of the box: Still need to pick "pulse" as device.
This works:

``` julia
sound(8,x, S)     # Mono
sound(8,[x y], S) # Stereo
```
