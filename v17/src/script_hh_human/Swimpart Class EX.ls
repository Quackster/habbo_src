property pSwimProps, pUnderWater

on define me, tPart, tmodel, tColor, tDirection, tAction, tAncestor
  pSwimProps = [#maskImage: 0, #ink: 0, #bgColor: rgb(0, 156, 156), #color: rgb(0, 156, 156), #blend: 60]
  if (((tAction = "sws") or (tAction = "swm")) or (tAction = "sit")) then
    tNoSwimFramesList = ["hr", "fc", "ey", "hd"]
    if (tNoSwimFramesList.getPos(tPart) > 0) then
      tAction = "std"
    end if
  end if
  callAncestor(#define, [me], tPart, tmodel, tColor, tDirection, tAction, tAncestor)
  if (["bd", "lg", "sh", "lh", "ls", "rh", "rs"].findPos(me.pPart) > 0) then
    me.pAnimList["swm"] = [0, 1, 2, 3]
    me.pAnimList["sws"] = [0, 1, 2, 3]
  end if
  pUnderWater = 1
  return 1
end

on update me, tForcedUpdate, tRectMod
  callAncestor(#update, [me], 1, tRectMod)
  if (pUnderWater and me.pBody.pSwim) then
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
    if me.pSwim then
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

on changePartData me, tmodel, tColor
  if (me.pPart = "ch") then
    return 1
  end if
  return callAncestor(#changePartData, [me], tmodel, tColor)
end

on setUnderWater me, tUnderWater
  pUnderWater = tUnderWater
end

on getMemberNumber me, tdir, tHumanSize, tAction, tAnimFrame
  tArray = callAncestor(#getMemberNumber, [me], tdir, tHumanSize, tAction, tAnimFrame)
  tMemNum = tArray[#memberNumber]
  if (tMemNum = 0) then
    tmodel = ("0" & me.pmodel.char[2])
    tArray = callAncestor(#getMemberNumber, [me], tdir, tHumanSize, tAction, tAnimFrame, tmodel)
  end if
  return tArray
end
