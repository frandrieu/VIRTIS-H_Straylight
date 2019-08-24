;;+
; NAME:
;     SRAYLIGHT_DETECT_VH_ALL_CUBES
;
; PURPOSE:
;     Adaptation of WATER_BD_VH_CUBE to look for water in the whole VIRTIS-H database
;     Classical linear interpolation between 2.55µm and 3.9µm (biggest water band bounds in VIRTIS-H range)
;
; CALLING SEQUENCE:
;    STRAYLIGHT_DETECT_VH_ALL_CUBES, LIST_CUBES, DETECT_CANDIDATES
;
; INPUTS:
;     LIST_CUBES:  A list of VIRTIS-H BACKUP cubes
;
; OUTPUTS:
;     DETECT_CANDIDATES:  a structure containing 3 fields:
;                                   the cube name of the candidate
;                                   the position in the said cube
;                                   an index of the strength of the stray light
;
; KEYWORD PARAMETERS:
;     BASELINE=BASELINE: ads a baseline of the specified value to the data to avoid division by 0
;     CRITERION        : the value for the band depth above which a stectrum is kept for further
;                       inverstigation. If no value is specified, it is set to 0.5.
;     DARK             : set this keyword to look for strayligth in dark. 
;                        set to 2 to look in both dark and raw data
;
; EXAMPLE:
;
; LIMITATIONS:
;
; MODIFICATION HISTORY:
;   F ANDRIEU, LESIA, 2017-11-08: Creation from adapting WATER_DETECT_VH_ALL_CUBES
;      Version 1.0


pro STRAYLIGHT_DETECT_VH_ALL_CUBES, LIST_CUBES, DETECT_CANDIDATES, BASELINE=BASELINE, CRITERION=CRITERION, DARK=DARK

  ;    restore, '/Users/fandrieu/Documents/Save_Macbook_pro/Documents/Inversion_Achille-dir/Const_optiques/index_ice_rf_warren_2008.txt-ascii_template'
  ;    data=read_ascii('/Users/fandrieu/Documents/Save_Macbook_pro/Documents/Inversion_Achille-dir/Const_optiques/index_ice_rf_warren_2008.txt', template=temp)
  ;    lambda=data.FIELD1
  ;    n=data.FIELD2
  ;    k=data.FIELD3
  ;    w=where((lambda gt 1.5) and (lambda lt 5.5))
  ;    lambda_select=lambda[w]
  ;    n_select=n[w]
  ;    k_select=k[w]

  ;restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_waves.sav'
  ;restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_orders.sav'
  ;band_center=lambda_select[where(k_select eq max(k_select))]
  ;water_band_center=band_center[0]
  ;pw=where(abs(wavelengths-water_band_center
  ;) lt 0.05 and orders eq 3, /null)


  if (keyword_set(dark)) then begin
    posxd=55
    posyd=150
    strayposxd=355
  endif
  posx=55
  strayposx=355
  posy=75
  
  
  if (keyword_set(baseline)) then base=baseline else base=0.
  if (keyword_set(criterion)) then crit=criterion else crit=100

  stray_crit=!NULL
  names=!NULL
  pos=!NULL
  stray_critd=!NULL
  namesd=!NULL
  posd=!NULL
  n_detect=0
  n_cubes_detect=0
  n_detectd=0
  n_cubes_detectd=0
