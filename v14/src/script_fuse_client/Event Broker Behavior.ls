property pProcList, id, pSprite, pLink

on registerProcedure me, tMethod, tClientID, tEvent 
  if voidp(pProcList) then
    pProcList = me.createProcListTemplate()
  end if
  if voidp(tEvent) and voidp(tMethod) then
    i = 1
    repeat while i <= pProcList.count
      pProcList.setAt(i, [pProcList.getPropAt(i), tClientID])
      i = (1 + i)
    end repeat
    exit repeat
  end if
  if voidp(tEvent) then
    i = 1
    repeat while i <= pProcList.count
      pProcList.setAt(i, [tMethod, tClientID])
      i = (1 + i)
    end repeat
    exit repeat
  end if
  if voidp(tMethod) then
    tMethod = tEvent
  end if
  pProcList.setAt(tEvent, [tMethod, tClientID])
  return TRUE
end

on removeProcedure me, tEvent 
  if voidp(tEvent) then
    pProcList = me.createProcListTemplate()
  else
    if pProcList.getaProp(tEvent) <> void() then
      pProcList.setAt(tEvent, [#null, 0])
    end if
  end if
  return TRUE
end

on getID me 
  return(id)
end

on setID me, tid 
  pSprite = sprite(me.spriteNum)
  if not stringp(tid) then
    return(error(me, "String expected:" && tid, #setID, #major))
  end if
  id = tid
  return TRUE
end

on getMember me 
  return(pSprite.member)
end

on setMember me, tmember 
  pSprite.member = tmember
  pSprite.width = pSprite.member.width
  pSprite.height = pSprite.member.height
  return TRUE
end

on getCursor me 
  return(pSprite.cursor)
end

on setcursor me, ttype 
  if symbolp(ttype) then
    if (ttype = #arrow) then
      ttype = -1
    else
      if (ttype = #ibeam) then
        ttype = 1
      else
        if (ttype = #crosshair) then
          ttype = 2
        else
          if (ttype = #crossbar) then
            ttype = 3
          else
            if (ttype = #timer) then
              ttype = 4
            end if
          end if
        end if
      end if
    end if
  else
    if stringp(ttype) then
      ttype = [getmemnum(ttype), getmemnum(ttype & ".mask")]
    else
      if listp(ttype) then
        ttype = [getmemnum(ttype.getAt(1)), getmemnum(ttype.getAt(2))]
      else
        if voidp(ttype) then
          ttype = 0
        end if
      end if
    end if
  end if
  pSprite.cursor = ttype
  return TRUE
end

on getLink me 
  if stringp(pLink) then
    return(pLink)
  else
    return FALSE
  end if
end

on setLink me, tUrlOrKey 
  if stringp(tUrlOrKey) then
    pLink = tUrlOrKey
    return TRUE
  else
    return FALSE
  end if
end

on mouseEnter me 
  return(me.redirectEvent(#mouseEnter))
end

on mouseLeave me 
  return(me.redirectEvent(#mouseLeave))
end

on mouseWithin me 
  return(me.redirectEvent(#mouseWithin))
end

on mouseDown me 
  if not voidp(pProcList) then
    getObject(#session).set("client_lastclick", id && "->" && pProcList.getAt(#mouseDown).getAt(2) && "/" && the long time)
  end if
  tResult = me.redirectEvent(#mouseDown)
  if tResult then
    stopEvent()
  end if
  return(tResult)
end

on mouseUp me 
  if not voidp(pLink) then
    getSpecialServices().openNetPage(pLink)
  end if
  tResult = me.redirectEvent(#mouseUp)
  if tResult then
    stopEvent()
  end if
  return(tResult)
end

on mouseUpOutSide me 
  return(me.redirectEvent(#mouseUpOutSide))
end

on keyDown me 
  if me.pSprite.spriteNum <> the keyboardFocusSprite then
    return TRUE
  end if
  if me.redirectEvent(#keyDown) then
    return TRUE
  end if
  pass()
end

on keyUp me 
  if me.pSprite.spriteNum <> the keyboardFocusSprite then
    return TRUE
  end if
  if me.redirectEvent(#keyUp) then
    return TRUE
  end if
  pass()
end

on redirectEvent me, tEvent 
  if voidp(pProcList) then
    pProcList = me.createProcListTemplate()
  end if
  if not pProcList.getAt(tEvent).getAt(2) then
    return FALSE
  end if
  if not objectExists(pProcList.getAt(tEvent).getAt(2)) then
    return FALSE
  end if
  return(call(pProcList.getAt(tEvent).getAt(1), getObject(pProcList.getAt(tEvent).getAt(2)), tEvent, id))
end

on createProcListTemplate me 
  tList = [:]
  tList.setAt(#mouseEnter, [#null, 0])
  tList.setAt(#mouseLeave, [#null, 0])
  tList.setAt(#mouseWithin, [#null, 0])
  tList.setAt(#mouseDown, [#null, 0])
  tList.setAt(#mouseUp, [#null, 0])
  tList.setAt(#mouseUpOutSide, [#null, 0])
  tList.setAt(#keyDown, [#null, 0])
  tList.setAt(#keyUp, [#null, 0])
  return(tList)
end
