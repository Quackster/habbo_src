property pOpenGameProps

on construct me
  pOpenGameProps = [:]
  return 1
end

on deconstruct me
  pOpenGameProps = [:]
  return 1
end

on sendGameOpen me
  if voidp(pOpenGameProps) then
    return 0
  end if
  if voidp(pOpenGameProps[#id]) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", pOpenGameProps[#id] && "OPEN")
  return 1
end

on sendGameClose me
  if voidp(pOpenGameProps) then
    return 0
  end if
  if voidp(pOpenGameProps[#id]) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", pOpenGameProps[#id] && "CLOSE")
  pOpenGameProps = [:]
  return 1
end

on openGameBoard me, tMsg
  pOpenGameProps = tMsg
  case pOpenGameProps[#name] of
    "TicTacToe":
      pOpenGameProps[#bothTypeChosen] = 0
      pOpenGameProps[#player1] = [#type: EMPTY, #name: EMPTY]
      pOpenGameProps[#player2] = [#type: EMPTY, #name: EMPTY]
      if me.sendGameOpen() then
        me.openTicTacToe(pOpenGameProps)
      end if
    "Chess":
      if me.sendGameOpen() then
        me.openChess(pOpenGameProps)
      end if
    "BattleShip":
      pOpenGameProps[#gameEnd] = 0
      if me.sendGameOpen() then
        me.openBattleShip(pOpenGameProps)
      end if
    "poker":
      if me.sendGameOpen() then
        me.openPoker(pOpenGameProps)
      end if
    otherwise:
      error(me, "Unknown game:" && pOpenGameProps[#name], #openGameBoard)
  end case
end

on closeGameBoard me, tMsg
  tCloseGameProps = tMsg
  case tCloseGameProps[#name] of
    "TicTacToe":
      me.getInterface().closeGame()
    "Chess":
      me.getInterface().closeGame()
    "BattleShip":
      me.getInterface().closeGame()
    "Poker":
      me.getInterface().closeGame()
  end case
  me.sendGameClose()
end

on processItemMessage me, tMsg
  if voidp(pOpenGameProps) then
    return 0
  end if
  case pOpenGameProps[#name] of
    "TicTacToe":
      if tMsg[#command] contains "BOARDDATA" then
        pOpenGameProps[#player1] = [#type: tMsg[#data].line[1].word[1], #name: tMsg[#data].line[1].word[2]]
        pOpenGameProps[#player2] = [#type: tMsg[#data].line[2].word[1], #name: tMsg[#data].line[2].word[2]]
        pOpenGameProps[#gameboard] = tMsg[#data].line[3..tMsg[#data].line.count]
        if pOpenGameProps[#bothTypeChosen] then
          me.getInterface().updateTicTacToe(pOpenGameProps)
        else
          me.getInterface().selectedTypeTicTacToe(pOpenGameProps[#player1], pOpenGameProps)
          me.getInterface().selectedTypeTicTacToe(pOpenGameProps[#player2], pOpenGameProps)
          me.getInterface().updateTicTacToe(pOpenGameProps)
        end if
      else
        if tMsg[#command] contains "SELECTTYPE" then
          pOpenGameProps[#mySelectedType] = tMsg[#command].word[2]
          getThread(#games).getInterface().StartTicTacToe(pOpenGameProps)
        else
          if tMsg[#command] contains "OPPONENTS" then
            me.restartTicTacToe()
            pOpenGameProps[#player1] = [#type: tMsg[#data].line[1].word[1], #name: tMsg[#data].line[1].word[2]]
            pOpenGameProps[#player2] = [#type: tMsg[#data].line[2].word[1], #name: tMsg[#data].line[2].word[2]]
            me.getInterface().selectedTypeTicTacToe(pOpenGameProps[#player1], pOpenGameProps)
            me.getInterface().selectedTypeTicTacToe(pOpenGameProps[#player2], pOpenGameProps)
            if (tMsg[#data].line[1].length > 3) and (tMsg[#data].line[2].length > 3) then
              pOpenGameProps[#bothTypeChosen] = 1
            else
              pOpenGameProps[#bothTypeChosen] = 0
            end if
          else
            if tMsg[#command] contains "TYPERESERVED" then
              beep(1)
            end if
          end if
        end if
      end if
    "Chess":
      if tMsg[#command] contains "SELECTTYPE" then
        pOpenGameProps[#mySelectedType] = tMsg[#command].word[2]
        me.getInterface().startChess(pOpenGameProps)
      else
        if tMsg[#command] contains "PIECEDATA" then
          if voidp(pOpenGameProps[#mySelectedType]) then
            return 0
          end if
          pOpenGameProps[#player1] = [#type: tMsg[#data].line[1].word[1], #name: tMsg[#data].line[1].word[2]]
          pOpenGameProps[#player2] = [#type: tMsg[#data].line[2].word[1], #name: tMsg[#data].line[2].word[2]]
          pOpenGameProps[#gameboard] = tMsg[#data].line[3..tMsg[#data].line.count]
          me.getInterface().updateChess(pOpenGameProps)
        else
          if tMsg[#command] contains "TYPERESERVED" then
            beep(1)
          end if
        end if
      end if
    "BattleShip":
      if not voidp(pOpenGameProps[#gameEnd]) then
        if pOpenGameProps[#gameEnd] = 1 then
          tText = getText("game_bs_won", "WON!") && pOpenGameProps[#winner]
          me.getInterface().battleShipGameEnd(tText)
          return 1
        end if
      end if
      if tMsg[#command] contains "TURN" then
        if voidp(pOpenGameProps[#myTurnNum]) then
          return 0
        end if
        if not voidp(pOpenGameProps[#gameEnd]) then
          if pOpenGameProps[#gameEnd] = 1 then
            return 0
          end if
        end if
        if not voidp(pOpenGameProps[#shootstatus]) then
          if pOpenGameProps[#shootstatus] = "HIT" then
            return 0
          end if
        end if
        if tMsg[#data].char[1] = pOpenGameProps[#myTurnNum] then
          pOpenGameProps[#myturn] = 1
          me.getInterface().battleShipMyTurn()
          if not voidp(pOpenGameProps[#player1Data]) then
            me.getInterface().updateBattleShipBoard(pOpenGameProps[#player1Data])
          end if
        else
          pOpenGameProps[#myturn] = 0
          me.getInterface().battleShipOtherPlayersTurn()
          if not voidp(pOpenGameProps[#player1Data]) then
            me.getInterface().updateBattleShipBoard(pOpenGameProps[#player2Data])
          end if
        end if
      else
        if tMsg[#command] contains "OPPONENTS" then
          repeat with i = 1 to tMsg[#data].line.count
            tLine = tMsg[#data].line[i]
            if tLine.word[2] = getObject(#session).get("user_name") then
              pOpenGameProps[#myTurnNum] = tLine.word[1]
            end if
          end repeat
        else
          if tMsg[#command] contains "BOTHCHOSEN" then
            me.sendGameClose()
            me.getInterface().closeGame()
          else
            if (tMsg[#command] contains "HIT") or (tMsg[#command] contains "SINK") then
              if pOpenGameProps[#myturn] then
                pOpenGameProps[#shootstatus] = "HIT"
              end if
              if pOpenGameProps[#shootstatus] = "HIT" then
                tText = getText("game_bs_hit", "A Hit!!!")
              else
                tText = getText("game_bs_toast", "Toast!!!")
              end if
              me.getInterface().battleShipShowStatusText(tText)
            else
              if tMsg[#command] contains "HITTWICE" then
                if pOpenGameProps[#myturn] then
                  pOpenGameProps[#shootstatus] = tMsg[#command]
                end if
                beep(1)
              else
                if tMsg[#command] contains "MISS" then
                  if pOpenGameProps[#myturn] then
                    pOpenGameProps[#shootstatus] = tMsg[#command]
                    me.getInterface().battleShipShowTurnText(0)
                  end if
                  tText = getText("game_bs_miss", "Miss !!!")
                  me.getInterface().battleShipShowStatusText(tText)
                else
                  if tMsg[#command] contains "GAMEEND" then
                    pOpenGameProps[#winner] = tMsg[#data].word[1]
                    pOpenGameProps[#gameEnd] = 1
                  else
                    if tMsg[#command] contains "SITUATION" then
                      tOpponent1Data = tMsg[#data].line[2]
                      tOpponent2Data = tMsg[#data].line[4]
                      pOpenGameProps[#player1Data] = []
                      pOpenGameProps[#player2Data] = []
                      repeat with j in [1, 2]
                        if j = 1 then
                          s = tOpponent1Data
                        else
                          s = tOpponent2Data
                        end if
                        repeat with i = 1 to s.length
                          ay = (i - 1) / 13
                          ax = (i - 1) mod 13
                          if j <> (value(pOpenGameProps[#myTurnNum]) + 1) then
                            case s.char[i] of
                              "O":
                                add(pOpenGameProps[#player1Data], [ax, ay, #miss])
                              "X":
                                add(pOpenGameProps[#player1Data], [ax, ay, #hit])
                              "S":
                                add(pOpenGameProps[#player1Data], [ax, ay, #sink])
                            end case
                            next repeat
                          end if
                          case char i of s of
                            "O":
                              add(pOpenGameProps[#player2Data], [ax, ay, #miss])
                            "X":
                              add(pOpenGameProps[#player2Data], [ax, ay, #hit])
                            "S":
                              add(pOpenGameProps[#player2Data], [ax, ay, #sink])
                          end case
                        end repeat
                      end repeat
                      if pOpenGameProps[#myturn] = 1 then
                        me.getInterface().updateBattleShipBoard(pOpenGameProps[#player1Data])
                      else
                        me.getInterface().updateBattleShipBoard(pOpenGameProps[#player2Data])
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    "Poker":
      case 1 of
        (tMsg[#command] contains "YOURCARDS"):
          return me.getInterface().PokerListMyCards(tMsg[#command])
        (tMsg[#command] contains "OPPONENTS"):
          return me.getInterface().PokerHandleOpponents(tMsg[#data])
        (tMsg[#command] contains "CHANGED"):
          return me.getInterface().pokerChangeCards(tMsg[#data])
        (tMsg[#command] contains "REVEALCARDS"):
          return me.getInterface().PokerRevealCards(tMsg[#data])
        (tMsg[#command] contains "OPPONENT_LOGOUT"):
          return me.getInterface().PokerOpponentLeaves(tMsg[#data].item[1])
      end case
    otherwise:
      put ">>>>>>>>>>", tMsg
  end case
end

on openTicTacToe me, tProps
  me.getInterface().openGameWindow("TicTacToe", tProps)
end

on chooseSideTicTacToe me, tside
  tid = pOpenGameProps[#id]
  if voidp(tid) or voidp(tside) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "CHOOSETYPE" && tside)
end

on makeMoveTicTacToe me, tX, tY
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if voidp(pOpenGameProps[#mySelectedType]) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "SETSECTOR" && pOpenGameProps[#mySelectedType] && tX && tY)
end

on restartTicTacToe me
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "RESTART")
end

on openChess me, tProps
  me.getInterface().openGameWindow("Chess", tProps)
end

on makeMoveChess me, tMove
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "MOVEPIECE" && tMove)
end

on sendChessByEmail me
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "SENDHISTORY")
end

on restartChess me
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  me.getInterface().startChess(pOpenGameProps)
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "RESTART")
end

on notRestartChess me
  me.getInterface().startChess(pOpenGameProps)
  me.getInterface().updateChess(pOpenGameProps)
end

on getMySideChess me
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if voidp(pOpenGameProps[#mySelectedType]) then
    return 0
  end if
  return pOpenGameProps[#mySelectedType]
end

on openBattleShip me, tProps
  me.getInterface().openGameWindow("BattleShip", tProps)
end

on sendBattleShipPlaceShip me, tMove
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "PLACESHIP" && tMove)
end

on restartBattleShip me
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  tTemp = [:]
  tTemp[#id] = pOpenGameProps[#id]
  tTemp[#name] = pOpenGameProps[#name]
  me.sendGameClose()
  me.openGameBoard(tTemp)
end

on sendBattleShipShoot me, tX, tY
  if pOpenGameProps[#myturn] <> 1 then
    return 0
  end if
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  if not voidp(pOpenGameProps[#gameEnd]) then
    if pOpenGameProps[#gameEnd] = 1 then
      return 0
    end if
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "SHOOT" && tX && tY)
  return 1
end

on openPoker me, tProps
  me.getInterface().openGameWindow("Poker", tProps)
end

on startPoker me
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "STARTOVER")
end

on restartPoker me
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  tTemp = [:]
  tTemp[#id] = pOpenGameProps[#id]
  tTemp[#name] = pOpenGameProps[#name]
  me.sendGameClose()
  me.openGameBoard(tTemp)
end

on pokerChangeCards me, tCards
  tid = pOpenGameProps[#id]
  if voidp(tid) then
    return 0
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return 0
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "CHANGE" && tCards)
end
