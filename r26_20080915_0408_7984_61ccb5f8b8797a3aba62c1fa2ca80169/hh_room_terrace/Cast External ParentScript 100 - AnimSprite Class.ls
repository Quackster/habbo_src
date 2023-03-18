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
  tVisual = getThread(#room).getInterface().getRoomVisualizer()
  if not tVisual then
    return 0
  end if
  tVisual.getSprById(pID).visible = tVisible
  pAnimFrame = pStartAnim
end

on updateSplashs me
  if pVisible <> 1 then
    return 0
  end if
  if pAnimFrame < pMaxFrames then
    tVisual = getThread(#room).getInterface().getRoomVisualizer()
    if not tVisual then
      return 0
    end if
    tmember = member(getmemnum(pMember & pAnimFrame))
    tVisual.getSprById(pID).setMember(tmember)
    pAnimFrame = pAnimFrame + 1
  else
    me.setVisible(0)
  end if
end
