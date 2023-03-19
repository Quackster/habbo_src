property pSwimProps, pUnderWater

on define me, tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart
  pSwimProps = [#maskImage: 0, #ink: 0, #bgColor: rgb(0, 156, 156), #color: rgb(0, 156, 156), #blend: 60]
  callAncestor(#define, [me], tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart)
  pUnderWater = 1
  return 1
end

on update me, tForcedUpdate, tRectMod
  callAncestor(#update, [me], tForcedUpdate, tRectMod)
  if pUnderWater and me.pBody.pSwim then
    repeat with i = 1 to me.pLayerPropList.count
      tdata = me.pLayerPropList[i]
      tDrawProps = tdata["drawProps"]
      pSwimProps[#maskImage] = tDrawProps[#maskImage]
      tDrawArea = me.getDrawArea(i)
      if tdata["cacheImage"] <> 0 then
        me.pBody.pBuffer.copyPixels(tdata["cacheImage"], tDrawArea, tdata["cacheImage"].rect, pSwimProps)
      end if
    end repeat
  end if
end

on render me
  callAncestor(#render, [me])
  repeat with i = 1 to me.pLayerPropList.count
    tdata = me.pLayerPropList[i]
    if memberExists(tdata["memString"]) then
      if me.pBody.pSwim then
        pSwimProps[#maskImage] = tdata["drawProps"][#maskImage]
        tDrawArea = me.getDrawArea(i)
        if tdata["cacheImage"] <> 0 then
          me.pBody.pBuffer.copyPixels(tdata["cacheImage"], tDrawArea, tdata["cacheImage"].rect, pSwimProps)
        end if
      end if
    end if
  end repeat
end

on defineInk me, tInk
  callAncestor(#defineInk, [me], tInk)
  if me.pLayerPropList.count > 0 then
    pSwimProps[#ink] = me.pLayerPropList[1]["drawProps"][#ink]
    return 1
  end if
  return 0
end

on setUnderWater me, tUnderWater
  pUnderWater = tUnderWater
end

on getMemberNumber me, tdir, tHumanSize, tAction, tAnimFrame, tLayerIndex
  tArray = callAncestor(#getMemberNumber, [me], tdir, tHumanSize, tAction, tAnimFrame, tLayerIndex)
  tMemNum = tArray[#memberNumber]
  if tMemNum = 0 then
    if voidp(tLayerIndex) then
      tLayerIndex = 1
    end if
    if (tLayerIndex < 1) or (tLayerIndex > me.pLayerPropList.count) then
      tLayerIndex = 1
    end if
    if me.pLayerPropList.count >= tLayerIndex then
      tmodel = me.pLayerPropList[tLayerIndex]["model"]
    end if
    if not voidp(tmodel) then
      tmodel = tmodel.char[2..tmodel.length]
      repeat while tmodel.char[1] = "0"
        tmodel = tmodel.char[2..tmodel.length]
      end repeat
    end if
    tArray = callAncestor(#getMemberNumber, [me], tdir, tHumanSize, tAction, tAnimFrame, tLayerIndex, tmodel)
  end if
  return tArray
end
