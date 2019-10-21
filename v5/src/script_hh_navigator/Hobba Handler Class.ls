on construct me 
  return(me.regMsgList(1))
end

on deconstruct me 
  return(me.regMsgList(0))
end

on handle_cryforhelp me, tMsg 
  tProps = [:]
  tProps.setAt(#picker, "")
  tProps.setAt(#sender, tMsg.message.getProp(#line, 2))
  tProps.setAt(#url, tMsg.message.getProp(#line, 3))
  i = 4
  repeat while i <= tMsg.message.count(#line)
    tLine = tMsg.message.getProp(#line, i)
    ttype = tLine.getProp(#char, 1, (offset(":", tLine) - 1))
    tValue = tLine.getProp(#char, (offset(":", tLine) + 1), length(tLine))
    if (ttype = "id") then
      tProps.setAt(#id, tValue)
    else
      if (ttype = "name") then
        tProps.setAt(#name, tValue)
      else
        if (ttype = "port") then
          tProps.setAt(#port, tValue)
        else
          if (ttype = "type") then
            tProps.setAt(#type, symbol(tValue))
          else
            if (ttype = "text") then
              tProps.setAt(#msg, replaceChunks(tValue, "<br>", "\r"))
            end if
          end if
        end if
      end if
    end if
    i = (1 + i)
  end repeat
  if tProps.getAt(#sender) <> "[AUTOMATIC]" then
    me.getComponent().receive_cryforhelp(tProps)
  end if
end

on handle_picked_cry me, tMsg 
  tPicker = tMsg.message.getProp(#line, 2)
  tLogUrl = tMsg.message.getProp(#line, 3)
  tProps = [#picker:tPicker, #url:tLogUrl]
  me.getComponent().receive_pickedCry(tProps)
end

on regMsgList me, tBool 
  tList = [:]
  tList.setAt("CRYFORHELP", #handle_cryforhelp)
  tList.setAt("PICKED_CRY", #handle_picked_cry)
  if tBool then
    return(registerListener(getVariable("connection.info.id"), me.getID(), tList))
  else
    return(unregisterListener(getVariable("connection.info.id"), me.getID(), tList))
  end if
end
