property pID, pAnimFrame, pMaxFrames, pStartAnim, pMember, pVisible, pLoc

on construct me
  pAnimFrame = 0
  return 1
end

on setData me, tProps
  pVisible = tProps[#visible]
  pMaxFrames = tProps[#AnimFrames]
  pAnimFrame = tProps[#startFrame]
  pStartAnim = tProps[#startFrame]
  pMember = tProps[#MemberName]
  pID = tProps[#id]
  if not voidp(tProps[#loc]) then
    pLoc = tProps[#loc]
    getThread(#room).getInterface().getRoomVisualizer().getSprById(pID).loc = pLoc
  end if
  me.setVisible(pVisible)
end

on Activate me
  me.delay(250, #setVisible, 1)
end

on setVisible me, tVisible
  pVisible = tVisible
  tVisObj = getThread(#room).getInterface().getRoomVisualizer()
  if tVisObj = 0 then
    return 0
  end if
  tVisObj.getSprById(pID).visible = tVisible
  pVisible = tVisible
  pAnimFrame = pStartAnim
end

on updateSplashs me
  if pVisible <> 1 then
    return 
  end if
  if pAnimFrame < pMaxFrames then
    tVisObj = getThread(#room).getInterface().getRoomVisualizer()
    if tVisObj = 0 then
      return 0
    end if
    tmember = member(getmemnum(pMember & pAnimFrame))
    tVisObj.getSprById(pID).setMember(tmember)
    pAnimFrame = pAnimFrame + 1
  else
    me.setVisible(0)
  end if
end
