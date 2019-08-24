pro visu_strayligh_model

restore, '/Users/fandrieu/Documents/Programmes/IDL_sav_files/list_straylight_robust_models_fullpath_neg.sav'

for i=0,n_elements(list_straylight_models_fullpath_neg)-1 do begin
  restore,list_straylight_models_fullpath_neg[i]
  p=plot_virtish(straylight_spectrum_model_neg)
  p.close
  
endfor

end