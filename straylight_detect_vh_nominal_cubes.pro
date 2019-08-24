;;+
; NAME:
;     SRAYLIGHT_DETECT_VH_NOMINAL_CUBES
;
; PURPOSE:
;     Adaptation of WATER_BD_VH_CUBE to look for stray light in the whole VIRTIS-H database
;
; CALLING SEQUENCE:
;    STRAYLIGHT_DETECT_VH_NOMINAL_CUBES, LIST_CUBES, DETECT_CANDIDATES
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


pro STRAYLIGHT_DETECT_VH_NOMINAL_CUBES, LIST_CUBES, DETECT_CANDIDATES, BASELINE=BASELINE, CRITERION=CRITERION, DARK=DARK

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

    imtab = cube.qube
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



  endfor

  print,n_detect, '  candidates found in ', n_cubes_detect, ' VIRTIS-H cubes'
  if (n_detect eq 0) then DETECT_CANDIDATES=!NULL else $
    DETECT_CANDIDATES={CUBE_NAME:names, ACQUISITION_NUMBER:pos, BAND_DEPTH:stray_crit}


  return


end