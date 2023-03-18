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
  if ilk(tdata) <> #propList then
    return error(me, "Node data was not a proplist", #feedData, #major)
  end if
  pData = tdata
  if tdata.getaProp(#navigateable) then
    tRenderer = createObject(#random, "Treeview Node Renderer Class")
    if tRenderer = 0 then
      return error(me, "Unable to create node renderer", #feedData, #major)
    else
      pRenderer = tRenderer
      pRenderer.define(me, [#width: tWidth])
    end if
  end if
  return 1
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
  if voidp(pRenderer) or (pRenderer = 0) then
    return VOID
  end if
  return pRenderer.getImage()
end
