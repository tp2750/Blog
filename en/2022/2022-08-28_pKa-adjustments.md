# Adjusting pKa values
TP, 2022-08-28

# Background

In 2022-08-28_more-buffers, I found that I can reproduce [textbook](https://microscopy.berkeley.edu/buffers-and-buffer-tables) pH of phosphare buffer by using corrected pKa values from [Clymer / Barton]( https://www.egr.msu.edu/~scb-group-web/buffers/buffers.html).

Here I look a bit closer on this, with the hope to also include temprerature effects and CO2 from the atmosphere.

# References

I use the following references:

* [Clymer / Barton]( https://www.egr.msu.edu/~scb-group-web/buffers/buffers.html) or actually the source code: :https://www.egr.msu.edu/~scb-group-web/buffers/buffers.js
* [Wikipedia](https://en.wikipedia.org/wiki/Debye%E2%80%93H%C3%BCckel_equation#Extensions_of_the_theory)
* [Kalka  Appendix B.2](https://www.mdpi.com/2624-8549/3/2/34/htm)
* [Reijenga 2013](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3747999/)
* [Samuelsen 2019](https://rucforsk.ruc.dk/ws/portalfiles/portal/64240902/Buffer_Solutions_in_Drug_Formulation_and_Processing_2nd_revision.pdf)
* [Kennedy 1990](https://iubmb.onlinelibrary.wiley.com/doi/pdf/10.1016/0307-4412%2890%2990017-I)
* http://websites.umich.edu/~chem241/lecture11final.pdf
* [REACH](http://www.reachdevices.com/Protein/pKa_explanation.html) "estimate pKa values of each buffer at temperatures form 3oC (cold room) to 37oC, and concentrations from 1mM up to 500mM."

# [Clymer / Barton]( https://www.egr.msu.edu/~scb-group-web/buffers/buffers.html)

The function they use is:

```js
function ioncorrection(pKa,con,za,a) {
	cona = con/2;
	conb = con/2;
	zb = za-1;
	ccat = -1*za*cona - zb*conb;
	Ic = 0.5*(ccat+(za*za)*cona+((zb*zb)*conb));
	Abig = 0.509;
	B = 0.33;
	m = Abig*Math.sqrt(Ic)/(1+B*a*Math.sqrt(Ic));
	
	dpKa= -1*m*(zb*zb-za*za);
	pKanew = pKa+dpKa;

	return pKanew;
}
```
where 

* pKa is a pKa value, 
* za the charge at this pH (0 for the lowest pKa value, then -1, -2, ...),
* con is the concentration of the buffer,
* a is a fixed size-parameter of 5

Writing this out, we get:

pKa_new = pKa + dpKa

```
Ic = 0.5*(ccat+(za*za)*cona+((zb*zb)*conb)) 
   = 0.5*(-1*za*con/2 - (za-1)*con/2 + za^2*con/2 + (za-1)^2*con/2
   = 0.25*con*(-za - (za-1) + za^2 + (za-1)^2)
   = 0.25*con*(1 - 2*za + za^2 + (za-1)^2) 
   = 0.25*con*2*(za-1)^2
   = 0.5*con*(za-1)^2
   
m = A*sqrt(Ic)/(1+B*a*sqrt(Ic))

dpKa = -m*((za-1)^2 - za^2)
     = -m*(z1^2 - 2za + 1 - za^2)
	 = -m(1-2za)
```

```julia
julia> pHcalc.ioncorrection([2.148, 7.198, 12.375], M=.1, size=5.)
3-element Vector{Float64}:
  2.0648590825585424
  6.805057825843171
 11.56467418465781
```

We tested that this simplification gives the same on the phosphoric acid case.

# Samuelsen

## Temperature

(4): DG = DH - T DS
(5): DG = -RTln(Ka)

Note, Ka = [H+][A-]/[HA], so it actually has a unit of concentration.
Not clear how to take log of that.

van't Hoff:
(7): d ln(Ka)/dT = DH/RT²

or

(8): ln(K1/K2) = -DH/R (1/T1 - 1/T2)

DH also depends on T and is related to heat capacity:

(9): DCp = dDh/dT

So if we know K1, DH1 and T1 and DCp (which presumably does not depend on T), we can compute 

(10): ln(K2) = (DH1 - T1 DCp)/R *(1/T1 - 1/T2) + DCp/R * ln(T2/T1) + ln(K1)

Note that the influence of ionic strength is (next section) is also temperature dependent.

## Ionic strength

Ka is actually in terms of activities, which are concentrations scaled by \gamma

Se quotes Debey-Hückel:

log(\gamma) = -z^2*A*sqrt(I)

where A = 1.824E6*(εT)−3/2 

so it also depends on temperature, and the dielectric constant of the solvent (water, I guess).

Se also quotes a corrected version looking like what is used by Clyber-Barton:

(18): log(\gamma) = - (Az^2*sqrt(I))(1+ B*a*sqrt(I)) + C*I

where a is a fitted size parameter.

Note, that she mentions that eg TRIS does not follow this formula, as in reality pKa of TRIS increases with ionic strength, where this formula says it decreases. we could model this by adding a ion-strength correction factor which is 1 if the formula holds, but could be -1.75 for tris to change the computed delta for M=2 from -0.2 to +.35

