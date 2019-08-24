;+
; NAME:
;   CALIBROS_STRAYLIGHT_EXTRACT_SPECTRUM
;
; PURPOSE:
;   Routine qui extrait sur la matrice un spectre correspondant uniquement à la contribution 
;   de la lumière parasite des images 2D [432,256] en entrée
;
; CALLING SEQUENCE:
;   CALIBROS_STRAYLIGHT_EXTRACT-SPECTRUM, structIn, DetecteurConf, pixelmap, $
;  DEBUG = debug
;
; INPUTS:
;   LIST_CUBES: list of VIRTIS H backup mode cubes in which to look for stray light
;   pixelmap_name : the name of the pixelmap to use
;
; OUTPUTS:
;   STRUCT_OUT: structure containing the name of the cubes and the stray light
;
;
; KEYWORD PARAMETERS:
;
; EXAMPLE:
;
;
; LIMITATIONS:
;   NEEDS CALIBROS_EXTRACT_MATRIX TO BE COMPILED 
;
;
; MODIFICATION HISTORY:
;   F.ANDRIEU, LESIA, 2017-11-15 : creation

pro CALIBROS_EXTRACT_STRAYLIGHT_SPECTRUM, CUBE_NAME, PIXELMAP_NAME, FTNAME, LAMBDAMAP_NAME, $
  CORRFT_NAME, SESSIONTYPE, STRUCT_OUT



  choice_corrft=1; 1=corr sol/vol, autre= pas de corr
  size_despike=5
  choice_despike=1
  choice_straylight_corr=1
  etal1=5
  ;if (choice_despike eq 1) then begin
  ;  cd, '/obs/fandrieu/Programmes/
  ;  resolve_routine, 'nospike'
  ;  cd, '/obs/fandrieu
  ;endif


  cube = virtispds(cube_name, /silent)
  if (choice_despike eq 1) then begin
    calibros_interpdkbkp_2, cube, cube.QUBE_DIM[0], cube.QUBE_DIM[1], cube.QUBE_DIM[2], 0, cubearr,$
      darkarr, scetarr, 5, 25,despike=size_despike
  endif else begin
    calibros_interpdkbkp_2, cube, cube.QUBE_DIM[0], cube.QUBE_DIM[1], cube.QUBE_DIM[2], 0, cubearr,$
      darkarr, scetarr, 5, 25
  endelse


  cube_str_straylight = { data:cubearr,  dkinterp:darkarr}


    CALIBROS_STRAYLIGHT_EXTRACT_MAP, cube_str_straylight, sessiontype, pixelmap_name

    calibros_mattospectre_fixed_etal, cube_str_straylight, pixelmap_name, sessiontype,spectre_str_straylight
    ;; *****
    ;; Lecture de la grille des Lambdas
    ;; *****
    wvlgrid = mrdfits(lambdamap_name, 1, /silent)
    lambdaSc = reform(wvlgrid.wavelength)


    readcol, FTname, lambdaFT, valFT, /SILENT
    FTinterp = dblarr(3456)
    for oo = 0,7 do begin
      FTinterp(indgen(432)+oo*432) = interpol(valFT(indgen(432)+oo*432), $
        lambdaFT(indgen(432)+oo*432), lambdaSc(indgen(432)+oo*432))
    endfor

    ;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ;; Correction sol/vol de la FT
    ;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ;; *****
    if choice_corrft EQ 1 then begin
      readcol, corrft_name, corrft
      FTinterp = FTinterp*corrft
    endif
    ;; *****
    ;;  Extraction du Temps d Exposition dans les HKs
    ;; *****
    HKs = v_pdshk(cube)
    Exposure_time = HKs.values(38,0,0)

    ;; *****
    ;;  Division des spectres par le FT
    ;; *****
    sizeSP = (size(spectre_str_straylight.data))(2)
    for ii = 0, sizeSP-1 do spectre_str_straylight.data[*,ii] = spectre_str_straylight.data[*,ii]/FTinterp  ;; *****
    ;;  Division des spectres par le Temps d'Exposition
    ;; *****
    for jj = 0, sizeSP-1 do spectre_str_straylight.data[*,jj] = spectre_str_straylight.data[*,jj]/Exposure_time

    ;; *****
    ;; Conversion en W/m2/sr/MICRON
    ;; *****
    for jj = 0, sizeSP-1 do spectre_str_straylight.data[*,jj] = spectre_str_straylight.data[*,jj]/1d6

  
  struct_out=spectre_str_straylight
  
end