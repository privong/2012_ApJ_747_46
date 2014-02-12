function coverfrac, n0, sigma
; needs qpint1d from the Markwardt library
cfrac = 1.0 - qpint1d("escprob", 0, !PI/2.0, [n0, sigma*!pi/180.])

return, cfrac
end
