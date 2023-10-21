using PortAudio, SampledSignals
S = 8192 # sampling rate (samples / second)
x = cos.(2pi*(1:2S)*440/S) # A440 tone for 2 seconds
PortAudioStream(0, 2; samplerate=S) do stream
    write(stream, x)
end

using Plots

plot((1:100) ./8192 *1E3, x[1:100], xlab="ms", label="440Hz", legend=:outertopright)

