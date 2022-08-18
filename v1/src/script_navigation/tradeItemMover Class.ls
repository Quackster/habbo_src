property pItemMember, pSpr, pSavedMem, pSavedLoc, pStripID

on new me, tItem, tStripID, tSpr, tBgColor 
  pItemType = tItem
  pItemMember = member(tItem & "_small")
  tFlag = 0
  if pItemMember.number < 0 then
    i = 1
    repeat while i <= the number of undefineds
      if tFlag then
      else
        tMemNum = getmemnum(string(castLib(i).name && "memberaliases"))
        if tMemNum > 0 then
          tList = member(tMemNum).text
          tSaveDelim = the itemDelimiter
          the itemDelimiter = "="
          y = 1
          repeat while y <= tList.count(#line)
            if (tList.getPropRef(#line, y).getProp(#item, 1) = string(tItem & "_small")) then
              put("L�ytyi:" && tList.getPropRef(#line, y).getProp(#item, 2))
              tItemMember = tList.getPropRef(#line, y).getProp(#item, 2)
            else
              y = (1 + y)
            end if
          end repeat
          the itemDelimiter = tSaveDelim
          if getmemnum(tItemMember) > 0 then
            put(member(tItemMember))
            pItemMember = member(tItemMember)
            tFlag = 1
          else
            i = (1 + i)
          end if
          if pItemMember.number < 0 then
            return()
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
          return(me)
        end if
      end if
    end repeat
  end if
end

on kill me 
  sprite(pSpr).member = pSavedMem
  sprite(pSpr).loc = pSavedLoc
  sprite(pSpr).locZ = pSpr
  pTimeOut = void()
  return(pStripID)
end

on exitFrame me 
  sprite(pSpr).loc = the mouseLoc
end

on timeOutHandling me 
end
