on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on sendAction(me, tActionStr)
  tConn = getConnection(#info)
  if tConn = 0 then
    return(0)
  end if
  tConn.send("PTM", [#integer:me.getIntActionFromString(tActionStr)])
  exit
end

on handle_pt_prepare(me, tMsg)
  tConn = tMsg.connection
  tPl1 = string(tConn.GetIntFrom())
  tPl2 = string(tConn.GetIntFrom())
  me.getComponent().prepareGame(tPl1, tPl2)
  exit
end

on handle_pt_start(me, tMsg)
  tConn = tMsg.connection
  tPl1 = string(tConn.GetIntFrom())
  tPl2 = string(tConn.GetIntFrom())
  me.getComponent().startGame(tPl1, tPl2)
  exit
end

on handle_pt_status(me, tMsg)
  tConn = tMsg.connection
  tPl1 = [#loc:tConn.GetIntFrom(), #bal:tConn.GetIntFrom(), #act:me.getStringActionFromInt(tConn.GetIntFrom()), #hit:tConn.GetBoolFrom()]
  tPl2 = [#loc:tConn.GetIntFrom(), #bal:tConn.GetIntFrom(), #act:me.getStringActionFromInt(tConn.GetIntFrom()), #hit:tConn.GetBoolFrom()]
  me.getComponent().updateGame(tPl1, tPl2)
  exit
end

on handle_pt_win(me, tMsg)
  tConn = tMsg.connection
  tResult = tConn.GetIntFrom()
  if me = 1 then
    me.getComponent().endGame(0)
  else
    if me = 0 then
      me.getComponent().endGame(#both)
    else
      if me = -1 then
        me.getComponent().endGame(1)
      end if
    end if
  end if
  return(0)
  exit
end

on handle_pt_timeout(me, tMsg)
  tConn = tMsg.connection
  me.getComponent().timeout(tConn.GetIntFrom())
  exit
end

on handle_pt_end(me, tMsg)
  me.getComponent().resetGame()
  exit
end

on getStringActionFromInt(me, tInt)
  if me = 0 then
    return("-")
  else
    if me = 1 then
      return("A")
    else
      if me = 2 then
        return("D")
      else
        if me = 3 then
          return("W")
        else
          if me = 4 then
            return("E")
          else
            if me = 5 then
              return("X")
            else
              if me = 6 then
                return("S")
              else
                if me = 7 then
                  return("0")
                else
                  if me = 8 then
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
  exit
end

on getIntActionFromString(me, tStr)
  if me = "-" then
    return(0)
  else
    if me = "A" then
      return(1)
    else
      if me = "D" then
        return(2)
      else
        if me = "W" then
          return(3)
        else
          if me = "E" then
            return(4)
          else
            if me = "X" then
              return(5)
            else
              if me = "S" then
                return(6)
              else
                if me = "0" then
                  return(7)
                else
                  if me = "Q" then
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
  return(0)
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setaProp(114, #handle_pt_start)
  tMsgs.setaProp(115, #handle_pt_prepare)
  tMsgs.setaProp(116, #handle_pt_end)
  tMsgs.setaProp(117, #handle_pt_timeout)
  tMsgs.setaProp(118, #handle_pt_status)
  tMsgs.setaProp(119, #handle_pt_win)
  tCmds = []
  tCmds.setaProp("PTM", 114)
  if tBool then
    registerListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.room.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.room.id"), me.getID(), tCmds)
  end if
  return(1)
  exit
end