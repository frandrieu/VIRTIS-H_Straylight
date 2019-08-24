pro find_overlap_05

  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_waves.sav'
  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_orders.sav'
  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_resol.sav'

  ;ORDER0
  overlap=intarr(n_elements(wavelengths))
  overlap_waves=lonarr(n_elements(wavelengths))
  for order=0,0 do begin
    pos=where(orders eq order)
    waves=wavelengths[pos]
    for wave=0,n_elements(waves)-1 do begin
      wl=wavelengths[pos[wave]]
      waveordsup=wavelengths[where(orders eq order+1, /null)]
      if n_elements(waveordsup) ge 1 and wave lt 400 and wave gt 360 then begin
        dif_closest=min(abs(wl - waveordsup), pos_closest)
        if (dif_closest lt resol[pos[wave]]/2.) then begin
          overlap[pos[wave]]=1
          closest_wl_pos=pos_closest+432*(order+1)
          overlap_waves[pos[wave]]=closest_wl_pos[0]
        endif else begin
          overlap[pos[wave]]=0
          overlap_waves[pos[wave]]=9999
        endelse
      endif else begin
        overlap[pos[wave]]=0
        overlap_waves[pos[wave]]=9999
      endelse
    endfor
  endfor
  w_over=where(overlap eq 1)
  overlap0=overlap
  overlap_waves0=overlap_waves
  w_over0=w_over
  ;
  ;
  save, overlap0, overlap_waves0, w_over0, filename='/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_overlap_upward_0.sav'

  ;ORDER 5
  overlap=intarr(n_elements(wavelengths))
  overlap_waves=lonarr(n_elements(wavelengths))

  for order=5,5 do begin
    pos=where(orders eq order)
    waves=wavelengths[pos]
    for wave=0,n_elements(waves)-1 do begin
      wl=wavelengths[pos[wave]]
      waveordsup=wavelengths[where(orders eq order+1, /null)]
      if n_elements(waveordsup) ge 1 and wave lt 400 and wave gt 30 then begin
        dif_closest=min(abs(wl - waveordsup), pos_closest)
        if (dif_closest lt resol[pos[wave]]/2.) then begin
          overlap[pos[wave]]=1
          closest_wl_pos=pos_closest+432*(order+1)
          overlap_waves[pos[wave]]=closest_wl_pos[0]
        endif else begin
          overlap[pos[wave]]=0
          overlap_waves[pos[wave]]=9999
        endelse
      endif else begin
        overlap[pos[wave]]=0
        overlap_waves[pos[wave]]=9999
      endelse
    endfor
  endfor
  w_over=where(overlap eq 1)
  overlap5=overlap
  overlap_waves5=overlap_waves
  w_over5=w_over
  save, overlap5, overlap_waves5, w_over5, filename='/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_overlap_upward_5.sav'
  save, overlap0, overlap_waves0, w_over0, overlap5, overlap_waves5, w_over5, filename='/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_overlap05_upward.sav
end