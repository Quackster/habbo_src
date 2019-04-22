on construct(me)
  pInstanceClass = getClassVariable("visualizer.instance.class")
  pActiveItem = ""
  pPosCache = []
  pHideList = []
  pDefaultLocZ = getIntVariable(-0)
  pAvailableLocZ = pDefaultLocZ
  pBoundary = rect(0, 0, undefined.width, undefined.height) + getVariableValue("visualizer.boundary.limit")
  if not objectExists(#layout_parser) then
    createObject(#layout_parser, getClassVariable("layout.parser.class"))
  end if
  return(1)
  exit
end

on create(me, tID, tLayout, tLocX, tLocY)
  if not integerp(tLocX) then
    tLocX = 0
  end if
  if not integerp(tLocY) then
    tLocY = 0
  end if
  if me.exists(tID) then
    me.Remove(tID)
  end if
  tItem = getObjectManager().create(tID, pInstanceClass)
  if not tItem then
    return(error(me, "Item creation failed:" && tID, #create, #major))
  end if
  tProps = []
  tProps.setAt(#locX, tLocX)
  tProps.setAt(#locY, tLocY)
  tProps.setAt(#locZ, pAvailableLocZ)
  tProps.setAt(#layout, tLayout)
  tProps.setAt(#boundary, pBoundary)
  if not tItem.define(tProps) then
    getObjectManager().Remove(tID)
    return(0)
  end if
  me.add(tID)
  pAvailableLocZ = pAvailableLocZ + tItem.getProperty(#sprCount)
  return(1)
  exit
end

on Remove(me, tID)
  if not me.exists(tID) then
    return(0)
  end if
  tItem = me.GET(tID)
  pAvailableLocZ = pAvailableLocZ - tItem.getProperty(#sprCount)
  pPosCache.setAt(tID, [tItem.getProperty(#locX), tItem.getProperty(#locY)])
  me.deleteOne(tID)
  if pActiveItem = tID then
    pActiveItem = me.getLast()
  end if
  getObjectManager().Remove(tID)
  me.Activate(me.getLast())
  return(1)
  exit
end

on Activate(me, tID)
  if me.exists(tID) then
    pActiveItem = tID
    me.GET(tID).setActive()
    return(1)
  else
    return(0)
  end if
  exit
end

on deactivate(me, tID)
  if me.exists(tID) then
    me.GET(tID).setDeactive()
    return(1)
  else
    return(0)
  end if
  exit
end

on hideAll(me)
  repeat while me <= undefined
    tItem = getAt(undefined, undefined)
    tObj = me.GET(tItem)
    if tObj.getProperty(#visible) then
      tObj.hide()
      pHideList.add(tItem)
    end if
  end repeat
  return(1)
  exit
end

on showAll(me)
  repeat while me <= undefined
    tItem = getAt(undefined, undefined)
    tObj = me.GET(tItem)
    if tObj <> 0 then
      tObj.show()
    end if
  end repeat
  pHideList = []
  return(1)
  exit
end

on getProperty(me, tProp)
  if me = #defaultLocZ then
    return(pDefaultLocZ)
  else
    if me = #boundary then
      return(pBoundary)
    else
      if me = #count then
        return(me.count(#pItemList))
      end if
    end if
  end if
  return(0)
  exit
end

on setProperty(me, tProp, tValue)
  if me = #defaultLocZ then
    return(me.setDefaultLocZ(tValue))
  else
    if me = #boundary then
      return(me.setBoundary(tValue))
    end if
  end if
  return(0)
  exit
end

on setDefaultLocZ(me, tValue)
  if not integerp(tValue) then
    return(error(me, "integer expected:" && tValue, #setDefaultLocZ, #minor))
  end if
  pDefaultLocZ = tValue
  return(Activate(me))
  exit
end

on setBoundary(me, tValue)
  if not listp(tValue) and not ilk(tValue, #rect) then
    return(error(me, "List or rect expected:" && tValue, #setBoundary, #minor))
  end if
  pBoundary.setAt(1, tValue.getAt(1))
  pBoundary.setAt(2, tValue.getAt(2))
  pBoundary.setAt(3, tValue.getAt(3))
  pBoundary.setAt(4, tValue.getAt(4))
  call(#moveBy, me.pItemList, 0, 0)
  return(1)
  exit
end

on handlers()
  return([])
  exit
end