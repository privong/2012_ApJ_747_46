function synchrotron,X,P

; P[0] = optically thick spectral index (alpha_1)
; P[1] = optically thin spectral index (alpha_2)
; P[2] = freq when tau=1 (nu_t)
; P[3] = cutoff in e- particle distribution (nu_cutoff)
; P[4] = scaling at 3370 microns (89 GHz)

pwmodelflux=(1e-5/X)^(P[0])
pwmodelflux=pwmodelflux*(1-exp(-(1e-5/X)^(-P[1]-P[0])))
pwmodelflux=pwmodelflux*exp(-(X/100.))

scale=pwmodelflux[where(X eq 2.99792458e2/3370.)]

if (scale) then begin
  pwmodelflux=pwmodelflux/scale[0]
  pwmodelflux=pwmodelflux*P[4]
endif

return,pwmodelflux

end
