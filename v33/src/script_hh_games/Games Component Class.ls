property pOpenGameProps

on construct me
  pOpenGameProps = [:] 
  return TRUE
  
end

on deconstruct me
  pOpenGameProps = [:] 
  return TRUE
  
end

on sendGameOpen me
  if voidp(pOpenGameProps) then return FALSE
  if voidp(pOpenGameProps.getAt(#id)) then return FALSE
  if not connectionExists(getVariable("connection.room.id")) then return FALSE
  
  getConnection(getVariable("connection.room.id")).send("IIM", pOpenGameProps.getAt(#id) && "OPEN")
  return TRUE
  
end

on sendGameClose me
  if voidp(pOpenGameProps) then return(0)
  if voidp(pOpenGameProps.getAt( #id)) then return(0)
  if not connectionExists(getVariable("connection.room.id")) then return(0)
  
  getConnection(getVariable("connection.room.id")).send("IIM", pOpenGameProps.getAt(#id) && "CLOSE")
  pOpenGameProps = [:]  
  return TRUE
  
end

on openGameBoard me, tMsg
  pOpenGameProps = tMsg
  case pOpenGameProps.getAt(#name) of
    "TicTacToe":
      pOpenGameProps.setAt(#bothTypeChosen, 0)
      pOpenGameProps.setAt(#player1, [#type: "", #name: ""])
      pOpenGameProps.setAt(#player2, [#type: "", #name: ""])
      if me.sendGameOpen() then me.openTicTacToe(pOpenGameProps)
      
    "Chess":
      if me.sendGameOpen() then me.openChess(pOpenGameProps)
      
    "BattleShip":
      pOpenGameProps.setAt(#gameEnd, 0)
      if me.sendGameOpen() then me.openBattleShip(pOpenGameProps)
      
    "poker":
      if me.sendGameOpen() then me.openPoker(pOpenGameProps)
      
    otherwise:
      error(me, "Unknown game:" && pOpenGameProps.getAt(#name), #openGameBoard)
      
  end case
end

on closeGameBoard me, tMsg
  tCloseGameProps = tMsg
  case tCloseGameProps.getAt(#name) of
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
  if voidp(pOpenGameProps) then return FALSE
  
  put ("tMsg command: " & tMsg.getAt(#command))
  put ("tMsg content: " & tMsg.getAt(#data))
  
  case pOpenGameProps.getAt(#name) of
    "TicTacToe":
      if tMsg.getAt(#command) contains "BOARDDATA" then
        pOpenGameProps.setAt(#player1, [#type: tMsg.getAt(#data).line[1].word[1], #name: tMsg.getAt(#data).line[1].word[2]])
        pOpenGameProps.setAt(#player2, [#type: tMsg.getAt(#data).line[2].word[1], #name: tMsg.getAt(#data).line[2].word[2]])
        pOpenGameProps.setAt(#gameboard, tMsg.getAt(#data).getProp(#line, 3, tMsg.getAt(#data).count(#line)))
        if pOpenGameProps.getAt(#bothTypeChosen) then
          me.getInterface().updateTicTacToe(pOpenGameProps)
          
        else
          me.getInterface().selectedTypeTicTacToe(pOpenGameProps.getAt(#player1), pOpenGameProps)
          me.getInterface().selectedTypeTicTacToe(pOpenGameProps.getAt(#player2), pOpenGameProps)
          me.getInterface().updateTicTacToe(pOpenGameProps)
          
        end if
      else if tMsg.getAt(#command) contains "SELECTTYPE" then
        pOpenGameProps.setAt(#mySelectedType, tMsg.getAt(#command).getProp(#word, 2))
        getThread(#games).getInterface().StartTicTacToe(pOpenGameProps)
        
      else if tMsg.getAt(#command) contains "OPPONENTS" then
        me.restartTicTacToe()
        pOpenGameProps.setAt(#player1, [#type: tMsg.getAt(#data).line[1].word[1], #name: tMsg.getAt(#data).line[1].word[2]])
        pOpenGameProps.setAt(#player2, [#type: tMsg.getAt(#data).line[2].word[1], #name: tMsg.getAt(#data).line[2].word[2]])
        me.getInterface().selectedTypeTicTacToe(pOpenGameProps.getAt(#player1), pOpenGameProps)
        me.getInterface().selectedTypeTicTacToe(pOpenGameProps.getAt(#player2), pOpenGameProps)
        if tMsg.getAt(#data).getPropRef(#line, 1).length > 3 and tMsg.getAt(#data).getPropRef(#line, 2).length > 3 then pOpenGameProps.setAt(#bothTypeChosen, 1)
        else pOpenGameProps.setAt(#bothTypeChosen, 0)
        
      else if tMsg.getAt(#command) contains "TYPERESERVED" then
        beep(1)
        
      end if
      
    "Chess":
      if tMsg.getAt(#command) contains "SELECTTYPE" then
        pOpenGameProps.setAt(#mySelectedType, tMsg.getAt( #command).getProp(#word, 2))
        me.getInterface().startChess(pOpenGameProps)
        
      else if tMsg.getAt(#command) contains "PIECEDATA" then
        if voidp(pOpenGameProps.getAt( #mySelectedType)) then return(0)
        pOpenGameProps.setAt(#player1, [#type: tMsg.getAt(#data).line[1].word[1], #name: tMsg.getAt(#data).line[1].word[2]])
        pOpenGameProps.setAt(#player2, [#type: tMsg.getAt(#data).line[2].word[1], #name: tMsg.getAt(#data).line[2].word[2]])
        pOpenGameProps.setAt(#gameboard, tMsg.getAt(#data).getProp(#line, 3, tMsg.getAt(#data).count(#line)))
        me.getInterface().updateChess(pOpenGameProps)
        
      else if tMsg.getAt(#command) contains "TYPERESERVED" then
        beep(1)
        
      end if
      
    "BattleShip":
      if not voidp(pOpenGameProps.getAt(#gameEnd)) then
        if pOpenGameProps.getAt(#gameEnd) = 1 then
          tText = getText("game_bs_won", "WON!") && pOpenGameProps.getAt(#winner)
          me.getInterface().battleShipGameEnd(tText)
          return TRUE
          
        end if
      end if
      if tMsg.getAt( #command) contains "TURN" then
        if voidp(pOpenGameProps.getAt(#myTurnNum)) then return FALSE
        
        if not voidp(pOpenGameProps.getAt(#gameEnd)) then
          if pOpenGameProps.getAt(#gameEnd) = 1 then return FALSE
          
        end if
        if not voidp(pOpenGameProps.getAt(#shootstatus)) then
          if pOpenGameProps.getAt(#shootstatus) = "HIT" then return FALSE
          
        end if
        if tMsg.getAt(#data).getProp(#char, 1) = pOpenGameProps.getAt(#myTurnNum) then
          pOpenGameProps.setAt( #myturn, 1)
          me.getInterface().battleShipMyTurn()
          if not voidp(pOpenGameProps.getAt( #player1Data)) then
            me.getInterface().updateBattleShipBoard( pOpenGameProps.getAt(#player1Data))
            
          end if
        else
          pOpenGameProps.setAt( #myturn, 0)
          me.getInterface().battleShipOtherPlayersTurn()
          if not voidp(pOpenGameProps.getAt( #player1Data)) then
            me.getInterface().updateBattleShipBoard( pOpenGameProps.getAt(#player2Data))
            
          end if
        end if
      else if tMsg.getAt(#command) contains "OPPONENTS" then
        repeat with i = 1 to tMsg.getAt(#data).count(#line)
          tLine = tMsg.getAt(#data).getProp(#line, i)
          if tLine.getProp(#word, 2) = GetObject(#session).get("user_name") then pOpenGameProps.setAt(#myTurnNum, tLine.getProp(#word, 1))
          
        end repeat
      else if tMsg.getAt(#command) contains "BOTHCHOSEN" then
        me.sendGameClose()
        me.getInterface().closeGame()
        
      else if tMsg.getAt(#command) contains "HIT" or tMsg.getAt(#command) contains "SINK" then
        if pOpenGameProps.getAt(#myturn) then pOpenGameProps.setAt(#shootstatus, "HIT")
        if pOpenGameProps.getAt(#shootstatus) = "HIT" then tText = getText("game_bs_hit", "A Hit!!!")
        else tText = getText("game_bs_toast", "Toast!!!")
        
        me.getInterface().battleShipShowStatusText(tText)
        
      else if tMsg.getAt(#command) contains "HITTWICE" then
        if pOpenGameProps.getAt(#myturn) then pOpenGameProps.setAt(#shootstatus, tMsg.getAt(#command))
        
        beep(1)
        
      else if tMsg.getAt(#command) contains "MISS" then
        if pOpenGameProps.getAt(#myturn) then
          pOpenGameProps.setAt(#shootstatus, tMsg.getAt(#command))
          me.getInterface().battleShipShowTurnText(0)
          
        end if
        tText = getText("game_bs_miss", "Miss !!!")
        me.getInterface().battleShipShowStatusText(tText)
        
      else if tMsg.getAt(#command) contains "GAMEEND" then
        pOpenGameProps.setAt(#winner, tMsg.getAt(#data).getProp(#word, 1))
        pOpenGameProps.setAt(#gameEnd, 1)
        
      else if tMsg.getAt(#command) contains "SITUATION" then
        tOpponent1Data = tMsg.getAt(#data).getProp(#line, 2)
        tOpponent2Data = tMsg.getAt(#data).getProp(#line, 4)
        pOpenGameProps.setAt(#player1Data, [])
        pOpenGameProps.setAt(#player2Data, [])
        repeat with j in [1, 2]
          if j = 1 then s = tOpponent1Data
          else s = tOpponent2Data
          
          repeat with i = 1 to s.length then -- jump 269
            ay = (i - 1) / 13
            ax = (i - 1) mod 13
            if j <> value(pOpenGameProps.getAt(#myTurnNum)) + 1 then -- jump 111
              case s.getProp(#char, i) of
                "O":
                  add(pOpenGameProps.getAt(#player1Data), [ax, ay, #miss])
                  
                "X":
                  add(pOpenGameProps.getAt(#player1Data), [ax, ay, #hit])
                  
                "S":
                  add(pOpenGameProps.getAt(#player1Data), [ax, ay, #sink])
                  
              end case
            else
              case char i of s of
                "O":
                  add(pOpenGameProps.getAt(#player2Data), [ax, ay, #miss])
                  
                "X":
                  add(pOpenGameProps.getAt(#player2Data), [ax, ay, #hit])
                  
                "S":
                  add(pOpenGameProps.getAt(#player2Data), [ax, ay, #sink])
                  
              end case
            end if
          end repeat
        end repeat
        
        if pOpenGameProps.getAt(#myturn) = 1 then me.getInterface().updateBattleShipBoard(pOpenGameProps.getAt(#player1Data))
        else me.getInterface().updateBattleShipBoard(pOpenGameProps.getAt(#player2Data))
        
      end if
      
    "Poker":
      case TRUE of
        (tMsg.getAt(#command) contains "YOURCARDS"):
          return(me.getInterface().PokerListMyCards(tMsg.getAt(#command)))
          
        (tMsg.getAt(#command) contains "OPPONENTS"):
          return(me.getInterface().PokerHandleOpponents(tMsg.getAt(#data)))
          
        (tMsg.getAt(#command) contains "CHANGED"):
          return(me.getInterface().pokerChangeCards(tMsg.getAt(#data)))
          
        (tMsg.getAt(#command) contains "REVEALCARDS"):
          return(me.getInterface().PokerRevealCards(tMsg.getAt(#data)))
          
        (tMsg.getAt(#command) contains "OPPONENT_LOGOUT"):
          return(me.getInterface().PokerOpponentLeaves(tMsg.getAt(#data).getProp(#item, 1)))
          
      end case
    otherwise:
      put(">>>>>>>>>>", tMsg)
      
  end case
end

on openTicTacToe me, tProps
  me.getInterface().openGameWindow("TicTacToe", tProps)
  
end

on chooseSideTicTacToe me, tside
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) or voidp(tside) then return FALSE
  if not connectionExists(getVariable("connection.room.id")) then return FALSE
  getConnection(getVariable("connection.room.id")).send( "IIM", tid && "CHOOSETYPE" && tside) -- jump 8 landing
  
end

on makeMoveTicTacToe me, tX, tY
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then return FALSE
  if voidp(pOpenGameProps.getAt( #mySelectedType)) then return FALSE
  if not connectionExists(getVariable("connection.room.id")) then return FALSE
  
  getConnection(getVariable("connection.room.id")).send( "IIM", tid && "SETSECTOR" && pOpenGameProps.getAt(#mySelectedType) && tX && tY) -- jump 8 landing
  
end

on restartTicTacToe me
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then return FALSE
  if not connectionExists(getVariable("connection.room.id")) then return FALSE
  
  getConnection(getVariable("connection.room.id")).send( "IIM", tid && "RESTART")
  
end

on openChess me, tProps
  me.getInterface().openGameWindow("Chess", tProps)
  
end

on makeMoveChess me, tMove
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then return FALSE
  if not connectionExists(getVariable("connection.room.id")) then return FALSE
  
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "MOVEPIECE" && tMove)
  
end

on sendChessByEmail me
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then return(0)
  if not connectionExists(getVariable("connection.room.id")) then return(0)
  
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "SENDHISTORY")
  
end

on restartChess me
  tid = pOpenGameProps.getAt( #id)
  if voidp(tid) then return(0)
  if not connectionExists(getVariable("connection.room.id")) then return(0)
  
  me.getInterface().startChess(pOpenGameProps)
  getConnection(getVariable("connection.room.id")).send( "IIM", tid && "RESTART")
  
end

on notRestartChess me
  me.getInterface().startChess(pOpenGameProps)
  me.getInterface().updateChess(pOpenGameProps)
  
end

on getMySideChess me
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then return FALSE
  if voidp(pOpenGameProps.getAt(#mySelectedType)) then return FALSE
  
  return pOpenGameProps.getAt(#mySelectedType)
  
end

on openBattleShip me, tProps
  me.getInterface().openGameWindow("BattleShip", tProps)
  
end

on sendBattleShipPlaceShip me, tMove
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then return FALSE
  if not connectionExists(getVariable("connection.room.id")) then return FALSE
  
  getConnection(getVariable("connection.room.id")).send( "IIM", tid && "PLACESHIP" && tMove)
  
end

on restartBattleShip me
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then return FALSE
  if not connectionExists(getVariable("connection.room.id")) then return FALSE
  
  tTemp = [:]
  tTemp.setAt(#id, pOpenGameProps.getAt(#id))
  tTemp.setAt(#name, pOpenGameProps.getAt(#name))
  me.sendGameClose()
  me.openGameBoard(tTemp)
  
end

on sendBattleShipShoot me, tX, tY
  if pOpenGameProps.getAt(#myturn) <> 1 then return FALSE
  
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then return FALSE
  if not connectionExists(getVariable("connection.room.id")) then return FALSE
  
  if not voidp(pOpenGameProps.getAt(#gameEnd)) then
    if pOpenGameProps.getAt(#gameEnd) = 1 then return FALSE
    
  end if
  getConnection(getVariable("connection.room.id")).send("IIM", tid && "SHOOT" && tX && tY)
  return TRUE
  
end

on openPoker me, tProps
  me.getInterface().openGameWindow("Poker", tProps)
  
end

on startPoker me
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then return FALSE
  if not connectionExists(getVariable("connection.room.id")) then return FALSE
  
  getConnection(getVariable("connection.room.id")).send( "IIM", tid && "STARTOVER")
  
end

on restartPoker me
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then return FALSE
  if not connectionExists(getVariable("connection.room.id")) then return FALSE
  
  tTemp = [:]
  tTemp.setAt(#id, pOpenGameProps.getAt(#id))
  tTemp.setAt(#name, pOpenGameProps.getAt(#name))
  me.sendGameClose()
  me.openGameBoard(tTemp)
  
end

on pokerChangeCards me, tCards
  tid = pOpenGameProps.getAt(#id)
  if voidp(tid) then return FALSE
  if not connectionExists(getVariable("connection.room.id")) then return FALSE
  
  getConnection(getVariable("connection.room.id")).send( "IIM", tid && "CHANGE" && tCards) -- jump 8 landing
  
end