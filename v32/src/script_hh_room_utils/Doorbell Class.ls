property pDoorbellQueue, pDoorbellWinID, pRingingUser

on construct me 
  pDoorbellQueue = []
  pDoorbellWinID = getText("win_doorbell", "Doorbell")
end

on deconstruct me 
end

on addDoorbellRinger me, tName 
  if pDoorbellQueue.getPos(tName) > 0 then
    return FALSE
  end if
  if not windowExists(pDoorbellWinID) then
    if not createWindow(pDoorbellWinID, "habbo_basic.window", 250, 200) then
      return(error(me, "Couldn't create window to show ringing doorbell!", #addDoorbellRinger, #major))
    end if
    tWndObj = getWindow(pDoorbellWinID)
    if not tWndObj.merge("habbo_doorbell.window") then
      tWndObj.close()
      return(error(me, "Couldn't create window to show ringing doorbell!", #addDoorbellRinger, #major))
    end if
    tWndObj.setProperty(#locZ, 2000000)
    tWndObj.lock(1)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcDoorBell, me.getID(), #mouseUp)
  end if
  pDoorbellQueue.append(tName)
  pRingingUser = pDoorbellQueue.count
  me.updateDoorbellWindow()
  return TRUE
end

on removeRingingUser me 
  pDoorbellQueue.deleteAt(pRingingUser)
  me.updateDoorbellWindow()
  return TRUE
end

on removeFromList me, tName 
  tRemoved = pDoorbellQueue.deleteOne(tName)
  if tRemoved then
    me.updateDoorbellWindow()
  end if
end

on displayNextDoorbellRinger me 
  pRingingUser = (pRingingUser + 1)
  if pRingingUser > pDoorbellQueue.count then
    pRingingUser = 1
  end if
  me.updateDoorbellWindow()
  return TRUE
end

on displayPreviousDoorbellRinger me 
  pRingingUser = (pRingingUser - 1)
  if pRingingUser < 1 then
    pRingingUser = pDoorbellQueue.count
  end if
  me.updateDoorbellWindow()
  return TRUE
end

on updateDoorbellWindow me 
  if (pDoorbellQueue = []) then
    me.hideDoorBell()
    return TRUE
  end if
  if pRingingUser > pDoorbellQueue.count then
    pRingingUser = pDoorbellQueue.count
  end if
  if not windowExists(pDoorbellWinID) then
    return FALSE
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
  return TRUE
end

on hideDoorBell me 
  pRingingUser = 0
  pDoorbellQueue = []
  if not windowExists(pDoorbellWinID) then
    return FALSE
  end if
  removeWindow(pDoorbellWinID)
  return TRUE
end

on eventProcDoorBell me, tEvent, tSprID, tParam 
  if (tSprID = "doorbell_yes") then
    getThread(#room).getComponent().getRoomConnection().send("LETUSERIN", [#string:pDoorbellQueue.getAt(pRingingUser), #boolean:1])
    me.removeRingingUser()
  else
    if (tSprID = "doorbell_no") then
      getThread(#room).getComponent().getRoomConnection().send("LETUSERIN", [#string:pDoorbellQueue.getAt(pRingingUser), #boolean:0])
      me.removeRingingUser()
    else
      if (tSprID = "close") then
        me.hideDoorBell()
      else
        if (tSprID = "doorbell_next") then
          me.displayNextDoorbellRinger()
        else
          if (tSprID = "doorbell_prev") then
            me.displayPreviousDoorbellRinger()
          end if
        end if
      end if
    end if
  end if
end
