on prepare(me)
  pUpOrDown = #up
  me.delay(random(1000) + 800, #bump)
  return(1)
  exit
end

on bump(me)
  if me.count(#pSprList) > 0 then
    if pUpOrDown = #up then
      pUpOrDown = #down
      tOff = point(0, 1)
    else
      pUpOrDown = #up
      tOff = point(0, -1)
    end if
    me.getPropRef(#pSprList, 1).loc = me.getPropRef(#pSprList, 1).loc + tOff
    me.delay(random(1000) + 800, #bump)
  end if
  exit
end