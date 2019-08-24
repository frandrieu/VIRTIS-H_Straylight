pro find_overlap
  
  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_waves.sav'
  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_orders.sav'
  restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_resol.sav'
  
  ;ORDER0
  overlap=intarr(n_elements(wavelengths))
  overlap_waves=lonarr(n_elements(wavelengths))
  wu=[332,735,1133,1512,1955,2369,2787, 3024] ; beginning of overlap upward for each order
  for order=0,7 do begin
    pos=where(orders eq order)
    waves=wavelengths[pos]
    for wave=0,n_elements(waves)-1 do begin
      wl=wavelengths[pos[wave]]
      waveordsup=wavelengths[where(orders eq order+1, /null)]
      if n_elements(waveordsup) ge 1 and wave lt 402 and wave gt $
              wu[order]-432*order+30 then begin    
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
save, overlap, overlap_waves, w_over, filename='/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_overlap_upward.sav'
end