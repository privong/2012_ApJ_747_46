function cisne_model,X,P

COMMON cisne

; P[0] - scaling for model 1
; P[1] - scaling for model 2
; P[2] - frequency of the powerlaw break (or exponential cutoff)
; P[3] - scaling of the opacity for the synchrotron

; this function just returns model combinations based on the parameters
m1=P[0]*m1flux
m2=0
if (m2now ne 'null') then begin
  m2=P[1]*m2flux
endif

; do self-absorbed synchrotron from Polletta etal 2000
;pwmodelflux=(1.e-4/X)^(0.18)  ; initial synchrotron powerlaw
;pwmodelflux=pwmodelflux*(1-exp(-((1.e-4/X)^(-0.18-2)))) ; self-absorbed spectrum (irrelevant here)
;pwmodelflux=pwmodelflux*(exp(-(X/P[2])))   ; exponential cutoff
;absorption through a dust screen
;pwmodelflux=pwmodelflux*exp(-1.*opacity*P[3])

; unmodified synchrotron with only dust extinction
;pwmodelflux=(1.e-4/X)^(0.18) ; initial synchrotron powerlaw
;absorption through a dust screen
;pwmodelflux=pwmodelflux*exp(-1.*opacity*P[3])



; Broken powerlaw (break frequency is the free parameter)
pwmodelflux=(1.e-4/X)^(0.18) ;initial synchrotron powerlaw
;pwmodelflux[where(X gt P[2])]=(1.e-4/P[2])^(0.18)*(P[2]/X[where(X gt P[2])])^(0.68)  ; 'case III' (aging + continuous injection)
pwmodelflux[where(X gt P[2])]=(1.e-4/P[2])^(0.18)*(P[2]/X[where(X gt P[2])])^(1.24)  ; 'case II' (aging)
;absorption through a dust screen
pwmodelflux=pwmodelflux*exp(-1.*opacity*P[3])

; scale powerlaw to the 3370 micron value
scale=pwmodelflux[where(X eq 2.99792458e2/3370.)]

if (scale) then begin
  pwmodelflux=pwmodelflux/scale[0]
  pwmodelflux=pwmodelflux*0.7
endif else begin
  pwmodelflux=pwmodelflux*0.7
endelse

; set the powerlaw break frequency to zero to ensure it propely is zeroed out
; if the powerlaw break frequency is zero, then exclude the powerlaw from fits
if (P[2] eq 0) then begin
  modflux=m1+m2
endif else begin  
  modflux=m1+m2+pwmodelflux
endelse

; now correct for galactic absorption
;modflux=modflux*excorr

return,modflux

end
