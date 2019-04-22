property pBottomBarId

on construct me 
  pBottomBarId = "RoomBarID"
  return(1)
end

on deconstruct me 
  return(me.deconstruct())
end

on displayEvent me, ttype 
  tInterface = getObject(#room_interface)
  if tInterface = 0 then
    return(0)
  end if
  if ttype <> #stage_starting then
    if ttype = #game_ending then
      tInterface.showRoomBar("ig_roombar.window")
    else
      return(0)
    end if
    me.createMyHeadIcon()
    me.updateSoundButton()
    tWndObj = getWindow(pBottomBarId)
    if tWndObj = 0 then
      return(0)
    end if
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseEnter)
    tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseLeave)
    return(1)
  end if
end

on updateSoundButton me 
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return(0)
  end if
  tstate = getSoundState()
  tElem = tWndObj.getElement("int_sound_image")
  if tElem <> 0 then
    if tstate then
      tMemNum = getmemnum("sounds_small_on_icon")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    else
      tMemNum = getmemnum("sounds_small_off_icon")
      if tMemNum > 0 then
        tElem.feedImage(member(tMemNum).image)
      end if
    end if
  end if
end

on createMyHeadIcon me 
  if objectExists("Figure_Preview") then
    getObject("Figure_Preview").createHumanPartPreview(pBottomBarId, "ownhabbo_icon_image", #head)
  end if
end

on eventProcRoomBar me, tEvent, tSprID, tParam 
  if tSprID = "game_rules_image" then
    if tSprID = #mouseUp then
      return(executeMessage(#ig_show_game_rules))
    else
      if tSprID = #mouseEnter then
        return(executeMessage(#setRollOverInfo, getText("interface_icon_game_rules")))
      else
        if tSprID = #mouseLeave then
          return(executeMessage(#setRollOverInfo, ""))
        end if
      end if
    end if
    return(1)
  end if
  tRoomBarObj = getObject("RoomBarProgram")
  if tRoomBarObj = 0 then
    return(0)
  end if
  if tEvent = #keyDown and tSprID = "chat_field" then
    tChatField = getWindow(tRoomBarObj.pBottomBarId).getElement(tSprID)
    if tSprID <> 36 then
      if tSprID = 76 then
        if tChatField.getText() = "" then
          return(1)
        end if
        if tRoomBarObj.pFloodblocking then
          if the milliSeconds < tRoomBarObj.pFloodTimer then
            return(0)
          else
            tRoomBarObj.pFloodEnterCount = void()
          end if
        end if
        if voidp(tRoomBarObj.pFloodEnterCount) then
          tRoomBarObj.pFloodEnterCount = 0
          tRoomBarObj.pFloodblocking = 0
          tRoomBarObj.pFloodTimer = the milliSeconds
        else
          tRoomBarObj.pFloodEnterCount = tRoomBarObj.pFloodEnterCount + 1
          tFloodCountLimit = 2
          tFloodTimerLimit = 3000
          tFloodTimeout = 30000
          if tRoomBarObj.pFloodEnterCount > tFloodCountLimit then
            if the milliSeconds < tRoomBarObj.pFloodTimer + tFloodTimerLimit then
              tChatField.setText("")
              createObject("FloodBlocking", "Flood Blocking Class")
              getObject("FloodBlocking").Init(tRoomBarObj.pBottomBarId, tSprID, tFloodTimeout)
              tRoomBarObj.pFloodblocking = 1
              tRoomBarObj.pFloodTimer = the milliSeconds + tFloodTimeout
            else
              tRoomBarObj.pFloodEnterCount = void()
            end if
          end if
        end if
        getConnection(#info).send("GAME_CHAT", [#string:tChatField.getText()])
        tChatField.setText("")
        return(1)
      else
        if tSprID = 117 then
          tChatField.setText("")
        end if
      end if
      return(0)
      tResult = tRoomBarObj.eventProcRoomBar(tEvent, tSprID, tParam)
      return(1)
    end if
  end if
end
