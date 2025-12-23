# Tuning systems
TP, 2024-05-28

# Equal temperement tuning 
Piano tuning:

All frequency ratios are 2^(1/12) = 1.05946

Also called 100 cent.

Using the standard note names, a major triad is: CEG.
Tonica, major third, fifth
Semi tone steps: 0, 4, 7
Cents above tonica: 0, 400, 700.
Frequency ratios: 1, 2^(4/12) ≈ 1.26, 2^(7/12) ≈ 1.49


Invertions. 
GCE: -500, 0, 400
Frequency ratios: 1, 2^(-5/12) ≈ 0.749,  2^(4/12) ≈ 1.26,

# Harmonic frequencies

Sting, pipe etc:

https://en.wikipedia.org/wiki/Harmonic_series_(music)#/media/File:Harmonic_partials_on_strings.svg

| Period | Nodes | Frequency Scale | Pitch Class | Decimal | Name          | Cents |
| 1      | 2     | 1               | 1//1        | 1       | Prime         | 0     |
| 1/2    | 3     | 2               | 1//1        | 1       | Octave        | 0     |
| 1/3    | 4     | 3               | 3//2        | 1.5     | Perfect fifth | 702   |
| 1/5    | 6     | 5               | 5//4        | 1.25    | Major third   | 386   |
| 1/7    | 8     | 7               | 7//4        | 1.75    | Minor seventh | 968   |
| 1/9    | 10    | 9               | 9//8        | 1.125   | Major second  | 204   |


https://en.wikipedia.org/wiki/Harmonic_series_(music) Table: Harmonics and tuning

This is harmonic series of periods.

# Geometric series: Pythagorean Tuning

3rd harmonic: 3//2 = 1.5, Perfect fifth.

12 fifths = 1.5^12 ≈ 129.75 ≈ 128 = 2^7 = 7 octaves.

Ratio is 3^12/2^19 = 531441//524288 ≈ 1.01364 ≈ 23.46 cents. = pythagorean comma. (about 1/4 semi-tone).

In geometric series we can also go down:

Pitch class of 3//2 is 4//3 ≈ 1.3333 = 498 cents.

If we also invert harmoci interals, we can get:

3rd: 4//3 = 1.333 = 498 cents = fith down
5th: 8//5 = 1.6 = 814 cents = major third down

So we can get:

| Step | Name                             | Pitch Class | Scale          | Cents | Note   | Harmonic |
| 0    | Pime                             | 1//1        | all            | 0     | C      | 1        |
| 1    | Minor second                     | 17//16      | Harm up        | 105   | C#     | 17       |
| 2    | Major second                     | 9//8        | Harm up, Pyt   | 204   | D      | 9        |
| 3    | Minor Third                      | 19//16      | Harm up        | 298   | Eb     | 19       |
| 4    | Major third                      | 5//4        | Harm_up        | 386   | E      | 5        |
| 5    | Perfect Fourth                   | 4//3        | Pyt            | 498   | F      | -3       |
| 6    | Tritonus                         | sqrt(2)     | 12-tet         | 600   | F#, Gb |          |
| 6    | Tritone                          | 23//16      | Harm up        | 628   | F#     | 23       |
| 7    | Perfect Fifth                    | 3//2        | Harm           | 702   | G      | 3        |
| 8    | Minor sixth, Major third down    | 8//5        | Harm down      | 814   | G#     | -5       |
| 9    | Major sixth, Minor third down    | 32//19      | Harm down      | 906   | A      | -19      |
| 10   | Minor seventh, Major secod down  | 16//9       | Harm down, pyt | 996   | Bb     | -9       |
| 11   | Major seventh, Minor second down | 32//17      | Harm down      | 1195  | B      | -17      |

Below 12 harmonics:

