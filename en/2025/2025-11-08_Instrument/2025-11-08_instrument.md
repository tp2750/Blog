# Instruments as structs
TP 2025-11-08

## Notes
An instrument is a struct that can be called with 3 parameters: frequency, duration, amplitude.
The returned function can be sampled to be played.

Start by paying with WAV.jl.

Constructing an instrument takes a tone generator and an envelope.

A tone generator is a 1-periodic function.
An envelope is a continuous function with support in 0:1 that is 0 in 0, 1.

Calling the instrument on a vector plays all times at the same time(chord).

This is starting now at the end and less with the notes.

Can then combine with musical playing and musical tuning.

Can this be combined with observables? Makie for musik. 

## Callable structs

``` julia
struct Instrument
    osc::Function
    env::Function
end

sin1(t) = sin(t*2pi)

using Plots
plot(sin1, 0,1)

function tri1(t)
    t <= 0 && return 0
    t >= 1 && return 0
    t <= .5 && return 2t
    return 2-2t
end

plot(tri1, -5,5)

i1 = Instrument(sin1, tri1)


(i::Instrument)(f) = t -> i.osc(t*f)*i.env(t)

plot(i1(10),0,1)

plot(i1(10),-1,2)

```

# Refinement

An Instrument takes a frequency, duration (sec) and loudness (defaults to 1) and returns a function that palys a tone with the frequency for the duration using the envelope.

Broadcasting will give a vector of such functions.
Arranging it in time is easily done by dilations.

* Instrument conatins:
  - osc: functor taking a frequency and returning an ocillator of that frequency
  - env: functor taking duration, loudness, (velocity and possibly other as kw args) and returning a function supported [0:duration] with amplitude loudness.

Example

``` julia

sin1(t) = sin(t*2pi)

function harm1(f)
    return t -> sin1(t*f)
end

using Plots
plot(harm1(2), 0, 1)

function harm2(f)
    t -> 0.75 * sin(t*2*pi*f) + 0.25 *  sin(t*2*pi*2*f)
end

plot(harm2(1), 0, 1)
plot(harm2(2), 0, 1)

function tri1(t)
    t <= 0 && return 0
    t >= 1 && return 0
    t <= .5 && return 2t
    return 2-2t
end

function tri(d, l=1)
    t -> l*tri1(t/d)
end

plot(tri(2), -1,3)

struct Instrument
    osc::Function
    env::Function
end
(i::Instrument)(f, d=1, l=1) = t -> i.osc(f)(t)*i.env(d,l)(t)

i1 = Instrument(harm1, tri)

plot(i1(10,2), -1,3)

```

## Chords: frequency vectors
Taking the instrument on a vector plays a chord.

Broadcasting will give a vector of single tones, that can be translated to a phrase.

Example:

``` julia
function (i::Instrument)(f::Vector{T}, d=1, l=1) where T
    t -> sum(i.(f,d,l)
end
```

This shows that I need to wrap the function returned by the instrument in a struct, so I can dispatch sum on it.

# Version 3

``` julia
struct Sound
    fun::Function
end

(i::Instrument)(f, d=1, l=1) = Sound(t -> i.osc(f)(t)*i.env(d,l)(t))

i1 = Instrument(harm1, tri)

plot(i1(10).fun)

```

Now the chord:

``` julia
import Base.+

(+)(f1::Function, f2::Function) = x -> f1(x) + f2(x)
(+)(s1::Sound, s2::Sound) = Sound(x -> s1.fun(x) + s2.fun(x))

function (i::Instrument)(f::Vector{T}, d=1, l=1) where T
    sum(i.(f, d, l))
end

```

## Playing phrases
Now we can play one sound, but how do we play a phrase?
The Sound needs to know it's duration if we are to concatenate them automatically.
We may also want to know it's "loudness" (RMSD?) if we want to mix them.

I think the Instrument also wants ot have a name, it can print when it plays.


# Version 4

``` julia
struct Sound{T}
    fun::Function
    duration::T # sec
end

(i::Instrument)(f, d=1, l=1) = Sound(t -> i.osc(f)(t)*i.env(d,l)(t), d)

(+)(s1::Sound, s2::Sound) = Sound(x -> s1.fun(x) + s2.fun(x), max(s1.duration, s2.duration))

function (i::Instrument)(f::Vector{T}, d=1, l=1) where T
    sum(i.(f, d, l))
end

i1 = Instrument(harm1, tri)

plot(i1([5,10],4).fun)

```

Now we can make a melody of Sounds by dilating them with the cummulated durations.

``` julia
function dilate(f::Function, d)
    return t -> f(t-d)
end

dilate(s::Sound, d) = Sound(dilate(s.fun, d), s.duration)

function melody(s::Vector{Sound{T}}) where T
    durations = map(x -> x.duration, s)
    starts = [0; cumsum(durations)]
    dilated = Sound{T}[]
    for i in eachindex(s)
        push!(dilated, dilate(s[i], starts[i]))
    end
    sum(dilated)
end

plot(melody(i1.([5,10])).fun)
```


# Aside: the "frequency" of a triad?

The "sum of sines identity" says[^1]

$$\sin(a) + \sin(b) = 2 \sin(\frac{a + b}{2}) \cos(\frac{a - b}{2})$$

This gives the "beat tones" of guitar tuning.

We can say that the sum of 2 tones has the averate frequency, modulated by the frequency different.

What does this give for a triad: 1:5/4:3/2?

This is not well defined as mean(mean(a,b),c) != mean(a, mean(b,c))



[^1]: https://en.wikipedia.org/wiki/List_of_trigonometric_identities#Sum-to-product_identities, https://personal.math.ubc.ca/~cbm/aands/page_72.htm

# Notes, Tunings and Tones
The tunng system is also a callable struct that takes a pitch and returns a frequency:

``` julia
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

t4 = Tuning([1, 1.25, 1.5, 1.75])

t4(1, root_pitch=1, root_frequency=1)


t4.(1:9, root_pitch=1, root_frequency=1)
#  1.0  1.25  1.5  1.75  2.0  2.5  3.0  3.5  4.0

tet12 = Tuning([(2^(1/12))^x for x in 0:(11)])
tet12(69)
# 440.0000000000001



```


