property pSwimProps, pUnderWater

on define me, tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart
  pSwimProps = [#maskImage: 0, #ink: 0, #bgColor: rgb(0, 156, 156), #color: rgb(0, 156, 156), #blend: 60]
  callAncestor(#define, [me], tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart)
  pUnderWater = 1
  return 1
end

on update me, tForcedUpdate, tRectMod
  callAncestor(#update, [me], 1, tRectMod)
  if pUnderWater and me.pBody.pSwim then
    pSwimProps[#maskImage] = me.pDrawProps[#maskImage]
    if me.pFlipH then
      tDrawRect = me.pCacheRectA
      tQuad = [point(tDrawRect[3], tDrawRect[2]), point(tDrawRect[1], tDrawRect[2]), point(tDrawRect[1], tDrawRect[4]), point(tDrawRect[3], tDrawRect[4])]
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
      pSwimProps[#maskImage] = me.pDrawProps[#maskImage]
      if me.pFlipH then
        tDrawRect = me.pCacheRectA
        tQuad = [point(tDrawRect[3], tDrawRect[2]), point(tDrawRect[1], tDrawRect[2]), point(tDrawRect[1], tDrawRect[4]), point(tDrawRect[3], tDrawRect[4])]
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
  pSwimProps[#ink] = me.pDrawProps[#ink]
  return 1
end

on setUnderWater me, tUnderWater
  pUnderWater = tUnderWater
end

on getMemberNumber me, tdir, tHumanSize, tAction, tAnimFrame
  tArray = callAncestor(#getMemberNumber, [me], tdir, tHumanSize, tAction, tAnimFrame)
  tMemNum = tArray[#memberNumber]
  if tMemNum = 0 then
    tmodel = "0" & me.pmodel.char[2..3]
    tArray = callAncestor(#getMemberNumber, [me], tdir, tHumanSize, tAction, tAnimFrame, tmodel)
  end if
  return tArray
end
