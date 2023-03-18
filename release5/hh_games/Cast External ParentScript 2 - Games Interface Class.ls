property pWindowTitle, pOpenWindow, pChessPieces, pChessWait, pBattleShipMyBoardImg

on construct me
  pWindowTitle = "GAME"
  return 1
end

on deconstruct me
  me.closeGame()
  return 1
end

on closeGame me
  if windowExists(pWindowTitle) then
    me.getComponent().sendGameClose()
    removeWindow(pWindowTitle)
  end if
end

on openGameWindow me, tWindowName, tProps
  case tWindowName of
    "TicTacToe":
      tWindowTitle = getText("game_TicTacToe", "TicTacToe")
      me.ChangeWindowView(tWindowTitle, "habbo_ttt_choose_side.window", #eventProcTicTacToe)
      me.chooseSideTicTacToe()
    "Chess":
      tWindowTitle = getText("game_Chess", "Chess")
      me.ChangeWindowView(tWindowTitle, "habbo_chess_choose_side.window", #eventProcChess)
      pChessWait = 0
    "BattleShip":
      tWindowTitle = getText("game_BattleShip", "BattleShip")
      me.ChangeWindowView(tWindowTitle, "habbo_battleships_start.window", #eventProcBattleShip)
  end case
end

on ChangeWindowView me, tWindowTitle, tWindowName, tEventProc, tX, tY, tWindowType
  if voidp(tWindowType) then
    tTemp = "habbo_basic.window"
  else
    tTemp = tWindowType
  end if
  createWindow(tWindowTitle, "habbo_basic.window")
  if windowExists(tWindowTitle) then
    tWndObj = getWindow(tWindowTitle)
    tWndObj.merge(tWindowName)
    tWndObj.center()
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(tEventProc, me.getID(), #mouseUp)
    tWndObj.registerProcedure(tEventProc, me.getID(), #keyDown)
    pWindowTitle = tWindowTitle
    pOpenWindow = tWindowName
  end if
end

on flipH me, tImg
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(tImg.width, 0), point(0, 0), point(0, tImg.height), point(tImg.width, tImg.height)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end

on flipV me, tImg
  tImage = image(tImg.width, tImg.height, tImg.depth)
  tQuad = [point(0, tImg.height), point(tImg.width, tImg.height), point(tImg.width, 0), point(0, 0)]
  tImage.copyPixels(tImg, tQuad, tImg.rect)
  return tImage
end

on chooseSideTicTacToe me
  me.drawGameBoardTicTacToe()
  getWindow(pWindowTitle).getElement("choose_side_x").setText("x")
  getWindow(pWindowTitle).getElement("choose_side_o").setText("o")
end

on StartTicTacToe me, tGameProps
  if not windowExists(pWindowTitle) then
    return 0
  end if
  me.ChangeWindowView(pWindowTitle, "habbo_ttt.window", #eventProcTicTacToe)
  me.drawGameBoardTicTacToe()
  tText = tGameProps[#player1][#type] && tGameProps[#player1][#name] & RETURN & tGameProps[#player2][#type] && tGameProps[#player2][#name]
  getWindow(pWindowTitle).getElement("game_text1").setText(tText)
end

on updateTicTacToe me, tGameProps
  if not windowExists(pWindowTitle) then
    return 0
  end if
  tText1 = tGameProps[#player1][#type] && tGameProps[#player1][#name] & RETURN & tGameProps[#player2][#type] && tGameProps[#player2][#name]
  if not getWindow(pWindowTitle).elementExists("game_text1") then
    return 0
  end if
  getWindow(pWindowTitle).getElement("game_text1").setText(tText1)
  me.drawGameBoardTicTacToe(tGameProps)
end

on drawGameBoardTicTacToe me, tGameProps
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement("game_area")
  tImg = member(getmemnum("game_TicTacToe.board.real")).image.duplicate()
  tElem.feedImage(tImg)
  if voidp(tGameProps) then
    return 0
  end if
  if voidp(tGameProps[#gameboard]) then
    return 0
  end if
  tW = 25
  tBuffer = tElem.getProperty(#image)
  repeat with i = 1 to tGameProps[#gameboard].length
    tC = tGameProps[#gameboard].char[i]
    if charToNum(tC) <> 32 then
      me.drawTicTacToe((i mod tW) - 1, i / tW, tC, tBuffer)
    end if
  end repeat
  tElem.render()
  return 1
end

on drawTicTacToe me, tX, tY, tC, tBuffer
  if not memberExists("game_TicTacToe." & tC) then
    return error(me, "Member not found:" && "game_TicTacToe." & tC)
  end if
  tSquareSize = 10
  tMemImg = member(getmemnum("game_TicTacToe." & tC)).image
  tdestrect = rect((tX * tSquareSize) + 1, (tY * tSquareSize) + 1, (tX + 1) * tSquareSize, (tY + 1) * tSquareSize)
  tBuffer.copyPixels(tMemImg, tdestrect, tMemImg.rect, [#ink: 36])
end

on selectedTypeTicTacToe me, tPlayerProps, tGameProps
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  if tPlayerProps[#type] = "x" then
    tElemID = "x_player"
  else
    tElemID = "o_player"
  end if
  if tWndObj.elementExists(tElemID) then
    tWndObj.getElement(tElemID).setText(tPlayerProps[#name])
  end if
  if tWndObj.elementExists("game_text1") then
    tText1 = tGameProps[#player1][#type] && tGameProps[#player1][#name] & RETURN & tGameProps[#player2][#type] && tGameProps[#player2][#name]
    tWndObj.getElement("game_text1").setText(tText1)
  end if
end

on getTicTacToeSector me, tpoint
  return [tpoint[1] / 10, tpoint[2] / 10]
end

on eventProcTicTacToe me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    case tElemID of
      "close":
        me.closeGame("TicTacToe")
      "choose_side_x":
        me.getComponent().chooseSideTicTacToe("X")
      "choose_side_o":
        me.getComponent().chooseSideTicTacToe("O")
      "game_newgame":
        me.getComponent().restartTicTacToe()
      "game_area":
        tClickArea = me.getTicTacToeSector(tParam)
        me.getComponent().makeMoveTicTacToe(tClickArea[1], tClickArea[2])
    end case
  end if
end

on startChess me, tGameProps
  if not windowExists(pWindowTitle) then
    return 0
  end if
  me.ChangeWindowView(pWindowTitle, "habbo_chess.window", #eventProcChess)
end

on updateChess me, tGameProps
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("game_area")
  if tElem = 0 then
    return 0
  end if
  tElem.clearImage()
  me.setupChessPieces(tGameProps)
  if tWndObj.elementExists("game_players") then
    tText = tGameProps[#player1][#type] && tGameProps[#player1][#name] & RETURN & tGameProps[#player2][#type] && tGameProps[#player2][#name]
    tWndObj.getElement("game_players").setText(tText)
  end if
end

on setupChessPieces me, tGameProps
  if voidp(tGameProps) then
    return 0
  end if
  if voidp(tGameProps[#gameboard]) then
    return 0
  end if
  tElem = getWindow(pWindowTitle).getElement("game_area")
  tBuffer = tElem.getProperty(#image)
  pChessPieces = [:]
  repeat with i = 1 to tGameProps[#gameboard].word.count
    if tGameProps[#gameboard].word[i].length = 5 then
      tC = "game_" & tGameProps[#gameboard].word[i].char[1..3]
      tPieceCoordinate = tGameProps[#gameboard].word[i].char[4..5]
      tX = charToNum(tPieceCoordinate.char[1]) - 97
      tY = 8 - integer(tPieceCoordinate.char[2])
      pChessPieces[string(tX & tY)] = tGameProps[#gameboard].word[i]
      me.drawChessPieces(tX, tY, tC, tBuffer)
    end if
  end repeat
  tElem.render()
end

on drawChessPieces me, tX, tY, tC, tBuffer
  tSize = 27
  tmember = member(getmemnum(tC))
  tMemImg = tmember.image
  tMemRect = tmember.rect
  tCenter = rect((tX * tSize) + (tSize / 2), (tY * tSize) + (tSize / 2), (tX * tSize) + (tSize / 2), (tY * tSize) + (tSize / 2))
  tDstRect = tMemRect + tCenter
  tDstRect = tDstRect - rect(tMemRect.width / 2, tMemRect.height / 2, tMemRect.width / 2, tMemRect.height / 2)
  tBuffer.copyPixels(tMemImg, tDstRect, tMemRect, [#ink: 36])
end

on getChessSector me, tpoint
  tSquareSize = 27
  return string(tpoint[1] / tSquareSize & tpoint[2] / tSquareSize)
end

on makeChessSectorEmpty me, tX, tY
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("game_area")
  if tElem = 0 then
    return 0
  end if
  tSquareSize = 27
  tdestrect = rect(tX * tSquareSize, tY * tSquareSize, (tX * tSquareSize) + tSquareSize, (tY * tSquareSize) + tSquareSize)
  tElem.getProperty(#image).fill(tdestrect, rgb(255, 255, 255))
  tElem.render()
end

on makeMoveChess me, tpoint, tPieceData
  tClickArea = me.getChessSector(tpoint)
  if not voidp(pChessPieces[tClickArea]) then
    tMySide = me.getComponent().getMySideChess()
    if (tMySide = pChessPieces[tClickArea].char[1]) and (tPieceData <> pChessPieces[tClickArea]) then
      return 0
    end if
  end if
  tMove = tPieceData.char[4..5] && numToChar(97 + value(tClickArea.char[1])) & 8 - value(tClickArea.char[2])
  me.getComponent().makeMoveChess(tMove)
  tC = "game_" & tPieceData.char[1..3]
  tX = value(tClickArea.char[1])
  tY = value(tClickArea.char[2])
  tElem = getWindow(pWindowTitle).getElement("game_area")
  me.drawChessPieces(tX, tY, tC, tElem.getProperty(#image))
  tElem.render()
  pChessWait = 1
  me.delay(500, #waitMoveChess)
  return 1
end

on waitMoveChess me
  pChessWait = 0
end

on eventProcChess me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    case tElemID of
      "close":
        if objectExists("chessPlacer") then
          removeObject("chessPlacer")
        end if
        me.closeGame("Chess")
      "chess_white":
        me.getComponent().chooseSideTicTacToe("w")
      "chess_black":
        me.getComponent().chooseSideTicTacToe("b")
      "game_area":
        if pChessWait then
          return 1
        end if
        tClickArea = me.getChessSector(tParam)
        if voidp(pChessPieces) then
          return 1
        end if
        if voidp(pChessPieces[tClickArea]) then
          return 1
        end if
        if objectExists("chessPlacer") then
          return 1
        end if
        if not voidp(pChessPieces[tClickArea]) then
          tPieceColor = pChessPieces[tClickArea].char[1]
        else
          tPieceColor = "Nothing"
        end if
        if me.getComponent().getMySideChess() <> tPieceColor then
          return 1
        end if
        me.makeChessSectorEmpty(tClickArea.char[1], tClickArea.char[2])
        tMemName = "game_" & pChessPieces[tClickArea].char[1..3]
        tmember = member(getmemnum(tMemName))
        tPieceData = pChessPieces[tClickArea]
        tAreaElem = getWindow(pWindowTitle).getElement("game_area")
        tlocz = tAreaElem.getProperty(#locZ) + 1
        createObject("chessPlacer", "Chess Placer Class")
        getObject("chessPlacer").Init(tmember, tlocz, tPieceData, tAreaElem.getProperty(#sprite))
      "game_chess_newgame":
        if not windowExists(pWindowTitle) then
          return 1
        end if
        if objectExists("chessPlacer") then
          removeObject("chessPlacer")
        end if
        me.ChangeWindowView(pWindowTitle, "habbo_chess_reset.window", #eventProcChess)
      "game_restart_yes":
        me.getComponent().restartChess()
      "game_restart_cancel":
        me.getComponent().notRestartChess()
      "game_chess_email":
        me.getComponent().sendChessByEmail()
    end case
  end if
end

on showShipInfo me, tText
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("game_battleships_text1")
  if tElem = 0 then
    return 0
  end if
  return tElem.setText(tText)
end

on placeShip me, tmember, tdestrect
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("game_area")
  if tElem = 0 then
    return 0
  end if
  tBuffer = tElem.getProperty(#image)
  tBuffer.copyPixels(tmember.image, tdestrect, tmember.rect, [#ink: 36])
  tElem.render()
end

on drawShip me, tX, tY, tmember, tImage
  tSquareSize = 19
  tMemberImg = tmember.image
  tMemRect = tmember.rect
  tCenter = rect((tX * tSquareSize) + (tSquareSize / 2), (tY * tSquareSize) + (tSquareSize / 2), (tX * tSquareSize) + (tSquareSize / 2), (tY * tSquareSize) + (tSquareSize / 2))
  tdestrect = tMemRect + tCenter
  tdestrect = tdestrect - rect(tMemRect.width / 2, tMemRect.height / 2, tMemRect.width / 2, tMemRect.height / 2)
  tImage.copyPixels(tMemberImg, tdestrect, tMemRect, [#ink: 36])
end

on getBattleShipSector me, tpoint
  tSquareSize = 19
  return string(tpoint[1] / tSquareSize && tpoint[2] / tSquareSize)
end

on battleShipWaitOtherPlayer me
  pBattleShipMyBoardImg = getWindow(pWindowTitle).getElement("game_area").getProperty(#image).duplicate()
  me.ChangeWindowView(pWindowTitle, "habbo_battleships_wait.window", #eventProcBattleShip)
end

on battleShipMyTurn me
  if pOpenWindow <> "habbo_battleships.window" then
    me.ChangeWindowView(pWindowTitle, "habbo_battleships.window", #eventProcBattleShip)
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("game_area")
  if tElem = 0 then
    return 0
  end if
  tElem.clearBuffer()
  tElem.clearImage()
  me.battleShipShowTurnText(1)
end

on battleShipOtherPlayersTurn me
  if pOpenWindow <> "habbo_battleships.window" then
    me.ChangeWindowView(pWindowTitle, "habbo_battleships.window", #eventProcBattleShip)
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("game_area")
  if tElem = 0 then
    return 0
  end if
  tElem.clearImage()
  tElem.clearBuffer()
  tBuffer = tElem.getProperty(#image)
  tBuffer.copyPixels(pBattleShipMyBoardImg, tBuffer.rect, tBuffer.rect)
  tElem.render()
  me.battleShipShowTurnText(0)
end

on battleShipShowTurnText me, tMyTurn
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  if not tWndObj.elementExists("game_battleships_text1") then
    return 0
  end if
  if not tWndObj.elementExists("game_battleships_text2") then
    return 0
  end if
  if tMyTurn then
    tText = getText("game_bs_turn1", "Your turn!")
  else
    tText = getText("game_bs_turn2", "The enemy's turn")
  end if
  tWndObj.getElement("game_battleships_text1").setText(tText)
  tWndObj.getElement("game_battleships_text2").setText(EMPTY)
end

on battleShipShowStatusText me, tText
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("game_battleships_text2")
  if tElem = 0 then
    return 0
  end if
  return tElem.setText(tText)
end

on battleShipGameEnd me, tText
  if not windowExists(pWindowTitle) then
    return 0
  end if
  me.ChangeWindowView(pWindowTitle, "habbo_battleships_end.window", #eventProcBattleShip)
  getWindow(pWindowTitle).getElement("game_winner").setText(tText)
end

on updateBattleShipBoard me, tBoardData
  if voidp(tBoardData) then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("game_area")
  if tElem = 0 then
    return 0
  end if
  tBuffer = tElem.getProperty(#image)
  tSquareSize = 19
  repeat with tShoot in tBoardData
    tX = tShoot[1]
    tY = tShoot[2]
    ttype = tShoot[3]
    tHitImage = member(getmemnum("game_bs_" & string(ttype))).image
    if ttype = #miss then
      tdestrect = rect(tX * tSquareSize, tY * tSquareSize, (tX * tSquareSize) + tHitImage.width - 1, (tY * tSquareSize) + tHitImage.height - 1)
    else
      tdestrect = rect((tX * tSquareSize) + 1, (tY * tSquareSize) + 1, (tX * tSquareSize) + tHitImage.width, (tY * tSquareSize) + tHitImage.height)
    end if
    tBuffer.copyPixels(tHitImage, tdestrect, tHitImage.rect, [#ink: 36])
  end repeat
  tElem.render()
end

on eventProcBattleShip me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    case tElemID of
      "close", "game_close":
        if objectExists("battleShipPlacer") then
          removeObject("battleShipPlacer")
        end if
        me.closeGame("BattleShip")
      "setships_ok":
        me.ChangeWindowView(pWindowTitle, "habbo_battleships_place.window", #eventProcBattleShip)
        tElem = getWindow(pWindowTitle).getElement("game_area")
        tlocz = tElem.getProperty(#locZ) + 1
        createObject("battleShipPlacer", "BattleShip Placer Class")
        getObject("battleShipPlacer").Init(tElem.getProperty(#sprite), tlocz)
      "game_battleships_turn":
        if objectExists("battleShipPlacer") then
          getObject("battleShipPlacer").turnShip()
        end if
      "game_area":
        tClickArea = me.getBattleShipSector(tParam)
        me.getComponent().sendBattleShipShoot(tClickArea.word[1], tClickArea.word[2])
      "game_newgame":
        me.getComponent().restartBattleShip()
    end case
  end if
end
