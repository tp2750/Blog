# Rational Music 1
TP, 2023-10-21

# Conclusions

# Objective

I want to investigate sounds from a computer sound sybthesys point of view.
Starting from sine curves. 
Adding harmnics to get timbre.
Combining tones into chords. 
Tones and intervals in integer ratios.
Sound durations for rythm.

Before starting I want to get some feeling for the numbers.

* Speed of sound
* Frequecies and wavelengths
* Durations and distance traveled.

Also look at spectra of 

* String
* Beam
* Drum (circle)

This is inspired by some of Baez writing: https://johncarlosbaez.wordpress.com/2023/10/13/perfect-fifths-in-equal-tempered-scales/

# Sound and physics

## Speed of sound

At 20C in dry air (normal pressure?) the speed of sound is 343 m/s

* c = 343 m/s
* 2.914 ms/m

$$
c = \sqrt{\frac{K_s}{\rho}}
$$

Speed of sound is squareroot of ratio between stiffness and density.

Ref: https://en.wikipedia.org/wiki/Speed_of_sound

## Frequency and wavelength

Wave speed is always wavelength * frequency

$$
c = l * f
$$

* Wavelength of 440Hz = 343/440 = 0.78 m
* Frequency of 1 m wavelength: 343 Hz between E4 and F4
* Wavelength of middle C 261.63 Hz is 1.31 m

The piano spans from 20 m to 4 cm of wavelength.

| Note | Hz     | m     |
| ---  | ---    | ---   |
| C0   | 16.35  | 20.98 |
| C1   | 32.7   | 10.49 |
| C2   | 65.4   | 5.24  |
| C3   | 130.8  | 2.62  |
| C4   | 261.6  | 1.31  |
| C5   | 523.2  | 0.65  |
| C6   | 1046.4 | .328  |
| C7   | 2092.8 | 0.16  |
| C8   | 4185.6 | 0.082 |
| C9   | 8371.2 | 0.041 |

``` julia
julia> a = 2 .^ [0,1,2,3,4,5,6,7,8,9] *16.35
julia> [a .* 16.35  343 ./ a] 
julia> [a   343 ./ a]
julia> [a   343 ./ a]
10×2 Matrix{Float64}:
   16.35  20.9786
   32.7   10.4893
   65.4    5.24465
  130.8    2.62232
  261.6    1.31116
  523.2    0.655581
 1046.4    0.327791
 2092.8    0.163895
 4185.6    0.0819476
 8371.2    0.0409738
```

A mathematician would choose C0 as 16 Hz to get nice numbers!
That would be 21.4 m at 343 m/s.

C6 would be 1024 Hz and 33.5 cm.

I'll probably use those in my tests.

I suppose it is the frequency that determines the sound, mot the wavelength.
