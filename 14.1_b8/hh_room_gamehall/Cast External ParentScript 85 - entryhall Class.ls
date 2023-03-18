property pAnimCounter, pAnimList, pCurrentFrame

on construct me
  pAnimCounter = 0
  pCurrentFrame = 1
  pAnimList = [2, 3, 4, 5, 6, 7]
  return 1
end

on deconstruct me
  return removeUpdate(me.getID())
end

on prepare me
  return receiveUpdate(me.getID())
end

on update me
  if pAnimCounter > 2 then
    tNextFrame = pAnimList[random(pAnimList.count)]
    pAnimList.deleteOne(tNextFrame)
    pAnimList.add(pCurrentFrame)
    pCurrentFrame = tNextFrame
    tmember = member(getmemnum("fountain_" & pCurrentFrame))
    tVisual = getThread(#room).getInterface().getRoomVisualizer()
    if not tVisual then
      return 0
    end if
    tVisual.getSprById("fountain").setMember(tmember)
    pAnimCounter = 0
  end if
  pAnimCounter = pAnimCounter + 1
end
