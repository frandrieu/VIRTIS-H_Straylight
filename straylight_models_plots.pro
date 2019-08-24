maindir='/Users/fandrieu/Documents/Programmes/IDL_sav_files'
restore, strcompress(maindir+'/list_straylight_robust_models_pos.sav', /remove_all)
    restore, strcompress(maindir+'/list_straylight_robust_models_neg.sav', /remove_all)
    straylight_model_names_pos=list_straylight_robust_models
    straylight_model_names_neg=list_straylight_robust_models_neg
basename=maindir+'/straylight_spectrum_model_'
    straylight_model_chosen_pos=26
straylight_model_chosen_neg=0
endname_pos=string(straylight_model_names_pos[straylight_model_chosen_pos[0]], format='(I011)')
    endname_neg=string(straylight_model_names_neg[straylight_model_chosen_neg[0]], format='(I011)')
    straylight_spectrum_pos_name=strcompress(basename+endname_pos+'_pos.sav', /remove_all)
    straylight_spectrum_neg_name=strcompress(basename+endname_neg+'_neg.sav', /remove_all)
  restore, straylight_spectrum_pos_name
  restore, straylight_spectrum_neg_name
p=plot_virtish(straylight_spectrum_measure_pos)
p=plot_virtish(straylight_spectrum_model_pos)
p=plot_virtish(straylight_spectrum_measure_neg)
p=plot_virtish(straylight_spectrum_model_neg)