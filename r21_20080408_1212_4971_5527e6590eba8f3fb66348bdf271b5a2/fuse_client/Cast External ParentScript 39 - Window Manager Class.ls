property pLockLocZ, pDefLocX, pDefLocY, pClsList, pModalID, pLastEventData

on construct me
  pLastEventData = [:]
  pLockLocZ = 0
  pDefLocX = getIntVariable("window.default.locx", 100)
  pDefLocY = getIntVariable("window.default.locy", 100)
  me.pItemList = []
  me.pHideList = []
  me.setProperty(#defaultLocZ, getIntVariable("window.default.locz", 0))
  me.pBoundary = rect(0, 0, (the stage).rect.width, (the stage).rect.height) + getVariableValue("window.boundary.limit")
  me.pInstanceClass = getClassVariable("window.instance.class")
  pClsList = [:]
  pModalID = #modal
  pClsList[#wrapper] = getClassVariable("window.wrapper.class")
  pClsList[#unique] = getClassVariable("window.unique.class")
  pClsList[#grouped] = getClassVariable("window.grouped.class")
  if not memberExists("null") then
    tNull = member(createMember("null", #bitmap))
    tNull.image = image(1, 1, 8)
    tNull.image.setPixel(0, 0, rgb(0, 0, 0))
  end if
  if not objectExists(#layout_parser) then
    createObject(#layout_parser, getClassVariable("layout.parser.class"))
  end if
  return 1
end

on create me, tID, tLayout, tLocX, tLocY, tSpecial
  case tSpecial of
    #modal:
      return me.modal(tID, tLayout)
    #modalcorner:
      return me.modal(tID, tLayout, #corner)
  end case
  if voidp(tLayout) then
    tLayout = "empty.window"
  end if
  if me.exists(tID) then
    if voidp(tLocX) then
      tLocX = me.GET(tID).getProperty(#locX)
    end if
    if voidp(tLocY) then
      tLocY = me.GET(tID).getProperty(#locY)
    end if
    me.Remove(tID)
  end if
  if integerp(tLocX) and integerp(tLocY) then
    tX = tLocX
    tY = tLocY
  else
    if not voidp(me.pPosCache[tID]) then
      tX = me.pPosCache[tID][1]
      tY = me.pPosCache[tID][2]
    else
      tX = pDefLocX
      tY = pDefLocY
    end if
  end if
  tItem = getObjectManager().create(tID, me.pInstanceClass)
  if not tItem then
    return error(me, "Failed to create window object:" && tID, #create, #major)
  end if
  tProps = [:]
  tProps[#locX] = tX
  tProps[#locY] = tY
  tProps[#locZ] = me.pAvailableLocZ
  tProps[#boundary] = me.pBoundary
  tProps[#elements] = pClsList
  tProps[#manager] = me
  if not tItem.define(tProps) then
    getObjectManager().Remove(tID)
    return 0
  end if
  if not tItem.merge(tLayout) then
    getObjectManager().Remove(tID)
    return 0
  end if
  me.pItemList.add(tID)
  pAvailableLocZ = pAvailableLocZ + tItem.getProperty(#sprCount)
  me.Activate()
  return 1
end

on Remove me, tID
  tWndObj = me.GET(tID)
  if tWndObj = 0 then
    return 0
  end if
  me.pPosCache[tID] = [tWndObj.getProperty(#locX), tWndObj.getProperty(#locY)]
  getObjectManager().Remove(tID)
  me.pItemList.deleteOne(tID)
  if me.pActiveItem = tID then
    tNextActive = me.pItemList.getLast()
  else
    tNextActive = me.pActiveItem
  end if
  if me.exists(pModalID) then
    tModals = 0
    repeat with i = me.pItemList.count down to 1
      tID = me.pItemList[i]
      if me.GET(tID).getProperty(#modal) then
        tModals = 1
        tNextActive = tID
        exit repeat
      end if
    end repeat
    if not tModals then
      me.Remove(pModalID)
    end if
  end if
  me.Activate(tNextActive)
  return 1
end

on Activate me, tID
  if pLockLocZ then
    return 0
  end if
  if me.pItemList.count = 0 then
    return 0
  end if
  if me.exists(me.pActiveItem) then
    if me.GET(me.pActiveItem).getProperty(#modal) then
      tID = me.pActiveItem
      if me.exists(pModalID) then
        me.pItemList.deleteOne(pModalID)
        me.pItemList.append(pModalID)
      end if
    end if
  end if
  if voidp(tID) then
    tID = me.pItemList.getLast()
  else
    if not me.exists(tID) then
      return 0
    end if
  end if
  me.pItemList.deleteOne(tID)
  me.pItemList.append(tID)
  me.pAvailableLocZ = me.pDefaultLocZ
  repeat with tCurrID in me.pItemList
    tWndObj = me.GET(tCurrID)
    tWndObj.setDeactive()
    repeat with tSpr in tWndObj.getProperty(#spriteList)
      tSpr.locZ = me.pAvailableLocZ
      me.pAvailableLocZ = me.pAvailableLocZ + 1
    end repeat
  end repeat
  me.pActiveItem = tID
  return me.GET(tID).setActive()
end

on reorder me, tNewOrder
  if tNewOrder = me.pItemList then
    return 1
  end if
  me.pItemList = tNewOrder
  me.pAvailableLocZ = me.pDefaultLocZ
  repeat with tCurrID in me.pItemList
    tWndObj = me.GET(tCurrID)
    repeat with tSpr in tWndObj.getProperty(#spriteList)
      tSpr.locZ = me.pAvailableLocZ
      me.pAvailableLocZ = me.pAvailableLocZ + 1
    end repeat
  end repeat
end

on deactivate me, tID
  if me.exists(tID) then
    if not me.GET(tID).getProperty(#modal) then
      me.pItemList.deleteOne(tID)
      me.pItemList.addAt(1, tID)
      me.Activate()
      return 1
    end if
  end if
  return 0
end

on lock me
  pLockLocZ = 1
  return 1
end

on unlock me
  pLockLocZ = 0
  return 1
end

on modal me, tID, tLayout, tPosition
  if voidp(tPosition) then
    tPosition = #center
  end if
  if not me.create(tID, tLayout) then
    return 0
  end if
  tWndObj = me.GET(tID)
  case tPosition of
    #center:
      tWndObj.center()
    #corner:
      tWndObj.moveTo(0, 0)
  end case
  tWndObj.lock()
  tWndObj.setProperty(#modal, 1)
  if not me.exists(pModalID) then
    if me.create(pModalID, "modal.window") then
      tModal = me.GET(pModalID)
      tModal.moveTo(0, 0)
      tModal.resizeTo((the stage).rect.width, (the stage).rect.height)
      tModal.lock()
      tModal.getElement("modal").setProperty(#blend, 40)
    else
      error(me, "Failed to create modal window layer!", #modal, #major)
    end if
  end if
  the keyboardFocusSprite = 0
  me.pActiveItem = tID
  me.Activate(tID)
  return 1
end

on registerWindowEvent me, tTitle, tSprID, tEvent
  pLastEventData[#title] = tTitle
  pLastEventData[#sprite] = tSprID
  pLastEventData[#event] = tEvent
end

on getLastEvent me
  return pLastEventData[#title] & "-" & pLastEventData[#sprite] & "-" & pLastEventData[#event]
end
