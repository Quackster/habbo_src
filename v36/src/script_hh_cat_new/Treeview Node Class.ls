on construct(me)
  pChildren = []
  pRenderer = void()
  pData = void()
  pState = #closed
  pSelected = 0
  exit
end

on deconstruct(me)
  tChildren = pChildren.duplicate()
  repeat while me <= undefined
    tChild = getAt(undefined, undefined)
    if objectp(tChild) then
      if tChild.valid then
        removeObject(tChild.getID())
      end if
    end if
  end repeat
  pChildren = []
  pData = void()
  if objectp(pRenderer) then
    removeObject(pRenderer.getID())
  end if
  exit
end

on feedData(me, tdata, tWidth)
  if ilk(tdata) <> #propList then
    return(error(me, "Node data was not a proplist", #feedData, #major))
  end if
  pData = tdata
  if tdata.getaProp(#navigateable) then
    tRenderer = createObject(#random, "Treeview Node Renderer Class")
    if tRenderer = 0 then
      return(error(me, "Unable to create node renderer", #feedData, #major))
    else
      pRenderer = tRenderer
      pRenderer.define(me, [#width:tWidth])
    end if
  end if
  return(1)
  exit
end

on getData(me, tKey)
  if ilk(pData) <> #propList then
    return(void())
  end if
  return(pData.getaProp(tKey))
  exit
end

on addChild(me, tChild)
  pChildren.add(tChild)
  exit
end

on getChildren(me)
  return(pChildren)
  exit
end

on hasChildren(me)
  if pChildren.count < 0 then
    return(0)
  end if
  tChildVisible = 0
  repeat while me <= undefined
    tChild = getAt(undefined, undefined)
    if tChild.getData(#navigateable) then
      tChildVisible = 1
    end if
  end repeat
  return(tChildVisible)
  exit
end

on setState(me, tstate)
  if pState <> tstate then
    pState = tstate
    if not voidp(pRenderer) then
      pRenderer.setState(tstate)
    end if
  end if
  exit
end

on select(me, tstate)
  if pSelected <> tstate then
    pSelected = tstate
    if not voidp(pRenderer) then
      pRenderer.select(tstate)
    end if
  end if
  exit
end

on getState(me)
  return(pState)
  exit
end

on getSelected(me)
  return(pSelected)
  exit
end

on getImage(me)
  if voidp(pRenderer) or pRenderer = 0 then
    return(void())
  end if
  return(pRenderer.getImage())
  exit
end