
;+
; NAME:
;   CALIBROS_MATTOSPECTRE_2
;
; PURPOSE:
;   Extrait le spectre (sommer sur "etal" pixels, puis divise par "etal") d une matrice
;       2D en utilisant la pixelmap
;
; CALLING SEQUENCE:
;   CALIBROS_MATTOSPECTRE, StructIn, pixelmapfile, sessiontype, etal $
;       structOut, $
;       DEBUG = debug, GRAPH = GRAPH
;
; INPUTS:
;   StrucIn : struture [432,256,nn]
;   pixelmapfile: (438,8) de valeurs y
;   sessiontype: FM1 ou IAS
;
;
; OUTPUTS:
;   StructOut: structure [3456,nn]
;           structout.data
;           structout.dark
;
;
; KEYWORD PARAMETERS:
;   /ETAL3 : mettre ce keyword si on veut sommer sur 3 pixels et diviser par 3
;   /debug   : gives detail on the execution
;
;
; EXAMPLE:
;
;
; LIMITATIONS:
;
; MODIFICATION HISTORY:
;   S. Jacquinod, LESIA, 2014-07-24: Creation
;      Version 1.0
;  F. Andrieu, LESIA, 2017-01-13: adding parameter etal
;-

PRO CALIBROS_MATTOSPECTRE_2, StructIn, pixelmapfile, sessiontype, etal, $
  structOut, $
  DEBUG = debug, GRAPH = GRAPH


  DEBUG = keyword_set(debug)
  GRAPH = keyword_set(graph)


  ;; Taille de la structure
  ;; Gestion du cas ou le tableau contient une seule image
  sizetab = size(StructIn.data)
  if sizetab(0) EQ 2 then nbim = 1 else nbim = sizetab(3)

  calibros_pixelmap, pixelmapfile, y, DEBUG = debug, GRAPH = graph

  ;etal=12
  sp=fltarr(3456,nbim)
  dk=fltarr(3456,nbim)

  for nn=0,nbim-1 do begin
    convert_438,structIn.data(*,*,nn),im_qub,sessiontype
    convert_438,structIn.dkinterp(*,*,nn),im_dk,sessiontype
    ss=0
    for oo=0,7 do begin
      for ii=0,431 do begin
        for kk=-etal/2,etal/2 do begin
          sp(ss,nn)=im_qub(ii+3,y(ii+3,oo)+kk)+sp(ss,nn)
          dk(ss,nn)=im_dk(ii+3,y(ii+3,oo)+kk)+dk(ss,nn)
        endfor
        sp(ss,nn)=sp(ss,nn)/5.
        dk(ss,nn)=dk(ss,nn)/5.
        ss=ss+1
      endfor
    endfor
  endfor
  ;fivepixIm = dblarr(438,etal,8)
  ;fivepixDk = dblarr(438,etal,8)
  ;for nn=0,nbim-1 do begin
  ;    convert_438,structIn.data(*,*,nn),im_qub,sessiontype
  ;    convert_438,structIn.dkinterp(*,*,nn),im_dk,sessiontype
  ;
  ;    for oo=0,7 do begin
  ;        for i=0,431 do begin
  ;            for et = 0,4 do begin
  ;                fivepixIm(i+3,et,oo) = im_qub(i+3,fix(y(i+3,oo)+0.5) + $
  ;                    (et-2))
  ;                fivepixDk(i+3,et,oo) = im_qub(i+3,fix(y(i+3,oo)+0.5) + $
  ;                    (et-2))
  ;            endfor
  ;        endfor
  ;     endfor
  ;    ;; sommation des 5 pixels et division par 5
  ;    sptemp = dblarr(432,8)
  ;    dktemp = dblarr(432,8)
  ;    for oo = 0,7 do begin
  ;        for j=0,431 do begin
  ;            sptemp(j,oo) = (total(fivepixIm(j+3,*,oo))/5.)
  ;            dktemp(j,oo) = (total(fivepixDk(j+3,*,oo))/5.)
  ;        endfor
  ;    endfor
  ;
  ;    ;; Mise en forme du spectre : 3456 points
  ;    for oo = 0,7 do begin
  ;        sp(indgen(432)+oo*432,nn) = sptemp(*,oo)
  ;        dk(indgen(432)+oo*432,nn) = dktemp(*,oo)
  ;    endfor
  ;endfor
  ;readcol, pixelmapfile, a, b, c, /SILENT
  ;pixelmap = dblarr(438,8)
  ;coeff = dblarr(3,8)
  ;coeff(0,*) = a
  ;coeff(1,*) = b
  ;coeff(2,*) = c
  ;for oo = 0,7 do begin
  ;    for i = 0,437 do begin
  ;        pixelmap(i,oo) = coeff(0,oo) + coeff(1,oo)*double(i) + coeff(2,oo)*double(i)*double(i)
  ;    endfor
  ;endfor
  ;mat = StructIn.data(*,*,0)
  ;convert_438, mat, matrice, sessiontype
  ;print, sessiontype
  ;        ;; extraction des 5 pixels de la matrice
  ;        fivepix = dblarr(438,5,8)
  ;        etal = 5
  ;        for oo=0,7 do begin
  ;            for i=0,431 do begin
  ;                for etal = 0,4 do begin
  ;                    fivepix(i+3,etal,oo) = matrice(i+3,fix(pixelmap(i+3,oo)+0.5) + $
  ;                    (etal-2))
  ;                endfor
  ;            endfor
  ;        endfor
  ;        ;; sommation des 5 pixels et division par 5
  ;        sp2 = dblarr(432,8)
  ;        for oo = 0,7 do begin
  ;            for j=0,431 do sp2(j,oo) = (total(fivepix(j+3,*,oo))/5.)
  ;        endfor

  ;stop


  structOut = { data:dblarr(3456,nbim), $
    dkinterp:dblarr(3456,nbim)}
  structOut.data = sp
  structOut.dkinterp = dk


END