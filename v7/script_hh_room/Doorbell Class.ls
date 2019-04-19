on construct(me)
  pDoorbellQueue = []
  pDoorbellWinID = getText("win_doorbell", "Doorbell")
  exit
end

on deconstruct(me)
  exit
end

on addDoorbellRinger(me, tName)
  if pDoorbellQueue.getPos(tName) > 0 then
    return(0)
  end if
  if not windowExists(pDoorbellWinID) then
    if not createWindow(pDoorbellWinID, "habbo_basic.window", 250, 200) then
      return(error(me, "Couldn't create window to show ringing doorbell!", #showDoorBell))
    end if
    tWndObj = getWindow(pDoorbellWinID)
    if not tWndObj.merge("habbo_doorbell.window") then
      return(tWndObj.close())
    end if
    -- UNK_80 16899
    tWndObj.lock(1)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcDoorBell, me.getID(), #mouseUp)
  end if
  pDoorbellQueue.append(tName)
  pRingingUser = pDoorbellQueue.count
  me.updateDoorbellWindow()
  return(1)
  exit
end

on removeRingingUser(me)
  pDoorbellQueue.deleteAt(pRingingUser)
  me.updateDoorbellWindow()
  return(1)
  exit
end

on removeFromList(me, tName)
  tRemoved = pDoorbellQueue.deleteOne(tName)
  if tRemoved then
    me.updateDoorbellWindow()
  end if
  exit
end

on displayNextDoorbellRinger(me)
  pRingingUser = pRingingUser + 1
  if pRingingUser > pDoorbellQueue.count then
    pRingingUser = 1
  end if
  me.updateDoorbellWindow()
  return(1)
  exit
end

on displayPreviousDoorbellRinger(me)
  pRingingUser = pRingingUser - 1
  if pRingingUser < 1 then
    pRingingUser = pDoorbellQueue.count
  end if
  me.updateDoorbellWindow()
  return(1)
  exit
end

on updateDoorbellWindow(me)
  if pDoorbellQueue = [] then
    me.hideDoorBell()
    return(1)
  end if
  if pRingingUser > pDoorbellQueue.count then
    pRingingUser = pDoorbellQueue.count
  end if
  if not windowExists(pDoorbellWinID) then
    return(0)
  end if
  tWndObj = getWindow(pDoorbellWinID)
  tText = getText("room_doorbell", "rings the doorbell...")
  tWndObj.getElement("doorbell_name").setText(pDoorbellQueue.getAt(pRingingUser))
  tWndObj.getElement("doorbell_text").setText(tText)
  if pDoorbellQueue.count > 1 then
    tWndObj.getElement("doorbell_next").show()
    tWndObj.getElement("doorbell_prev").show()
    tCountText = pRingingUser & "/" & pDoorbellQueue.count
  else
    tWndObj.getElement("doorbell_next").hide()
    tWndObj.getElement("doorbell_prev").hide()
    tCountText = ""
  end if
  tWndObj.getElement("doorbell_req_num").setText(tCountText)
  return(1)
  exit
end

on hideDoorBell(me)
  pRingingUser = 0
  pDoorbellQueue = []
  if not windowExists(pDoorbellWinID) then
    return(0)
  end if
  removeWindow(pDoorbellWinID)
  return(1)
  exit
end

on eventProcDoorBell(me, tEvent, tSprID, tParam)
  if me = "doorbell_yes" then
    getThread(#room).getComponent().getRoomConnection().send("LETUSERIN", pDoorbellQueue.getAt(pRingingUser))
    me.removeRingingUser()
  else
    if me = "doorbell_no" then
      me.removeRingingUser()
    else
      if me = "close" then
        me.hideDoorBell()
      else
        if me = "doorbell_next" then
          me.displayNextDoorbellRinger()
        else
          if me = "doorbell_prev" then
            me.displayPreviousDoorbellRinger()
          end if
        end if
      end if
    end if
  end if
  exit
end