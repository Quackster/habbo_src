property pActLoc, pKoppiWndID, pState, pSpeed, pCurLoc, pElevSpr_a, pElevSpr_b, pUserSpr, pLocAnimList, pLocAnimIndx, pEndLoc, pUserName, pSwimSuitModel, pSwimSuitColor, pSwimSuitIndex

on construct me 
  pKoppiWndID = "dew_pukukoppi"
  pUserName = ""
  tVisual = getThread(#room).getInterface().getRoomVisualizer()
  pState = #ready
  pSpeed = 1
  pActLoc = point(102, 308)
  pEndLoc = point(-14, 424)
  pCurLoc = pActLoc
  pLocAnimList = [[2, 0], [2, 0], [2, 0], [2, 0], [2, 0], [2, 2], [2, 0], [2, 2], [2, 2], [2, 2], [2, 2]]
  pLocAnimIndx = 1
  if not objectExists("Figure_System_Mountain") then
    createObject("Figure_System_Mountain", ["OLD Figure System Class"])
    getObject("Figure_System_Mountain").define(["type":"member", "source":"swimfigure_ids_"])
  end if
  tsprite = tVisual.getSprById("pool_teleport")
  if ilk(tsprite, #sprite) then
    tsprite.registerProcedure(#eventProcDew, me.getID(), #mouseUp)
  end if
  tsprite = tVisual.getSprById("highscore_table")
  if ilk(tsprite, #sprite) then
    tsprite.registerProcedure(#eventProcDew, me.getID(), #mouseDown)
    tsprite.registerProcedure(#eventProcDew, me.getID(), #mouseUp)
  end if
  return TRUE
end

on deconstruct me 
  if objectExists("Figure_System_Mountain") then
    removeObject("Figure_System_Mountain")
  end if
  if windowExists(pKoppiWndID) then
    removeWindow(pKoppiWndID)
  end if
  return(removePrepare(me.getID()))
end

on openPukukoppi me 
  if not objectExists("Figure_System_Mountain") then
    return(error(me, "Figure system object not found", #openPukukoppi))
  end if
  pSwimSuitIndex = 1
  if (getObject(#session).GET("user_sex") = "F") then
    pSwimSuitModel = "s01"
  else
    pSwimSuitModel = "s02"
  end if
  if (getObject(#session).GET("user_sex") = "F") then
    tSetID = 20
  else
    tSetID = 10
  end if
  tPartProps = getObject("Figure_System_Mountain").getColorOfPartByOrderNum("ch", 1, tSetID, getObject(#session).GET("user_sex"))
  if (tPartProps.ilk = #propList) then
    tColor = rgb(tPartProps.getAt("color"))
    pSwimSuitColor = tColor
  end if
  createWindow(pKoppiWndID, "dew_pukukoppi.window", void(), void(), #modal)
  tWndObj = getWindow(pKoppiWndID)
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcPukukoppi, me.getID(), #mouseUp)
  me.createFigurePrew()
  return TRUE
end

on closePukukoppi me 
  if windowExists(pKoppiWndID) then
    pSwimSuitIndex = 1
    removeWindow(pKoppiWndID)
  end if
end

on prepare me 
  if (pState = #ready) then
  else
    if (pState = #action) then
      me.executeEscape()
    else
      if (pState = #return) then
        me.executeReturn()
      end if
    end if
  end if
end

on executeEscape me 
  pSpeed = (pSpeed * 1.2)
  pCurLoc = (pCurLoc + [-pSpeed, pSpeed])
  pElevSpr_a.loc = pCurLoc
  pElevSpr_b.loc = (pElevSpr_b.loc + [pSpeed, -pSpeed])
  pUserSpr.loc = (pUserSpr.loc + [-pSpeed, pSpeed])
  if pCurLoc.getAt(1) < -20 then
    pSpeed = 1
    pCurLoc = pActLoc
    pElevSpr_b.flipH = 1
    pElevSpr_b.loc = ((pActLoc + [-17, -11]) + [pElevSpr_b.width, 0])
    pState = #return
  end if
end

on executeReturn me 
  pElevSpr_b.loc = (pElevSpr_b.loc + pLocAnimList.getAt(pLocAnimIndx))
  pLocAnimIndx = (pLocAnimIndx + 1)
  if (pLocAnimIndx = pLocAnimList.count) then
    pElevSpr_a.loc = pActLoc
    pElevSpr_b.loc = (pEndLoc + [0, -22])
    pElevSpr_b.flipH = 0
    pLocAnimIndx = 1
    pUserSpr.visible = 0
    pState = #ready
    removePrepare(me.getID())
    if (pUserName = getObject(#session).GET(#userName)) then
      executeMessage(#leaveRoom)
    end if
    pUserName = ""
  end if
end

on createFigurePrew me 
  if not objectExists("Figure_Preview") then
    return(error(me, "Figure preview not found!", #createFigurePrew))
  end if
  tFigure = getObject(#session).GET("user_figure").duplicate()
  if (getObject(#session).GET("user_sex") = "F") then
    tFigure.getAt("ch").setAt("model", pSwimSuitModel)
  else
    tFigure.getAt("ch").setAt("model", pSwimSuitModel)
  end if
  if voidp(pSwimSuitColor) then
    pSwimSuitColor = rgb("#EEEEEE")
  end if
  tWndObj = getWindow(pKoppiWndID)
  tFigure.getAt("ch").setAt("color", pSwimSuitColor)
  tPartList = #swimmer
  tHumanImg = getObject("Figure_Preview").getHumanPartImg(tPartList, tFigure, 4, "sh")
  if tWndObj.getElement("preview_img") <> 0 then
    tWidth = tWndObj.getElement("preview_img").getProperty(#width)
    tHeight = tWndObj.getElement("preview_img").getProperty(#height)
    tPrewImg = image(tWidth, tHeight, 16)
    tMargins = rect(39, 0, 39, 0)
    tdestrect = (rect(0, (tPrewImg.height - (tHumanImg.height * 4)), (tHumanImg.width * 4), tPrewImg.height) + tMargins)
    tPrewImg.copyPixels(tHumanImg, tdestrect, tHumanImg.rect)
    tWndObj.getElement("preview_img").feedImage(tPrewImg)
  end if
  tWndObj.getElement("preview_color").setProperty(#bgColor, pSwimSuitColor)
end

on changeSwimSuitColor me, tPart, tButtonDir 
  if not objectExists("Figure_System_Mountain") then
    return(error(me, "Figure system Mountain object not found", #changeSwimSuitColor))
  end if
  if (getObject(#session).GET("user_sex") = "F") then
    tSetID = 20
  else
    tSetID = 10
  end if
  tMaxValue = getObject("Figure_System_Mountain").getCountOfPartColors(tPart, tSetID, getObject(#session).GET("user_sex"))
  if (tButtonDir = 0) then
    pSwimSuitIndex = 1
  else
    if (pSwimSuitIndex + tButtonDir) > tMaxValue then
      pSwimSuitIndex = tMaxValue
    else
      if (pSwimSuitIndex + tButtonDir) < 1 then
        pSwimSuitIndex = 1
      else
        pSwimSuitIndex = (pSwimSuitIndex + tButtonDir)
      end if
    end if
  end if
  tPartProps = getObject("Figure_System_Mountain").getColorOfPartByOrderNum(tPart, pSwimSuitIndex, tSetID, getObject(#session).GET("user_sex"))
  if (tPartProps.ilk = #propList) then
    tColor = rgb(tPartProps.getAt("color"))
    pSwimSuitColor = tColor
  end if
  me.createFigurePrew()
end

on eventProcPukukoppi me, tEvent, tSprID, tParam 
  if (tEvent = #mouseUp) then
    if (tSprID = "exit") then
      me.closePukukoppi()
      getConnection(getVariable("connection.room.id")).send("SWIMSUIT", [#string:""])
      getConnection(getVariable("connection.room.id")).send("CLOSE_UIMAKOPPI")
    else
      if (tSprID = "go") then
        me.closePukukoppi()
        tTempDelim = the itemDelimiter
        the itemDelimiter = ","
        tColor = string(pSwimSuitColor)
        tR = integer(tColor.getPropRef(#item, 1).getProp(#char, 5, tColor.getPropRef(#item, 1).length))
        tG = integer(tColor.getProp(#item, 2))
        tB = integer(tColor.getPropRef(#item, 3).getProp(#char, 1, (tColor.getPropRef(#item, 3).length - 1)))
        the itemDelimiter = tTempDelim
        tColor = tR & "," & tG & "," & tB
        tswimsuit = "ch=" & pSwimSuitModel & "/" & tColor
        getConnection(getVariable("connection.room.id")).send("SWIMSUIT", [#string:tswimsuit])
        getConnection(getVariable("connection.room.id")).send("CLOSE_UIMAKOPPI")
      else
        if (tSprID = "dew") then
          getConnection(getVariable("connection.room.id")).send("SWIMSUIT")
          getConnection(getVariable("connection.room.id")).send("CHANGESHRT")
          getConnection(getVariable("connection.info.id")).send("REFRESHFIGURE")
          getConnection(getVariable("connection.room.id")).send("CLOSE_UIMAKOPPI")
        else
          if (tSprID = "prev") then
            me.changeSwimSuitColor("ch", -1)
          else
            if (tSprID = "next") then
              me.changeSwimSuitColor("ch", 1)
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcDew me, tEvent, tSprID, tParam 
  if (tEvent = #mouseUp) then
    if (tSprID = "pool_teleport") then
      tName = getObject(#session).GET("user_name")
      tObj = getThread(#room).getComponent().getUserObject(tName)
      if not tObj then
        return FALSE
      end if
      if (tObj.pClass = "pelle") then
        if tObj.isSwimming() then
          getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:12, #short:11])
        else
          getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:11, #short:11])
        end if
      end if
    else
      if (tSprID = "highscore_table") then
        return(openNetPage("url_peeloscore"))
      else
        put(tSprID)
      end if
    end if
  end if
  return FALSE
end
