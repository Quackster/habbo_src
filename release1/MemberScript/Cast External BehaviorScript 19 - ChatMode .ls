property chatmode, newChatMode, animFrame, cycle, defaultMode
global gChatMode

on beginSprite me
  chatmode = defaultMode
  newChatMode = defaultMode
end

on chatModeUp me
  if chatmode = 3 then
    changeMode(me, 1)
  else
    changeMode(me, chatmode + 1)
  end if
end

on chatModeDown me
  if chatmode <= 1 then
    changeMode(me, 3)
  else
    changeMode(me, chatmode - 1)
  end if
end

on changeMode me, newMode
  newChatMode = newMode
  animFrame = 0
end

on exitFrame me
  cycle = cycle + 1
  if (cycle mod 2) = 0 then
    return 
  end if
  gChatMode = chatmode
  if newChatMode <> chatmode then
    animFrame = animFrame + 1
    if animFrame > 3 then
      chatmode = newChatMode
      set the castNum of sprite the spriteNum of me to getmemnum("chatmode_" & chatmode)
    else
      if ((newChatMode > chatmode) and not ((newChatMode = 3) and (chatmode = 1))) or ((newChatMode = 1) and (chatmode = 3)) then
        set the castNum of sprite the spriteNum of me to getmemnum("chatmode_" & chatmode & "_" & animFrame)
      else
        set the castNum of sprite the spriteNum of me to getmemnum("chatmode_" & newChatMode & "_" & 4 - animFrame)
      end if
    end if
  end if
end

on getPropertyDescriptionList me
  return [#defaultMode: [#comment: "Defaultti", #format: #integer, #range: [1, 2, 3], #default: 0]]
end
