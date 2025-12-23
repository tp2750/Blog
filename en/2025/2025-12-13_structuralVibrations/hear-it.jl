# hear the sound of a mechanical structure
# Set up the system
# solve
# sum all the elements
# tuner functions: tune parameter to get desired frequency
# strech goal: make an "instrument" out of it
# In principle a loudspeaker is of this type: signle dof
# According to this paper: https://www.eurecom.fr/publication/8193/download/sec-publi-8193.pdf the acoustic pressure (sound) contribution from a string element is proportional to the *speed* of the element:
## p(t) = ρ0c0/4π ∂uR(x, tr)/∂t
## It also has string parameters for guitar string:
# Parameters for a nylon string B3 (247 Hz)
# The parameters for the nylon string chosen are [8] [9] [10]:
# • L = 0.65 m
# • µ = 0.000582 kg m−1
# • T = 60 N

# first single dof system
using StructuralVibration

m = 1.
f₀ = 10.
ξ = 0.01

# Initialization of Sdof
sdof = Sdof(m, f₀, ξ)
