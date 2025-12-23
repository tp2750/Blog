#  Exploring musical tunings with Julia
TP, 2024-05-18

## What I want to do

Given a score as a set of note steps.
Map the note steps to frequencies given a tuning system.
Play the result.

Stretch goal: dynamically map to frequencies, so all intervals are simple (as in just intonation).

Illustrations:

- frequencies on circle
- "natural score" where y axes is log2-pich, ticks are in cents.
- "oscilloscope" graph of the tone. Makie interface ot play with stødtoner?



# Definitions

## Sound

A sound is something that can be head.
Everything we can hear is a sound.

## Tone

A tone is the simplest sound that can be produced by an intrument.
Examples: A single string on a guitar, a pipe on an organ, a finger positions on a flute.

A tone is characterized by:

* Pitch: frequency
* Duration
* Loudness: amplitude
* Timbre

### Instrument

An instrument is characterized by the tones it can play.
Monophonic instruments play a sinble tone at a time (eg a flute).
Polyphonic instruments can play multiple tones together (eg a guitar (6), piano, organ).

## Note

A note is an abstract representation of a tone.
It encodes the pitch, duration (and possibly relative loudness).

The same note played on different instruments will have a different sound. 
Mainly due to the differnce in timbre.

Note pitches are often denoted by capital letters:

C, D, E, F, G, A, B

## Octave

An octave is a frequency ratio of 2.

## Interval

An interval is a difference in pitch between two sounds.
https://en.wikipedia.org/wiki/Interval_(music)


## Interval ratio

Ratio of frequency of pitches of different tones.

### Note step (/ scale step?)

Less standard.

* Note step is number of notes up from a base note.
* Note interval between two note steps s1 and s2 is s2 - s1.
* A note interval gives a pitch ratio.

## Tuning

Mapping from note steps to pitches.

In the *equal temperament tuning* all frequency ratios are 2^(1/12) ≈ 1.06

This does not determine the absolute pitch, but that is often fixed by setting A = 440 Hz

# Notation

note_number: integer

# Tuning systems:

## Equal Tempered Scale

* All frequency rations are 2^(1/12)

This is also called 12-TET scale, as the octave is divided in 12 equal frequency-ratios

See also 53-TET equal temper scale https://en.wikipedia.org/wiki/53_equal_temperament

## Pythagorean Scale

Based on octave folding of frequency ratios of 3/2 (quint or fifth up) and 2/3 (quarter or fourth down)

Is a form of "3-limit tuning".
All frequency rations are powers of 2 and 3.

## Just Intonation

A form of 5-limit tuning. 
All frequency ratios are powers of 2, 3, 5.

### Justly 
Justly uses

    Octave: 2/1
    Perfect fifth: 3/2
    Major third: 5/4
    Harmonic seventh: 7/4

So assumes 7-limit tuning https://en.wikipedia.org/wiki/7-limit_tuning

# Stories

Why 12 semi-tones?

Based on the harmonic series and octave folding.

https://en.wikipedia.org/wiki/Harmonic_series_(music)

# Making sound

## WAV works

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

## PortAudio

We need to name the device.

This does not work:

``` julia
using PortAudio, SampledSignals
S = 8192 # sampling rate (samples / second)
x = cos.(2pi*(1:2S)*440/S) # A440 tone for 2 seconds
PortAudioStream(0, 2; samplerate=S) do stream
    write(stream, x)
end
```

We need to know our devices:

``` julia
julia> using PortAudio
julia> devices()
8-element Vector{PortAudio.PortAudioDevice}:
 "HD-Audio Generic: HDMI 0 (hw:0,3)" 0→2
 "HD-Audio Generic: HDMI 1 (hw:0,7)" 0→8
 "USB Audio: - (hw:1,0)" 2→8
 "USB Audio: #1 (hw:1,1)" 2→2
 "USB Audio: #2 (hw:1,2)" 2→2
 "USB Audio: #3 (hw:1,3)" 0→2
 "hdmi" 0→2
 "pulse" 32→32

```

Then this works:

``` julia
using PortAudio, SampledSignals
S = 44100 ## 8192 # sampling rate (samples / second)
x = cos.(2pi*(1:2S)*440/S) # A440 tone for 2 seconds
PortAudioStream("pulse", "pulse", 0, 2; samplerate=S) do stream
# PortAudioStream(0, 2; samplerate=S) do stream
    write(stream, x)
end
```

# Design goal

Take a representation like a Lilypond score, apply a tuning system, and get notes (frequency, duration).

Render these notes to tones and play them.

## Tuning system:

* Number of note steps per octave.
* Frequency ranges for each step.

