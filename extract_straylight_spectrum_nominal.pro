pro extract_straylight_spectrum_nominal, cube_name


 opt=1
;cube_name='/Users/fandrieu/data/mapVH/T1_00399297801.CAL'
cube=virtispds(cube_name,/si)
data=cube.qube

basename='/Users/fandrieu/Documents/Programmes/IDL_sav_files/straylight_spectrum_model_'
;straylight_model_chosen=where(strayligng_model_names-cubedate eq min(strayligng_model_names-cubedate))
endname=strmid(cube_name, 14,11, /reverse_offset)
straylight_spectrum_name=strcompress(basename+endname+'.sav', /remove_all)


restore, '/Users/fandrieu/Documents/Programmes/IDL_sav_files/straylight_spectrum_model.sav'
restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_waves.sav'
restore,'/Users/fandrieu/Documents/Programmes/IDL_sav_files/VIRTIS-H_orders.sav'
dif_straylight=0.229203; result of: dif_straylight=median(straylight_spectrum_model[pos3r:pos3l:2, *], $
;  dimension=1)-median(straylight_spectrum_model[pos4r:pos4l:2, *], dimension=1)
;
; where straylight_spectrum_model is an empirical model for the straylight,
; estimated using all available backup cubes.
cube=virtispds(cube_name,/si)
data=cube.qube
;;;Scaling of the function around 2.75µm using difference between orders 3 and 4
if opt eq 0 then begin  
  pos=intarr(4,7)
  pos[0,0]=396 ; lambda=4.15090µm (order 0, even, affected by stray light)
  pos[1,0]=360 ; lambda=4.25040µm (order 0, even, affected by stray light)
  pos[2,0]=542 ; lambda=4.14900µm (order 1, even, NOT affected by stray light)
  pos[3,0]=480 ; lambda=4.25120µm (order 1, even, NOT affected by stray light)
  
  pos[0,1]=854 ; lambda=3.49920µm (order 1, even, affected by stray light)
  pos[1,1]=832 ; lambda=3.55290µm (order 1, even, affected by stray light)
  pos[2,1]=1056 ; lambda=3.50110µm (order 2, even, NOT affected by stray light)
  pos[3,1]=1026 ; lambda=3.54940µm (order 2, even, NOT affected by stray light)
  
  pos[0,2]=1282 ; lambda=3.07160µm (order 2, even, affected by stray light)
  pos[1,2]=1268 ; lambda=3.10150µm (order 2, even, affected by stray light)
  pos[2,2]=1518 ; lambda=3.06850µm (order 3, even, NOT affected by stray light)
  pos[3,2]=1498 ; lambda=3.09870µm (order 3, even, NOT affected by stray light)
  
  pos[0,3]=1702 ; lambda=2.75220µm (order 3, even, affected by stray light)
  pos[1,3]=1676 ; lambda=2.80160µm (order 3, even, affected by stray light)
  pos[2,3]=1956 ; lambda=2.75340µm (order 4, even, NOT affected by stray light)
  pos[3,3]=1922 ; lambda=2.80160µm (order 4, even, NOT affected by stray light)
  
  pos[0,4]=2120 ; lambda=2.50040µm (order 4, even, affected by stray light)
  pos[1,4]=2090 ; lambda=2.55030µm (order 4, even, affected by stray light)
  pos[2,4]=2390 ; lambda=2.49950µm (order 5, even, NOT affected by stray light)
  pos[3,4]=2350 ; lambda=2.54910µm (order 5, even, NOT affected by stray light)
  
  pos[0,5]=2540 ; lambda=2.29070µm (order 5, even, affected by stray light)
  pos[1,5]=2508 ; lambda=2.33850µm (order 5, even, affected by stray light)
  pos[2,5]=2822 ; lambda=2.29120µm (order 6, even, NOT affected by stray light)
  pos[3,5]=2778 ; lambda=2.34090µm (order 6, even, NOT affected by stray light)
  
  pos[0,6]=2934 ; lambda=2.15140µm (order 6, even, affected by stray light)
  pos[1,6]=2904 ; lambda=2.19090µm (order 6, even, affected by stray light)
  pos[2,6]=3220 ; lambda=2.15130µm (order 7, even, NOT affected by stray light)
  pos[3,6]=3182 ; lambda=2.18980µm (order 7, even, NOT affected by stray light)
  dif_straylight=fltarr(7)
  
  for order_index=0,6 do dif_straylight[order_index]=median(straylight_spectrum_model[pos[1,order_index]:pos[0,order_index]:2, *],dimension=1)-$
     median(straylight_spectrum_model[pos[3,order_index]:pos[2,order_index]:2, *], dimension=1)
  index_straylight=fltarr(7, cube.qube_dim[1])
  for order_index=0,6 do index_straylight[order_index,*]=median(data[pos[1,order_index]:pos[0,order_index]:2, *], dimension=1)-$
     median(data[pos[3,order_index]:pos[2,order_index]:2, *], dimension=1)
