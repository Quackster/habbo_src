on construct(me)
  pWindowID = "if_window"
  pState = 0
  pDefaultMode = 0
  pmode = pDefaultMode
  pDragStart = point(0, 0)
  tStageWidth = the stageRight - the stageLeft
  pWndLoc = point(tStageWidth - 247, 4)
  tWndLocPref = string(getPref(getVariable("infofeed.window.location.prefname")))
  if tWndLocPref <> "" then
    pWndLoc = value(tWndLocPref)
  end if
  registerMessage(#changeRoom, me.getID(), #minimize)
  registerMessage(#tutorial_hand_opened, me.getID(), #pushBehindHand)
  return(1)
  exit
end

on deconstruct(me)
  unregisterMessage(#changeRoom, me.getID())
  me.removeUI()
  return(1)
  exit
end

on hide(me)
  if not pState then
    return(1)
  end if
  return(me.removeUI())
  exit
end

on toggleMode(me)
  if pmode then
    return(me.minimize())
  else
    return(me.maximize())
  end if
  exit
end

on minimize(me)
  if not pState then
    return(0)
  end if
  if not pmode then
    return(1)
  end if
  pmode = 0
  return(me.updateUI())
  exit
end

on maximize(me)
  if not pState then
    return(0)
  end if
  if pmode then
    return(1)
  end if
  pmode = 1
  return(me.updateUI())
  exit
end

on showItem(me, tItemID)
  pItemPointer = tItemID
  me.updateUI()
  return(1)
  exit
end

on itemCreated(me, tItemID)
  tItemObj = me.getComponent().getItem(tItemID)
  if tItemObj.getShowOnCreate() then
    me.maximize()
    return(me.showItem(tItemID))
  else
    return(me.updateUI())
  end if
  exit
end

on createUI(me)
  if not me.checkContentToDisplay() then
    return(1)
  end if
  if not windowExists(pWindowID) then
    createWindow(pWindowID)
    tWndObj = getWindow(pWindowID)
    if tWndObj = 0 then
      return(0)
    end if
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProc, me.getID(), #mouseDown)
    pmode = 0
    tWndObj.moveTo(pWndLoc.locH, pWndLoc.locV)
  end if
  pState = 1
  return(1)
  exit
end

on removeUI(me)
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  pState = 0
  pmode = pDefaultMode
  return(1)
  exit
end

on updateUI(me)
  if not me.checkContentToDisplay() then
    return(1)
  end if
  if not pState then
    me.createUI()
  end if
  if pmode then
    return(me.updateFullUI())
  else
    return(me.updateMinUI())
  end if
  exit
end

on updateMinUI(me)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.unmerge()
  tItemRef = me.getCurrentItem()
  if tItemRef = 0 then
    return(me.checkContentToDisplay())
  end if
  if pLastRead = me.getComponent().getItemCount() then
    tItemRef.renderMinDefault(tWndObj)
  else
    tItemRef.renderMin(tWndObj)
  end if
  return(1)
  exit
end

on updateFullUI(me)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.unmerge()
  tItemRef = me.getCurrentItem()
  if tItemRef = 0 then
    return(me.checkContentToDisplay())
  end if
  tComponent = me.getComponent()
  tItemPos = tComponent.getItemPos(pItemPointer)
  tItemCount = tComponent.getItemCount()
  tItemRef.renderFull(tWndObj, tItemPos, tItemCount)
  if pLastRead < tItemPos then
    pLastRead = tItemPos
  end if
  return(1)
  exit
end

on checkContentToDisplay(me)
  if me.getCurrentItem() <> 0 then
    return(1)
  end if
  pItemPointer = me.getComponent().getLatestItemId()
  if me.getCurrentItem() <> 0 then
    return(1)
  end if
  me.removeUI()
  return(0)
  exit
end

on pushBehindHand(me)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  tStageWidth = the stageRight - the stageLeft
  if pWndLoc.locH + tWndObj.getProperty(#width) > tStageWidth - 325 and pWndLoc.locV < 178 then
    -- UNK_40 9
    ERROR.setProperty()
    tWndObj.lock(1)
  end if
  exit
end

on getItemPointer(me)
  if me.getComponent().getItemCount() = 0 then
    return(-1)
  end if
  return(pItemPointer)
  exit
end

on getCurrentItem(me)
  tItemRef = me.getComponent().getItem(me.getItemPointer())
  return(tItemRef)
  exit
end

on showNextItem(me)
  exit
end

on saveWindowPosition(me)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  pWndLoc = point(tWndObj.getProperty(#locX), tWndObj.getProperty(#locY))
  setPref(getVariable("infofeed.window.location.prefname"), string(pWndLoc))
  exit
end

on eventProc(me, tEvent, tElemID, tParam)
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(0)
  end if
  if me = #mouseUp then
    if me = "if_title" then
      tWndObj.drag(0)
      if pDragStart = the mouseLoc then
        return(me.toggleMode())
      else
        me.saveWindowPosition()
      end if
      return(1)
    else
      if me = "if_btn_toggle" then
        return(me.toggleMode())
      else
        if me = "if_btn_prev" then
          me.getComponent().executePrevCallbacks(me.getItemPointer())
          tID = me.getComponent().getPreviousFrom(pItemPointer)
          return(me.showItem(tID))
        else
          if me = "if_btn_next" then
            me.getComponent().executeNextCallbacks(me.getItemPointer())
            tID = me.getComponent().getNextFrom(pItemPointer)
            return(me.showItem(tID))
          end if
        end if
      end if
    end if
  else
    if me = #mouseDown then
      tWndObj.lock(0)
      if me = "if_title" then
        pDragStart = the mouseLoc
        tWndObj.drag(1)
      end if
    end if
  end if
  return(1)
  exit
end