property pVisualizer, pShadowWrapper, pRenderDisabled

on construct me 
  pRenderDisabled = 0
  return TRUE
end

on deconstruct me 
  return TRUE
end

on define me, tWrapID 
  pVisualizer = getThread(#room).getInterface().getRoomVisualizer()
  pShadowWrapper = pVisualizer.createWrapper(tWrapID)
  tProps = [:]
  tProps.setAt(#id, tWrapID)
  tProps.setAt(#offsetx, 0)
  tProps.setAt(#offsety, 0)
  tProps.setAt(#locZ, (pVisualizer.getProperty(#locZ) - 9000))
  tProps.setAt(#typeDef, #other)
  pShadowWrapper.define(tProps)
  pShadowWrapper.setProperty(#blend, 30)
  pShadowWrapper.setProperty(#ink, 41)
  pShadowWrapper.setProperty(#palette, #grayscale)
  return TRUE
end

on addShadow me, tProps 
  tmember = tProps.getAt(#member)
  if memberExists(tmember) then
    pShadowWrapper.addPart(tProps)
    pShadowWrapper.setProperty(#ink, 36)
  else
    put(tProps.getAt(#member))
  end if
end

on removeShadow me, tid 
  if pRenderDisabled then
    return FALSE
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
    return FALSE
  end if
  pShadowWrapper.updateWrap()
end
