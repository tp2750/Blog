using PortAudio, SampledSignals
using Statistics, StatsBase
# S = 8192 # sampling rate (samples / second)
# x = cos.(2pi*(1:2S)*440/S) # A440 tone for 2 seconds
# PortAudioStream(0, 2; samplerate=S) do stream
#     write(stream, x)
# end


function play_freq(hz,sec;sample_rate = 8192)
    # x = cos.(2pi*(1:2S)*440/S) # A440 tone for 2 seconds
    x = sin.(2pi*(1:sec*sample_rate)*hz/sample_rate)
    PortAudioStream(0, 2; samplerate=sample_rate) do stream
        write(stream, x)
    end
    x
end

function sample(hz;sec=1, sample_rate = 8192)
    sin.(2pi*(1:sec*sample_rate)*hz/sample_rate)
end

function mix(samples)
    x = mean(samples)
    x ./ maximum(x)
end

function play_sample(x; sample_rate = 8192)
    PortAudioStream(0, 2; samplerate=sample_rate) do stream
        write(stream, x)
    end
end

f1 = 256
for f in 1:10
    @info "$f1 Hz w $(f-1) harmonics"
    local m1 = mix([sample(x*f1) for x in 1:f])
    play_sample(m1)
    sleep(1)
end

f1 = 256
for f in 1:10
    @info "$f1 Hz w $(f-1) harmonics damped"
    local m1 = mix([sample(x*f1) ./x for x in 1:f])
    play_sample(m1)
    sleep(1)
end

