property pID, pLoc, pVisible, pStartAnim, pAnimFrame, pMaxFrames, pMember

on construct me 
  pAnimFrame = 0
  return(1)
end

on setData me, tProps 
  pVisible = tProps.getAt(#visible)
  pMaxFrames = tProps.getAt(#AnimFrames)
  pAnimFrame = tProps.getAt(#startFrame)
  pStartAnim = tProps.getAt(#startFrame)
  pMember = tProps.getAt(#MemberName)
  pID = tProps.getAt(#id)
  if not voidp(tProps.getAt(#loc)) then
    pLoc = tProps.getAt(#loc)
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
    return(0)
  end if
  tVisObj.getSprById(pID).visible = tVisible
  pVisible = tVisible
  pAnimFrame = pStartAnim
end

on updateSplashs me 
  if pVisible <> 1 then
    return()
  end if
  if pAnimFrame < pMaxFrames then
    tVisObj = getThread(#room).getInterface().getRoomVisualizer()
    if tVisObj = 0 then
      return(0)
    end if
    tmember = member(getmemnum(pMember & pAnimFrame))
    tVisObj.getSprById(pID).setMember(tmember)
    pAnimFrame = pAnimFrame + 1
  else
    me.setVisible(0)
  end if
end
