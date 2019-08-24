; NAME
;   VIRTISPDS_STRAYCOR_SP
;
; PURPOSE
;   Correct the contribution from the stray light on a VH nominal mode calibrated spectrum
;   if not nominal mode VIRTIS-H calibrated data, probably badly crashes
;   
; CALLING SEQUENCE:
;   result=VIRTISPDS_STRAYCOR_NOMINAL('filename')
;
; WARNING
;   the directory 'maindir' where the empirical stray light models are stored must be manually
;   entered befor compilation
;
; INPUTS:
; SPECRUM, a calibrated VH spectrum in nominal mode
; FILENAME = Scalar string containing the name of the VHcube (used as a date in the code)
;
;
; OUTPUTS:
; result: structure containing the label and data
; For image data:
;   result.label : label of the PDS file
;   result.nimages : number of images in the file
;   result.images : a 3D array containing all the images of the file with size:
;        (nbimages,nbcolums,nbrows)
;
; For QUBE data:
;   result.label: label of the PDS file
;   result.qube_name: string array with cube name and unit (if data),
;                         or parameter names (if geometry)
;   result.qube_coeff: array providing scaling coefficient for geometry cubes (size=# of bands)
;   result.qube_dim: 3 or 2-elt array with cube dimensions
;   result.qube: data qube in the file (size=# of bands, # of lines, # of frames)
;   result. suf_name: list of HK names for H or M � these tags are only indicative, and should not
;               be used as data pointers (may change in the future; the order is permanent, though)
;   result.suf_dim: 3 or 2-elt array with suffix dimensions
;   result.suffix: suffix of the data qube, reformatted (the first dimension contains
;               a complete group of HK) Size = # of HK, # of HK structure/frame, # of frames
;
;  An HK structure (for a given spectrum) is plotted with: plot (or tvscl), result.suffix(*,n,p)
;  A given HK is plotted against time with: plot, result.suffix(m,*,*)
;  VEx H calibrated cubes & suffices are reformed to 2D arrays.
;  VEx M calibrated files suffices are reformed to 2D (1 single Scet per frame)
;
; For table data:
;   result.label : label of the PDS file
;   result.column_names : names of columns
;   result.table : a 2D array containing the table
;
; KEYWORDS:
;    SILENT = suppresses messsages.
;   
;
; MODIFICATION HISTORY: Written by François Andrieu, 04/2018





function virtispds_straycor_sp, spectrum, filename, silent=silent

  ;On_error, 2                    ;2: Return to user, 0: debug

  maindir='/Users/fandrieu/Documents/Programmes/IDL_sav_files'
  restore, strcompress(maindir+'/VIRTIS-H_overlap05_upward.sav', /remove_all)
  restore, strcompress(maindir+'/VIRTIS-H_overlap_upward.sav', /remove_all)  

  if (strmid(filename, 17,2, /reverse_offset)) ne 'T1' then begin
    print, filename, ' is not a nominal mode calibrated VIRTIS H cube'
    print, 'NO straylight was removed'
    ;cube=virtispds(filename,silent=silent,debug=debug)
    return, spectrum
  endif
  silent = keyword_set(silent)
  debug = keyword_set(debug)

  cubedate=long64(strmid(filename, 14,11, /reverse_offset))


    ; Available stray light models
    restore, strcompress(maindir+'/list_straylight_robust_models_pos.sav', /remove_all)
    restore, strcompress(maindir+'/list_straylight_robust_models_neg.sav', /remove_all)
    straylight_model_names_pos=list_straylight_robust_models
    straylight_model_names_neg=list_straylight_robust_models_neg

    ; Selection of the closest model
    basename=maindir+'/straylight_spectrum_model_'
    straylight_model_chosen_pos=where(straylight_model_names_pos-cubedate eq min(straylight_model_names_pos-cubedate))
    endname_pos=string(straylight_model_names_pos[straylight_model_chosen_pos[0]], format='(I011)')
    straylight_model_chosen_neg=where(straylight_model_names_neg-cubedate eq min(straylight_model_names_neg-cubedate))
    endname_neg=string(straylight_model_names_neg[straylight_model_chosen_neg[0]], format='(I011)')
    straylight_spectrum_pos_name=strcompress(basename+endname_pos+'_pos.sav', /remove_all)
    straylight_spectrum_neg_name=strcompress(basename+endname_neg+'_neg.sav', /remove_all)
  restore, straylight_spectrum_pos_name
  restore, straylight_spectrum_neg_name


  ;Positions where stray light can be easily identified on orders 0 to 7
  ;Used to determine the strength of stray ligth correction to apply when stray light is detected
  pos=intarr(4,8)
  ;***ORDER 0***
  pos[0,0]=230
  pos[1,0]=250
  pos[2,0]=400
  pos[3,0]=420

  ;***ORDER 1***
  pos[0,1]=665
  pos[1,1]=685
  pos[2,1]=830
  pos[3,1]=850

  ;***ORDER 2***
  pos[0,2]=1215
  pos[1,2]=1225
  pos[2,2]=1280
  pos[3,2]=1290

  ;***ORDER 3***
  pos[0,3]=1625
  pos[1,3]=1645
  pos[2,3]=1700
  pos[3,3]=1720

  ;***ORDER 4***
  pos[0,4]=2070
  pos[1,4]=2080
  pos[2,4]=2140
  pos[3,4]=2150

  ;***ORDER 5***
  pos[0,5]=2495
  pos[1,5]=2505
  pos[2,5]=2555
  pos[3,5]=2565

  ;***ORDER 6***
  pos[0,6]=2945
  pos[1,6]=2955
  pos[2,6]=3005
  pos[3,6]=3015

  ;***ORDER 7***
  pos[0,7]=3375
  pos[1,7]=3385
  pos[2,7]=3435
  pos[3,7]=3445



  
  data=spectrum

  ; identification of the stray light in the cube
  dif_straylight_pos=fltarr(8)
  dif_straylight_neg=fltarr(8)
  index_straylight=fltarr(8)
  for order_index=0,7 do begin
    dif_straylight_pos[order_index]=-median(straylight_spectrum_model_pos[pos[0,order_index]:pos[1,order_index]:2, *],dimension=1)+$
      median(straylight_spectrum_model_pos[pos[2,order_index]:pos[3,order_index]:2, *], dimension=1)
    index_straylight[order_index]=-median(data[pos[0,order_index]:pos[1,order_index]:2])+$
      median(data[pos[2,order_index]:pos[3,order_index]:2])
    dif_straylight_neg[order_index]=-median(straylight_spectrum_model_neg[pos[0,order_index]:pos[1,order_index]:2, *],dimension=1)+$
      median(straylight_spectrum_model_neg[pos[2,order_index]:pos[3,order_index]:2, *], dimension=1)
  endfor
  ;**********


  ;;;NOISE ESTIMATION;;;
  ; Hypothesis:
  ;       * the noise is uncorrelated in wavelength bins spaced two pixels apart
  ;       * the noise is Normal distributed
  ;       * for large wavelength regions, the signal over the scale of 5 or more pixels can
  ;         be approximated by a straight line
  ;
  ;       For most spectra, these conditions are met.
  ;
  ;*PROCEDURE:
  ;       This function computes the noise following the
  ;       definition set forth by the Spectral Container Working Group of ST-ECF,
  ;       MAST and CADC. ( ST-ECF Newsletter, Issue #42)
  ;

  w_over0m2=w_over0-2
  w_over0p2=w_over0+2
  w_over5m2=w_over5-2
  w_over5p2=w_over5+2
  noise0=( 1.482602 / sqrt(6)) *(median(abs(2.*data[overlap_waves0[w_over0]] - $
    data[overlap_waves0[w_over0m2]] - data[overlap_waves0[w_over0p2]])))
  noise5=( 1.482602 / sqrt(6)) *(median(abs(2.*data[overlap_waves5[w_over5],*] - $
    data[overlap_waves5[w_over5m2]] - data[overlap_waves5[w_over5p2]])))
  ;Mismatch calculation for orders 0 and 5
  overmed0=median((data[w_over0]-data[overlap_waves0[w_over0]]))
  overmed5=median((data[w_over5]-data[overlap_waves0[w_over5]]))
  ;Detection of stray-light based on the mismatch compared to the noise
  straypos=where(overmed0 gt 0.5*noise0); and overmed5 gt 0.1*noise5)
  strayneg=where(overmed0 lt -0.5*noise0); and  overmed5 lt -0.1*noise5)



  if overmed0 gt 0.5*noise0 then begin
    coefpos=fltarr(8)
    for order_index=0,7 do coefpos[order_index]=index_straylight[order_index]/dif_straylight_pos[order_index]

    ;if thermal signal is too strong, the stranght of the stray-light to be removed is extrapolated from higher orders
    th0=median(data[50:150])
    th1=median(data[460:560])
    th2=median(data[900:1000])
    indpos0=index_straylight[0]
    indpos1=index_straylight[1]
    indpos2=index_straylight[2]
    if th2 GT abs(0.5*index_straylight[2]) and th2 gt 0.005 then coefpos[2]=coefpos[3]
    if th1 GT abs(0.5*index_straylight[1]) and th1 gt 0.005 then coefpos[1]=coefpos[2]
    if th0 GT abs(0.5*index_straylight[0]) and th0 gt 0.005 then coefpos[0]=coefpos[1]
    for order_index=0,7 do $
      data[order_index*432:(order_index+1)*432-1]=data[order_index*432:(order_index+1)*432-1]-$
      straylight_spectrum_model_pos[order_index*432:(order_index+1)*432-1]*coefpos[order_index]


  endif
  if overmed0 lt -0.5*noise0 then begin
    coefneg=fltarr(8)
    for order_index=0,7 do coefneg[order_index]=index_straylight[order_index]/dif_straylight_neg[order_index]

    th0=median(data[50:150])
    th1=median(data[460:560])
    th2=median(data[900:1000])
    indpos0=index_straylight[0]
    indpos1=index_straylight[1]
    indpos2=index_straylight[2]
    if th2 GT abs(0.5*index_straylight[2]) and th2 gt 0.005 then coefpos[2]=coefpos[3]
    if th1 GT abs(0.5*index_straylight[1]) and th1 gt 0.005 then coefpos[1]=coefpos[2]
    if th0 GT abs(0.5*index_straylight[0]) and th0 gt 0.005 then coefpos[0]=coefpos[1]
    for order_index=0,7 do $
      data[order_index*432:(order_index+1)*432-1]=data[order_index*432:(order_index+1)*432-1]-$
      straylight_spectrum_model_neg[order_index*432:(order_index+1)*432-1]*coefneg[order_index]
  endif

  ;Removal of the stray light based on the scaling of known stray light contribution,
  ;each order separately. Orders 0 and 1 are scaled using order 2






  ;find where correction failed
  
  Nfact=median(spectrum[614:634])
  if Nfact lt 1e-3 then Nfact=1e-3
  spN=spectrum/Nfact
  difN=exp(-0.1*(abs(spN[w_over]-spN[overlap_waves[w_over]])^0.1))
  qual=median(difN, dimension=1)
  Nfact=median(data[614:634])
  if Nfact lt 1e-3 then Nfact=1e-3
  spN=data/Nfact
  difN=exp(-0.1*(abs(spN[w_over]-spN[overlap_waves[w_over]])^0.1))
  qualcor=median(difN, dimension=1)

  if (qualcor gt qual) then begin
    if not keyword_set(silent) then print, "stray light successfully corrected"
    return, data
  endif else begin
    if not keyword_set(silent) then print, "no stray light found"
    return, spectrum
  endelse
  
end

