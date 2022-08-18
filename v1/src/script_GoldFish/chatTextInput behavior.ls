property ReturnCount, WaitTime, FirstReturnPressTime
global gChosenUser, textInputSpr

on beginSprite me
  the keyboardFocusSprite = me.spriteNum
  set the selStart to 0
  member(sprite(me.spriteNum).member).text = EMPTY
  member(sprite(me.spriteNum).member).font = "Volter (goldfish)"
  member(sprite(me.spriteNum).member).fontSize = 9
  ReturnCount = 1
  WaitTime = 0
  FirstReturnPressTime = the timer
  textInputSpr = me.spriteNum
end

on enterFrame me
  if ((WaitTime <> 0) and (WaitTime <= the timer)) then
    sprite(me.spriteNum).editable = 1
    member(sprite(me.spriteNum).member).text = EMPTY
    FirstReturnPressTime = the timer
    ReturnCount = 1
    WaitTime = 0
  end if
  if ((WaitTime <> 0) and (WaitTime > the timer)) then
    WaitText = AddTextToField("TypeTooFast")
    member(sprite(me.spriteNum).member).text = (WaitText && (((WaitTime - the timer) / 60) + 1))
  end if
end

on keyDown me
  global gChatMode, gBSSoundsOn, gUserSprites, gpObjects, gMyName
  if (ReturnCount > 4) then
    put "NELJ�S RETURN"
    ReturnCount = 1
    put (FirstReturnPressTime + 180), the timer
    if ((FirstReturnPressTime + 180) > the timer) then
      WaitTime = (the timer + 1200)
      sprite(me.spriteNum).editable = 0
    end if
    FirstReturnPressTime = the timer
  end if
  if ((WaitTime <> 0) and (WaitTime > the timer)) then
    exit
  end if
  if (the key = RETURN) then
    message = sprite(me.spriteNum).member.text
    if getaProp(gUserSprites, getaProp(gpObjects, gMyName)).isModerator then
      s = message
      if ((((s contains "alert x") or (s contains "ban x")) or (s contains "kick x")) or (s contains "superban x")) then
        if ((s contains member("item.info_name").text) = 0) then
          message = stringReplace(s, "x", member("item.info_name").text)
          sprite(me.spriteNum).member.text = message
          set the selStart to sprite(me.spriteNum).member.text.length
          set the selEnd to sprite(me.spriteNum).member.text.length
        end if
      end if
    end if
    if (message contains ":bot") then
      sendFuseMsg(("CTRL_SAY" && message.word[2]))
      return 
    end if
    ReturnCount = (ReturnCount + 1)
    if (message <> EMPTY) then
      if (gChatMode = 1) then
        chatType = "CHAT"
      else
        if (gChatMode = 2) then
          chatType = "SHOUT"
        else
          if (gChatMode = 3) then
            chatType = ("WHISPER" && gChosenUser)
          else
            chatType = "CHAT"
          end if
        end if
      end if
      if (message = "/sounds") then
        gBSSoundsOn = 1
        return 
      end if
      put (("%%" && chatType) && message)
      if not the shiftDown then
        sendFuseMsg((chatType && message))
      else
        sendFuseMsg(("SHOUT" && message))
      end if
      if (the movieName contains "private") then
        nothing()
      else
        if (gChatMode = 2) then
          gChatMode = 1
        end if
      end if
      sprite(me.spriteNum).member.text = EMPTY
    end if
  else
    pass()
  end if
end
