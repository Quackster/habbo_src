on handle_userobject me, tuser
  tSession = getObject(#session)
  repeat with i = 1 to tuser.count
    tSession.set("user_" & tuser.getPropAt(i), tuser[i])
  end repeat
  tSession.set(#userName, tSession.get("user_name"))
  tSession.set("user_password", tSession.get(#password))
  executeMessage(#updateFigureData)
  if me.getComponent().getState() = "connection" then
    me.getComponent().updateState("loginOk")
    return 1
  end if
  if me.getComponent().getState() = "connectionOk" then
    me.getComponent().updateState("loginOk")
  end if
end

on handle_memberinfo me, tMsg
  case tMsg.subject of
    "NAMERESERVED":
      if threadExists(#registration) then
        getThread(#registration).getInterface().userNameAlreadyReserved(tMsg.content)
      end if
    "MEMBERINFO":
      if threadExists(#messenger) then
        getThread(#messenger).getComponent().receive_UserFound(tMsg.content)
      end if
  end case
end

on handle_advertisement me, tProps
  if tProps[#url] = EMPTY then
    return 0
  end if
  tMemNum = queueDownload(tProps[#url], "advertisement", #bitmap, 1)
  tSession = getObject(#session)
  tSession.set("ad_id", tProps[#id])
  tSession.set("ad_url", tProps[#url])
  tSession.set("ad_text", tProps[#text])
  tSession.set("ad_type", tProps[#type])
  tSession.set("ad_memnum", tMemNum)
  if tProps[#link] = EMPTY then
    tSession.set("ad_link", 0)
  else
    tSession.set("ad_link", tProps[#link])
  end if
end

on handle_error me, tMsg
  error(me, "Error from server:" && tMsg.content, #handle_error)
  if tMsg.message contains "login incorrect" then
    if connectionExists(tMsg.getaProp(#connection)) then
      removeConnection(tMsg.getaProp(#connection))
    end if
    if getObject(#session).exists("failed_password") then
      me.getInterface().getLogin().forgottenpw()
    else
      getObject(#session).set("failed_password", 1)
      me.getComponent().updateState("login")
      executeMessage(#alert, [#msg: "Alert_WrongNameOrPassword"])
    end if
  else
    if tMsg.message contains "inproper" then
      executeMessage(#alert, [#id: "BannWarning", #title: "Alert_YouAreBanned_T", #msg: "Alert_YouAreBanned"])
      removeConnection(getVariableValue("connection.info.id"))
      me.getInterface().getLogin().hideLogin()
    else
      if tMsg.message contains "MODERATOR WARNING" then
        tDelim = the itemDelimiter
        the itemDelimiter = "/"
        tTextStr = tMsg.message.item[2..tMsg.message.item.count]
        the itemDelimiter = tDelim
        executeMessage(#alert, [#title: "alert_warning", #msg: tTextStr])
      else
        if tMsg.message contains "Cannot enter" then
        else
          if tMsg.message contains "user already" then
          else
            if tMsg.message contains "incorrect flat password" then
            else
              if tMsg.message contains "password required" then
              else
                if tMsg.message contains "login in" then
                else
                  if tMsg.message contains "Version not correct" then
                    executeMessage(#alert, [#msg: "Old client version!!!"])
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return 1
end
