property pDefaultMode, pWndLoc, pState, pmode, pWindowID, pLastRead, pItemPointer, pDragStart

on construct me 
  pWindowID = "if_window"
  pState = 0
  pDefaultMode = 0
  pmode = pDefaultMode
  pDragStart = point(0, 0)
  tStageWidth = (the stageRight - the stageLeft)
  tWndLocPref = string(getPref(getVariable("infofeed.window.location.prefname")))
  if tWndLocPref <> "" then
    pWndLoc = value(tWndLocPref)
  end if
  if pWndLoc.ilk <> #point then
    pWndLoc = point((tStageWidth - 247), 4)
  end if
  registerMessage(#changeRoom, me.getID(), #minimize)
  registerMessage(#tutorial_hand_opened, me.getID(), #pushBehindHand)
  return TRUE
end

on deconstruct me 
  unregisterMessage(#changeRoom, me.getID())
  me.removeUI()
  return TRUE
end

on hide me 
  if not pState then
    return TRUE
  end if
  return(me.removeUI())
end

on toggleMode me 
  if pmode then
    return(me.minimize())
  else
    return(me.maximize())
  end if
end

on minimize me 
  if not pState then
    return FALSE
  end if
  if not pmode then
    return TRUE
  end if
  pmode = 0
  return(me.updateUI())
end

on maximize me 
  if not pState then
    return FALSE
  end if
  if pmode then
    return TRUE
  end if
  pmode = 1
  return(me.updateUI())
end

on showItem me, tItemID 
  pItemPointer = tItemID
  me.updateUI()
  return TRUE
end

on itemCreated me, tItemID 
  tItemObj = me.getComponent().getItem(tItemID)
  if tItemObj.getShowOnCreate() then
    me.maximize()
    return(me.showItem(tItemID))
  else
    return(me.updateUI())
  end if
end

on createUI me 
  if not me.checkContentToDisplay() then
    return TRUE
  end if
  if not windowExists(pWindowID) then
    createWindow(pWindowID)
    tWndObj = getWindow(pWindowID)
    if (tWndObj = 0) then
      return FALSE
    end if
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProc, me.getID(), #mouseDown)
    pmode = 0
    tWndObj.moveTo(pWndLoc.locH, pWndLoc.locV)
  end if
  pState = 1
  return TRUE
end

on removeUI me 
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  pState = 0
  pmode = pDefaultMode
  return TRUE
end

on updateUI me 
  if not me.checkContentToDisplay() then
    return TRUE
  end if
  if not pState then
    me.createUI()
  end if
  if pmode then
    return(me.updateFullUI())
  else
    return(me.updateMinUI())
  end if
end

on updateMinUI me 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.unmerge()
  tItemRef = me.getCurrentItem()
  if (tItemRef = 0) then
    return(me.checkContentToDisplay())
  end if
  if (pLastRead = me.getComponent().getItemCount()) then
    tItemRef.renderMinDefault(tWndObj)
  else
    tItemRef.renderMin(tWndObj)
  end if
  return TRUE
end

on updateFullUI me 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.unmerge()
  tItemRef = me.getCurrentItem()
  if (tItemRef = 0) then
    return(me.checkContentToDisplay())
  end if
  tComponent = me.getComponent()
  tItemPos = tComponent.getItemPos(pItemPointer)
  tItemCount = tComponent.getItemCount()
  tItemRef.renderFull(tWndObj, tItemPos, tItemCount)
  if pLastRead < tItemPos then
    pLastRead = tItemPos
  end if
  return TRUE
end

on checkContentToDisplay me 
  if me.getCurrentItem() <> 0 then
    return TRUE
  end if
  pItemPointer = me.getComponent().getLatestItemId()
  if me.getCurrentItem() <> 0 then
    return TRUE
  end if
  me.removeUI()
  return FALSE
end

on pushBehindHand me 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  tStageWidth = (the stageRight - the stageLeft)
  if (pWndLoc.locH + tWndObj.getProperty(#width)) > (tStageWidth - 325) and pWndLoc.locV < 178 then
    tWndObj.setProperty(#locZ, -1000000)
    tWndObj.lock(1)
  end if
end

on getItemPointer me 
  if (me.getComponent().getItemCount() = 0) then
    return(-1)
  end if
  return(pItemPointer)
end

on getCurrentItem me 
  tItemRef = me.getComponent().getItem(me.getItemPointer())
  return(tItemRef)
end

on showNextItem me 
end

on saveWindowPosition me 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  pWndLoc = point(tWndObj.getProperty(#locX), tWndObj.getProperty(#locY))
  setPref(getVariable("infofeed.window.location.prefname"), string(pWndLoc))
end

on eventProc me, tEvent, tElemID, tParam 
  tWndObj = getWindow(pWindowID)
  if (tWndObj = 0) then
    return FALSE
  end if
  if (tEvent = #mouseUp) then
    if (tEvent = "if_title") then
      tWndObj.drag(0)
      if (pDragStart = the mouseLoc) then
        return(me.toggleMode())
      else
        me.saveWindowPosition()
      end if
      return TRUE
    else
      if (tEvent = "if_btn_toggle") then
        return(me.toggleMode())
      else
        if (tEvent = "if_btn_prev") then
          me.getComponent().executePrevCallbacks(me.getItemPointer())
          tID = me.getComponent().getPreviousFrom(pItemPointer)
          return(me.showItem(tID))
        else
          if (tEvent = "if_btn_next") then
            me.getComponent().executeNextCallbacks(me.getItemPointer())
            tID = me.getComponent().getNextFrom(pItemPointer)
            return(me.showItem(tID))
          end if
        end if
      end if
    end if
  else
    if (tEvent = #mouseDown) then
      tWndObj.lock(0)
      if (tEvent = "if_title") then
        pDragStart = the mouseLoc
        tWndObj.drag(1)
      end if
    end if
  end if
  return TRUE
end
