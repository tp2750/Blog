using PortAudio

## from https://github.com/JuliaAudio/PortAudio.jl
## Does not work directly:
using PortAudio, SampledSignals
S = 8192 # sampling rate (samples / second)
x = cos.(2pi*(1:2S)*440/S) # A440 tone for 2 seconds
PortAudioStream(0, 2; samplerate=S) do stream
    write(stream, x)
end
## ERROR: PortAudioException: Invalid sample rate

## But using "pulse" as device works:
using PortAudio, SampledSignals
S = 8192 # sampling rate (samples / second)
x = cos.(2pi*(1:2S)*440/S) # A440 tone for 2 seconds
PortAudioStream("pulse","pulse",0, 2; samplerate=S) do stream
    write(stream, x)
end

