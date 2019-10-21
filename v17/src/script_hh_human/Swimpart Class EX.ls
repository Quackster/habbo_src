property pUnderWater, pSwimProps

on define me, tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart 
  pSwimProps = [#maskImage:0, #ink:0, #bgColor:rgb(0, 156, 156), #color:rgb(0, 156, 156), #blend:60]
  callAncestor(#define, [me], tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart)
  pUnderWater = 1
  return TRUE
end

on update me, tForcedUpdate, tRectMod 
  callAncestor(#update, [me], 1, tRectMod)
  if pUnderWater and me.pBody.pSwim then
    pSwimProps.setAt(#maskImage, me.getProp(#pDrawProps, #maskImage))
    if me.pFlipH then
      tDrawRect = me.pCacheRectA
      tQuad = [point(tDrawRect.getAt(3), tDrawRect.getAt(2)), point(tDrawRect.getAt(1), tDrawRect.getAt(2)), point(tDrawRect.getAt(1), tDrawRect.getAt(4)), point(tDrawRect.getAt(3), tDrawRect.getAt(4))]
      me.pBody.pBuffer.copyPixels(me.pCacheImage, tQuad, me.pCacheRectB, pSwimProps)
    else
      tDrawRect = me.pCacheRectA
      me.pBody.pBuffer.copyPixels(me.pCacheImage, tDrawRect, me.pCacheRectB, pSwimProps)
    end if
  end if
end

on render me 
  callAncestor(#render, [me])
  if memberExists(me.pMemString) then
    if me.pBody.pSwim then
      pSwimProps.setAt(#maskImage, me.getProp(#pDrawProps, #maskImage))
      if me.pFlipH then
        tDrawRect = me.pCacheRectA
        tQuad = [point(tDrawRect.getAt(3), tDrawRect.getAt(2)), point(tDrawRect.getAt(1), tDrawRect.getAt(2)), point(tDrawRect.getAt(1), tDrawRect.getAt(4)), point(tDrawRect.getAt(3), tDrawRect.getAt(4))]
        me.pBody.pBuffer.copyPixels(me.pCacheImage, tQuad, me.pCacheRectB, pSwimProps)
      else
        tDrawRect = me.pCacheRectA
        me.pBody.pBuffer.copyPixels(me.pCacheImage, tDrawRect, me.pCacheRectB, pSwimProps)
      end if
    end if
  end if
end

on defineInk me, tInk 
  callAncestor(#defineInk, [me], tInk)
  pSwimProps.setAt(#ink, me.getProp(#pDrawProps, #ink))
  return TRUE
end

on setUnderWater me, tUnderWater 
  pUnderWater = tUnderWater
end

on getMemberNumber me, tdir, tHumanSize, tAction, tAnimFrame 
  tArray = callAncestor(#getMemberNumber, [me], tdir, tHumanSize, tAction, tAnimFrame)
  tMemNum = tArray.getAt(#memberNumber)
  if (tMemNum = 0) then
    tmodel = "0" & me.pmodel.getProp(#char, 2, 3)
    tArray = callAncestor(#getMemberNumber, [me], tdir, tHumanSize, tAction, tAnimFrame, tmodel)
  end if
  return(tArray)
end
