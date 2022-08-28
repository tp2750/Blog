# More buffers
tp2750 2022-08-27

# Background
I have implemented the pHcalc package in Julia: https://github.com/tp2750/pHcalc.jl

I have had problems using this to compute classical buffers like Sørensen's phosphate buffer or citric acid buffer https://microscopy.berkeley.edu/buffers-and-buffer-tables/

I think I now have a grasp on it.

In the case of the phosphoric acid, the pKa values are 2.15, 7.20, and 12.38 at 25°C (ignoring ion-strngth effects).
This is modeled as 
`H3PO4 = acid(concentration, [2.15, 7.20, 12.38], charge = 0)`. 
The charege parameter is only for zwitterions.

The Phosphate buffer is made by mixing 
`NaH2PO4` and `Na2HPO4`.
I suppose I model these as 
`NaH2PO4 = acid(concentration, [7.20, 12.38], charge=0)` and 
`Na2HPO4 = acid(concentration, [12.38], charge=0)` as the first hydrogen(s) have already been titrated away.

Let's see if this works.

# Sørensens Phosphate buffer

## Henderson-Hasselback calculation
The Henderson-Hasselbach equation gives the following ([ref](https://youtu.be/oht2PJwz2xo?t=103):

pH = pKa + log10([A-]/[HA])

Using pKa = 7.19 and 0.110 M of Na2HPO4 + 0.220 M of NaH2PO4, we get:

pH = 7.19 + log10([Na2HPO4]/[NaH2PO4]) = 7.19 + log10(.11/.22) = 6.89.


## pHcacl calculation


```julia
H3PO4(conc) = acid(conc, [2.15, 7.20, 12.38], charge = 0)
NaH2PO4(conc) = acid(conc, [7.20, 12.38], charge = 0)
Na2HPO4(conc) = acid(conc, [12.38], charge = 0)

pH(H3PO4(.1))
# 1.6326066490073885
pH(NaH2PO4(.1))
# 4.1001721393347506
pH(Na2HPO4(.1))
# 6.643309917287664

pH([Na2HPO4(.11),NaH2PO4(.22)])
# 3.9289040737390195
```

So this does not appear to work.

I would expect `Na2HPO4(.11)` to have a pH above 7, but

```julia
julia> pH(Na2HPO4(.11))
# 6.62646682865576
julia> pH(NaH2PO4(.22))
# 3.928904791652548
```

## Comparing to the Python version

Does it work in the python version?

```python
h3phos = System(Acid(pKa=[2.15, 7.20, 12.38], charge=0, conc=0.1))
h2phos = System(Acid(pKa=[7.20, 12.38], charge=0, conc=0.22))
h1phos = System(Acid(pKa=[12.38], charge=0, conc=0.11))
h3phos.pHsolve()
h2phos.pHsolve()
h1phos.pHsolve()
h3phos.pH
# 1.6326087951660133
h2phos.pH
# 3.9289070129394514
h1phos.pH
# 6.626469421386718
```

So the individual parts give the same.

Also the mix:

```python
h2phos = Acid(pKa=[7.20, 12.38], charge=0, conc=0.22)
h1phos = Acid(pKa=[12.38], charge=0, conc=0.11)
buf1 = System(h2phos, h1phos)
buf1.pHsolve()
buf1.pH
# 3.9289016723632795
```

So either both calculate it wrongly, or my method does not work.

## What to expect

According to this online calculator:  http://www.aqion.onl/reacs/new/392534?
100 mM of NaHPO4 has a pH of 9.13.
That is also what I would expect with a pKa of 12.4

However, wikipedia has pretty much what I'm thinking:
https://en.wikipedia.org/wiki/Acid_dissociation_constant#Polyprotic_acids

I guess I need to re-read Kalka: [Harald Kalka: Polyprotic Acids and Beyond—An Algebraic Approach (2021)](https://www.mdpi.com/2624-8549/3/2/34)

## The quadratic approach

We can always find the pH of a monoproic acid from the definition of the association constant, mass ballance and solving a quadratic equation:

Consider the equilibrium of a weak acid in water:

HA <-> A- + H+

The pKa is defined as -log10(Ka) where

Ka = [A-][H+]/[AH] // (dimension of concentration)

As each AH becomes one A- and one H+, we have that 

[A-] == [H+] = C-[HA], where C is in the stochiometric concetration of the wak acid desolved in water.

Writing x for [A-] == [H+] we get:

Ka = x^2/(C-x) or

x^2 - Ka(C-x) = 0 <=>

x^2 + Ka x - Ka C = 0

Solving the quadric gives:

x = (-Ka +- sqrt(Ka^2 + 4CKa))/2

In case of pKa = 12.4, C = 100 mM we get:

x = (-10^-12.4 + sqrt(10^-24.8 + 0.4*10^-12.4))/2 = 1.995260324434019e-7

pH = -log10(x) = 6.70

This is not so far from what I get with pHcalc:

```julia
julia> pH(acid(.1, 12.4))
6.651338912723566
```

I suppose the small difference comes from the fact that the monopriotic calculation ignores that some of the H+ produces will enter an equilibrium with H2PO4. However, that should lower the amount of free H+ and thus increase pH slightly.




## Looking closer at http://www.aqion.onl/

Looking at the result of dissplving 100 mM of Na2HPO4 in water we get:
http://www.aqion.onl/reacs/new/392541?

| Aqueous | Species   (in  mM) |
| H+      | 9.51e-07           |
| OH-     | 1.97e-02           |
| NaOH    | 3.31e-04           |
| Na+     | 1.92e+02           |
| NaHPO4- | 8.07e+00           |
| H3PO4   | 2.70e-08           |
| H2PO4-  | 3.65e-01           |
| HPO4-2  | 9.12e+01           |
| PO4-3   | 3.45e-01           |
| O2      | 1.05e-10           |

This looks like they have titrated H3PO4 with NaOH.

# Comparing sources

I'll compare the following sources:

* Clymer / Barton tool: https://www.egr.msu.edu/~scb-group-web/buffers/buffers.html
* Aqion tool: http://www.aqion.onl/reacs/new/392647?
* Table values: https://microscopy.berkeley.edu/buffers-and-buffer-tables/
* Henderson-Hasselback calculation

## Phosphate buffer

I take as a starting point the values used in [Berkley](https://microscopy.berkeley.edu/buffers-and-buffer-tables/) for pH 6.0, 7.0, 8.0.
This is for a 100 mM buffer based on 200 mM stock solutions ("Mix appropriate volumes of stock and add an equal volume of distilled water to make a final 0.1 M")

### pH 6.0

#### [Berkley](https://microscopy.berkeley.edu/buffers-and-buffer-tables/)
Mix 87.7 mL of 0.2 M NaH2PO4 with 12.3 mL 0.2 M Na2HPO4 and add 100 mL pure H2O:

Concentrations: 

* NaH2PO4: (87.7 mL * 0.2 M)/200 mL = 0.0877 M = 87.7 mM
* Na2HPO4: (12.3 mL * 0.2 M)/200 mL = 0.0123 M = 12.3 mM

#### [Clymer / Barton]( https://www.egr.msu.edu/~scb-group-web/buffers/buffers.html)

* Monosodium phosphate, monohydrate: 11.93 g/L, 86.47 mM
* Disodium phosphate, heptahydrate:  3.626 g/L, 13.53 mM

### [Aqion](http://www.aqion.onl/reacs/new/392647?)

* Berkley values:
  * H2O 	+ 	87.7 mM   NaH2PO4	+ 	12.3 mM   Na2HPO4
  * pH = 5.96		(at 25 °C)

* Clymer / Barton values:
  * H2O 	+ 	86.47 mM   NaH2PO4	+ 	13.53 mM   Na2HPO4
  * pH = 6.01		(at 25 °C)

### pHcalc

```julia
julia> pH([ acid(86.47/1000, [7.20, 12.38], charge=0), acid(13.53/1000,12.38)])
4.131752135230726
```

Clearly wrong. Most likely I'm doing it wrong.

However, this works:

```julia
julia> pH([acid(86.47/1000, [2.06486, 6.80506, 11.564674], charge=1), acid(13.53/1000, [2.06486, 6.80506, 11.564674], charge=2)])
5.999949468928148
```

Here I'm using the corrected pKa values extracted from Barton:

phosphate:  originalpKa = [	2.148, 7.198, 12.375];;  Activities at 0.1M : [2.06486, 6.80506, 11.564674]

Using standard pKa gives:


```julia
julia> pH([acid(86.47/1000, [2.148, 7.198, 12.375], charge=1), acid(13.53/1000, [2.148, 7.198, 12.375], charge=2)])
# 6.39
julia> pH([acid(87.7/1000, [2.148, 7.198, 12.375], charge=1), acid(12.3/1000, [2.148, 7.198, 12.375], charge=2)])
# 6.35
```

OK, so I model 

* NaH2PO4 as acid(86.7/1000, [2.148, 7.198, 12.375], charge=1)
* Na2HPO4 as acid(12.3/1000, [2.148, 7.198, 12.375], charge=2)

The mnemonic is: "Charge is how many H have alredy been removed".

Now we can model the [Berkley](https://microscopy.berkeley.edu/buffers-and-buffer-tables/) recipe:

```julia
A = sample(acid(.2, [2.06486, 6.80506, 11.564674], charge=1),87.7/1000)
B = sample(acid(.2, [2.06486, 6.80506, 11.564674], charge=2),100-87.7)
pH(dilute.(mix([A,B]),2))
# 5.952521020139692 ## Table: 6.0
A = sample(acid(.2, [2.06486, 6.80506, 11.564674], charge=1),39.0/1000)
B = sample(acid(.2, [2.06486, 6.80506, 11.564674], charge=2),61.0/1000)
pH(dilute.(mix([A,B]),2))
# 6.999296458898779 ## Table 7.0
A = sample(acid(.2, [2.06486, 6.80506, 11.564674], charge=1), 5.3/1000)
B = sample(acid(.2, [2.06486, 6.80506, 11.564674], charge=2),94.7/1000)
pH(dilute.(mix([A,B]),2))
# 8.054381724634077 ## Table 8.0
```

This is close enough!

Here's the table:

| NaH2PO4 | Na2HPO4 | Berkley | Clymer | Aqion | pHCalc |
| 87.7    | 12.3    | 6.0     | 5.953  | 5.96  | 5.9525 |
| 39.0    | 61.0    | 7.0     | 7.0    | 6.93  | 7.0    |
| 5.3     | 94.7    | 8.0     | 8.05   | 7.95  | 8.054  |


# Conclusions

My Julia implementation agrees with the python implementation.

I can get similar results as [Berkley](https://microscopy.berkeley.edu/buffers-and-buffer-tables/),  [Clymer / Barton]( https://www.egr.msu.edu/~scb-group-web/buffers/buffers.html) and  [Aqion](http://www.aqion.onl/reacs/new/392647?) by using the charge parameter to indicate how many H have been substituted in the salt.

For realistic buffer calculations we need to consider:

* pKa values [Harald Kalka: Polyprotic Acids and Beyond—An Algebraic Approach (2021)](https://www.mdpi.com/2624-8549/3/2/34)
* Ionic strength https://www.egr.msu.edu/~scb-group-web/buffers/buffers.html, https://en.wikipedia.org/wiki/Debye%E2%80%93H%C3%BCckel_equation#Extensions_of_the_theory, https://www.mdpi.com/2624-8549/3/2/34/htm Appendix B.2
* CO2 of the atmosphere http://www.aqion.onl/reacs/new/392541?
* Temperature https://en.wikipedia.org/wiki/Acid_dissociation_constant#Temperature_dependence