endif else begin
  pos=intarr(4,8)
  poscut=[80,345,570,780,1025,1230,1450,1660]
  ;***ORDER 2***
  pos[0,0]=1215
  pos[1,0]=1225
  pos[2,0]=1280
  pos[3,0]=1290

  ;***ORDER 3***
  pos[0,1]=1625
  pos[1,1]=1645
  pos[2,1]=1700
  pos[3,1]=1720

  ;***ORDER 4***
  pos[0,2]=2070
  pos[1,2]=2080
  pos[2,2]=2140
  pos[3,2]=2150

  ;***ORDER 5***
  pos[0,3]=2495
  pos[1,3]=2505
  pos[2,3]=2555
  pos[3,3]=2565

  ;***ORDER 6***
  pos[0,4]=2945
  pos[1,4]=2955
  pos[2,4]=3005
  pos[3,4]=3015

  ;***ORDER 7***
  pos[0,5]=3375
  pos[1,5]=3385
  pos[2,5]=3435
  pos[3,5]=3445

  ;**********
  ;mismatch between orders 0 and 1 and between orders 2 and 3
  posmis0=[396,360,542,480]     ; lambda=4.15090µm (order 0, even, affected by stray light)
  ; lambda=4.25040µm (order 0, even, affected by stray light)
  ; lambda=4.14900µm (order 1, even, NOT affected by stray light)
  ; lambda=4.25120µm (order 1, even, NOT affected by stray light)
  posmis2=[1282,1268,1518,1498] ; lambda=3.07160µm (order 2, even, affected by stray light)
  ; lambda=3.10150µm (order 2, even, affected by stray light)
  ; lambda=3.06850µm (order 3, even, NOT affected by stray light)
  ; lambda=3.09870µm (order 3, even, NOT affected by stray light)
  posmis3=[1702,1676,1956,1922]  ; lambda=2.75220µm (order 3, even, affected by stray light)
  ; lambda=2.80160µm (order 3, even, affected by stray light)
  ; lambda=2.75340µm (order 4, even, NOT affected by stray light)
  ; lambda=2.80160µm (order 4, even, NOT affected by stray light)

  ;**********
  mis_order0=median(data[posmis0[1]:posmis0[0]:2, *], dimension=1)-$
    median(data[posmis0[3]:posmis0[2]:2, *], dimension=1)
  mis_order2=median(data[posmis2[1]:posmis2[0]:2, *], dimension=1)-$
    median(data[posmis2[3]:posmis2[2]:2, *], dimension=1)
  mis_order3=median(data[posmis3[1]:posmis3[0]:2, *], dimension=1)-$
    median(data[posmis3[3]:posmis3[2]:2, *], dimension=1)

  ;Criterion based on both slopes and mismatch between orders : signature of the stray light
 ; straypos=where(abs(index_straylight[3, *]) gt 0. and abs(index_straylight[5, *]) gt 0. $
 ;   and abs(mis_order3) gt 0.2*stddev(data)^2 )

  dif_straylight=fltarr(8)
  index_straylight=fltarr(8, cube.qube_dim[1])
  for order_index=0,5 do begin
    dif_straylight[order_index+2]=median(straylight_spectrum_model[pos[0,order_index]:pos[1,order_index]:2, *],dimension=1)-$
      median(straylight_spectrum_model[pos[2,order_index]:pos[3,order_index]:2, *], dimension=1)
    index_straylight[order_index+2,*]=median(data[pos[0,order_index]:pos[1,order_index]:2, *], dimension=1)-$
      median(data[pos[2,order_index]:pos[3,order_index]:2, *], dimension=1)
  endfor
  dif_straylight[0:1]=dif_straylight[2]
  index_straylight[0,*]=index_straylight[2,*]
  index_straylight[1,*]=index_straylight[2,*]
  therm=median(cube.qube[500:550,*], dimension=1)
  straypos=where(abs(index_straylight[3, *]) gt 5*stddev(data)^2 and therm lt 0.0005 and $
    mis_order0 gt 5*stddev(data)^2 and mis_order3 gt 5*stddev(data)^2 ); and abs(index_straylight[3, *]) lt 20*stddev(data)^2 )
  if (n_elements(straypos) lt 2) then begin
    print, 'no sufficient straylight in cube T1_'+endname
    return
  endif
  data_stray=data[*,straypos]
  meanstray=median(data_stray, dimension=2)
  ;p=plot_virtish(meanstray)
  stray_orders=fltarr(432,8)
  for order_index=0,7 do stray_orders[*,order_index]=meanstray[order_index*432:(order_index+1)*432-1]
  straysmooth=meanstray
  for order_index=0,7 do straysmooth[order_index*432:(order_index+1)*432-1]=smooth(stray_orders[*,order_index],20, /edge_truncate)
  ;p=plot_virtish(straysmooth)
  memememe=meanstray
  ;for i=0,7 do memememe[i*432:i*432+240]=0.
  even=fltarr(216,8)
  odd=fltarr(216,8)
  for i=0,7 do even[*,i]=memememe[i*432:(i+1)*432-1:2]
  for i=0,7 do odd[*,i]=memememe[i*432+1:(i+1)*432-1:2]
 
  evenmod=fltarr(216)
  oddmod=fltarr(216)
  evenmod[*]=0.
  oddmod[*]=0.
  straylight_spectrum_mod=fltarr(3456)

  for i=0,7 do begin
    evev=even[*, i]
    evenmod=smooth(evev, 20, /edge_truncate)
    odod=odd[*, i]
    oddmod=smooth(odod, 20, /edge_truncate)
    straylight_spectrum_mod[i*432:(i+1)*432-1:2]=evenmod-oddmod[poscut[i]-i*216]
    straylight_spectrum_mod[i*432+1:(i+1)*432-1:2]=oddmod-oddmod[poscut[i]-i*216]
    straylight_spectrum_mod[i*432:2*poscut[i]]=0.
  endfor

endelse

STRAYLIGHT_SPECTRUM_MEASURE= meanstray
STRAYLIGHT_SPECTRUM_MODEL= straylight_spectrum_mod
abb=where(STRAYLIGHT_SPECTRUM_MODEL le 0.)
STRAYLIGHT_SPECTRUM_MODEL[abb]=0.


save, STRAYLIGHT_SPECTRUM_MEASURE, STRAYLIGHT_SPECTRUM_MODEL, filename=straylight_spectrum_name
print, 'straylight extracted for cube T1_'+endname
end