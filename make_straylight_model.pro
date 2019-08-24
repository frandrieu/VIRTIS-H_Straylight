pro make_straylight_model


straylight_spectrum_name='/Users/fandrieu/Documents/Programmes/IDL_sav_files/straylight_spectrum_model_backup.sav'
restore, '/Users/fandrieu/Documents/Programmes/IDL_sav_files/straylight_spectrum_model.sav'
straylight_spectrum_model(where(straylight_spectrum_model le 0.))=0.
poscut=[80,345,570,780,1025,1230,1450,1660]

even=fltarr(216,8)
odd=fltarr(216,8)
for i=0,7 do even[*,i]=straylight_spectrum_model[i*432:(i+1)*432-1:2]
for i=0,7 do odd[*,i]=straylight_spectrum_model[i*432+1:(i+1)*432-1:2]

evenmod=fltarr(216)
oddmod=fltarr(216)
evenmod[*]=0.
oddmod[*]=0.
straylight_spectrum_mod=fltarr(3456)

for i=0,7 do begin
  evev=even[*, i]
  evenmod=smooth(evev, 20, /edge_truncate)
  odod=odd[*, i]
  oddmod=smooth(odod, 20, /edge_truncate)
  straylight_spectrum_mod[i*432:(i+1)*432-1:2]=evenmod-oddmod[poscut[i]-i*216]
  straylight_spectrum_mod[i*432+1:(i+1)*432-1:2]=oddmod-oddmod[poscut[i]-i*216]
  straylight_spectrum_mod[i*432:2*poscut[i]]=0.
endfor

STRAYLIGHT_SPECTRUM_MODEL=STRAYLIGHT_SPECTRUM_MOD

save, STRAYLIGHT_SPECTRUM_MEASURE, STRAYLIGHT_SPECTRUM_MODEL, filename=straylight_spectrum_name

end