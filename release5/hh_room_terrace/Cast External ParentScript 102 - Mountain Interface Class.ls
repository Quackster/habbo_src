property pKoppiWndID, pTicketWndID, pSwimSuitModel, pSwimSuitIndex, pSwimSuitColor, pState, pSpeed, pUserSpr, pUserMem, pElevSpr_a, pElevSpr_b, pActLoc, pEndLoc, pCurLoc, pLocAnimList, pLocAnimIndx, pUserName

on construct me
  pKoppiWndID = "dew_pukukoppi"
  pTicketWndID = getText("ph_tickets_title")
  pUserName = EMPTY
  tVisual = getThread(#room).getInterface().getRoomVisualizer()
  pState = #ready
  pSpeed = 1.0
  pActLoc = point(102, 308)
  pEndLoc = point(-14, 424)
  pCurLoc = pActLoc
  pLocAnimList = [[2, 0], [2, 0], [2, 0], [2, 0], [2, 0], [2, 2], [2, 0], [2, 2], [2, 2], [2, 2], [2, 2]]
  pLocAnimIndx = 1
  tSprite = tVisual.getSprById("pool_teleport")
  if ilk(tSprite, #sprite) then
    tSprite.registerProcedure(#eventProcDew, me.getID(), #mouseUp)
  end if
  tSprite = tVisual.getSprById("highscore_table")
  if ilk(tSprite, #sprite) then
    tSprite.registerProcedure(#eventProcDew, me.getID(), #mouseDown)
    tSprite.registerProcedure(#eventProcDew, me.getID(), #mouseUp)
  end if
  tSprite = tVisual.getSprById("ticket_box")
  if ilk(tSprite, #sprite) then
    tSprite.registerProcedure(#eventProcDew, me.getID(), #mouseDown)
    tSprite.registerProcedure(#eventProcDew, me.getID(), #mouseUp)
  end if
  return 1
end

on deconstruct me
  if windowExists(pKoppiWndID) then
    removeWindow(pKoppiWndID)
  end if
  if windowExists(pTicketWndID) then
    removeWindow(pTicketWndID)
  end if
  return removePrepare(me.getID())
end

on openPukukoppi me
  pSwimSuitIndex = 1
  if getObject(#session).get("user_sex") = "F" then
    pSwimSuitModel = "s01"
  else
    pSwimSuitModel = "s02"
  end if
  if getObject(#session).get("user_sex") = "F" then
    tSetID = 20
  else
    tSetID = 10
  end if
  tPartProps = me.getColorOfPartByOrderNum("ch", 1, tSetID, getObject(#session).get("user_sex"))
  if tPartProps.ilk = #propList then
    tColor = rgb(tPartProps["color"])
    pSwimSuitColor = tColor
  end if
  createWindow(pKoppiWndID, "dew_pukukoppi.window", VOID, VOID, #modal)
  tWndObj = getWindow(pKoppiWndID)
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcPukukoppi, me.getID(), #mouseUp)
  me.createFigurePrew()
  return 1
end

on closePukukoppi me
  if windowExists(pKoppiWndID) then
    pSwimSuitIndex = 1
    removeWindow(pKoppiWndID)
  end if
end

on openTicketWnd me, tIsUpdate
  if not windowExists(pTicketWndID) then
    createWindow(pTicketWndID, "habbo_basic.window")
    tWndObj = getWindow(pTicketWndID)
    tWndObj.merge("habbo_ph_tickets.window")
    tWndObj.center()
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcTickets, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcTickets, me.getID(), #keyDown)
  else
    tWndObj = getWindow(pTicketWndID)
  end if
  if tIsUpdate = 1 then
    tText = getText("ph_tickets_txt")
  else
    tText = getText("ph_tickets_txt")
  end if
  tTickets = getThread(#mountain).getComponent().getTicketCount()
  tText = replaceChunks(tText, "\x1", tTickets)
  tWndObj.getElement("ph_tickets_number").setText(string(tTickets))
  tWndObj.getElement("ph_tickets_txt").setText(string(tText))
  tWndObj.getElement("ph_tickets_namefield").setText(getObject(#session).get("user_name"))
  return 1
end

on doTheDew me, tUserName
  return 0
  if not getThread(#room).getComponent().userObjectExists(tUserName) then
    return error(me, "User not found:" && tUserName, #doTheDew)
  end if
  tUserObj = getThread(#room).getComponent().getUserObject(tUserName)
  tUserSpr = tUserObj.getSprites()[1]
  if voidp(tUserSpr) then
    return error(me, "Couldn't extract sprites from user object:" && tUserName, #doTheDew)
  end if
  pUserName = tUserName
  tUserObj.refresh(12, 21, tUserObj.pLocH, 4, 4)
  tUserObj.fuseAction_wave()
  call(#doHandWorkRight, tUserObj.pPartList, "wav")
  tUserObj.prepare()
  tUserObj.render()
  pUserMem.image = tUserSpr.member.image
  pUserMem.regPoint = tUserSpr.member.regPoint
  pUserSpr.loc = tUserSpr.loc + [-2, -3]
  pUserSpr.locZ = tUserSpr.locZ
  pUserSpr.flipH = tUserSpr.flipH
  pUserSpr.visible = 1
  getThread(#room).getComponent().removeUserObject(pUserName)
  receivePrepare(me.getID())
  if pState = #ready then
    pState = #action
  end if
end

on prepare me
  case pState of
    #ready:
    #action:
      me.executeEscape()
    #return:
      me.executeReturn()
  end case
end

on executeEscape me
  pSpeed = pSpeed * 1.19999999999999996
  pCurLoc = pCurLoc + [-pSpeed, pSpeed]
  pElevSpr_a.loc = pCurLoc
  pElevSpr_b.loc = pElevSpr_b.loc + [pSpeed, -pSpeed]
  pUserSpr.loc = pUserSpr.loc + [-pSpeed, pSpeed]
  if pCurLoc[1] < -20 then
    pSpeed = 1.0
    pCurLoc = pActLoc
    pElevSpr_b.flipH = 1
    pElevSpr_b.loc = pActLoc + [-17, -11] + [pElevSpr_b.width, 0]
    pState = #return
  end if
end

on executeReturn me
  pElevSpr_b.loc = pElevSpr_b.loc + pLocAnimList[pLocAnimIndx]
  pLocAnimIndx = pLocAnimIndx + 1
  if pLocAnimIndx = pLocAnimList.count then
    pElevSpr_a.loc = pActLoc
    pElevSpr_b.loc = pEndLoc + [0, -22]
    pElevSpr_b.flipH = 0
    pLocAnimIndx = 1
    pUserSpr.visible = 0
    pState = #ready
    removePrepare(me.getID())
    if pUserName = getObject(#session).get(#userName) then
      executeMessage(#leaveRoom)
    end if
    pUserName = EMPTY
  end if
end

on createFigurePrew me
  tFigure = getObject(#session).get("user_figure").duplicate()
  tFigure["hd"]["model"] = "001"
  tFigure["fc"]["model"] = "001"
  if getObject(#session).get("user_sex") = "F" then
    tFigure["ch"]["model"] = pSwimSuitModel
  else
    tFigure["ch"]["model"] = pSwimSuitModel
  end if
  if voidp(pSwimSuitColor) then
    pSwimSuitColor = rgb("#EEEEEE")
  end if
  tWndObj = getWindow(pKoppiWndID)
  tFigure["ch"]["color"] = pSwimSuitColor
  tPartList = ["lh", "bd", "ch", "hd", "fc", "hr", "rh"]
  tHumanImg = getThread(#registration).getComponent().getHumanPartImg(tPartList, tFigure, 2, "sh")
  tWidth = tWndObj.getElement("preview_img").getProperty(#width)
  tHeight = tWndObj.getElement("preview_img").getProperty(#height)
  tPrewImg = image(tWidth, tHeight, 16)
  tMargins = rect(-11, 24, -11, 24)
  tdestrect = rect(0, tPrewImg.height - (tHumanImg.height * 4), tHumanImg.width * 4, tPrewImg.height) + tMargins
  tPrewImg.copyPixels(tHumanImg, tdestrect, tHumanImg.rect)
  tWndObj.getElement("preview_img").feedImage(tPrewImg)
  tWndObj.getElement("preview_color").setProperty(#bgColor, pSwimSuitColor)
end

on changeSwimSuitColor me, tPart, tButtonDir
  if getObject(#session).get("user_sex") = "F" then
    tSetID = 20
  else
    tSetID = 10
  end if
  tMaxValue = me.getCountOfPartColors(tPart, tSetID, getObject(#session).get("user_sex"))
  if tButtonDir = 0 then
    pSwimSuitIndex = 1
  else
    if (pSwimSuitIndex + tButtonDir) > tMaxValue then
      pSwimSuitIndex = tMaxValue
    else
      if (pSwimSuitIndex + tButtonDir) < 1 then
        pSwimSuitIndex = 1
      else
        pSwimSuitIndex = pSwimSuitIndex + tButtonDir
      end if
    end if
  end if
  tPartProps = me.getColorOfPartByOrderNum(tPart, pSwimSuitIndex, tSetID, getObject(#session).get("user_sex"))
  if tPartProps.ilk = #propList then
    tColor = rgb(tPartProps["color"])
    pSwimSuitColor = tColor
  end if
  me.createFigurePrew()
end

on eventProcPukukoppi me, tEvent, tSprID, tParam
  if tEvent = #mouseUp then
    case tSprID of
      "exit":
        me.closePukukoppi()
        getConnection(getVariable("connection.room.id")).send(#room, "UPDATE" && "ph_figure=")
        getConnection(getVariable("connection.room.id")).send(#room, "CLOSE_UIMAKOPPI")
      "go":
        me.closePukukoppi()
        tTempDelim = the itemDelimiter
        the itemDelimiter = ","
        tColor = string(pSwimSuitColor)
        tR = value(tColor.item[1].char[5..tColor.item[1].length])
        tG = value(tColor.item[2])
        tB = value(tColor.item[3].char[1..tColor.item[3].length - 1])
        the itemDelimiter = tTempDelim
        tColor = tR & "," & tG & "," & tB
        tswimsuit = "ph_figure=ch=" & pSwimSuitModel & "/" & tColor
        getConnection(getVariable("connection.room.id")).send(#room, "UPDATE" && tswimsuit)
        getConnection(getVariable("connection.room.id")).send(#room, "CLOSE_UIMAKOPPI")
      "dew":
        getConnection(getVariable("connection.room.id")).send(#room, "UPDATE" && "ph_figure=")
        getConnection(getVariable("connection.room.id")).send(#room, "CHANGESHRT")
        getConnection(getVariable("connection.info.id")).send(#room, "REFRESHFIGURE")
        getConnection(getVariable("connection.room.id")).send(#room, "CLOSE_UIMAKOPPI")
      "prev":
        me.changeSwimSuitColor("ch", -1)
      "next":
        me.changeSwimSuitColor("ch", 1)
    end case
  end if
end

on eventProcDew me, tEvent, tSprID, tParam
  if tEvent = #mouseUp then
    case tSprID of
      "pool_teleport":
        tName = getObject(#session).get("user_name")
        tObj = getThread(#room).getComponent().getUserObject(tName)
        if not tObj then
          return 0
        end if
        if tObj.pClass = "pelle" then
          if tObj.isSwimming() then
            getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && 12 && 11)
          else
            getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && 11 && 11)
          end if
        end if
      "ticket_box":
        return me.openTicketWnd()
      "highscore_table":
        return openNetPage("url_peeloscore")
      otherwise:
        put tSprID
    end case
  end if
  return 0
end

on eventProcTickets me, tEvent, tSprID, tParam, tWndID
  if tEvent = #mouseUp then
    if tSprID = "close" then
      if windowExists(pTicketWndID) then
        return removeWindow(pTicketWndID)
      end if
    else
      if tSprID = "ph_tickets_buy_button" then
        tUserName = getWindow(tWndID).getElement("ph_tickets_namefield").getText()
        if connectionExists(getVariable("connection.info.id")) then
          getConnection(getVariable("connection.info.id")).send(#info, "BTCKS /" & tUserName)
        end if
        if windowExists(pTicketWndID) then
          return removeWindow(pTicketWndID)
        end if
      end if
    end if
  end if
end
