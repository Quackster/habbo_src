property chatType, isEnabled

on beginSprite me 
end

on enable me 
  isEnabled = 1
end

on disable me 
  isEnabled = 0
end

on exitFrame me 
  if (chatType = "WHISPER") then
    if (isEnabled = 1) and voidp(gChosenUser) then
      sendSprite(me.spriteNum, #disable)
    else
      if (isEnabled = 0) and stringp(gChosenUser) and length(member("texttypefield").text) > 0 then
        sendSprite(me.spriteNum, #enable)
      end if
    end if
  else
    if (isEnabled = 1) and (member("texttypefield").text = "") then
      sendSprite(me.spriteNum, #disable)
      return()
    else
      if chatType <> "WHISPER" and (isEnabled = 0) and length(member("texttypefield").text) > 0 then
        sendSprite(me.spriteNum, #enable)
      end if
    end if
  end if
end

on mouseDown me 
  if (isEnabled = 1) then
    if chatType <> "WHISPER" then
      sendFuseMsg(chatType && member("texttypefield").text)
    else
      sendFuseMsg(chatType && gChosenUser && member("texttypefield").text)
    end if
    member("texttypefield").text = ""
  end if
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #chatType, [#format:#string, #default:"CHAT", #comment:"Help text when enabled", #range:["CHAT", "SHOUT", "WHISPER"]])
  return(pList)
end
