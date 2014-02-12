function escprob, beta, P

n0 = p[0]
sigma = p[1]

eprob = exp(-n0*exp(-beta*beta/sigma/sigma))*cos(beta)

return, eprob
end

