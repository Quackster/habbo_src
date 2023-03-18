property pTimeOut, pItemType, pItemMember, pSprite, pBgColor, pStripID, pSpr, pSavedMem, pSavedLoc

on new me, tItem, tStripID, tSpr, tBgColor
  pItemType = tItem
  pItemMember = member(tItem & "_small")
  tFlag = 0
  if pItemMember.number < 0 then
    repeat with i = 1 to the number of castLibs
      if tFlag then
        exit repeat
      end if
      tMemNum = getmemnum(string(castLib(i).name && "memberaliases"))
      if tMemNum > 0 then
        tList = member(tMemNum).text
        tSaveDelim = the itemDelimiter
        the itemDelimiter = "="
        repeat with y = 1 to tList.line.count
          if tList.line[y].item[1] = string(tItem & "_small") then
            put "Lšytyi:" && tList.line[y].item[2]
            tItemMember = tList.line[y].item[2]
            exit repeat
          end if
        end repeat
        the itemDelimiter = tSaveDelim
        if getmemnum(tItemMember) > 0 then
          put member(tItemMember)
          pItemMember = member(tItemMember)
          tFlag = 1
          exit repeat
        end if
      end if
    end repeat
  end if
  if pItemMember.number < 0 then
    return 
  end if
  pSprite = tSpr
  pStripID = tStripID
  pSpr = 886
  pSavedMem = sprite(pSpr).member
  pSavedLoc = sprite(pSpr).loc
  sprite(pSpr).member = pItemMember
  sprite(pSpr).loc = the mouseLoc
  sprite(pSpr).visible = 1
  sprite(pSpr).locZ = 2000000014
  sprite(pSpr).bgColor = tBgColor
  pTimeOut = timeout("tradeMover").new(60000, #timeOutHandling, me)
  return me
end

on kill me
  sprite(pSpr).member = pSavedMem
  sprite(pSpr).loc = pSavedLoc
  sprite(pSpr).locZ = pSpr
  pTimeOut = VOID
  return pStripID
end

on exitFrame me
  sprite(pSpr).loc = the mouseLoc
end

on timeOutHandling me
end
