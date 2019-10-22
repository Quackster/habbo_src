property pUnderWater, pSwimProps

on define me, tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart 
  pSwimProps = [#maskImage:0, #ink:0, #bgColor:rgb(0, 156, 156), #color:rgb(0, 156, 156), #blend:60]
  callAncestor(#define, [me], tPart, tmodel, tColor, tDirection, tAction, tBody, tFlipPart)
  pUnderWater = 1
  return TRUE
end

on update me, tForcedUpdate, tRectMod 
  callAncestor(#update, [me], tForcedUpdate, tRectMod)
  if pUnderWater and me.pBody.pSwim then
    i = 1
    repeat while i <= me.count(#pLayerPropList)
      tdata = me.getProp(#pLayerPropList, i)
      tDrawProps = tdata.getAt("drawProps")
      pSwimProps.setAt(#maskImage, tDrawProps.getAt(#maskImage))
      tDrawArea = me.getDrawArea(i)
      if tdata.getAt("cacheImage") <> 0 then
        me.pBody.pBuffer.copyPixels(tdata.getAt("cacheImage"), tDrawArea, tdata.getAt("cacheImage").rect, pSwimProps)
      end if
      i = (1 + i)
    end repeat
  end if
end

on render me 
  callAncestor(#render, [me])
  i = 1
  repeat while i <= me.count(#pLayerPropList)
    tdata = me.getProp(#pLayerPropList, i)
    if memberExists(tdata.getAt("memString")) then
      if me.pBody.pSwim then
        pSwimProps.setAt(#maskImage, tdata.getAt("drawProps").getAt(#maskImage))
        tDrawArea = me.getDrawArea(i)
        if tdata.getAt("cacheImage") <> 0 then
          me.pBody.pBuffer.copyPixels(tdata.getAt("cacheImage"), tDrawArea, tdata.getAt("cacheImage").rect, pSwimProps)
        end if
      end if
    end if
    i = (1 + i)
  end repeat
end

on defineInk me, tInk 
  callAncestor(#defineInk, [me], tInk)
  if me.count(#pLayerPropList) > 0 then
    pSwimProps.setAt(#ink, me.getPropRef(#pLayerPropList, 1).getAt("drawProps").getAt(#ink))
    return TRUE
  end if
  return FALSE
end

on setUnderWater me, tUnderWater 
  pUnderWater = tUnderWater
end

on getMemberNumber me, tdir, tHumanSize, tAction, tAnimFrame, tLayerIndex 
  tArray = callAncestor(#getMemberNumber, [me], tdir, tHumanSize, tAction, tAnimFrame, tLayerIndex)
  tMemNum = tArray.getAt(#memberNumber)
  if (tMemNum = 0) then
    if voidp(tLayerIndex) then
      tLayerIndex = 1
    end if
    if tLayerIndex < 1 or tLayerIndex > me.count(#pLayerPropList) then
      tLayerIndex = 1
    end if
    if me.count(#pLayerPropList) >= tLayerIndex then
      tmodel = me.getPropRef(#pLayerPropList, tLayerIndex).getAt("model")
    end if
    if not voidp(tmodel) then
      tmodel = tmodel.getProp(#char, 2, tmodel.length)
      repeat while (tmodel.getProp(#char, 1) = "0")
        tmodel = tmodel.getProp(#char, 2, tmodel.length)
      end repeat
    end if
    tArray = callAncestor(#getMemberNumber, [me], tdir, tHumanSize, tAction, tAnimFrame, tLayerIndex, tmodel)
  end if
  return(tArray)
end
