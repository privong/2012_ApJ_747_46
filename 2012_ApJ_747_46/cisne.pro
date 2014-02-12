pro cisne,path,file,SUFFIX=suffix,PARAMS=params,PREFIX=prefix,SOURCE=source,MAXITER=maxiter,INCL=incl

; path: array of paths to the model files
; model: array of file names comtaining information about the file
; PARAMS: initial parameters (these are all set to 1 if nothing specified)
; PREFIX: differentiate between different subsets (0 - AGN, 1 - no AGN)


; set up common variables
COMMON cisne,opacity,m1flux,m2flux,m1now,m2now,n_models,excorr

resolve_routine,'cisne_model',/IS_FUNCTION

n_models=size(path,/N_ELEMENTS)
MAXITER=1000

DATADIR='/home/grads/gcp8y/LMC/data/'
;set some fluxes yo
opacity=0
m1flux=0
m2flux=0

; fit models

; 1 - load a file with the lists of model types
; 2 - iterate through the combinations
; 3 - generate a .pro file for the current combination
; 4 - fit that combination to the data
; 5 - write the resulting parameters to a file for later evaluation

if (not(keyword_set(PREFIX))) then prefix=0

if (not(keyword_set(SOURCE))) then source='CygA'

if (not(keyword_set(MAXITER))) then maxiter=100

if (not(keyword_set(INCL))) then incl=90