| Step | Name                            | Pitch Class | Scale          | Cents | Note | Harmonic |
| 0    | Pime                            | 1//1        | all            | 0     | C    | 1        |
| 2    | Major second                    | 9//8        | Pyt            | 204   | D    | 9        |
|      |                                 | 8//7        | Harm           | 231   |      | 7        |
| 4    | Major third                     | 5//4        | Harm_up        | 386   | E    | 5        |
| 5    | Perfect Fourth                  | 4//3        | Pyt, Harm down | 498   | F    | -3       |
| 7    | Perfect Fifth                   | 3//2        | Harm           | 702   | G    | 3        |
| 8    | Minor sixth, Major third down   | 8//5        | Harm down      | 814   | G#   | -5       |
|      |                                 | 7//4        |                | 968   |      | 7        |
| 10   | Minor seventh, Major secod down | 16//9       | Harm down, pyt | 996   | Bb   | -9       |


What scale?
s1 = tuning_table(@transform(DataFrame(Name = "sc1", Cycle = 1:8), :Ratio = [1//1, 8//7, 5//4, 4//3, 3//2, 5//3, 7//4, 2//1]), cycle=2)
s2 = tuning_table(@transform(DataFrame(Name = "sc2", Cycle = 1:8), :Ratio = [1//1, 8//7, 5//4, 4//3, 3//2, 5//3, 7//4, 2//1]), max_cents=600, cycle=2)

```julia
julia> s1 = tuning_table(@transform(DataFrame(Name = "sc1", Cycle = 1:8), :Ratio = [1//1, 8//7, 5//4, 4//3, 3//2, 5//3, 7//4, 2//1]), cycle=2)
7×8 DataFrame
 Row │ Name    Ratio      Decimal  Cents    Cycles  NextRatio  NextScale  NextCents 
     │ String  Rational…  Float64  Float64  String  Rational…  Float64    Float64   
─────┼──────────────────────────────────────────────────────────────────────────────
   1 │ sc1          1//1  1.0        0.0    1, 8         8//7    1.14286   231.174
   2 │ sc1          8//7  1.14286  231.174  2          35//32    1.09375   155.14
   3 │ sc1          5//4  1.25     386.314  3          16//15    1.06667   111.731
   4 │ sc1          4//3  1.33333  498.045  4            9//8    1.125     203.91
   5 │ sc1          3//2  1.5      701.955  5           10//9    1.11111   182.404
   6 │ sc1          5//3  1.66667  884.359  6          21//20    1.05       84.4672
   7 │ sc1          7//4  1.75     968.826  7            8//7    1.14286   231.174

julia> s2 = tuning_table(@transform(DataFrame(Name = "sc1", Cycle = 1:8), :Ratio = [1//1, 8//7, 5//4, 4//3, 3//2, 5//3, 7//4, 2//1]), max_cents=600, cycle=2)
7×8 DataFrame
 Row │ Name    Ratio      Decimal   Cents     Cycles  NextRatio  NextScale  NextCents 
     │ String  Rational…  Float64   Float64   String  Rational…  Float64    Float64   
─────┼────────────────────────────────────────────────────────────────────────────────
   1 │ sc1          3//4  0.75      -498.045  5           10//9    1.11111   182.404
   2 │ sc1          5//6  0.833333  -315.641  6          21//20    1.05       84.4672
   3 │ sc1          7//8  0.875     -231.174  7            8//7    1.14286   231.174
   4 │ sc1          1//1  1.0          0.0    1, 8         8//7    1.14286   231.174
   5 │ sc1          8//7  1.14286    231.174  2          35//32    1.09375   155.14
   6 │ sc1          5//4  1.25       386.314  3          16//15    1.06667   111.731
   7 │ sc1          4//3  1.33333    498.045  4            3//2    1.5       701.955


```

function plot_pitch(p)
 x = collect((0:100).*2.0.*pi)
 y = sin.(s.*p)
 plot(x,y)
end

function sin_p(p)
  x -> sin(x*2*pi*p)
end

## I morgen:
* Opdater RationalMusic, så den virker ("pulse" device)
* Lyt til Harmonic scale (folded)
* brug sin_p ideen til at lave plots og "sample late"
