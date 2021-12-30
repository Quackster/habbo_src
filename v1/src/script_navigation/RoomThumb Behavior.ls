property pThumbNameList, spriteNum

on beginSprite me 
  if voidp(pThumbNameList) then
    pThumbNameList = [:]
    tSaveDelim = the itemDelimiter
    the itemDelimiter = "="
    i = 1
    repeat while i <= member("Thumbs for rooms list").text.count(#line)
      tLine = member("Thumbs for rooms list").text.getProp(#line, i)
      if (tLine = "") or (tLine = " ") then
        nothing()
      else
        if (tLine.getProp(#char, 1, 2) = "--") then
          nothing()
        else
          pThumbNameList.setAt(tLine.getPropRef(#item, 1).getProp(#word, 1, tLine.getPropRef(#item, 1).count(#word)), tLine.getPropRef(#item, 2).getProp(#word, 1, tLine.getPropRef(#item, 2).count(#word)))
        end if
      end if
      i = (1 + i)
    end repeat
    the itemDelimiter = tSaveDelim
  end if
  setRoomThumb(me)
end

on setRoomThumb me 
  if voidp(pThumbNameList) then
    beginSprite(me)
  end if
  if not voidp(pThumbNameList.getAt(gChosenRoomName)) then
    tMem = getmemnum(pThumbNameList.getAt(gChosenRoomName))
    if tMem > 1 then
      sprite(spriteNum).member = member(tMem)
    end if
    updateStage()
  else
    put("Missing roomname in member" && "\"" & "Thumbs for rooms list" & "\"" & ":" && gChosenRoomName)
  end if
end
