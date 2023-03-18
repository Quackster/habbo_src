property pVisualizer, pShadowWrapper, pRenderDisabled

on construct me
  pRenderDisabled = 0
  return 1
end

on deconstruct me
  return 1
end

on define me, tWrapID
  pVisualizer = getThread(#room).getInterface().getRoomVisualizer()
  pShadowWrapper = pVisualizer.createWrapper(tWrapID)
  tProps = [:]
  tProps[#id] = tWrapID
  tProps[#offsetx] = 0
  tProps[#offsety] = 0
  tProps[#locZ] = pVisualizer.getProperty(#locZ) - 9000
  tProps[#typeDef] = #other
  pShadowWrapper.define(tProps)
  pShadowWrapper.setProperty(#blend, 30)
  pShadowWrapper.setProperty(#ink, 41)
  pShadowWrapper.setProperty(#palette, #grayscale)
  return 1
end

on addShadow me, tProps
  tmember = tProps[#member]
  if memberExists(tmember) then
    pShadowWrapper.addPart(tProps)
    pShadowWrapper.setProperty(#ink, 36)
  else
    put tProps[#member]
  end if
end

on removeShadow me, tid
  if pRenderDisabled then
    return 0
  end if
  if not voidp(pShadowWrapper) then
    pShadowWrapper.removePart(tid)
  end if
end

on disableRender me, tDisable
  if tDisable then
    pRenderDisabled = 1
  else
    pRenderDisabled = 0
  end if
end

on render me
  if pRenderDisabled then
    return 0
  end if
  pShadowWrapper.updateWrap()
end
