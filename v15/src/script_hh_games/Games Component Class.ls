property pOpenGameProps

on construct me 
  pOpenGameProps = [:]
  return(1)
end

on deconstruct me 
  pOpenGameProps = [:]
  return(1)
end

on sendGameOpen me 
  if voidp(pOpenGameProps) then
    return(0)
  end if
  if voidp(pOpenGameProps.getAt(#id)) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", pOpenGameProps.getAt(#id) && "OPEN")
  return(1)
end

on sendGameClose me 
  if voidp(pOpenGameProps) then
    return(0)
  end if
  if voidp(pOpenGameProps.getAt(#id)) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", pOpenGameProps.getAt(#id) && "CLOSE")
  pOpenGameProps = [:]
  return(1)
end

on openGameBoard me, tMsg 
  pOpenGameProps = tMsg
  if pOpenGameProps.getAt(#name) = "TicTacToe" then
    pOpenGameProps.setAt(#bothTypeChosen, 0)
    pOpenGameProps.setAt(#player1, [#type:"", #name:""])
    pOpenGameProps.setAt(#player2, [#type:"", #name:""])
    if me.sendGameOpen() then
      me.openTicTacToe(pOpenGameProps)
    end if
  else
    if pOpenGameProps.getAt(#name) = "Chess" then
      if me.sendGameOpen() then
        me.openChess(pOpenGameProps)
      end if
    else
      if pOpenGameProps.getAt(#name) = "BattleShip" then
        pOpenGameProps.setAt(#gameend, 0)
        if me.sendGameOpen() then
          me.openBattleShip(pOpenGameProps)
        end if
      else
        if pOpenGameProps.getAt(#name) = "poker" then
          if me.sendGameOpen() then
            me.openPoker(pOpenGameProps)
          end if
        else
          error(me, "Unknown game:" && pOpenGameProps.getAt(#name), #openGameBoard)
        end if
      end if
    end if
  end if
end

on closeGameBoard me, tMsg 
  tCloseGameProps = tMsg
  if tCloseGameProps.getAt(#name) = "TicTacToe" then
    me.getInterface().closeGame()
  else
    if tCloseGameProps.getAt(#name) = "Chess" then
      me.getInterface().closeGame()
    else
      if tCloseGameProps.getAt(#name) = "BattleShip" then
        me.getInterface().closeGame()
      else
        if tCloseGameProps.getAt(#name) = "Poker" then
          me.getInterface().closeGame()
        end if
      end if
    end if
  end if
  me.sendGameClose()
end

on processItemMessage me, tMsg 
  if voidp(pOpenGameProps) then
    return(0)
  end if
  if pOpenGameProps.getAt(#name) = "TicTacToe" then
    if tMsg.getAt(#command) contains "BOARDDATA" then
      pOpenGameProps.setAt(#player1, [#type:tMsg.getAt(#data).getPropRef(#line, 1).getProp(#word, 1), #name:tMsg.getAt(#data).getPropRef(#line, 1).getProp(#word, 2)])
      pOpenGameProps.setAt(#player2, [#type:tMsg.getAt(#data).getPropRef(#line, 2).getProp(#word, 1), #name:tMsg.getAt(#data).getPropRef(#line, 2).getProp(#word, 2)])
      pOpenGameProps.setAt(#gameboard, tMsg.getAt(#data).getProp(#line, 3, tMsg.getAt(#data).count(#line)))
      if pOpenGameProps.getAt(#bothTypeChosen) then
        me.getInterface().updateTicTacToe(pOpenGameProps)
      else
        me.getInterface().selectedTypeTicTacToe(pOpenGameProps.getAt(#player1), pOpenGameProps)
        me.getInterface().selectedTypeTicTacToe(pOpenGameProps.getAt(#player2), pOpenGameProps)
        me.getInterface().updateTicTacToe(pOpenGameProps)
      end if
    else
      if tMsg.getAt(#command) contains "SELECTTYPE" then
        pOpenGameProps.setAt(#mySelectedType, tMsg.getAt(#command).getProp(#word, 2))
        getThread(#games).getInterface().StartTicTacToe(pOpenGameProps)
      else
        if tMsg.getAt(#command) contains "OPPONENTS" then
          me.restartTicTacToe()
          pOpenGameProps.setAt(#player1, [#type:tMsg.getAt(#data).getPropRef(#line, 1).getProp(#word, 1), #name:tMsg.getAt(#data).getPropRef(#line, 1).getProp(#word, 2)])
          pOpenGameProps.setAt(#player2, [#type:tMsg.getAt(#data).getPropRef(#line, 2).getProp(#word, 1), #name:tMsg.getAt(#data).getPropRef(#line, 2).getProp(#word, 2)])
          me.getInterface().selectedTypeTicTacToe(pOpenGameProps.getAt(#player1), pOpenGameProps)
          me.getInterface().selectedTypeTicTacToe(pOpenGameProps.getAt(#player2), pOpenGameProps)
          if tMsg.getAt(#data).getPropRef(#line, 1).length > 3 and tMsg.getAt(#data).getPropRef(#line, 2).length > 3 then
            pOpenGameProps.setAt(#bothTypeChosen, 1)
          else
            pOpenGameProps.setAt(#bothTypeChosen, 0)
          end if
        else
          if tMsg.getAt(#command) contains "TYPERESERVED" then
            beep(1)
          end if
        end if
      end if
    end if
  else
    if pOpenGameProps.getAt(#name) = "Chess" then
      if tMsg.getAt(#command) contains "SELECTTYPE" then
        pOpenGameProps.setAt(#mySelectedType, tMsg.getAt(#command).getProp(#word, 2))
        me.getInterface().startChess(pOpenGameProps)
      else
        if tMsg.getAt(#command) contains "PIECEDATA" then
          if voidp(pOpenGameProps.getAt(#mySelectedType)) then
            return(0)
          end if
          pOpenGameProps.setAt(#player1, [#type:tMsg.getAt(#data).getPropRef(#line, 1).getProp(#word, 1), #name:tMsg.getAt(#data).getPropRef(#line, 1).getProp(#word, 2)])
          pOpenGameProps.setAt(#player2, [#type:tMsg.getAt(#data).getPropRef(#line, 2).getProp(#word, 1), #name:tMsg.getAt(#data).getPropRef(#line, 2).getProp(#word, 2)])
          pOpenGameProps.setAt(#gameboard, tMsg.getAt(#data).getProp(#line, 3, tMsg.getAt(#data).count(#line)))
          me.getInterface().updateChess(pOpenGameProps)
        else
          if tMsg.getAt(#command) contains "TYPERESERVED" then
            beep(1)
          end if
        end if
      end if
    else
      if pOpenGameProps.getAt(#name) = "BattleShip" then
        if not voidp(pOpenGameProps.getAt(#gameend)) then
          if pOpenGameProps.getAt(#gameend) = 1 then
            tText = getText("game_bs_won", "WON!") && pOpenGameProps.getAt(#winner)
            me.getInterface().battleShipGameEnd(tText)
            return(1)
          end if
        end if
        if tMsg.getAt(#command) contains "TURN" then
          if voidp(pOpenGameProps.getAt(#myTurnNum)) then
            return(0)
          end if
          if not voidp(pOpenGameProps.getAt(#gameend)) then
            if pOpenGameProps.getAt(#gameend) = 1 then
              return(0)
            end if
          end if
          if not voidp(pOpenGameProps.getAt(#shootstatus)) then
            if pOpenGameProps.getAt(#shootstatus) = "HIT" then
              return(0)
            end if
          end if
          if tMsg.getAt(#data).getProp(#char, 1) = pOpenGameProps.getAt(#myTurnNum) then
            pOpenGameProps.setAt(#myturn, 1)
            me.getInterface().battleShipMyTurn()
            if not voidp(pOpenGameProps.getAt(#player1Data)) then
              me.getInterface().updateBattleShipBoard(pOpenGameProps.getAt(#player1Data))
            end if
          else
            pOpenGameProps.setAt(#myturn, 0)
            me.getInterface().battleShipOtherPlayersTurn()
            if not voidp(pOpenGameProps.getAt(#player1Data)) then
              me.getInterface().updateBattleShipBoard(pOpenGameProps.getAt(#player2Data))
            end if
          end if
        else
          if tMsg.getAt(#command) contains "OPPONENTS" then
            i = 1
            repeat while i <= tMsg.getAt(#data).count(#line)
              tLine = tMsg.getAt(#data).getProp(#line, i)
              if tLine.getProp(#word, 2) = getObject(#session).GET("user_name") then
                pOpenGameProps.setAt(#myTurnNum, tLine.getProp(#word, 1))
              end if
              i = 1 + i
            end repeat
            exit repeat
          end if
          if tMsg.getAt(#command) contains "BOTHCHOSEN" then
            me.sendGameClose()
            me.getInterface().closeGame()
          else
            if tMsg.getAt(#command) contains "HIT" or tMsg.getAt(#command) contains "SINK" then
              if pOpenGameProps.getAt(#myturn) then
                pOpenGameProps.setAt(#shootstatus, "HIT")
              end if
              if pOpenGameProps.getAt(#shootstatus) = "HIT" then
                tText = getText("game_bs_hit", "A Hit!!!")
              else
                tText = getText("game_bs_toast", "Toast!!!")
              end if
              me.getInterface().battleShipShowStatusText(tText)
            else
              if tMsg.getAt(#command) contains "HITTWICE" then
                if pOpenGameProps.getAt(#myturn) then
                  pOpenGameProps.setAt(#shootstatus, tMsg.getAt(#command))
                end if
                beep(1)
              else
                if tMsg.getAt(#command) contains "MISS" then
                  if pOpenGameProps.getAt(#myturn) then
                    pOpenGameProps.setAt(#shootstatus, tMsg.getAt(#command))
                    me.getInterface().battleShipShowTurnText(0)
                  end if
                  tText = getText("game_bs_miss", "Miss !!!")
                  me.getInterface().battleShipShowStatusText(tText)
                else
                  if tMsg.getAt(#command) contains "GAMEEND" then
                    pOpenGameProps.setAt(#winner, tMsg.getAt(#data).getProp(#word, 1))
                    pOpenGameProps.setAt(#gameend, 1)
                  else
                    if tMsg.getAt(#command) contains "SITUATION" then
                      tOpponent1Data = tMsg.getAt(#data).getProp(#line, 2)
                      tOpponent2Data = tMsg.getAt(#data).getProp(#line, 4)
                      pOpenGameProps.setAt(#player1Data, [])
                      pOpenGameProps.setAt(#player2Data, [])
                      repeat while pOpenGameProps.getAt(#name) <= undefined
                        j = getAt(undefined, tMsg)
                        if j = 1 then
                          s = tOpponent1Data
                        else
                          s = tOpponent2Data
                        end if
                        i = 1
                        repeat while i <= s.length
                          ay = i - 1 / 13
                          ax = i - 1 mod 13
                          if j <> value(pOpenGameProps.getAt(#myTurnNum)) + 1 then
                            if pOpenGameProps.getAt(#name) = "O" then
                              add(pOpenGameProps.getAt(#player1Data), [ax, ay, #miss])
                            else
                              if pOpenGameProps.getAt(#name) = "X" then
                                add(pOpenGameProps.getAt(#player1Data), [ax, ay, #hit])
                              else
                                if pOpenGameProps.getAt(#name) = "S" then
                                  add(pOpenGameProps.getAt(#player1Data), [ax, ay, #sink])
                                end if
                              end if
                            end if
                          else
                            if pOpenGameProps.getAt(#name) = "O" then
                              add(pOpenGameProps.getAt(#player2Data), [ax, ay, #miss])
                            else
                              if pOpenGameProps.getAt(#name) = "X" then
                                add(pOpenGameProps.getAt(#player2Data), [ax, ay, #hit])
                              else
                                if pOpenGameProps.getAt(#name) = "S" then
                                  add(pOpenGameProps.getAt(#player2Data), [ax, ay, #sink])
                                end if
                              end if
                            end if
                          end if
                          i = 1 + i
                        end repeat
                      end repeat
                      if pOpenGameProps.getAt(#myturn) = 1 then
                        me.getInterface().updateBattleShipBoard(pOpenGameProps.getAt(#player1Data))
                      else
                        me.getInterface().updateBattleShipBoard(pOpenGameProps.getAt(#player2Data))
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      else
        if pOpenGameProps.getAt(#name) = "Poker" then
          if pOpenGameProps.getAt(#name) = tMsg.getAt(#command) contains "YOURCARDS" then
            return(me.getInterface().PokerListMyCards(tMsg.getAt(#command)))
          else
            if pOpenGameProps.getAt(#name) = tMsg.getAt(#command) contains "OPPONENTS" then
              return(me.getInterface().PokerHandleOpponents(tMsg.getAt(#data)))
            else
              if pOpenGameProps.getAt(#name) = tMsg.getAt(#command) contains "CHANGED" then
                return(me.getInterface().pokerChangeCards(tMsg.getAt(#data)))
              else
                if pOpenGameProps.getAt(#name) = tMsg.getAt(#command) contains "REVEALCARDS" then
                  return(me.getInterface().PokerRevealCards(tMsg.getAt(#data)))
                else
                  if pOpenGameProps.getAt(#name) = tMsg.getAt(#command) contains "OPPONENT_LOGOUT" then
                    return(me.getInterface().PokerOpponentLeaves(tMsg.getAt(#data).getProp(#item, 1)))
                  end if
                end if
              end if
            end if
          end if
        else
          put(">>>>>>>>>>", tMsg)
        end if
      end if
    end if
  end if
end

on openTicTacToe me, tProps 
  me.getInterface().openGameWindow("TicTacToe", tProps)
end

on chooseSideTicTacToe me, tside 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) or voidp(tside) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "CHOOSETYPE" && tside)
end

on makeMoveTicTacToe me, tX, tY 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if voidp(pOpenGameProps.getAt(#mySelectedType)) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "SETSECTOR" && pOpenGameProps.getAt(#mySelectedType) && tX && tY)
end

on restartTicTacToe me 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "RESTART")
end

on openChess me, tProps 
  me.getInterface().openGameWindow("Chess", tProps)
end

on makeMoveChess me, tMove 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "MOVEPIECE" && tMove)
end

on sendChessByEmail me 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "SENDHISTORY")
end

on restartChess me 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  me.getInterface().startChess(pOpenGameProps)
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "RESTART")
end

on notRestartChess me 
  me.getInterface().startChess(pOpenGameProps)
  me.getInterface().updateChess(pOpenGameProps)
end

on getMySideChess me 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if voidp(pOpenGameProps.getAt(#mySelectedType)) then
    return(0)
  end if
  return(pOpenGameProps.getAt(#mySelectedType))
end

on openBattleShip me, tProps 
  me.getInterface().openGameWindow("BattleShip", tProps)
end

on sendBattleShipPlaceShip me, tMove 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "PLACESHIP" && tMove)
end

on restartBattleShip me 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  tTemp = [:]
  tTemp.setAt(#id, pOpenGameProps.getAt(#id))
  tTemp.setAt(#name, pOpenGameProps.getAt(#name))
  me.sendGameClose()
  me.openGameBoard(tTemp)
end

on sendBattleShipShoot me, tX, tY 
  if pOpenGameProps.getAt(#myturn) <> 1 then
    return(0)
  end if
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  if not voidp(pOpenGameProps.getAt(#gameend)) then
    if pOpenGameProps.getAt(#gameend) = 1 then
      return(0)
    end if
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "SHOOT" && tX && tY)
  return(1)
end

on openPoker me, tProps 
  me.getInterface().openGameWindow("Poker", tProps)
end

on startPoker me 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "STARTOVER")
end

on restartPoker me 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  tTemp = [:]
  tTemp.setAt(#id, pOpenGameProps.getAt(#id))
  tTemp.setAt(#name, pOpenGameProps.getAt(#name))
  me.sendGameClose()
  me.openGameBoard(tTemp)
end

on pokerChangeCards me, tCards 
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then
    return(0)
  end if
  if not connectionExists(getVariable("connection.room.id")) then
    return(0)
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "CHANGE" && tCards)
end
