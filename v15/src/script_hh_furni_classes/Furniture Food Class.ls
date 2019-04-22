on prepare me, tdata 
  if tdata.count = 0 then
    tdata = [#extra:"0"]
  end if
  return(me.updateStuffdata(tdata.getAt(#extra)))
end

on updateStuffdata me, tValue 
  tCount = integer(tValue)
  if not ilk(tCount, #integer) then
    tCount = 0
  end if
  i = 1
  repeat while i <= me.count(#pSprList)
    tMemName = member.name
    me.getPropRef(#pSprList, i).member = member(getmemnum(tMemName & tCount))
    me.getPropRef(#pSprList, i).width = member.width
    me.getPropRef(#pSprList, i).height = member.height
    i = 1 + i
  end repeat
  return(1)
end
