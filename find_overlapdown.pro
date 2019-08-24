pro find_overlapdown

  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_waves.sav'
  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_orders.sav'
  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_resol.sav'
  overlap=intarr(n_elements(wavelengths))
  overlap_waves=lonarr(n_elements(wavelengths))
  for order=0,7 do begin
    pos=where(orders eq 7-order)
    waves=wavelengths[pos]
    for wave=0,n_elements(waves)-1 do begin
      wl=wavelengths[pos[wave]]
      waveordinf=wavelengths[where(orders eq 7-order-1, /null)]
      if n_elements(waveordinf) ge 1 then begin
        dif_closest=min(abs(wl - waveordinf), pos_closest)
        if (dif_closest lt resol[pos[wave]]/2.) then begin
          overlap[pos[wave]]=1
          closest_wl_pos=pos_closest+432*(7-order-1)
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

  rustuc=rastac
end