PRO STRAYLIGHT_EXTRACT_ALL_BACKUP, STRUCT_OUT, SAVE_FILENAME=SAVE_FILENAME

  cd, '/Users/fandrieu/Documents/Programmes/'
  resolve_routine, 'calibros_straylight_extract_map'
  resolve_routine, 'calibros_extract_straylight_spectrum'
  main_dir='/Users/fandrieu/'
  cd, main_dir


  FTname='Documents/Programmes/CALIBROS/CALIB_PRODUCTS/FT_CLEAN/140929_FT.txt'
  lambdamap_name='Documents/Programmes/CALIBROS/SETUP_files/150126_Grid.fits'
  corrft_name='Documents/Programmes/CALIBROS/SETUP_files/CorrFT_Lut_22-08-2014.txt'
  pixelmap_name='Documents/Programmes/CALIBROS/SETUP_files/CoefMap14-02-19.txt'
  FTname=strcompress(main_dir+FTname, /remove_all)
  lambdamap_name=strcompress(main_dir+lambdamap_name, /remove_all)
  corrft_name=strcompress(main_dir+corrft_name, /remove_all)
  pixelmap_name=strcompress(main_dir+pixelmap_name, /remove_all)
  sessiontype='FM1'
  n_waves=3456
  RESTORE, '/Users/fandrieu/Documents/Programmes/IDL_sav_files/detect_candidates.sav'

  list_cubes=uniq(detect_candidates.cube_name)

  list_cubes=['/Users/fandrieu/data/H1_00153604824.QUB',$
  '/Users/fandrieu/data/H1_00237396920.QUB',$
  '/Users/fandrieu/data/H1_00385586377.QUB',$
  '/Users/fandrieu/data/H1_00385937834.QUB',$
  '/Users/fandrieu/data/H1_00389083498.QUB']

  straylight_median_spectra=fltarr(n_elements(list_cubes), n_waves)
  for cube_index=0,n_elements(list_cubes)-1 do begin
    cube_name=list_cubes[cube_index]
    CALIBROS_EXTRACT_STRAYLIGHT_SPECTRUM, CUBE_NAME, PIXELMAP_NAME, FTNAME, LAMBDAMAP_NAME, $
      CORRFT_NAME, SESSIONTYPE, STRUCT_INTERM
      
      
    straylight_median_spectra[cube_index, *]=median(struct_interm.data, dimension=2)
    
    
    
  endfor
  
  struct_out={cube_name:list_cubes, median_straylight:straylight_median_spectra}
  if (keyword_set(SAVE_FILENAME)) then begin
    straylight_spectra=struct_out
    save,struct_out, filename=save_filename
  endif
  
  return

END