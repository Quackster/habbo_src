property pMaxRipples, pRipples, pMemberImg, pLocFixPoint, pCounter

on construct me 
  pMaxRipples = 20
  pRippleSize = member(getmemnum("ripple_1")).rect
  pCounter = 1
  pRipples = []
  return(1)
end

on deconstruct me 
  removePrepare(me.getID())
  pRipples = []
  return(1)
end

on Init me, tID 
  if voidp(tID) then
    return(0)
  end if
  tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById(tID)
  pMemberImg = member.image
  f = 1
  repeat while f <= pMaxRipples
    pRipples.add(createObject(#temp, "Ripple Class"))
    pRipples.getAt(f).define([#id:f, #buffer:pMemberImg])
    f = 1 + f
  end repeat
  pMemberImg.fill(pMemberImg.rect, rgb(0, 153, 153))
  pLocFixPoint = point(tSpr.locH - (pMemberImg.width / 2), tSpr.locV - (pMemberImg.height / 2))
  receivePrepare(me.getID())
end

on NewRipple me, tRloc 
  if not voidp(pMemberImg) and not voidp(tRloc) then
    call(#getAvailableRipple, pRipples)
    tID = the result
    if not voidp(tID) then
      pRipples.getAt(tID).setTargetPoint(tRloc - pLocFixPoint)
    end if
  end if
end

on prepare me 
  if not voidp(pMemberImg) then
    pCounter = pCounter + 1
    if pCounter > 2 then
      pCounter = 0
    else
      if pCounter = 2 then
        call(#update, pRipples)
      end if
    end if
  end if
end
