property pChildren, pRenderer, pData, pState, pSelected

on construct me
  pChildren = []
  pRenderer = VOID
  pData = VOID
  pState = #closed
  pSelected = 0
end

on deconstruct me
  tChildren = pChildren.duplicate()
  repeat with tChild in tChildren
    if objectp(tChild) then
      if tChild.valid then
        removeObject(tChild.getID())
      end if
    end if
  end repeat
  pChildren = []
  pData = VOID
  if objectp(pRenderer) then
    removeObject(pRenderer.getID())
  end if
end

on feedData me, tdata, tWidth
  pData = tdata
  if tdata[#navigateable] then
    pRenderer = createObject(#random, "Treeview Node Renderer Class")
    pRenderer.define(me, [#width: tWidth])
  end if
end

on getData me, tKey
  if ilk(pData) <> #propList then
    return VOID
  end if
  return pData.getaProp(tKey)
end

on addChild me, tChild
  pChildren.add(tChild)
end

on getChildren me
  return pChildren
end

on hasChildren me
  if pChildren.count < 0 then
    return 0
  end if
  tChildVisible = 0
  repeat with tChild in pChildren
    if tChild.getData(#navigateable) then
      tChildVisible = 1
    end if
  end repeat
  return tChildVisible
end

on setState me, tstate
  if pState <> tstate then
    pState = tstate
    if not voidp(pRenderer) then
      pRenderer.setState(tstate)
    end if
  end if
end

on select me, tstate
  if pSelected <> tstate then
    pSelected = tstate
    if not voidp(pRenderer) then
      pRenderer.select(tstate)
    end if
  end if
end

on getState me
  return pState
end

on getSelected me
  return pSelected
end

on getImage me
  if voidp(pRenderer) then
    return VOID
  else
    return pRenderer.getImage()
  end if
end
