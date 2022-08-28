# Understanding Buffers
2022-08-14

# Background
I want to be able to design buffes with a given pH and calculate the sensitivity to addition of strong acid/base.

In particular:

* Compute the amounts of stocks to mix to get a certain pH
* Plot titration curves (pH as function of added acid/base)
* Calculate the amount of strong acid/base needed to change the pH x units

Ideally it should compensate for

* Ionic strength ([Debye-Hückel theory](https://en.wikipedia.org/wiki/Debye%E2%80%93H%C3%BCckel_theory))
* Temperature \Delta G^\circ (https://youtu.be/pJdUR2uak2s?t=444)

## Ryan Nelson: pHcalc

I have translated the python program [pHcalc](https://github.com/rnelsonchem/pHcalc) to Julia and looked at the corresponding publications:

* [Juan José Baeza-Baeza* and María Celia García-Álvarez-Coque: Systematic Approach To Calculate the Concentration of Chemical Species in Multi-Equilibrium Problems (2011)](https://pubs.acs.org/doi/abs/10.1021/ed100784v) (paywalled)
* [James E. Kipp: PHCALC: A Computer Program for Acid/Base Equilibrium Calculations (1994)](https://pubs.acs.org/doi/pdf/10.1021/ed071p119) (paywalled)

The pHcalc program does not consider ionic strength, but the Kipp paper (and program) does this through Davis approximation of the [Debye-Hückel equation](https://en.wikipedia.org/wiki/Debye%E2%80%93H%C3%BCckel_equation).

## Clymer / Barton javascript program

This web-page pretty much deos what I want: 

* https://www.egr.msu.edu/~scb-group-web/buffers/buffers.html

It even inclues the javascript sourcecode, which is quite readable: https://www.egr.msu.edu/~scb-group-web/buffers/buffers.js.

This is where I became aware of this complication.

## Kalka: algebraic approach

Today I found a new promissing publication, and the following notes are from reading that:

* [Harald Kalka: Polyprotic Acids and Beyond—An Algebraic Approach (2021)](https://www.mdpi.com/2624-8549/3/2/34)


## PHREEQC

Kalka uses PHREEQC as the standard for realistic calculations
https://www.usgs.gov/software/phreeqc-version-3

Source code is available.

# First reading of  [Harald Kalka: Polyprotic Acids and Beyond—An Algebraic Approach (2021)](https://www.mdpi.com/2624-8549/3/2/34)

Obs: This paper does not do buffer calculations ith mix of acid and conjugate base.


He mentions an "excellent review article": 
* [Agustin G. Asuero, Tadeusz Michałowski: Comprehensive Formulation of Titration Curves for Complex Acid-Base Systems and Its Analytical Implications (2011)](https://www.tandfonline.com/doi/full/10.1080/10408347.2011.559440) (paywalled, but uploaded here: https://www.researchgate.net/publication/239787248_Comprehensive_Formulation_of_Titration_Curves_for_Complex_AcidBase_Systems_and_Its_Analytical_Implications)

The main equation is this:

n = Y_1 + w/C_T

Note what he says about buffer capacity:

## Quotes:


### Abstract
Principally, there are two main approaches to N-protic acids: one from hydrochemistry and one “outside inorganic hydrochemistry”. They differ in many ways: the choice of the reference state (either HNA or A−N), the reaction type (dissociation or association), the type/nature of the acidity constants, and the structure of the formulas.


Finally, from the viewpoint of statistical mechanics (canonical isothermal–isobaric ensemble), buffer capacities, buffer intensities, and higher pH derivatives are actually fluctuations in the form of variance, skewness, and kurtosis. 

### 1 Introduction

For the general case of aquatic systems (as mixtures of any number of acids and bases plus solid and gaseous phases), there are two prototypes of numerical approaches: (i) models that are based on the law of mass action (e.g., PhreeqC [11] and many others) and (ii) models that are based on Gibbs energy minimization (GEM) [12,13].


There are two principal ways of mathematical description: (i) the hydrochemical approach (based on dissociation reactions with reference state HNA) and (ii) the approach employed in organic and biochemistry (based on association reactions with reference state A−N). The present review follows the first approach; 

In titration, a titrant (strong base of amount CB) is added to the analyte (N-protic acid with amount CT), resulting in a certain pH value. 

The central formula is the equivalent fraction n = Y1 + w/CT

In this report, the function n(x) appears under several names: equivalence fraction, titration function/curve, and normalized buffer capacity

Table 1. pK values for four N-protic acids at 25 °C. (The composite carbonic acid is the sum of the unionized species CO2(aq) and the pure acid: H2CO3* = CO2(aq) + H2CO3; to simplify the notation, we omit the asterisk (*) on H2CO3* throughout the paper).
| N | Acid                      | Formula | Type | pK1  | pK2   | pK3   | Ref. |
| 1 | acetic acid               | CH3COOH | HA   | 4.76 |       |       | [35] |
| 2 | (composite) carbonic acid | H2CO3   | H2A  | 6.35 | 10.33 |       | [36] |
| 3 | phosphoric acid           | H3PO4   | H3A  | 2.15 | 7.12  | 12.35 | [35] |
| 3 | citric acid               | C6H8O7  | H3A  | 3.13 | 4.76  | 6.4   | [35] |


An acid is a proton donor

An N-protic acid HNA dissolves into N + 1 species:
1 undissociated species:	HNA0	(uncharged)
N dissociated species:	HN−1A−1, …, HA−(N−1), A−N	(anions)

In chemical thermodynamics, one has to distinguish between molar concentrations and activities:
concentrations:	denoted by square brackets	[j]
activities	denoted by curly braces	{j}

As discussed in Appendix B, activities are “effective concentrations” calculated from the molar concentrations using semi-empirical activity corrections γj:
{j} = γj [j]
(5)
The activity corrections γj increase with the ionic strength I of the solution.


The activity of H+ is abbreviated with x; it is linked to the pH value via:
x ≡ {H+} = 10−pH  ⇔  pH = −lg x  (6)
Using x instead of pH simplifies the formulas considerably.


The self-ionization of water (autoprotolysis) is defined by
H2O = H+ + OH−   with   Kw = {H+}{OH−}
(7)
and Kw = 1.0 × 10−14 at 25 °C. This yields [OH−] ≈ {OH−} = Kw/x.

onization fractions:
aj ≡ [j]CT      for j=0, 1, 2,…N
(16)


The Lth moment YL is defined as the weighting sum over aj:
YL≡∑j=0N j L aj (22)

| Y0 = a0 + a1 + … + aN = 1 | ⇒ mass balance               |                  | (23) |
| Y1 = a1 + 2a2 + … + N aN  | ⇒ enters buffer capacity     | in Equation (68) | (24) |
| Y2 = a1 + 4a2 + … + N2 aN | ⇒ enters buffer intensity β  | in Equation (69) | (25) |
| Y3 = a1 + 8a2 + … + N3 aN | ⇒ enters 1st derivative of β | in Equation (70) | (26) |

 while the mass-action laws are based on activities, the mass balance and charge balance rely on molar concentrations.
 
 
Plotting n = n(pH) as a function of pH yields the titration curve.
 
 
Alternatively, taking 100 mM NaHCO3 (or Na2CO3), the titration will start at n = 1 (or n = 2)


2.2.2. Analytical Formula (Titration Curves)

The essence

n(x)=Y1(x)+w(x)CT (41)

**This formula encapsulates the information contained in all other equations**

In the high-CT limit, the last term in Equation (41) vanishes and the formula simplifies to n = Y1(x).

Equation (41), the following tasks emerge:

    forward task 1: given pH and CT ⇒ calculate n (or CB)
    forward task 2: given pH and n (or CB) ⇒ calculate CT
    inverse task: given CT and n (or CB) ⇒ calculate pH
	

2.3. Equivalence Points

equivalence point:  [acid] = [conjugate base] (50)


EP:	[j − 1] = [j + 1]	⇒	aj−1(x) = aj+1(x)	        (51)
semi-EP:	[j − 1] = [j]	⇒	aj−1(x) = aj(x)	        (52)


To recall: In contrast to n, j is an integer (never a half-integer); j indicates the acid species [j], the acidity constants Kj, and the ionization fraction aj. In the new notation, Equations (51) and (52) become:
EPn:	[n − 1] = [n + 1]	  (for integer n = 0, 1, … N)	        (53)
semi-EPn:	[n − ½] = [n + ½]	  (for half-integer n = ½, 3/2, … N − ½)	        (54)


Each EPn is characterized by a specific pH value called pHn. The 2N − 1 internal EPs provide particularly simple formulas that establish a direct link to the acidity constants:

pHn={12 (pKn+pKn+1)pKn+1/2 ⇔⇔ EPnsemi-EPn (for integer n, except 0 and N)(for half-integer n)
(55)



Table 3. Internal equivalence points (based on pK values in Table 1).

| N | Acid                      | pH1/2 | pH1  | pH3/2 | pH2  | pH5/2 |
| 1 | acetic acid               | 4.76  |      |       |      |       |
| 2 | (composite) carbonic acid | 6.35  | 8.34 | 10.33 |      |       |
| 3 | phosphoric acid           | 2.15  | 4.68 | 7.21  | 9.78 | 12.35 |
| 3 | citric acid               | 3.13  | 3.94 | 4.76  | 5.58 | 6.4   |

 In contrast, pH0 and pHN depend sensitively on CT.

For CT → ∞ the two external EPs drift apart: pH0 → 0 and pH3 → 14, while all internal EPs remain fixed at the position dictated by the pK values in Equation (55).


2.3.2. EPs of the 3-Component Acid–Base System

In the most general sense, equivalence points are equilibrium states in which the equivalent fraction n = CB/CT becomes an integer or half-integer value: 

For CT ≫ w, the last term in Equation (60) vanishes,

This approximation works for CT > 10−3 M, but fails miserably for very dilute acids


2.4. Buffer Capacities
2.4.1. ANC and BNC

Buffer capacities are “distances” between two equilibrium states,

The ANC is the amount of basicity of the system that can be titrated with a strong acid to a chosen equivalence point EPj (at pHj):
[ANC]n=j = CB(pH) − j·CT  (64)


The curves display the amount of strong acid (normalized by CT) required to remove the inherent basicity and to attain pH0 (blue curve), pH1 (green curve), and pH2 (red curve).

2.4.2. Buffer Intensity


normalized buffer intensity:	β = dΔn/dpH = dn/dpH	(unitless)	(69)
buffer intensity:	βC = dCB/dpH = β CT	(in mM)	(70)

[Note: The last equation is valid if CT = const (standard case), otherwise we have to use dCB/dpH = β CT + n(dCT/dpH)].


The acid-neutralizing capacity is re-established by integrating βC over a definite pH interval (usually starting from an equivalence point EPn):
[ANC]n=∫pHnpHβC(pH′) d pH′ (71)

Figure 18. Optimal buffer range of the H2CO3 system with CT = 100 mM


In other words, the slope of the titration curve in Figure 18, Δn/ΔpH, should be large for maximum buffering capability.
The buffer intensity, β = dn/dpH, is just the measure of this slope


Figure 20. Same as Figure 19, but for CT = 100 mM. 


 2.5. Alternative and Statistical Approaches
2.5.1. Dissociation vs. Association Reactions


Acids can be described either by dissociation reactions (deprotonation), as shown in Section 2.1.2 and Equation (13), or as association reactions (protonation or complex formation). The corresponding cumulative (overall) equilibrium constants kj and βj differ significantly:

While dissociation reactions are preferred in hydrochemistry, association reactions are used in other fields (e.g., organic and biochemistry, ligand theory).

Figure 21. Micro- and macrostates of a triprotic acid and the corresponding (cumulative) equilibrium constants. 


2.5.2. Microstates vs. Macrostates

A polyprotic acid HNA is a molecule with N proton-binding sites. Each site is capable of binding 1 proton; the corresponding site-variable has two states: αi = 0 (empty) and 1 (occupied). In total, there are 2N microstates α(ν) = (α1, α2, … αN), which form a statistical ensemble. The microstates can be grouped into N + 1 macrostates [j], characterized by the number j of protons released from the fully protonated state HNA (undissociated acid). The number of microstates that form the macrostate [j] is equal to the number of microstates that form the macrostate [N − j] and is given by 

One of these two states can be chosen as the reference state (with Gibbs energy G = 0).

 In this report, the reference state is HNA = [0] defined by j = 0;

2.5.3. Probability Distributions and Averages


The result in Equation (87) can be generalized to any power L of aj, interpreting the moments YL (originally introduced in Equation (22)) as expectation values:

2.5.4. Partition Functions and Moments in Statistics


The ensemble of N + 1 macrostates [j] is specified by N acidity constants Kj (or ionization fractions aj).

The first approach is based on dissociation reactions (defined by cumulative acidity constants kj), the second on association reactions (defined by βj). 

In particular, the so-called binding polynomial Z was introduced in [32] for the description of ligands that bind to macromolecules

everything falls into the right place nicely

“excess kurtosis” is kurtosis relative to the normal distribution (with a kurtosis of 3).


2.5.5. Decoupled Sites Representation and Simms Constants


After a coefficient comparison, the conversion between the cumulative equilibrium constants and Simms constants is found

2.5.6. Polyprotic Acids as Mixtures of Monoprotic Acids

In fact, the mathematical treatment of a sum of monoprotic acids is much easier to handle than the polyprotic acid as a whole


2.5.7. The World of Acidity Constants

Polyprotic acids are specified by the N acidity constants Kj (or pKj values), which describe the step-by-step dissociation without any indication from which specific site the H+ is released. So, any of all the N binding sites can contribute to K1 (making K1 the largest value). For K2, as the second dissociation step, the proton comes from any one of the remaining N − 1 sites, and so on. This implies the order by size: K1 > K2 > … > KN.


Table 4. Macroscopic and microscopic acidity constants.

3. Applications
3.1. More About Acids
3.1.1. Strong Acids vs. Weak Acids

Table 5. Strong vs. weak acids (greatly simplified).
|                     | Strong Acid         | Weak Acid           |
| acidity constant    | Ka ≫ 1              | Ka ≤ 1              |
| pKa = −lg Ka        | pKa < 0             | pKa > 0             |
| [H+] ≈ {H+} = 10−pH | [H+] ≈ CT           | [H+] ≪ CT           |
| undissociated acid  | [HA] ≈ 0 or a0 ≈ 0  | [HA] ≈ CT or a0 ≈ 1 |
| dissociated acid    | [A−] ≈ CT or a1 ≈ 1 | [A−] ≪ CT or a1 ≪ 1 |


Figure 24. Undissociated fraction a0 for strong and weak acids. Strong acids are completely dissociated in the pH range above pH ≈ 0. 


3.1.4. Mixtures of Acids


Example. Given is a mixture of two acids: phosphoric acid plus carbonic acid with equal amounts: Cphos = Ccarb = CT/2

3.2.2. EPs as Inflection Points of Titration Curves
Table 7. Equivalence points as local extrema and inflection points. 

3.2.3. Ionization Fractions—Two Approaches

Summary. The two approaches are complementary, as shown in Figure 29. Approach 1 offers a very clever approximation in log-plots but fails to reproduce the S-shaped and bell-shaped curves in pH-aj diagrams (dashed curves in the bottom left diagram). Conversely, Approach 2 reproduces the aj curves perfectly, but if we look more closely, we see deviations in the log-plots for values below 10−5 (dashed curves in the top-right diagram).


3.3. Alkalinity and Carbonate System
3.3.1. Alkalinity and Acidity

In carbonate systems, ANC is known as alkalinity and BNC as acidity

3.3.2. pH as Reference Point of ANC and BNC

indicator methylorange (titration endpoint 4.2 to 4.5) and indicator phenolphthalein (titration endpoint 8.2 to 8.3). 

The measured “ANC to pH 4.3” corresponds to the total alkalinity (or M-alkalinity) of the system; the measured “ANC to pH 8.2” to the P-alkalinity. Here, the abbreviation “M” refers to the indicator methylorange and “P” to phenolphthalein.

3.3.3. Acid–Base Titration with H2CO3 as Titrant

During titration, a titrant is added to the analyte to reach the target pH


Concentation dependance: 
var B	CT = (CB − w)/Y1	with CB = 100 mM
[Note: In var B, pH < 5 is not available in practice.]





3.3.4. Open vs. Closed CO2 System

Figure 32. Species distribution of H2CO3 as a function of pH for var A (left) and var C (right). 


The more alkaline the solution becomes, the more CO2 is sucked out of the atmosphere (which increases the CT exponentially). [Note: In var C, pH < 5 is not available in practice.]

Resume. The three variants (var A, var B, var C) discussed in the last two sections exhibit the universality of the ionization fractions aj (shown in the bottom left diagram in Figure 3). They are independent of the chosen model, i.e., the functional dependence of CT.


 3.3.5. Seawater
The analytical formulas in Equation (41) and Equation (117) are based on the assumption that activities could be replaced by concentrations, {j} → [j].
This is valid either for dilute systems with near-zero ionic strength (I ≈ 0), or for non-dilute systems when the thermodynamic equilibrium constants are replaced by conditional constants, K → cK.


Seawater has I ≈ 0.7 M, which is at the upper limit of the validity range of common activity models


Table 8. Thermodynamic and conditional equilibrium constants for H2CO3 in pure water and seawater (at 25 °C, 1 atm); cK values from [39].
|     | Thermodynamic  K    | Conditional cK          |
|     | (Pure Water  I = 0) | (Seawater    I = 0.7 M) |
| pK1 | 5.18                | 6.0                     |
| pK2 | 10.33               | 9.1                     |
| pKw | 14.0                | 13.9                    |


3.3.6. From Ideal to Real Solutions


All calculations so far (except in Section 3.3.5) were performed for the ideal case (i.e., no activity corrections, no aqueous complexation). Modern hydrochemistry software does not adhere to those restrictions; they perform activity corrections per se. In this respect, they are able to predict the relationship between pH and a given CT for real systems more accurately.



numerical-model predictions (dots) using PhreeqC [11]


4. Beyond Ordinary Acids
4.1. Zwitterionic Acids
4.1.1. Zwitterions and Amino Acids

Amino acids are the best-known examples of zwitterions. 

The NH2 group is the stronger base, and so it picks up H+ from the COOH group to form a zwitterion (i.e., the amine group deprotonates the carboxylic acid):


Unlike amphoteric compounds, which can only form either a cationic or an anionic species, a zwitterion has both ionic states simultaneously.

The only difference is the offset Z = 1, where Z represents the positive charge of the highest protonated species (which equals the number of amine groups in the molecule). Ordinary acids have Z = 0. The offset determines the individual charge of species j: zj = Z − j. It confirms the statement that the offset Z equals the charge of the highest protonated species (j = 0): Z = z0.


Table 10. The three species of an ordinary diprotic acid vs. the simplest zwitterion.
|      | Diprotic Acid (Z = 0) |           | Zwitterion (Z = 1) |           |                     |
| [0]: | [H2A]                 | (neutral) | [H2A+]             | (cation)  | highest protonation |
| [1]: | [HA−]                 | (anion)   | [HA]               | (neutral) |                     |
| [2]: | [A−2]                 | (anion)   | [A−]               | (anion)   | fully deprotonated  |


Z is the positive charge of the highest protonated species.

Thus, an extension of the acid–base model to zwitterions requires a redefinition of the charge-balance equation. 

4.1.4. Glycine (Z = 1) vs. Carbonic Acid (Z = 0)

4.1.5. Polyprotic Zwitterions (N = 2 to 6)


Table 12. Acidity constants for carbonic acid and zwitterionic acids (the pK values for EDTA are taken from [5]; they differ slightly from those in [17]).
| Acid          | N | Z | pK1  | pK2   | pK3   | pK4   | pK5   | pK6   | [j = 0] | [j = Z] | [j = N] |
| carbonic acid | 2 | 0 | 6.35 | 11.33 |       |       |       |       | H2A     | H2A     | A−2     |
| glycine       | 2 | 1 | 2.35 | 9.778 |       |       |       |       | H2A+    | HA      | A−1     |
| glutamic acid | 3 | 1 | 2.16 | 4.30  | 9.96  |       |       |       | H3A+    | H2A     | A−2     |
| NTA           | 4 | 1 | 1.0  | 2.0   | 2.942 | 10.28 |       |       | H4A+    | H3A     | A−3     |
| EDTA          | 6 | 2 | 0    | 1.5   | 2.16  | 3.119 | 6.281 | 10.94 | H6A+2   | H4A     | A−4     |

EDTA looks like a good buffer, but is also a strong chelator as far as I remember.

the pK values for EDTA are taken from [5]; they differ slightly from those in [17]

4.1.6. EDTA

4.1.8. Isoionic vs. Isoelectric Points
The isoionic point is the pH of the pure, neutral polyprotic acid (i.e., when the neutral zwitterion is dissolved in water). The isoelectric point pI is the pH at which the average charge zav of the polyprotic acid is zero (the net charge of the solution is always zero):
isoionic point: pH0 	(= pH of 2-component system “acid + H2O”)	
isoelectric point: pI = pH at which zav = 0	(= pH of 1-component system “acid”)


4.2. Surface Complexation
4.2.1. Definition


5. Summary



Polyprotic acids in the general form HNA+Z include ordinary acids as a special case (Z = 0). They are specified by N acidity constants: K1, K2, … KN. The acid–base system is then characterized by:
(normalized) buffercapacity:(normalized) bufferintensity:1st derivative of β:n(x)=(Y1−Z)+wCTβ(x)≡dnd pH=(ln10) (Y2−Y21+w+2xCT)dβd pH=(ln10)2 (Y3−3Y1Y2+2Y31+wCT)(147)(148)(149)

The function n(x) has different meanings/names: (i) equivalent fraction (n = CB/CT), (ii) titration function/curve and (iii) normalized buffer capacity.


 As sketched in Figure 44, there are three mathematical equivalent representations of the N-protic acid–base system (all carrying the same information content): (i) the algebraic set of N + 3 equations, (ii) the equivalent-fraction formula as defined in Equation (41) or Equation (147), and (iii) the polynomial of degree N + 2 in Equation (44).


Final Remark. The mathematical framework is based on three assumptions: (i) activities are replaced by concentrations, (ii) no aqueous complex formation, and (iii) no density effects (molality = molarity).



Appendix B. Activity Models
Appendix B.1. Activity vs. Concentration

Ions in solution interact with each other and with H2O molecules. In this way, ions behave chemically like they are less concentrated than they actually are (or measured). This effective concentration, which is available for reactions, is called activity:
activity = effective concentration ≤ real concentration 

 ionic strength:
I=12 ∑j z2j [ j ]
(A3)


Appendix B.2. Activity Corrections

For the calculation of the activity correction γ or lg γ, several semi-empirical approaches are available (each with its own validity range defined by the ionic strength):
Debye–Hückel (DH):Extended DH:Davies:Truesdell–Jones:lgγj=−Az2jI√lgγj=−Az2j (I√1+BαjI√)lgγj=−Az2j (I√1+I√−0.3⋅I)lgγj=−Az2j (I√1+Bα0jI√−bj I)(for I < 10−2.3 M)(for I < 0.1 M)(for I ≤ 0.5 M)(for I ≤ 0.5 M)(A4)(A5)(A6)(A7)


For water at 25 °C, we have (with ε = εrε0 = 78.54·8.854·10−12 J−1 C2 m−1):
A = 1.82·106 (εT)−3/2 = 0.5085 M−1/2    and   B = 3.29 nm−1 M−1/2



Appendix C.2. pH Derivatives



## Notes

K_a is based on activities (an observed quantity)
Whereas mass ballance is based on concentrations (nothing disappears, but is just converted).

Remember $x$ is {H^+}, so _activity_ of oxonium - not concentration.

See eg (27)-(32) (summarised above (33)): Equations with K are activityies, those with C are concentrations.
nOte also the name of he "K-equations": mass-action laws, vs mass ballance and charge ballance laws.

Note the  comment above Figure 7 about the relation between H2CO3, NaHCO3 and Na2CO3.

Remember, that he is not taking dilution into account, but still: the high-CT limit, n = Y1

Equation (55) give the good buffer pHs where the titation curve is flat.

Figure 24 implicity has pKa values og HCl, H2SO4, HNO3


"During titration, a titrant is added to the analyte to reach the target pH"

Glycine is probably a good buffer. "Glycine buffer". fig 37 (good at low or high pH)




## Things I do not (yet) understand

### C_T
Note: The total concentration CT = [HNA]T should not be confused with the molar concentration of the undissociated species [HNA].

CT≡[HNA]T=∑j=0N[j]=[0]+[1]+…+[N]     (mass balance)
(4)


Why not?

### Figure 22

How can a probability density function (f0) be negative?

## TODO

* [ ] Download and read [Agustin G. Asuero, Tadeusz Michałowski: Comprehensive Formulation of Titration Curves for Complex Acid-Base Systems and Its Analytical Implications (2011)](https://www.tandfonline.com/doi/full/10.1080/10408347.2011.559440) (paywalled)

* Read [A. S. A. Khan: A Simple Method for Analysis of Titration Curves of Polyprotic Acids (2015)](http://202.83.167.189/index.php/Nucleus/article/view/675)
*  Agustin G. Asuero & Tadeusz Michałowski (2011) Comprehensive Formulation of Titration Curves for Complex Acid-Base Systems and Its Analytical Implications, Critical Reviews in Analytical Chemistry, 41:2, 151-187, DOI: 10.1080/10408347.2011.559440 https://www.tandfonline.com/doi/full/10.1080/10408347.2011.559440  (paywalled)

* Agustin G. Asuero (2007) Buffer Capacity of a Polyprotic Acid: First Derivative of the Buffer Capacity and pK a Values of Single and Overlapping Equilibria, Critical Reviews in Analytical Chemistry, 37:4, 269-301, DOI: 10.1080/10408340701266238  https://www.tandfonline.com/doi/abs/10.1080/10408340701266238 (paywalled)

*     D. Whitney King  and Dana R. Kester : A general approach for calculating polyprotic acid speciation and buffer capacity (1990) https://pubs.acs.org/doi/10.1021/ed067p932 (paywalled)

* Look at the Gibbs energy based methods: [12, 13]. See 1.1

* Derive (17)

* Reproduce plots in Figure 3

* Derive (41); the essencial equation

* Do some examples with (55) to get good buffer pHs (see table 3 for the easy parts)

* Show that kurtosis of normal distribution is 3 (just above 2.5.5)

* Look at PHREEQC https://www.usgs.gov/software/phreeqc-version-3
  Linux (any processor): phreeqc-3.7.3-15968.tar.gz [12M] - Source, configure, database files, examples, PDF documentation
  http://water.usgs.gov/water-resources/software/PHREEQC/phreeqc-3.7.3-15968.tar.gz
  https://www.phreeqpy.com/

# More directly on buffers

## How pKa values depend on temperature, pressure and ionic strength
Buffer solutions in drug formulation and processing: How pKa values depend on temperature, pressure and ionic strength  https://www.sciencedirect.com/science/article/abs/pii/S0378517319301425 paywalled bu available here:
https://rucforsk.ruc.dk/ws/portalfiles/portal/64240902/Buffer_Solutions_in_Drug_Formulation_and_Processing_2nd_revision.pdf


## Text book version
https://chem.libretexts.org/Bookshelves/Physical_and_Theoretical_Chemistry_Textbook_Maps/Supplemental_Modules_(Physical_and_Theoretical_Chemistry)/Acids_and_Bases/Monoprotic_Versus_Polyprotic_Acids_And_Bases/Calculating_the_pH_of_the_Solution_of_a_Polyprotic_Base%2F%2FAcid

## Lecture notes

https://christou.chem.ufl.edu/wp-content/uploads/sites/62/2017/01/Chapter-18-Acids-and-Bases-Week-2.pdf

## Catherine Drennan lectures

https://ocw.mit.edu/courses/5-111sc-principles-of-chemical-science-fall-2014/

* [22. Acid-Base Equilibrium: Salt Solutions and Buffers](https://www.youtube.com/watch?v=caonmXHGB60)
* [23. Acid-Base Titrations Part I](https://www.youtube.com/watch?v=pIwp65fPyYU)
* [24. Acid-Base Titrations Part II](https://www.youtube.com/watch?v=Om_5b29d_9g&t=708s)
