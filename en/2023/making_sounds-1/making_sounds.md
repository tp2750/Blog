# Making sounds
tp 2023-10-21

# Conclusions

# Purpose

I want to generate a tone startng with a sine and adding harmonics.
I'm on Linux / Ubuntu.

# Playing sines

## ZynAddSubFX

No sound. This is probably a Pulse / ALSA, JACS issue.
leaving it for now


## Bitwig

Grid works ok for this, but does not really scale.

See rational_music-1.bwproject.

## Supercollider

https://supercollider.github.io/

There is a lot to learn.

## Csound

https://csound.com/

Looks a bit "classic" while the web ide is cool: https://ide.csound.com/

# I want something in Julia


## PortAudiuo.jl

PortAudio.jl gives libportaudio.

Test example:

``` julia
using PortAudio, SampledSignals
S = 8192 # sampling rate (samples / second)
x = cos.(2pi*(1:2S)*440/S) # A440 tone for 2 seconds
PortAudioStream(0, 2; samplerate=S) do stream
    write(stream, x)
end
```

This works! I think I can work with this!

How bad is the latency? It's not bad as all.

Make a few simple functions in sounds.jl

JuliaMusic has something in https://juliamusic.github.io/AudioSchedules.jl/dev/

## WAV.jl

WAV.jl also has a really simple example:

``` julia
using WAV
fs = 8e3
t = 0.0:1/fs:prevfloat(1.0)
f = 1e3
y = sin.(2pi * f * t) * 0.1
wavwrite(y, "example.wav", Fs=fs)

y, fs = wavread("example.wav")
y = sin.(2pi * 2f * t) * 0.1
wavappend(y, "example.wav")

y, fs = wavread("example.wav")
wavplay(y, fs)
```

## LibSndFile.jl

This can play and plot samples:

``` julia
julia> using FileIO: load, save, loadstreaming, savestreaming
julia> import LibSndFile

x = load("myfile.wav")
plot(x[:, 1]) # plots with samples on the x axis
plot(domain(x), x[:, 1]) # plots with time on the x axis

# Plot the spectrum of the left channel

x = load("myfile.wav")
f = fft(x) # returns a FrequencySampleBuf
fmin = 0Hz
fmax = 10000Hz
fs = Float32[float(f_i) for f_i in domain(f[fmin..fmax])]
plot(fs, abs.(f[fmin..fmax]).data, xlim=(fs[1],fs[end]), ylim=(0,20000))
```

## Fx: ACME.jl

When we get to effects ACME looks really cool!

# Links

*** Programmatisk lyd
    Midi palyer via synthesis and/or soundfont
  - https://github.com/HSU-ANT/ACME.jl ref: https://dafx23.create.aau.dk/index.php/workshops/
  - https://github.com/JuliaAudio/LibSndFile.jl
  - https://github.com/JuliaAudio/PortAudio.jl 
    https://discourse.julialang.org/t/playing-recording-signals-with-portaudio-jl/85878
  - https://github.com/luvsound/pippi
  - https://supercollider.github.io/
  - https://csound.com/
  - https://sonic-pi.net/
  - https://www.musicdsp.org/en/latest/
  - http://web.mit.edu/music21/
  - https://github.com/danigb/smplr
  - https://github.com/PortAudio/portaudio # cross platform audio lib
    - https://people.csail.mit.edu/hubert/pyaudio/
      https://github.com/JuliaAudio/PortAudio.jl #Yes!
  - http://libsound.io/ # cross platform audio lib
  - WildMIDI https://github.com/Mindwerks/wildmidi
  - python wrapping ZynAddSubFx https://github.com/narenratan/jird/
    https://github.com/narenratan/jird/blob/main/src/jird/zyn.py
    Notation in ratios (just tunings) https://jird.readthedocs.io/en/latest/
  - https://github.com/dancasimiro/WAV.jl
