property pBottomBarId

on construct me
  pBottomBarId = "RoomBarID"
  return 1
end

on deconstruct me
  return me.ancestor.deconstruct()
end

on displayEvent me, ttype
  tInterface = getObject(#room_interface)
  if tInterface = 0 then
    return 0
  end if
  case ttype of
    #stage_starting, #game_ending:
      tInterface.showRoomBar("ig_roombar.window")
    otherwise:
      return 0
  end case
  me.createMyHeadIcon()
  me.updateSoundButton()
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #keyDown)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseEnter)
  tWndObj.registerProcedure(#eventProcRoomBar, me.getID(), #mouseLeave)
  return 1
end

on updateSoundButton me
  tWndObj = getWindow(pBottomBarId)
  if tWndObj = 0 then
    return 0
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
  case tSprID of
    "game_rules_image":
      case tEvent of
        #mouseUp:
          return executeMessage(#ig_show_game_rules)
        #mouseEnter:
          return executeMessage(#setRollOverInfo, getText("interface_icon_game_rules"))
        #mouseLeave:
          return executeMessage(#setRollOverInfo, EMPTY)
      end case
      return 1
  end case
  tRoomBarObj = getObject("RoomBarProgram")
  if tRoomBarObj = 0 then
    return 0
  end if
  if (tEvent = #keyDown) and (tSprID = "chat_field") then
    tChatField = getWindow(tRoomBarObj.pBottomBarId).getElement(tSprID)
    case the keyCode of
      36, 76:
        if tChatField.getText() = EMPTY then
          return 1
        end if
        if tRoomBarObj.pFloodblocking then
          if the milliSeconds < tRoomBarObj.pFloodTimer then
            return 0
          else
            tRoomBarObj.pFloodEnterCount = VOID
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
            if the milliSeconds < (tRoomBarObj.pFloodTimer + tFloodTimerLimit) then
              tChatField.setText(EMPTY)
              createObject("FloodBlocking", "Flood Blocking Class")
              getObject("FloodBlocking").Init(tRoomBarObj.pBottomBarId, tSprID, tFloodTimeout)
              tRoomBarObj.pFloodblocking = 1
              tRoomBarObj.pFloodTimer = the milliSeconds + tFloodTimeout
            else
              tRoomBarObj.pFloodEnterCount = VOID
            end if
          end if
        end if
        getConnection(#Info).send("GAME_CHAT", [#string: tChatField.getText()])
        tChatField.setText(EMPTY)
        return 1
      117:
        tChatField.setText(EMPTY)
    end case
    return 0
  end if
  tResult = tRoomBarObj.eventProcRoomBar(tEvent, tSprID, tParam)
  return 1
end
