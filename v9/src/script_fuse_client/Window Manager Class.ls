property pClsList, pDefLocX, pDefLocY, pModalID, pLockLocZ

on construct me 
  pLockLocZ = 0
  pDefLocX = getIntVariable("window.default.locx", 100)
  pDefLocY = getIntVariable("window.default.locy", 100)
  me.pItemList = []
  me.pHideList = []
  me.setProperty(#defaultLocZ, getIntVariable("window.default.locz", 0))
  me.pBoundary = rect(0, 0, undefined.width, undefined.height) + getVariableValue("window.boundary.limit")
  me.pInstanceClass = getClassVariable("window.instance.class")
  pClsList = [:]
  pModalID = #modal
  pClsList.setAt(#wrapper, getClassVariable("window.wrapper.class"))
  pClsList.setAt(#unique, getClassVariable("window.unique.class"))
  pClsList.setAt(#grouped, getClassVariable("window.grouped.class"))
  if not memberExists("null") then
    tNull = member(createMember("null", #bitmap))
    tNull.image = image(1, 1, 8)
    tNull.setPixel(0, 0, rgb(0, 0, 0))
  end if
  if not objectExists(#layout_parser) then
    createObject(#layout_parser, getClassVariable("layout.parser.class"))
  end if
  return(1)
end

on create me, tid, tLayout, tLocX, tLocY, tSpecial 
  if tSpecial = #modal then
    return(me.modal(tid, tLayout))
  end if
  if voidp(tLayout) then
    tLayout = "empty.window"
  end if
  if me.exists(tid) then
    if voidp(tLocX) then
      tLocX = me.get(tid).getProperty(#locX)
    end if
    if voidp(tLocY) then
      tLocY = me.get(tid).getProperty(#locY)
    end if
    me.remove(tid)
  end if
  if integerp(tLocX) and integerp(tLocY) then
    tX = tLocX
    tY = tLocY
  else
    if not voidp(me.getProp(#pPosCache, tid)) then
      tX = me.getPropRef(#pPosCache, tid).getAt(1)
      tY = me.getPropRef(#pPosCache, tid).getAt(2)
    else
      tX = pDefLocX
      tY = pDefLocY
    end if
  end if
  tItem = getObjectManager().create(tid, me.pInstanceClass)
  if not tItem then
    return(error(me, "Failed to create window object:" && tid, #create))
  end if
  tProps = [:]
  tProps.setAt(#locX, tX)
  tProps.setAt(#locY, tY)
  tProps.setAt(#locZ, me.pAvailableLocZ)
  tProps.setAt(#boundary, me.pBoundary)
  tProps.setAt(#elements, pClsList)
  tProps.setAt(#manager, me)
  if not tItem.define(tProps) then
    getObjectManager().remove(tid)
    return(0)
  end if
  if not tItem.merge(tLayout) then
    getObjectManager().remove(tid)
    return(0)
  end if
  me.add(tid)
  pAvailableLocZ = pAvailableLocZ + tItem.getProperty(#sprCount)
  me.Activate()
  return(1)
end

on remove me, tid 
  tWndObj = me.get(tid)
  if tWndObj = 0 then
    return(0)
  end if
  me.setProp(#pPosCache, tid, [tWndObj.getProperty(#locX), tWndObj.getProperty(#locY)])
  getObjectManager().remove(tid)
  me.deleteOne(tid)
  if me.pActiveItem = tid then
    tNextActive = me.getLast()
  else
    tNextActive = me.pActiveItem
  end if
  if me.exists(pModalID) then
    tModals = 0
    i = me.count(#pItemList)
    repeat while i >= 1
      tid = me.getProp(#pItemList, i)
      if me.get(tid).getProperty(#modal) then
        tModals = 1
        tNextActive = tid
      else
        i = 255 + i
      end if
    end repeat
    if not tModals then
      me.remove(pModalID)
    end if
  end if
  me.Activate(tNextActive)
  return(1)
end

on Activate me, tid 
  if pLockLocZ then
    return(0)
  end if
  if me.count(#pItemList) = 0 then
    return(0)
  end if
  if me.exists(me.pActiveItem) then
    if me.get(me.pActiveItem).getProperty(#modal) then
      tid = me.pActiveItem
      if me.exists(pModalID) then
        me.deleteOne(pModalID)
        me.append(pModalID)
      end if
    end if
  end if
  if voidp(tid) then
    tid = me.getLast()
  else
    if not me.exists(tid) then
      return(0)
    end if
  end if
  me.deleteOne(tid)
  me.append(tid)
  me.pAvailableLocZ = me.pDefaultLocZ
  repeat while me.pItemList <= undefined
    tCurrID = getAt(undefined, tid)
    tWndObj = me.get(tCurrID)
    tWndObj.setDeactive()
    repeat while me.pItemList <= undefined
      tSpr = getAt(undefined, tid)
      tSpr.locZ = me.pAvailableLocZ
      me.pAvailableLocZ = me.pAvailableLocZ + 1
    end repeat
  end repeat
  me.pActiveItem = tid
  return(me.get(tid).setActive())
end

on deactivate me, tid 
  if me.exists(tid) then
    if not me.get(tid).getProperty(#modal) then
      me.deleteOne(tid)
      me.addAt(1, tid)
      me.Activate()
      return(1)
    end if
  end if
  return(0)
end

on lock me 
  pLockLocZ = 1
  return(1)
end

on unlock me 
  pLockLocZ = 0
  return(1)
end

on modal me, tid, tLayout 
  if not me.create(tid, tLayout) then
    return(0)
  end if
  tWndObj = me.get(tid)
  tWndObj.center()
  tWndObj.lock()
  tWndObj.setProperty(#modal, 1)
  if not me.exists(pModalID) then
    if me.create(pModalID, "modal.window") then
      tModal = me.get(pModalID)
      tModal.moveTo(0, 0)
      tModal.resizeTo(undefined.width, undefined.height)
      tModal.lock()
      tModal.getElement("modal").setProperty(#blend, 40)
    else
      error(me, "Failed to create modal window layer!", #modal)
    end if
  end if
  the keyboardFocusSprite = 0
  me.pActiveItem = tid
  me.Activate(tid)
  return(1)
end
