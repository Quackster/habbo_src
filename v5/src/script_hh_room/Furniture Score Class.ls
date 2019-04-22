property pScore

on prepare me, tdata 
  pScore = 0
  tTemp = tdata.getaProp("SCORE")
  me.setScore(tTemp)
  return(1)
end

on relocate me 
  me.setScore(pScore)
end

on updateStuffdata me, tProp, tValue 
  me.setScore(tValue)
end

on setScore me, tScore 
  if me.count(#pSprList) < 4 then
    return(0)
  end if
  if tScore = "x" then
    pScore = "x"
    me.getPropRef(#pSprList, 3).blend = 0
    me.getPropRef(#pSprList, 4).blend = 0
    return(1)
  end if
  pScore = integer(tScore)
  if pScore.ilk <> #integer then
    pScore = 0
  end if
  if pScore < 0 then
    pScore = 99
  end if
  if pScore > 99 then
    pScore = 0
  end if
  tString = string(pScore)
  if length(tString) = 1 then
    tString = "0" & tString
  end if
  me.getPropRef(#pSprList, 3).member = member(getmemnum("hockey_score_" & me.getProp(#pDirection, 1) & "_" & tString.getProp(#char, 1)))
  me.getPropRef(#pSprList, 4).member = member(getmemnum("hockey_score_" & me.getProp(#pDirection, 1) & "_" & tString.getProp(#char, 2)))
  if me.getProp(#pDirection, 1) = 2 then
    me.getPropRef(#pSprList, 3).loc = me.getPropRef(#pSprList, 1).loc + [26, -100]
    me.getPropRef(#pSprList, 4).loc = me.getPropRef(#pSprList, 1).loc + [36, -105]
  else
    me.getPropRef(#pSprList, 3).loc = me.getPropRef(#pSprList, 1).loc + [-44, -105]
    me.getPropRef(#pSprList, 4).loc = me.getPropRef(#pSprList, 1).loc + [-34, -100]
  end if
  me.getPropRef(#pSprList, 3).width = member.width
  me.getPropRef(#pSprList, 3).height = member.height
  me.getPropRef(#pSprList, 4).width = member.width
  me.getPropRef(#pSprList, 4).height = member.height
  me.getPropRef(#pSprList, 3).blend = 100
  me.getPropRef(#pSprList, 4).blend = 100
  return(1)
end

on select me 
  tUpdate = 0
  tScore = pScore
  tloc = point(the mouseH - me.getPropRef(#pSprList, 1).left, the mouseV - me.getPropRef(#pSprList, 1).top)
  if pScore <> "x" then
    if inside(tloc, rect(14, 108, 22, 116)) then
      tUpdate = 1
      tScore = tScore - 1
      if tScore < 0 then
        tScore = 99
      end if
    else
      if inside(tloc, rect(26, 108, 34, 116)) then
        tUpdate = 1
        tScore = tScore + 1
        if tScore > 99 then
          tScore = 0
        end if
      end if
    end if
  end if
  if tUpdate = 0 and the doubleClick then
    tUpdate = 1
    if pScore = "x" then
      tScore = 0
    else
      tScore = "x"
    end if
  end if
  if tUpdate then
    getThread(#room).getComponent().getRoomConnection().send(#room, "SETSTUFFDATA /" & me.getID() & "/" & "SCORE" & "/" & tScore)
  end if
  return(1)
end