### Pythagorean Tuning:

Octave folded Geometric series over 3/2

``` julia
function octave_fold(x; max_cents = 1200) ## chould be calle pitch_class https://en.wikipedia.org/wiki/Pitch_class
    while x < 1
        x = x*2
    end
    while x >=2
        x = x/ 2
    end
    x
end

function octave_fold_cents(x; max_cents = 1200) ## chould be calle pitch_class https://en.wikipedia.org/wiki/Pitch_class
    while 1200* log2(x) < max_cents - 1200 ## x < 1
        x = x*2
    end
    while 1200* log2(x) >= max_cents
        x = x/ 2
    end
    x
end

note_names =  [["C","Db","D", "Eb", "E", "F", "Gb"]; ["F#", "G", "Ab", "A", "Bb","B"]]

p1 = DataFrame(Fifth = 6:-1:-6)

using Chain
using ShiftedArrays
p2 = @chain p1 begin
    @transform(:Ratio = octave_fold.((3//2).^:Fifth))
    @transform(:Decimal = 1.0 * :Ratio)
    @transform(:Cents = 1200* log2.(:Decimal))
    sort(order(:Decimal))
    @transform(:Name = note_names)
    @transform(:NextRatio = ShiftedArrays.lead(:Ratio, default = 2) ./ :Ratio)
    @transform(:NextScale = 1.0 * :NextRatio)
    @transform(:NextCents = 1200 * log2.(:NextRatio))
end

```


``` julia
using PrettyTables
julia> pretty_table(p2) ## , backend = Val(:markdown)
┌───────┬─────────────────┬─────────┬─────────┬────────┬─────────────────┬───────────┬───────────┐
│ Fifth │           Ratio │ Decimal │   Cents │   Name │       NextRatio │ NextScale │ NextCents │
│ Int64 │ Rational{Int64} │ Float64 │ Float64 │ String │ Rational{Int64} │   Float64 │   Float64 │
├───────┼─────────────────┼─────────┼─────────┼────────┼─────────────────┼───────────┼───────────┤
│     0 │            1//1 │     1.0 │     0.0 │      C │        256//243 │    1.0535 │    90.225 │
│    -5 │        256//243 │  1.0535 │  90.225 │     Db │      2187//2048 │   1.06787 │   113.685 │
│     2 │            9//8 │   1.125 │  203.91 │      D │        256//243 │    1.0535 │    90.225 │
│    -3 │          32//27 │ 1.18519 │ 294.135 │     Eb │      2187//2048 │   1.06787 │   113.685 │
│     4 │          81//64 │ 1.26562 │  407.82 │      E │        256//243 │    1.0535 │    90.225 │
│    -1 │            4//3 │ 1.33333 │ 498.045 │      F │        256//243 │    1.0535 │    90.225 │
│    -6 │       1024//729 │ 1.40466 │  588.27 │     Gb │  531441//524288 │   1.01364 │     23.46 │
│     6 │        729//512 │ 1.42383 │  611.73 │     F# │        256//243 │    1.0535 │    90.225 │
│     1 │            3//2 │     1.5 │ 701.955 │      G │        256//243 │    1.0535 │    90.225 │
│    -4 │         128//81 │ 1.58025 │  792.18 │     Ab │      2187//2048 │   1.06787 │   113.685 │
│     3 │          27//16 │  1.6875 │ 905.865 │      A │        256//243 │    1.0535 │    90.225 │
│    -2 │           16//9 │ 1.77778 │  996.09 │     Bb │      2187//2048 │   1.06787 │   113.685 │
│     5 │        243//128 │ 1.89844 │ 1109.78 │      B │        256//243 │    1.0535 │    90.225 │
└───────┴─────────────────┴─────────┴─────────┴────────┴─────────────────┴───────────┴───────────┘

```

This tuning as 12 intervals, where interval 7 has 2 version: Gb and F#. Each 11.73 cents above or below the 600 cent tone.

## Just Intonation

The major triad gets frequency ratios 4:5:6.

In just intonation, the majors scale is mostly going up by 1/8 frequency.
Except for fourth and sixth.

Add the major third: 5//4. 
This is the fifth harmonics.

This is included in the 5-limnit tuning.

