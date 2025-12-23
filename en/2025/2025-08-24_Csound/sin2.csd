<CsoundSynthesizer>
<CsOptions>
-o dac
</CsOptions>
<CsInstruments>

sr = 44100
ksmps = 64
nchnls = 2
0dbfs = 1

instr Hello
  aSine = poscil:a(0.2,400)
  outall(aSine)
endin

instr Hello2
  aSine = poscil:a(0.2,600)
  outall(aSine)
endin

</CsInstruments>
<CsScore>
i "Hello" 0 2
i "Hello2" 2 4
</CsScore>
</CsoundSynthesizer>
