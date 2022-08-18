property spriteNum, pThumbNameList
global gChosenRoomName

on beginSprite me
  if voidp(pThumbNameList) then
    pThumbNameList = [:]
    tSaveDelim = the itemDelimiter
    the itemDelimiter = "="
    repeat with i = 1 to member("Thumbs for rooms list").text.line.count
      tLine = member("Thumbs for rooms list").text.line[i]
      if ((tLine = EMPTY) or (tLine = " ")) then
        nothing()
        next repeat
      end if
      if (tLine.char[1] = "--") then
        nothing()
        next repeat
      end if
      pThumbNameList[tLine.item[1].word[1]] = tLine.item[2].word[1]
    end repeat
    the itemDelimiter = tSaveDelim
  end if
  setRoomThumb(me)
end

on setRoomThumb me
  if voidp(pThumbNameList) then
    beginSprite(me)
  end if
  if not voidp(pThumbNameList[gChosenRoomName]) then
    tMem = getmemnum(pThumbNameList[gChosenRoomName])
    if (tMem > 1) then
      sprite(spriteNum).member = member(tMem)
    end if
    updateStage()
  else
    put ((((("Missing roomname in member" && QUOTE) & "Thumbs for rooms list") & QUOTE) & ":") && gChosenRoomName)
  end if
end
