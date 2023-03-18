on construct me
  return me.regMsgList(1)
end

on deconstruct me
  return me.regMsgList(0)
end

on handle_cryforhelp me, tMsg
  tProps = [:]
  tProps[#picker] = EMPTY
  tProps[#sender] = tMsg.message.line[2]
  tProps[#url] = tMsg.message.line[3]
  repeat with i = 4 to tMsg.message.line.count
    tLine = tMsg.message.line[i]
    ttype = tLine.char[1..offset(":", tLine) - 1]
    tValue = tLine.char[offset(":", tLine) + 1..length(tLine)]
    case ttype of
      "id":
        tProps[#id] = tValue
      "name":
        tProps[#name] = tValue
      "port":
        tProps[#port] = tValue
      "type":
        tProps[#type] = symbol(tValue)
      "text":
        tProps[#msg] = replaceChunks(tValue, "<br>", RETURN)
    end case
  end repeat
  if tProps[#sender] <> "[AUTOMATIC]" then
    me.getComponent().receive_cryforhelp(tProps)
  end if
end

on handle_picked_cry me, tMsg
  tPicker = tMsg.message.line[2]
  tLogUrl = tMsg.message.line[3]
  tProps = [#picker: tPicker, #url: tLogUrl]
  me.getComponent().receive_pickedCry(tProps)
end

on regMsgList me, tBool
  tList = [:]
  tList["CRYFORHELP"] = #handle_cryforhelp
  tList["PICKED_CRY"] = #handle_picked_cry
  if tBool then
    return registerListener(getVariable("connection.info.id"), me.getID(), tList)
  else
    return unregisterListener(getVariable("connection.info.id"), me.getID(), tList)
  end if
end
