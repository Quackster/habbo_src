property pDefaultLocZ, pInstanceClass, pAvailableLocZ, pBoundary, pPosCache, pActiveItem, pHideList

on construct me 
  pInstanceClass = getClassVariable("visualizer.instance.class")
  pActiveItem = ""
  pPosCache = [:]
  pHideList = []
  pDefaultLocZ = getIntVariable("visualizer.default.locz", -20000000)
  pAvailableLocZ = pDefaultLocZ
  pBoundary = (rect(0, 0, the stage.rect.width, the stage.rect.height) + getVariableValue("visualizer.boundary.limit"))
  if not objectExists(#layout_parser) then
    createObject(#layout_parser, getClassVariable("layout.parser.class"))
  end if
  return TRUE
end

on create me, tID, tLayout, tLocX, tLocY 
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
  tProps = [:]
  tProps.setAt(#locX, tLocX)
  tProps.setAt(#locY, tLocY)
  tProps.setAt(#locZ, pAvailableLocZ)
  tProps.setAt(#layout, tLayout)
  tProps.setAt(#boundary, pBoundary)
  if not tItem.define(tProps) then
    getObjectManager().Remove(tID)
    return FALSE
  end if
  me.pItemList.add(tID)
  pAvailableLocZ = (pAvailableLocZ + tItem.getProperty(#sprCount))
  return TRUE
end

on Remove me, tID 
  if not me.exists(tID) then
    return FALSE
  end if
  tItem = me.GET(tID)
  pAvailableLocZ = (pAvailableLocZ - tItem.getProperty(#sprCount))
  pPosCache.setAt(tID, [tItem.getProperty(#locX), tItem.getProperty(#locY)])
  me.pItemList.deleteOne(tID)
  if (pActiveItem = tID) then
    pActiveItem = me.pItemList.getLast()
  end if
  getObjectManager().Remove(tID)
  me.Activate(me.pItemList.getLast())
  return TRUE
end

on Activate me, tID 
  if me.exists(tID) then
    pActiveItem = tID
    me.GET(tID).setActive()
    return TRUE
  else
    return FALSE
  end if
end

on deactivate me, tID 
  if me.exists(tID) then
    me.GET(tID).setDeactive()
    return TRUE
  else
    return FALSE
  end if
end

on hideAll me 
  repeat while me.pItemList <= undefined
    tItem = getAt(undefined, undefined)
    tObj = me.GET(tItem)
    if tObj.getProperty(#visible) then
      tObj.hide()
      pHideList.add(tItem)
    end if
  end repeat
  return TRUE
end

on showAll me 
  repeat while pHideList <= undefined
    tItem = getAt(undefined, undefined)
    tObj = me.GET(tItem)
    if tObj <> 0 then
      tObj.show()
    end if
  end repeat
  pHideList = []
  return TRUE
end

on getProperty me, tProp 
  if (tProp = #defaultLocZ) then
    return(pDefaultLocZ)
  else
    if (tProp = #boundary) then
      return(pBoundary)
    else
      if (tProp = #count) then
        return(me.count(#pItemList))
      end if
    end if
  end if
  return FALSE
end

on setProperty me, tProp, tValue 
  if (tProp = #defaultLocZ) then
    return(me.setDefaultLocZ(tValue))
  else
    if (tProp = #boundary) then
      return(me.setBoundary(tValue))
    end if
  end if
  return FALSE
end

on setDefaultLocZ me, tValue 
  if not integerp(tValue) then
    return(error(me, "integer expected:" && tValue, #setDefaultLocZ, #minor))
  end if
  pDefaultLocZ = tValue
  return(Activate(me))
end

on setBoundary me, tValue 
  if not listp(tValue) and not ilk(tValue, #rect) then
    return(error(me, "List or rect expected:" && tValue, #setBoundary, #minor))
  end if
  pBoundary.setAt(1, tValue.getAt(1))
  pBoundary.setAt(2, tValue.getAt(2))
  pBoundary.setAt(3, tValue.getAt(3))
  pBoundary.setAt(4, tValue.getAt(4))
  call(#moveBy, me.pItemList, 0, 0)
  return TRUE
end