for cube_index=0, n_elements(list_cubes)-1 do begin

    cube = virtispds(list_cubes[cube_index], /silent)
    hk_qub = v_pdshk(cube)
    dark_pos = reform(hk_qub.values(6,0,*))
    ;; Tableau des indices de la position des darks
    ind_dark = where(dark_pos EQ 1)
    ;; Tableau des indices de la position des observations
    ind_qub = where(dark_pos NE 1)
    ;; Tableau des images de darks
    darktab = reform(cube.qube(*,*,ind_dark))
    
    
    if (keyword_set(dark)) then begin
      if (dark eq 2) then begin  ;;;;;;;;;;;;;;;;;; ON BOTH DATA AND DARKS;;;;;;;;;;;
        imtab = reform(cube.qube(*,*,ind_qub))
        darktab = reform(cube.qube(*,*,ind_dark))
        nb_im = (size(imtab))(3)
        nb_drk = (size(darktab))(3)
        
         
        imtab = reform(cube.qube(*,*,ind_qub))
        nb_im=(size(imtab))(3)

        Rs=fltarr(nb_im)
        Rn=fltarr(nb_im)
        Stray=fltarr(nb_im)
        Rs=median(imtab[strayposx,posy:posy+5,*], dimension=2)
        Rn=median(imtab[posx,posy:posy+5,*], dimension=2)

        stray_strength= Rs-Rn
        sb=where(stray_strength gt crit, /NULL)
        if (n_elements(sb) ne 0) then begin
          stray_crit=[stray_crit, stray_strength[sb]]
          names=[names, replicate(list_cubes[cube_index],n_elements(sb))]
          pos=[pos, sb]
          n_cubes_detect=n_cubes_detect+1
          n_detect=n_detect+n_elements(sb)
        endif
        
        Rsd=fltarr(nb_drk)
        Rnd=fltarr(nb_drk)
        Strayd=fltarr(nb_drk)
        Rsd=median(imtab[strayposx,posy:posy+5,*], dimension=2)
        Rnd=median(imtab[posx,posy:posy+5,*], dimension=2)

        stray_strengthd= Rsd-Rnd
        sbd=where(stray_strengthd gt critd, /NULL)
        if (n_elements(sbd) ne 0) then begin
          stray_critd=[stray_critd, stray_strengthd[sb]]
          namesd=[namesd, replicate(list_cubesd[cube_index],n_elements(sb))]
          posd=[pos, sb]
          n_cubes_detecdt=n_cubes_detectd+1
          n_detectd=n_detectd+n_elements(sbd)
        endif     
                         
      endif else begin ;;;;;;;;;;;;;;;;;;ONLY ON DARKS;;;;;;;;;;;
        nb_drk = (size(darktab))(3)
        darktab = reform(cube.qube(*,*,ind_dark))
        Rsd=fltarr(nb_drk)
        Rnd=fltarr(nb_drk)
        Strayd=fltarr(nb_drk)
        Rsd=median(imtab[strayposx,posy:posy+5,*], dimension=2)
        Rnd=median(imtab[posx,posy:posy+5,*], dimension=2)

        stray_strengthd= Rsd-Rnd
        sbd=where(stray_strengthd gt critd, /NULL)
        if (n_elements(sbd) ne 0) then begin
          stray_critd=[stray_critd, stray_strengthd[sb]]
          namesd=[namesd, replicate(list_cubesd[cube_index],n_elements(sb))]
          posd=[pos, sb]
          n_cubes_detecdt=n_cubes_detectd+1
          n_detectd=n_detectd+n_elements(sbd)
        endif   
      endelse 
    endif else begin  ;;;;;;;;;;;;;;;;;;ONLY ON DATA;;;;;;;;;;;
      imtab = reform(cube.qube(*,*,ind_qub))
      nb_im=(size(imtab))(3)
      
      Rs=fltarr(nb_im)
      Rn=fltarr(nb_im)
      Stray=fltarr(nb_im)
      Rs=median(imtab[strayposx,posy:posy+5,*], dimension=2)
      Rn=median(imtab[posx,posy:posy+5,*], dimension=2)
  
      stray_strength= Rs-Rn
      sb=where(stray_strength gt crit, /NULL)
      if (n_elements(sb) ne 0) then begin
        stray_crit=[stray_crit, stray_strength[sb]]
        names=[names, replicate(list_cubes[cube_index],n_elements(sb))]
        pos=[pos, sb]
        n_cubes_detect=n_cubes_detect+1
        n_detect=n_detect+n_elements(sb)
      endif
  
  
    
  endelse


endfor

if (keyword_set(dark)) then begin
  if (dark eq 2) then begin  ;;;;;;;;;;;;;;;;;; ON BOTH DATA AND DARKS;;;;;;;;;;;
  print,n_detect, '  candidates found in ', n_cubes_detect, ' VIRTIS-H cubes'
  if (n_detect eq 0) then DETECT_CANDIDATES=!NULL else $
    DETECT_CANDIDATES={CUBE_NAME:names, ACQUISITION_NUMBER:pos, STRAY_CRIT:stray_crit, $
    CUBE_NAME_DRK:namesd, ACQUISITION_NUMBER_DRK:posd, STRAY_CRIT_DRK:stray_critd}
  endif else begin ;;;;;;;;;;;;;;;;;; ONLY ON DARKS;;;;;;;;;;;
    print,n_detect, '  candidates found in ', n_cubes_detect, ' VIRTIS-H cubes'
    if (n_detect eq 0) then DETECT_CANDIDATES=!NULL else $
      DETECT_CANDIDATES={CUBE_NAME_DRK:namesd, ACQUISITION_NUMBER_DRK:posd, STRAY_CRIT_DRK:stray_critd}
  endelse
endif else begin;;;;;;;;;;;;;;;;;; ONLY ON DATA;;;;;;;;;;;
  print,n_detect, '  candidates found in ', n_cubes_detect, ' VIRTIS-H cubes'
  if (n_detect eq 0) then DETECT_CANDIDATES=!NULL else $
    DETECT_CANDIDATES={CUBE_NAME:names, ACQUISITION_NUMBER:pos, BAND_DEPTH:stray_crit}
endelse


return


end