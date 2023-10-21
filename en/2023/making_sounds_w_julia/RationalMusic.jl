using PortAudio, SampledSignals
using Statistics


struct Tone{T}
    frequency::T
    duration::T
    sample_rate::Int
    samples::Vector{T}
end

Tone(frequency, duration, sample_rate) = Tone(frequence, duration, sample_rate, sin.(2pi*(1:sec*sample_rate)*hz/sample_rate))
Tone(frequency, duration; sample_rate = 8192) = Tone(frequency, duration, sample_rate)
Tone(frequency; duration=1.0, sample_rate = 8192) =  Tone(frequency, duration, sample_rate)

function play_sample(x; sample_rate = 8192)
    PortAudioStream(0, 2; samplerate=sample_rate) do stream
        write(stream, x)
    end
end

play(t::Tone) = play_sample(t.sample, sample_rate = t.sample_rate)

# plot(t::Tone)
# describe(t::Tone): freq, period, wavelength, Note name
# mix
# 
