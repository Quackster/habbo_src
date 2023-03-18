property pAnimCounter, pAnimList, pCurrentFrm

on construct me
  pAnimCounter = 0
  pCurrentFrm = 1
  pAnimList = [1, 2, 3, 4, 5, 6, 7]
  initThread("hubu.index")
  return receiveUpdate(me.getID())
end

on deconstruct me
  removeUpdate(me.getID())
  closeThread(#hubu)
  return 1
end

on prepare me
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  repeat with tid in ["bus", "hubu_kiosk_1", "hubu_kiosk_2", "hubu_kiosk_3", "hubu_kiosk_4", "hubu_kiosk_5"]
    tsprite = tRoomVis.getSprById(tid)
    registerProcedure(tsprite, #parkAEventProc, me.getID(), #mouseDown)
  end repeat
end

on showprogram me, tMsg
  if voidp(tMsg) then
    return 0
  end if
  tDst = tMsg[#show_dest]
  tCmd = tMsg[#show_command]
  tPar = tMsg[#show_params]
  if tDst contains "bus" then
    me.busDoor(tDst, tCmd)
  end if
end

on busDoor me, tid, tCommand
  case tCommand of
    "open":
      tMem = member(getmemnum("park_bussioviopen"))
    "close":
      tMem = member(getmemnum("park_bussi_ovi"))
  end case
  tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
  if tRoomVis = 0 then
    return 0
  end if
  tRoomVis.getSprById(tid).setMember(tMem)
end

on parkAEventProc me, tEvent, tSprID, tParm
  tConnection = getThread(#room).getComponent().getRoomConnection()
  if tConnection = 0 then
    return 0
  end if
  if tSprID = "bus" then
    tConnection.send("TRYBUS")
  else
    if tSprID contains "hubu_kiosk" then
      case tSprID of
        "hubu_kiosk_1":
          tKioskLoc = "12 20"
        "hubu_kiosk_2":
          tKioskLoc = "12 21"
        "hubu_kiosk_3":
          tKioskLoc = "12 22"
        "hubu_kiosk_4":
          tKioskLoc = "12 23"
        "hubu_kiosk_5":
          tKioskLoc = "12 24"
      end case
      dumpVariableField("hubu.http.links")
      me.ChangeWindowView("hubukiosk", "hubu_kiosk_1.window")
      tImg = member(getmemnum("hubu_kiosk_tab1_cont")).image
      getWindow("hubukiosk").getElement("hubu_kiosk_text").feedImage(tImg)
      tConnection.send("MOVE", tKioskLoc)
    end if
  end if
end

on ChangeWindowView me, tWindowTitle, tWindowName, tX, tY
  createWindow(tWindowTitle, tWindowName, VOID, VOID, #modal)
  tWndObj = getWindow(tWindowTitle)
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#hubuEventProc, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#hubuEventProc, me.getID(), #keyDown)
end

on hubuEventProc me, tEvent, tSprID, tParm
  if tSprID contains "hubukiosk_navibutton" then
    tWindow = "hubu_kiosk_" & tSprID.char[tSprID.char.count] & ".window"
    me.ChangeWindowView("hubukiosk", tWindow)
    tImg = member(getmemnum("hubu_kiosk_tab" & tSprID.char[tSprID.char.count] & "_cont")).image
    getWindow("hubukiosk").getElement("hubu_kiosk_text").feedImage(tImg)
  else
    if tSprID contains "close" then
      if windowExists("hubukiosk") then
        removeWindow("hubukiosk")
      end if
    else
      if tSprID contains "hubukiosk_txtlink" then
        tTemp = getVariableValue("hubu_t" & tSprID.char[length(tSprID) - 2..length(tSprID)])
        if not listp(tTemp) then
          return error(me, "Missing link:" && "hubu_t" & tSprID.char[length(tSprID) - 2..length(tSprID)], #hubuEventProc)
        end if
        tURL = tTemp[1]
        tAdId = tTemp[2]
        openNetPage(tURL)
        if connectionExists(getVariable("connection.info.id")) then
          getConnection(getVariable("connection.info.id")).send("ADVIEW", tAdId)
          getConnection(getVariable("connection.info.id")).send("ADCLICK", tAdId)
        end if
      end if
    end if
  end if
end

on update me
  if pAnimCounter > 2 then
    tNextFrm = pAnimList[random(pAnimList.count)]
    pAnimList.deleteOne(tNextFrm)
    pAnimList.add(pCurrentFrm)
    pCurrentFrm = tNextFrm
    tMem = member(getmemnum("park_fountain" & pCurrentFrm))
    tRoomVis = getThread(#room).getInterface().getRoomVisualizer()
    if not tRoomVis then
      return 0
    end if
    tRoomVis.getSprById("fountain").setMember(tMem)
    pAnimCounter = 0
  end if
  pAnimCounter = pAnimCounter + 1
end