; last three param values are for synchrotron:
; 2nd to last: spectral index (0.18 for 3C405)
; last: high frequency cutoff (initially 0.5 (x10^13 Hz)

if (not(keyword_set(PARAMS))) then begin
  params=findgen(n_models+2) ; +2 for synchrotron options
  params[*]=1
  params[n_models]=0.18
  params[n_models+1]=0.5
endif

; here we're assuming the TORUS/AGN model will be read first
print,'Reading first models...'
;if (strmatch(path[0],'clumpy',/FOLD_CASE)) then begin
  readcol,file[0],m1list,format='(a)'
;endif else if (strmatch(path[0],'agnx',/FOLD_CASE)) then begin
  readcol,file[0],m1list,format='(a)'
;endif

; starburst model goes second
print,'Reading second models...'
readcol,file[1],m2list,format='(a)'

;figure out how much of each we've got
n_m1=n_elements(m1list)
n_m2=n_elements(m2list)

; make sure the user knows what (s)he's getting into:
print,'Preparing to fit ',n_m1*n_m2,' combinations of models.'
print,'Are you sure? CTRL+C if this is too many...'
pause

;readcol,'/home/gcp1035/idl/testdata.dat',wave,flux,/SILENT
;error=0.1*flux

;start by loading the data
readcol,DATADIR+'IRS-20_arcsec-cleaned.dat',irswave,irsflux,/SILENT
irserr=0.1*irsflux
readcol,DATADIR+'MIPS.dat',mipswave,mipsflux,mipserr,/SILENT
readcol,DATADIR+'IRAC.dat',iracwave,iracflux,iracerr,/SILENT
;readcol,DATADIR+'Kband.dat',kwave,kflux,/SILENT
;kerr=0.1*kflux
readcol,DATADIR+'RADIO.dat',rwave,rflux,rerr,/SILENT
readcol,DATADIR+'SCUBA.dat',scubawave,scubaflux,scubaerr,/SILENT
;readcol,DATADIR+'2MASS.dat',masswave,massflux,masserr,/SILENT

;combine the data
;flux=[irsflux,mipsflux,iracflux,kflux,rflux,scubaflux]
;wave=[irswave,mipswave,iracwave,kwave,rwave,scubawave]
;error=[irserr,mipserr,iracerr,kerr,rerr,scubaerr]

; with 2MASS
;flux=[irsflux,mipsflux,iracflux,rflux,scubaflux,massflux]
;wave=[irswave,mipswave,iracwave,rwave,scubawave,masswave]
;error=[irserr,mipserr,iracerr,rerr,scubaerr,masserr]

flux=[irsflux,mipsflux,iracflux,rflux,scubaflux]
wave=[irswave,mipswave,iracwave,rwave,scubawave]
error=[irserr,mipserr,iracerr,rerr,scubaerr]

; sort the data
freq=2.99792458e2/wave
sortIndex=sort(freq[*])
freq[*]=freq[sortIndex]
flux[*]=flux[sortIndex]
error[*]=error[sortIndex]

; now that we're done loading the data, load the opacity curve
opacwave=[1.05006, 1.16717, 1.29724, 1.42499, 1.54701, 1.82308, 1.97926, 2.30535, 2.50266, 2.74902, 2.98441, 3.27831, 3.51752, 3.86405, 4.8873 , 5.43254, 6.11053, 6.79273, 7.46437, 7.73513, 7.82954, 8.11767, 8.31854, 8.42221, 8.93816, 9.04725, 9.26607, 9.49019, 10.3039, 11.7164, 12.2771, 12.7137, 13.3221, 13.9596, 14.8078, 15.5266, 16.2808, 16.8714, 17.6903, 19.2134, 21.3562, 23.4601, 25.7704, 28.9845, 32.2181, 35.8137, 39.8092, 44.2488, 49.1852, 54.6705, 60.0543, 65.9708, 72.4674, 80.5491, 87.4431, 96.0544, 105.514, 115.904, 127.318, 139.862, 153.629, 166.784, 183.202, 201.244, 218.476, 239.991, 263.615, 286.187, 314.371, 345.329, 374.899, 411.803, 447.065, 491.091, 539.453, 585.644, 643.294, 698.378, 767.153, 842.7  , 914.858]
opac=[1.911166981, 1.601806078, 1.304993679, 1.091095376, 0.923032172, 0.633082476, 0.54321312, 0.387817034, 0.323463435, 0.266638657, 0.225568873, 0.188596869, 0.163736951, 0.13885457, 0.092612485, 0.078729839, 0.068049089, 0.059512155, 0.057336654, 0.062884787, 0.071616979, 0.095791896, 0.133369558, 0.167736259, 0.201277444, 0.229227666, 0.258010138, 0.290407252, 0.256351479, 0.153635076, 0.129025584, 0.108094418, 0.090779232, 0.076238574, 0.076085577, 0.082473304, 0.090674291, 0.099448179, 0.107798059, 0.108106322, 0.090606943, 0.076838121, 0.064243861, 0.053976091, 0.045884767, 0.039563631, 0.033632929, 0.028188787, 0.023963306, 0.020084506, 0.016792469, 0.014240573, 0.011906485, 0.009979205, 0.008323275, 0.006959046, 0.005818403, 0.004864767, 0.004067406, 0.003449271, 0.002843337, 0.002405381, 0.001982811, 0.001657813, 0.001402461, 0.001172594, 0.000966599, 0.000817717, 0.000683686, 0.000571629, 0.000483581, 0.000398627, 0.000337226, 0.000281954, 0.000235741, 0.00019943, 0.000164395, 0.000139073, 0.000116278, 9.72197E-05, 8.22451E-05]
opacnu=2.99792458e2/opacwave ; convert to frequency
sortIndex=sort(opacnu[*]) ; sort by frequency
opacnu[*]=opacnu[sortIndex]
opac[*]=opac[sortIndex]
; interpolate the tau to the available data
dropac=interpol(indgen(n_elements(opac)),opacnu,freq)
opacity=interpolate(opac,dropac)

; load the galactic extinction curve to apply to the model sum
;readcol,DATADIR+'A.dat',awave,amag,/SILENT
;afreq=2.99792458e2/awave
;acorr=10^(amag/2.5)
;sortIndex=sort(afreq[*])
;afreq[*]=afreq[sortIndex]
;acorr[*]=acorr[sortIndex]
;dracorr=interpol(indgen(n_elements(acorr)),afreq,freq)
;excorr=interpolate(acorr,dracorr)

fitrecfile=strtrim(string(prefix),1)+'fitrecords.dat'
openu,outfile,fitrecfile,/APPEND,/GET_LUN,WIDTH=500

;DO THE PARINFO values here
parinfo=replicate({value:1.D, fixed:0, limited:[1,0], limits:[1.e-9,0]}, n_models+2)
parinfo[*].value=params
parinfo[2].limited[1]=1
parinfo[2].limits[0]=0.001 ; nu_cutoff shouldn't be until somewhere after the SCUBA points
parinfo[2].limits[1]=60. ; nu_cutoff can't exceed the IR data
parinfo[3].limits[0]=0.

; don't vary the break/cutoff frequency if it isn't in the models
;parinfo[2].fixed=1
;parinfo[2].value=1
;params[2]=1

;reset the parinfo to limit the synchrotron cutoff to before the MIPS 160 point
;parinfo[2].limits[0]=0.1
;parinfo[2].limits[1]=1.

; constant scaling of the Starburst Models
parinfo[1].fixed=1
parinfo[1].value=0.047258979
params[1]=0.047258979

; no starburst model
;parinfo[1].fixed=1
;parinfo[1].value=1.e-9
;params[1]=1.e-9

; do a fixed value for the opacity
;parinfo[3].fixed=1
;parinfo[3].value=12.963  ; this puts tau~5.18 at K band (corresponds to the observed A_K~5.6)
;params[3]=12.963

; no radio opacity
;parinfo[3].fixed=1
;parinfo[3].value=0
;params[3]=0

; i guess we're continuing! start rockin' the combos
; iterate over CLUMPY models
for i=0,n_m1-1 do begin

  ; sanitize the names: replace '-' with '_'
  ;ctemp=strjoin(strsplit(clumpylist[i],'-',/regex,/extract,/preserve_null),'_')
  ;m1now=strjoin(strsplit(ctemp,'\+',/regex,/extract,/preserve_null),'_')
  m1now=m1list[i]

  ; load the model data from the file and get to it!
  if (strmatch(path[0],'*clumpy*',/FOLD_CASE)) then begin
    ;CLUMPY model
    rdfloat,path[0]+m1now+suffix[0],m1wave,i0,i10,i20,i30,i40,i50,i60,i70,i80,i90,/SILENT,SKIPLINE=53
    ; select an inclination 
    if (incl eq 90) then m1flux=i90 $
    else if (incl eq 80) then m1flux=i80 $
    else if (incl eq 70) then m1flux=i70 $
    else if (incl eq 60) then m1flux=i60 $
    else if (incl eq 50) then m1flux=i50
    ; convert to frequency
    m1freq=2.99792458e2/m1wave  ;m1freq is now in THz
    ;convert CLUMPY model to F_nu
    m1flux=m1flux/(1.e12*m1freq)
    ; renomralize clumpy up
    m1flux=m1flux*1.e12
  endif else if (strmatch(path[1],'*SB*',/FOLD_CASE)) then begin
    ; Siebenmorgen AGN model
    rdfloat,path[0]+m1now+suffix[0],m1wave,m1flux
    m1freq=2.99792458e2/m1wave
  endif else print,'ERROR! Model unknown!!!'

  ; interpolate to grid
  dm1freq=interpol(indgen(n_elements(m1flux)),m1freq,freq)
  m1flux=interpolate(m1flux,dm1freq)
  ; normalize model to a peak of 1
 ; m1max=max(m1flux)
 ; m1flux[*]=m1flux[*]/m1max

  print,'Fitting AGN model #',i+1,' (',m1now,') of ',n_m1,' with ',n_m2,' starburst models. At inclination i=',incl

  ;iterate through all the SB models
  for j=0,n_m2-1 do begin

    m2now=m2list[j]

    ; load the model data
    rdfloat,path[1]+m2now+suffix[1],m2wave,m2flux,/SILENT,SKIPLINE=3
    m2freq=2.99792458e2/m2wave
    ;m2flux=m2flux/10000.
    ;now interpolate it
    dm2freq=interpol(indgen(n_elements(m2flux)),m2freq,freq)
    m2flux=interpolate(m2flux,dm2freq)
    ; normalize model to a peak of 1
;    m2max=max(m2flux)
;    m2flux[*]=m2flux[*]/m2max

    ;print,'Fitting CLUMPY model #',i+1,' (',m1now,') of ',n_m1,' and SB model #',j+1,' of ',n_m2,' (',m2now,')'


    chi=0

    newpar=mpfitfun('cisne_model',freq,flux,error,params,MAXITER=maxiter,PARINFO=parinfo,BESTNORM=chi,DOF=dof,/QUIET)

    ; now calculate the reduced chi-squared and write the results to a file
    redchi=chi/dof

    if (redchi le 4.) then begin
      printf,outfile,source,' ',strtrim(string(systime(/JULIAN)),1),' ',m1now,' ',' ',m2now,' ',incl,' ',newpar,' ',strtrim(string(redchi),1)
    endif
  endfor

endfor

close,outfile

print,"finished.. DONE. All of them!"

end

; CLUMPY (no AGN) and Siebenmorgen Starburst Models (sampled grids)
; cisne,['/home/gcp1035/Models/ClumpyTorusGrid/','/home/gcp1035/Models/Siebenmorgen/SBgrid/'],['clumpy.txt','s_gridlist-small.txt'],PREFIX=0,MAXITER=1000,SUFFIX=['.txt','.plot'],INCL=80

; CLUMPY (with AGN) and Siebenmorgen Starburst Models (sampled grids)
; cisne,['/home/gcp1035/Models/ClumpyTorusGrid/','/home/gcp1035/Models/Siebenmorgen/SBgrid/'],['clumpy-agn.txt','s_gridlist-small.txt'],PREFIX=1,MAXITER=1000,SUFFIX=['.txt','.plot'],INCL=80

; Siebenmorgen AGN and Starburst Models (sampled grids)
; cisne,['/home/gcp1035/Models/Siebenmorgen/AGN/','/home/gcp1035/Models/Siebenmorgen/SBgrid/'],['s_agn.txt','s_gridlist-small.txt'],PREFIX=2,MAXITER=1000,SUFFIX=['.plot','.plot']


; new clumpy models
;cisne,['/home/gcp1035/Models/clumpymodels/','/home/gcp1035/Models/Siebenmorgen/SBgrid/'],['cnew_gridlist.txt','snew_gridlist.txt'],PREFIX=0,MAXITER=1000,SUFFIX=['.txt','.plot'],INCL=80
;cisne,['/home/gcp1035/Models/clumpymodels/','/home/gcp1035/Models/Siebenmorgen/SBgrid/'],['cnew_gridlist.txt','snew_gridlist.txt'],PREFIX=1,MAXITER=1000,SUFFIX=['.txt','.plot'],INCL=70
;cisne,['/home/gcp1035/Models/clumpymodels/','/home/gcp1035/Models/Siebenmorgen/SBgrid/'],['cnew_gridlist.txt','snew_gridlist.txt'],PREFIX=2,MAXITER=1000,SUFFIX=['.txt','.plot'],INCL=50

; fine grid clumpy models
;cisne,['/home/gcp1035/Models/clumpymodels/fine/','/home/gcp1035/Models/Siebenmorgen/SBgrid/'],['clumpy_new-fine.txt','snew_gridlist.txt'],PREFIX=0,MAXITER=1000,SUFFIX=['.txt','.plot'],INCL=80

; clumpy path on callahan
;cisne,['/net/home/gcp8y/astro/Models/Clumpy-cfrac/clumpymodels/','/net/home/gcp8y/astro/Models/SBgrid/'],['/home/grads/gcp8y/LMC/idl/clumpy-cfrac.txt','/home/grads/gcp8y/LMC/idl/s_gridlist.txt'],PREFIX=0,MAXITER=1000,SUFFIX=['.txt','.plot'],INCL=80