To also include the 7th harmonic ("harmonic seventh): 7//4, we need 7-limit tuning.



# Tonal Diamond
https://en.wikipedia.org/wiki/Tonality_diamond#7-limit

# Harmonic Series:

``` julia
h1 = DataFrame(Harm = 1:24)
using Chains

h2 = @chain  DataFrame(Harm = 1:24)  begin
    @transform(:Ratio = octave_fold.((1//1).*:Harm))
    @transform(:Decimal = 1.0 * :Ratio)
    @transform(:Cents = 1200* log2.(:Decimal))
    @groupby([:Ratio, :Decimal, :Cents])
    @combine(:Harms = join(:Harm, ", "))
    sort(order(:Decimal))
end

```

``` julia

12×4 DataFrame
 Row │ Ratio      Decimal  Cents     Harms          
     │ Rational…  Float64  Float64   String         
─────┼──────────────────────────────────────────────
   1 │      1//1   1.0        0.0    1, 2, 4, 8, 16
   2 │    17//16   1.0625   104.955  17
   3 │      9//8   1.125    203.91   9, 18
   4 │    19//16   1.1875   297.513  19
   5 │      5//4   1.25     386.314  5, 10, 20
   6 │    21//16   1.3125   470.781  21
   7 │     11//8   1.375    551.318  11, 22
   8 │    23//16   1.4375   628.274  23
   9 │      3//2   1.5      701.955  3, 6, 12, 24
  10 │     13//8   1.625    840.528  13
  11 │      7//4   1.75     968.826  7, 14
  12 │     15//8   1.875   1088.27   15


```



# Equal tempers

Geometric series in 2^(1/12)

2-TET: Includes only the tritonus! https://johncarlosbaez.wordpress.com/2023/11/06/just-intonation-part-2/

2^(1/2) = 1.4142135623 = 600 cents

3-TET: 
2^(1/3) = 0, 400, 800, 1200

Pythagorean is geometric in 3//2 = 701.955 cents.

# Tunings

Tuning:
DataFrame(Cycle, Ratio)

``` julia
cents(x) = 1200*log2(x)

function tuning_table(t; max_cents = 1200, cycle = missing)
	@chain  t  begin
        @transform(:Ratio = octave_fold_cents.(:Ratio; max_cents))
        @transform(:Decimal = 1.0 * :Ratio)
        @transform(:Cents = cents.(:Decimal))
        @groupby([:Name, :Ratio, :Decimal, :Cents])
        @combine(:Cycles = join(:Cycle, ", "))
        sort(order(:Decimal))
        @transform(:NextRatio = ShiftedArrays.lead(:Ratio, default = cycle) ./ :Ratio)
        @transform(:NextScale = 1.0 * :NextRatio)
        @transform(:NextCents = 1200 * log2.(:NextRatio))
    end
end

pyt1 = tuning_table(@transform(DataFrame(Name = "Pyt1", Cycle = -6:6), :Ratio = (3//2).^:Cycle), cycle = 2)
pyt2 = tuning_table(@transform(DataFrame(Name = "Pyt2", Cycle = -6:6), :Ratio = (3//2).^:Cycle), max_cents = 600)
harm_up1 = tuning_table(@transform(DataFrame(Name = "Harm_up1", Cycle = 1:24), :Ratio = (1//1).*:Cycle))
harm_down1 = tuning_table(@transform(DataFrame(Name = "Harm_down1", Cycle = 1:24), :Ratio = (1//1)./:Cycle))
harm_up2 = tuning_table(@transform(DataFrame(Name = "Harm_up2", Cycle = 1:24), :Ratio = (1//1).*:Cycle), max_cents = 600)
harm_down2 = tuning_table(@transform(DataFrame(Name = "Harm_down2", Cycle = 1:24), :Ratio = (1//1)./:Cycle), max_cents = 600)

```


# Ptolemy diatonic scale

``` julia
ptml1 = tuning_table(@transform(DataFrame(Name = "Ptml1", Cycle = 1:8), :Ratio = [1//1, 9//8, 5//4, 4//3, 3//2, 5//3, 15//8, 2//1]))
ptml2 = tuning_table(@transform(DataFrame(Name = "Ptml2", Cycle = 1:8), :Ratio = [1//1, 9//8, 5//4, 4//3, 3//2, 5//3, 15//8, 2//1]), max_cents = 600)

julia> ptml1 = tuning_table(@transform(DataFrame(Cycle = 1:8), :Ratio = [1//1, 9//8, 5//4, 4//3, 3//2, 5//3, 15//8, 2//1]))
7×7 DataFrame
 Row │ Ratio      Decimal  Cents     Cycles  NextRatio   NextScale      NextCents   
     │ Rational…  Float64  Float64   String  Rational…?  Float64?       Float64?    
─────┼──────────────────────────────────────────────────────────────────────────────
   1 │      1//1  1.0         0.0    1, 8          9//8        1.125        203.91
   2 │      9//8  1.125     203.91   2            10//9        1.11111      182.404
   3 │      5//4  1.25      386.314  3           16//15        1.06667      111.731
   4 │      4//3  1.33333   498.045  4             9//8        1.125        203.91
   5 │      3//2  1.5       701.955  5            10//9        1.11111      182.404
   6 │      5//3  1.66667   884.359  6             9//8        1.125        203.91
   7 │     15//8  1.875    1088.27   7          missing  missing        missing     

julia> ptml2 = tuning_table(@transform(DataFrame(Cycle = 1:8), :Ratio = [1//1, 9//8, 5//4, 4//3, 3//2, 5//3, 15//8, 2//1]), max_cents = 600)
7×7 DataFrame
 Row │ Ratio      Decimal   Cents     Cycles  NextRatio   NextScale      NextCents   
     │ Rational…  Float64   Float64   String  Rational…?  Float64?       Float64?    
─────┼───────────────────────────────────────────────────────────────────────────────
   1 │      3//4  0.75      -498.045  5            10//9        1.11111      182.404
   2 │      5//6  0.833333  -315.641  6             9//8        1.125        203.91
   3 │    15//16  0.9375    -111.731  7           16//15        1.06667      111.731
   4 │      1//1  1.0          0.0    1, 8          9//8        1.125        203.91
   5 │      9//8  1.125      203.91   2            10//9        1.11111      182.404
   6 │      5//4  1.25       386.314  3           16//15        1.06667      111.731
   7 │      4//3  1.33333    498.045  4          missing  missing        missing     

```

# All

``` julia
a1 = sort(vcat(pyt1, harm_up1, harm_down1, ptml1), order(:Cents))
a2 = sort(vcat(pyt2, harm_up2, harm_down2, ptml2), order(:Cents))
a = sort(vcat(a1, a2), order(:Cents))
ac = @combine(@groupby(a, [:Ratio, :Decimal, :Cents]), Names = join(:Name, ","))

```

Pythagorean comma is 23.5 cents (almost 1/4 semitone).

# Choir application
* https://www.jstor.org/stable/26870192. Based on this thesis: https://ir.canterbury.ac.nz/server/api/core/bitstreams/a740a805-2b42-4b61-9e94-20604e64a943/content. Local copy Withington Andrew Final PhD thesis, 33399012) - 25 May, 2017-1.pdf

Introduces notation to guide singers: AWJITS

"While there are an infinite
number of harmonics, the intonations of twelve of the
first sixteen are the most useful in a choral context, as
four produce unsatisfactory results (these are crossed [x]
in Figure 1)."

He discards 4 of the first 16 harmonics, leaving 12 (but only 6 different)
Discard: 7, 11, 13, 14 (==7)
Keep:


12×4 DataFrame
 Row │ Ratio      Decimal  Cents     Harms          
     │ Rational…  Float64  Float64   String         
─────┼──────────────────────────────────────────────
   1 │      1//1   1.0        0.0    1, 2, 4, 8, 16
   3 │      9//8   1.125    203.91   9
   5 │      5//4   1.25     386.314  5, 10
   9 │      3//2   1.5      701.955  3, 6, 12
  12 │     15//8   1.875   1088.27   15

C, D, E, G, H. C maj9 chrod
https://lilypond.org/doc/v2.23/Documentation/notation/chord-name-chart
Ratios between these also include
Perfect 4th (498 cent) up from perfect fifth (3rd harmonic) and 
minor 6th (316 cents) up from 5th to 6th harmonic

See tables in thesis: p 91 (awjits), 33 (scale "degree")


# References

* https://johncarlosbaez.wordpress.com/2023/10/30/just-intonation-part-1/
* https://www.jstor.org/stable/26870192. Based on this thesis: https://ir.canterbury.ac.nz/server/api/core/bitstreams/a740a805-2b42-4b61-9e94-20604e64a943/content. Local copy Withington Andrew Final PhD thesis, 33399012) - 25 May, 2017-1.pdf
* https://mtosmt.org/issues/mto.06.12.3/mto.06.12.3.duffin.html
* https://en.m.wikipedia.org/wiki/7-limit_tuning
* https://en.m.wikipedia.org/wiki/Musical_tuning#Tuning_systems
* https://en.m.wikipedia.org/wiki/Five-limit_tuning
* https://en.m.wikipedia.org/wiki/Music_and_mathematics (I think fugure of vibrating string has gone? 2024-05-20)
* https://drive.google.com/file/d/1_DWuvN2h9tZQMOhEoEbXqGXE1gZSFlkP/view Gowers talk: "any consecutive 5 notes tin the circle of fifths give a pentatonic scale"
