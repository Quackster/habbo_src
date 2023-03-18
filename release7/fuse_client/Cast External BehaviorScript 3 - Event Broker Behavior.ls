property id, pSprite, pLink, pProcList

on registerProcedure me, tMethod, tClientID, tEvent
  if voidp(pProcList) then
    pProcList = me.createProcListTemplate()
  end if
  if voidp(tEvent) and voidp(tMethod) then
    repeat with i = 1 to pProcList.count
      pProcList[i] = [pProcList.getPropAt(i), tClientID]
    end repeat
  else
    if voidp(tEvent) then
      repeat with i = 1 to pProcList.count
        pProcList[i] = [tMethod, tClientID]
      end repeat
    else
      if voidp(tMethod) then
        tMethod = tEvent
      end if
      pProcList[tEvent] = [tMethod, tClientID]
    end if
  end if
  return 1
end

on removeProcedure me, tEvent
  if voidp(tEvent) then
    pProcList = me.createProcListTemplate()
  else
    if pProcList.getaProp(tEvent) <> VOID then
      pProcList[tEvent] = [#null, 0]
    end if
  end if
  return 1
end

on getID me
  return id
end

on setID me, tid
  pSprite = sprite(me.spriteNum)
  if not stringp(tid) then
    return error(me, "String expected:" && tid, #setID)
  end if
  id = tid
  return 1
end

on getMember me
  return pSprite.member
end

on setMember me, tmember
  pSprite.member = tmember
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  return 1
end

on getCursor me
  return pSprite.cursor
end

on setcursor me, ttype
  if symbolp(ttype) then
    case ttype of
      #arrow:
        ttype = -1
      #ibeam:
        ttype = 1
      #crosshair:
        ttype = 2
      #crossbar:
        ttype = 3
      #timer:
        ttype = 4
    end case
  else
    if stringp(ttype) then
      ttype = [getmemnum(ttype), getmemnum(ttype & ".mask")]
    else
      if listp(ttype) then
        ttype = [getmemnum(ttype[1]), getmemnum(ttype[2])]
      else
        if voidp(ttype) then
          ttype = 0
        end if
      end if
    end if
  end if
  pSprite.cursor = ttype
  return 1
end

on getLink me
  if stringp(pLink) then
    return pLink
  else
    return 0
  end if
end

on setLink me, tUrlOrKey
  if stringp(tUrlOrKey) then
    pLink = tUrlOrKey
    return 1
  else
    return 0
  end if
end

on mouseEnter me
  return me.redirectEvent(#mouseEnter)
end

on mouseLeave me
  return me.redirectEvent(#mouseLeave)
end

on mouseWithin me
  return me.redirectEvent(#mouseWithin)
end

on mouseDown me
  if not voidp(pProcList) then
    getObject(#session).set("client_lastclick", id && "->" && pProcList[#mouseDown][2] && "/" && the long time)
  end if
  tResult = me.redirectEvent(#mouseDown)
  if tResult then
    stopEvent()
  end if
  return tResult
end

on mouseUp me
  if not voidp(pLink) then
    getSpecialServices().openNetPage(pLink)
  end if
  tResult = me.redirectEvent(#mouseUp)
  if tResult then
    stopEvent()
  end if
  return tResult
end

on mouseUpOutSide me
  return me.redirectEvent(#mouseUpOutSide)
end

on keyDown me
  if me.pSprite.spriteNum <> the keyboardFocusSprite then
    return 1
  end if
  if me.redirectEvent(#keyDown) then
    return 1
  end if
  pass()
end

on keyUp me
  if me.pSprite.spriteNum <> the keyboardFocusSprite then
    return 1
  end if
  if me.redirectEvent(#keyUp) then
    return 1
  end if
  pass()
end

on redirectEvent me, tEvent
  if voidp(pProcList) then
    pProcList = me.createProcListTemplate()
  end if
  if not pProcList[tEvent][2] then
    return 0
  end if
  if not objectExists(pProcList[tEvent][2]) then
    return 0
  end if
  return call(pProcList[tEvent][1], getObject(pProcList[tEvent][2]), tEvent, id)
end

on createProcListTemplate me
  tList = [:]
  tList[#mouseEnter] = [#null, 0]
  tList[#mouseLeave] = [#null, 0]
  tList[#mouseWithin] = [#null, 0]
  tList[#mouseDown] = [#null, 0]
  tList[#mouseUp] = [#null, 0]
  tList[#mouseUpOutSide] = [#null, 0]
  tList[#keyDown] = [#null, 0]
  tList[#keyUp] = [#null, 0]
  return tList
end
