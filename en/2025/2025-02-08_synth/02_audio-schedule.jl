# https://juliamusic.github.io/AudioSchedules.jl/dev/#AudioSchedules.AudioSchedule-Tuple{}
using AudioSchedules
audio_schedule = AudioSchedule()
 push!(audio_schedule, Map(sin, Cycles(440Hz)), 0s, @envelope(
           0,
           Line => 1s,
           0.2,
           Line => 1s,
           0,
       ))
push!(audio_schedule, Map(sin, Cycles(660Hz)), 2s, @envelope(
            0,
            Line => 1s,
            0.2,
            Line => 1s,
            0,
        ))
audio_schedule

using PortAudio: PortAudioStream
dev = "pulse"
# PortAudioStream(0, 1, warn_xruns = false) do stream
#     write(stream, audio_schedule)
# end
PortAudioStream(dev, dev, 1, 2, warn_xruns = false) do stream # still does not work
    write(stream, audio_schedule)
end
