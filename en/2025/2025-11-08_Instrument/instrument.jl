## Obs physical modeling: https://www.eurecom.fr/publication/8193/download/sec-publi-8193.pdf
## Here's a new take on sound synthesis (To be added to MusicalPlaying)

"""
        An Instrument consists of 2 functors returning functions
        - osc: takes a frequency
        - end: takes duration (in sec) and amplitude

        An instruments is callable taking
        - frequency (Hz)
        - duration (sec)
        - amplitude
        as input and returning a Sound
example:

```
sin1(t) = sin(t*2pi)

function harm1(f)
    return t -> sin1(t*f)
end

function tri1(t)
    t <= 0 && return 0
    t >= 1 && return 0
    t <= .5 && return 2t
    return 2-2t
end

function tri(d, l=1)
    t -> l*tri1(t/d)
end

     
i1 = Instrument(harm1, tri)

using Plots
plot(
        plot(harm1(10), -1, 3, label="osc"),
        plot(tri(2,1), -1, 3, label = "env"),
        plot(i1(10, 2, 1).fun, -1, 3, label = "sound"),
        layout = (3,1), 
)
```        

An instrument can play chords by applying it to a vector of frequencies.

Example:
```
plot(i1([5,10],4).fun)
```

"""
struct Instrument
    osc::Function
    env::Function
    ## name::String
end

struct Sound{T}
    fun::Function
    duration::T # sec
end

(i::Instrument)(f, d=1, l=1) = Sound(t -> i.osc(f)(t)*i.env(d,l)(t), d)

## Chords
import Base.+

(+)(f1::Function, f2::Function) = x -> f1(x) + f2(x)
(+)(s1::Sound, s2::Sound) = Sound(x -> s1.fun(x) + s2.fun(x), max(s1.duration, s2.duration))

function (i::Instrument)(f::Vector{T}, d=1, l=1) where T
    sum(i.(f, d, l))
end

## Melody

function dilate(f::Function, d)
    return t -> f(t-d)
end

dilate(s::Sound, d) = Sound(dilate(s.fun, d), s.duration)

"""
    melody(s::Vector{Sound{T}}) where T
    tunrs a vector of sounds into a melody (a single Sound) by playing the sounds in succession

Example:
```
plot(melody(i1.([5,10])).fun)
```
"""
function melody(s::Vector{Sound{T}}) where T
    durations = map(x -> x.duration, s)
    starts = [0; cumsum(durations)]
    dilated = Sound{T}[]
    for i in eachindex(s)
        push!(dilated, dilate(s[i], starts[i]))
    end
    sum(dilated)
end

## Notes, Tunings and Tones
"""
        A Tuning consists of the vector of scalings in an octave.
        It is called on a pitch and returns the corresponding frequency.
        The root pitch and frequency are given as keyword arguments

Example:
```
t4 = Tuning([1, 1.25, 1.5, 1.75])
t4(1, root_pitch=1, root_frequency=1)
# 1.0

t4.(1:9, root_pitch=1, root_frequency=1)
# 9-element Vector{Float64}:
#  1.0
#  1.25
#  1.5
#  1.75
#  2.0
#  2.5
#  3.0
#  3.5
#  4.0

tet12 = Tuning([(2^(1/12))^x for x in 0:(11)])
tet12(69)
# 440.0000000000001

```
"""
struct Tuning{T}
    scalings::Vector{T}
    # name::String
end 

import Base.length
length(t::Tuning) = length(t.scalings)

function (t::Tuning)(p; root_pitch = 60, root_frequency = 261.6255653005986)
    octave_length = length(t)
    pitch_diff = p - root_pitch
    scale_idx = mod(pitch_diff, octave_length) + 1
    scaling = t.scalings[scale_idx]
    octave = pitch_diff >=0 ? div(pitch_diff, octave_length) : div(pitch_diff, octave_length, RoundFromZero)
    freq = (root_frequency * scaling)*2.0^octave
    @debug "pitch=$p, octave=$octave, scale index=$scale_idx, scaling=$scaling, frequency=$freq"
    return freq
end

const tet12 = Tuning([(2^(1/12))^x for x in 0:(11)])

abstract type AbstractNote end
struct Note{T} <: AbstractNote
    pitch::Int
    volume::Float32
    beats::T
end

note(n::Int; l=1, d=1) = Note(n,convert(Float32,l),d)

import MIDI

note(n::T; l=1., d=1) where T <: AbstractString = Note(MIDI.name_to_pitch(n), convert(Float32,l), d)

## Now take instrument on note

(i::Instrument)(n::Note; tuning = tet12, bpm = 60) = i(tuning(n.pitch), n.beats * 60/bpm, n.volume )

i1(note("A"))

# plot(i1(note("A")).fun, -1,2)
