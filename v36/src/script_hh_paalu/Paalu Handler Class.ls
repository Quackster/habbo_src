on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on sendAction me, tActionStr 
  tConn = getConnection(#info)
  if (tConn = 0) then
    return FALSE
  end if
  tConn.send("PTM", [#integer:me.getIntActionFromString(tActionStr)])
end

on handle_pt_prepare me, tMsg 
  tConn = tMsg.connection
  tPl1 = string(tConn.GetIntFrom())
  tPl2 = string(tConn.GetIntFrom())
  me.getComponent().prepareGame(tPl1, tPl2)
end

on handle_pt_start me, tMsg 
  tConn = tMsg.connection
  tPl1 = string(tConn.GetIntFrom())
  tPl2 = string(tConn.GetIntFrom())
  me.getComponent().startGame(tPl1, tPl2)
end

on handle_pt_status me, tMsg 
  tConn = tMsg.connection
  tPl1 = [#loc:tConn.GetIntFrom(), #bal:tConn.GetIntFrom(), #act:me.getStringActionFromInt(tConn.GetIntFrom()), #hit:tConn.GetBoolFrom()]
  tPl2 = [#loc:tConn.GetIntFrom(), #bal:tConn.GetIntFrom(), #act:me.getStringActionFromInt(tConn.GetIntFrom()), #hit:tConn.GetBoolFrom()]
  me.getComponent().updateGame(tPl1, tPl2)
end

on handle_pt_win me, tMsg 
  tConn = tMsg.connection
  tResult = tConn.GetIntFrom()
  if (tResult = 1) then
    me.getComponent().endGame(1)
  else
    if (tResult = 0) then
      me.getComponent().endGame(#both)
    else
      if (tResult = -1) then
        me.getComponent().endGame(0)
      end if
    end if
  end if
  return FALSE
end

on handle_pt_timeout me, tMsg 
  tConn = tMsg.connection
  me.getComponent().timeout(tConn.GetIntFrom())
end

on handle_pt_end me, tMsg 
  me.getComponent().resetGame()
end

on getStringActionFromInt me, tInt 
  if (tInt = 0) then
    return("-")
  else
    if (tInt = 1) then
      return("A")
    else
      if (tInt = 2) then
        return("D")
      else
        if (tInt = 3) then
          return("W")
        else
          if (tInt = 4) then
            return("E")
          else
            if (tInt = 5) then
              return("X")
            else
              if (tInt = 6) then
                return("S")
              else
                if (tInt = 7) then
                  return("0")
                else
                  if (tInt = 8) then
                    return("Q")
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return("-")
end

on getIntActionFromString me, tStr 
  if (tStr = "-") then
    return FALSE
  else
    if (tStr = "A") then
      return TRUE
    else
      if (tStr = "D") then
        return(2)
      else
        if (tStr = "W") then
          return(3)
        else
          if (tStr = "E") then
            return(4)
          else
            if (tStr = "X") then
              return(5)
            else
              if (tStr = "S") then
                return(6)
              else
                if (tStr = "0") then
                  return(7)
                else
                  if (tStr = "Q") then
                    return(8)
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return FALSE
end

on regMsgList me, tBool 
  tMsgs = [:]
  tMsgs.setaProp(114, #handle_pt_start)
  tMsgs.setaProp(115, #handle_pt_prepare)
  tMsgs.setaProp(116, #handle_pt_end)
  tMsgs.setaProp(117, #handle_pt_timeout)
  tMsgs.setaProp(118, #handle_pt_status)
  tMsgs.setaProp(119, #handle_pt_win)
  tCmds = [:]
  tCmds.setaProp("PTM", 114)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return TRUE
end
