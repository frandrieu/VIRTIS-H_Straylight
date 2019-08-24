pro build_straylight_model, model, degree
  
  restore, '/Users/fandrieu/Documents/Programmes/IDL_sav_files/STRAYLIGHT_IN_ALL_BKP_CUBES_SPECTRA.sav'
  gluvis=struct_out.MEDIAN_STRAYLIGHT[60:207,*]
  memememe=median(gluvis, dimension=1)
  for i=0,7 do memememe[i*432:i*432+240]=0.
  even=fltarr(216,8)
  odd=fltarr(216,8)
  for i=0,7 do even[*,i]=memememe[i*432:(i+1)*432-1:2]
  for i=0,7 do odd[*,i]=memememe[i*432+1:(i+1)*432-1:2]
  evenmod=fltarr(216)
  oddmod=fltarr(216)
  evenmod[*]=0.
  oddmod[*]=0.
  straylight_spectrum_mod=fltarr(3456)
  for i=0,7 do begin
    evev=even[119:215, i]
    evenfit=robust_poly_fit(indgen(n_elements(evev))*1., evev, degree, yfit)
    evenmod[119:215]=yfit
    odod=odd[119:215, i]
    oddfit=robust_poly_fit(indgen(n_elements(odod))*1., odod, degree, yfit)
    oddmod[119:215]=yfit
    straylight_spectrum_mod[i*432:(i+1)*432-1:2]=evenmod
    straylight_spectrum_mod[i*432+1:(i+1)*432-1:2]=oddmod
  endfor

  model={straylight_measure:memememe, straylight_model:straylight_spectrum_mod}
return
end