# Music Thinking 
TP 2024-10-12

# Conclusions

# Purpose

Planning what to do.

# Ideas

## Playing

* play([c, e, g]) is a triad.
* play.([c, e, g]) is arpegiated.

## Nomenclature

* note is C4: 1/4 C (Lilypond notation): pitch number, duration (relative: fraction), volume (relative: float)
* tone: frequency, phase. Keep duration, volume. tone = note + tuning + phase
* sound: function. sound = tone + synthesizer. Keep tone
* voice: vector of notes. render is broadcast.
* harmony: vector of notes. render as vector. what if not all notes have same length?
* performance: combining sounds in tempo using envelope.

We should be able to adjust tuning, envelope, dynamics, phrasing per note.

Playing sounds together, they need an envelope.
If we just concatenates them, we get clicks.

# Use cases

* Playing a stream of MIDI in real time
* Render a "score" to sampled signal

The second looks simpler. Start there.

# Pipeline

1. Score in lilypond format or DataFrame. These are notes.
2. Add tuning
3. Add synthesizer per channel
4. Add BPM to set tempo
5. Render/play to sampled signal (wav)

Keep everything as functions.

The simplest is to ignore harmonies and treat everything as individual voices.

# Score as DataFrame

* Set resolution (eg 1/16).
* Row is sub-beat (eg 16 per beat).
* Column is vioce.
* Note is in (i,j) if it starts at sub-beat i in voice j.

# Structs

struct Note{T} where T<: Real
    pitch::Int
    duration::T
    volume::Float32
end

struct Tone
    frequency::Float32
    phase::Float32
	note::Note
end

struct Sound
    func::Function
	tone::Tone
end

