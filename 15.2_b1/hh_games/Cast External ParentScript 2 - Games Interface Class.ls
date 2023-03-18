property pWindowTitle, pOpenWindow, pChessPieces, pChessWait, pBattleShipMyBoardImg, pPokerChangeCards, pMyName, pPokerOpponentChange

on construct me
  pWindowTitle = "GAME"
  return 1
end

on deconstruct me
  me.closeGame()
  return 1
end

on closeGame me
  if objectExists("battleShipPlacer") then
    removeObject("battleShipPlacer")
  end if
  if objectExists("chessPlacer") then
    removeObject("chessPlacer")
  end if
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
    "Poker":
      tWindowTitle = getText("game_poker", "Poker")
      if not windowExists(tWindowTitle) then
        me.ChangeWindowView(tWindowTitle, "poker.window", #eventProcPoker)
      else
        me.changePokerWindow("poker.window")
      end if
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
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(tEventProc, me.getID(), #mouseUp)
    tWndObj.registerProcedure(tEventProc, me.getID(), #keyDown)
    pWindowTitle = tWindowTitle
    pOpenWindow = tWindowName
    if not voidp(tX) and not voidp(tY) then
      tWndObj.moveTo(tX, tY)
    else
      tWndObj.center()
    end if
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
  tElem.clearBuffer()
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
  tcenter = rect((tX * tSize) + (tSize / 2), (tY * tSize) + (tSize / 2), (tX * tSize) + (tSize / 2), (tY * tSize) + (tSize / 2))
  tDstRect = tMemRect + tcenter
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
  tcenter = rect((tX * tSquareSize) + (tSquareSize / 2), (tY * tSquareSize) + (tSquareSize / 2), (tX * tSquareSize) + (tSquareSize / 2), (tY * tSquareSize) + (tSquareSize / 2))
  tdestrect = tMemRect + tcenter
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

on PokerShowStatusText me, tText, tElement
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement(tElement)
  if tElem = 0 then
    return 0
  end if
  return tElem.setText(tText)
end

on drawPokerCard me, tElem, tMemName
  if not windowExists(pWindowTitle) then
    return error(me, "Window not exists!", #drawPokerCard)
  end if
  tWndObj = getWindow(pWindowTitle)
  if not tWndObj.elementExists(tElem) then
    return error(me, "Element not exists," && tElem, #drawPokerCard)
  end if
  if not memberExists(tMemName) then
    return error(me, "Member not exists," && tMemName, #drawPokerCard)
  end if
  tElem = tWndObj.getElement(tElem)
  tImg = member(getmemnum(tMemName)).image.duplicate()
  tElem.feedImage(tImg)
end

on pokerMarkCards me
  if pOpenWindow <> "poker_cards.window" then
    return 0
  end if
  tOppCount = me.getComponent().pOpenGameProps[#opponentList].count
  tList = pPokerOpponentChange
  tCardBack = "game_small_back_0"
  if not voidp(tList) then
    repeat with i = 1 to tOppCount
      repeat with e = 1 to 5
        if tList[i].findPos(e) > 0 then
          me.fitOpponentCards("player_" & i & "_" & e, "game_small_back_1")
          next repeat
        end if
        me.fitOpponentCards("player_" & i & "_" & e, tCardBack)
      end repeat
    end repeat
  end if
end

on fitOpponentCards me, tElemID, tImage
  tWndObj = getWindow(pWindowTitle)
  if tWndObj.elementExists(tElemID) then
    tElem = tWndObj.getElement(tElemID)
    tDestImg = tElem.getProperty(#image)
    tSourceImg = member(tImage).image
    tdestrect = tDestImg.rect
    tMargins = tDestImg.rect - tSourceImg.rect
    tdestrect = rect(0, 0, tSourceImg.width, tSourceImg.height) + tMargins
    tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect)
    tElem.feedImage(tDestImg)
  end if
end

on RemoveOpponentCards me, tOpponentNum
  if pOpenWindow <> "poker_cards.window" then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  repeat with i = 1 to 5
    tElem = tWndObj.getElement("player_" & tOpponentNum & "_" & i)
    if tElem = 0 then
      return 0
    end if
    tElem.clearImage()
  end repeat
end

on drawSelectedCards me, tElemName
  if pOpenWindow <> "poker_cards.window" then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  tElem = tWndObj.getElement(tElemName)
  tmember = "game_small_back_1"
  if tmember <> 0 then
    tDestImg = tElem.getProperty(#image)
    tSourceImg = member(tmember).image
    tdestrect = tDestImg.rect
    tDestImg.copyPixels(tSourceImg, tdestrect, tSourceImg.rect)
    tElem.feedImage(tDestImg)
  end if
end

on hideChangeCards me
  if pOpenWindow <> "poker_cards.window" then
    return 0
  end if
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("poker_ready")
  if tElem = 0 then
    return 0
  end if
  tElem.setProperty(#visible, 0)
  return 1
end

on changePokerWindow me, tView
  tWndObj = getWindow(pWindowTitle)
  if tWndObj = 0 then
    return 0
  end if
  tPosY = tWndObj.getProperty(#locY)
  tPosX = tWndObj.getProperty(#locX)
  me.ChangeWindowView(pWindowTitle, tView, #eventProcPoker, tPosX, tPosY)
end

on PokerListMyCards me, tMsg
  tItemD = the itemDelimiter
  the itemDelimiter = "/"
  tProps = tMsg.item[2]
  the itemDelimiter = ","
  me.getComponent().pOpenGameProps[#changeDone] = tProps.item[1]
  me.getComponent().pOpenGameProps[#amountChanged] = tProps.item[2]
  if value(tProps.item[1]) = 0 then
    tText = getText("game_poker_change", "Choose cards to change")
    me.PokerShowStatusText(tText, "poker_message")
  end if
  the itemDelimiter = "/"
  repeat with i = 1 to 5
    tCard = tMsg.item[i + 2]
    me.getComponent().pOpenGameProps[#my_ & i] = tCard
    me.drawPokerCard("my_" & i, "game_" & tCard)
  end repeat
  the itemDelimiter = tItemD
  if not voidp(pPokerOpponentChange) then
    me.pokerMarkCards()
  end if
end

on PokerHandleOpponents me, tMsg
  pMyName = getObject(#session).get(#userName)
  if voidp(pPokerOpponentChange) then
    pPokerOpponentChange = [[], [], []]
  end if
  tOppList = me.getComponent().pOpenGameProps[#opponentList]
  if not voidp(tOppList) then
    tOpponents = tOppList
  end if
  tOppList = []
  repeat with i = 1 to tMsg.line.count - 1
    tName = tMsg.line[i].word[1]
    tChange = tMsg.line[i].word[2]
    tText = getText("game_poker_changed", "changed")
    if tName <> pMyName then
      tOppList.add(tName)
      if pOpenWindow = "poker_cards.window" then
        if value(tChange) > 0 then
          tPlayer = tName & RETURN & tText && tChange
          me.PokerShowStatusText(tPlayer, "poker_player_" & tOppList.count)
        else
          me.PokerShowStatusText(tName, "poker_player_" & tOppList.count)
        end if
      end if
      me.pokerMarkCards()
    end if
  end repeat
  if not voidp(tOpponents) then
    repeat with i = 1 to tOpponents.count
      if tOppList.findPos(tOpponents[i]) = 0 then
        tName = tOpponents[i]
        if tName <> pMyName then
          me.PokerOpponentLeaves(tName)
        end if
      end if
    end repeat
  end if
  me.getComponent().pOpenGameProps[#opponentList] = tOppList
end

on PokerOpponentLeaves me, tName
  tOppList = me.getComponent().pOpenGameProps[#opponentList]
  tPlayerNum = tOppList.findPos(tName)
  me.RemoveOpponentCards(tPlayerNum)
  tOppList.deleteAt(tPlayerNum)
  tText = getText("game_poker_logoff", "Left the game")
  tPlayer = tName & RETURN & tText
  me.PokerShowStatusText(tPlayer, "poker_player_" & tPlayerNum)
  me.getComponent().pOpenGameProps[#opponentList] = tOppList
end

on pokerChangeCards me, tMsg
  tOppList = me.getComponent().pOpenGameProps[#opponentList]
  tOpponents = tOppList.count
  tItemD = the itemDelimiter
  the itemDelimiter = "/"
  if tMsg.item[1] <> pMyName then
    tPlayerNum = tOppList.findPos(tMsg.item[1])
    tOpChanged = []
    if tMsg.item[2].word.count > 0 then
      repeat with i = 1 to tMsg.item[2].word.count
        tOpChanged.add(integer(tMsg.item[2].word[i]) + 1)
      end repeat
    end if
    pPokerOpponentChange[tPlayerNum] = tOpChanged
    if pOpenWindow = "poker_cards.window" then
      me.pokerMarkCards()
    end if
    repeat with i = 1 to tMsg.line.count - 1
      tName = tMsg.line[i].word[1]
      if tName <> pMyName then
        tOppList.add(tName)
        me.PokerShowStatusText(tName, "poker_player_" & tOppList.count)
      end if
    end repeat
    if pOpenWindow = "poker_cards.window" then
      tText = getText("game_poker_changed", "changed")
      tPlayer = tMsg.item[1] & RETURN & tText && tOpChanged.count
      me.PokerShowStatusText(tPlayer, "poker_player_" & tPlayerNum)
    end if
  else
    me.pokerChangeCursor()
  end if
  the itemDelimiter = tItemD
end

on PokerRevealCards me, tMsg
  pPokerOpponentChange = [[], [], []]
  tOppChanged = me.getComponent().pOpenGameProps[#PokerOpponentChange]
  tOppList = me.getComponent().pOpenGameProps[#opponentList]
  tOpponents = tOppList.count
  tOppChanged = [:]
  tItemD = the itemDelimiter
  the itemDelimiter = "/"
  tPlayersCards = []
  repeat with i = 1 to tMsg.line.count - 1
    if tMsg.line[i].item[1] <> pMyName then
      tPlayersCards.add([])
      tMyList = tPlayersCards.count
      repeat with e = 1 to 7
        tPlayersCards[tMyList].add(tMsg.line[i].item[e])
      end repeat
    end if
  end repeat
  me.changePokerWindow("poker_end.window")
  repeat with i = 1 to 5
    me.drawPokerCard("my_" & i, "game_" & me.getComponent().pOpenGameProps[#my_ & i])
  end repeat
  tText = getText("game_poker_ready", "READY")
  repeat with i = 1 to tOpponents
    tPlayerNum = tOppList.findPos(tPlayersCards[i][1])
    repeat with e = 1 to 5
      me.drawPokerCard("player_" & tPlayerNum & "_" & e, "game_" & tPlayersCards[tPlayerNum][e + 2])
    end repeat
    tPlayer = tPlayersCards[i][1] & RETURN & tText
    me.PokerShowStatusText(tPlayer, "poker_player_" & tPlayerNum)
  end repeat
  the itemDelimiter = tItemD
end

on pokerChangeCursor me
  tWinObj = getWindow(pWindowTitle)
  tElem = tWinObj.getElement("my_1")
  if tElem.getProperty(#cursor) <> 0 then
    repeat with i = 1 to 5
      tWinObj.getElement("my_" & i).setProperty(#cursor, 0)
    end repeat
  end if
end

on eventProcPoker me, tEvent, tElemID, tParam
  if tEvent = #mouseUp then
    case tElemID of
      "close":
        me.closeGame("Poker")
      "game_newgame":
        pPokerChangeCards = []
        me.changePokerWindow("poker_cards.window")
        me.getComponent().startPoker()
        tText = getText("game_poker", "POKER")
        me.PokerShowStatusText(tText, "poker_text1")
        tText = getText("game_newgame", "Start a new game")
        me.PokerShowStatusText(tText, "poker_start")
      "my_1", "my_2", "my_3", "my_4", "my_5":
        if value(me.getComponent().pOpenGameProps[#changeDone]) = 0 then
          tMyCard = integer(tElemID.char[length(tElemID)] - 1)
          tCardSearch = pPokerChangeCards.findPos(tMyCard)
          if tCardSearch <> 0 then
            pPokerChangeCards.deleteAt(tCardSearch)
            me.drawPokerCard(tElemID, "game_" & me.getComponent().pOpenGameProps[tElemID])
          else
            pPokerChangeCards.add(tMyCard)
            me.drawPokerCard(tElemID, "game_BACKSIDE")
          end if
        end if
      "poker_ready":
        if value(me.getComponent().pOpenGameProps[#changeDone]) = 0 then
          me.hideChangeCards()
          tCardCount = pPokerChangeCards.count
          tCardList = EMPTY
          if tCardCount > 0 then
            repeat with i = 1 to pPokerChangeCards.count
              tCardList = tCardList && pPokerChangeCards[i]
            end repeat
          end if
          me.getComponent().pokerChangeCards(tCardList)
          pPokerChangeCards = []
          if me.getComponent().pOpenGameProps[#opponentList].count > 0 then
            tText = getText("game_poker_waiting", "Waiting for opponents")
            me.PokerShowStatusText(tText, "poker_message")
          else
            tText = getText("game_poker_changed", "Cards changed")
            me.PokerShowStatusText(tText, "poker_message")
          end if
        end if
    end case
  end if
end
