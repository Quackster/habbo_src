property pLocalSprite, pRadius, pPosition, pArcOffset, pheight, pArcSpeed, pChildren, pAnimOffset, pFrameList, pAnimation, pInk, pBlend, pZshift, pGeometry

on construct me 
  pGeometry = getThread(#room).getInterface().getGeometry()
  pLocalSprite = void()
  pChildren = []
  pPosition = 0
  pAnimOffset = 1
  pFrameList = []
  pAnimation = []
  pLocalSprite = sprite(reserveSprite(me.getID()))
  return TRUE
end

on deconstruct me 
  if (ilk(pLocalSprite) = #sprite) then
    releaseSprite(pLocalSprite.spriteNum)
  end if
  return TRUE
end

on getWorldPosition me 
  return([(pRadius * cos((pPosition + pArcOffset))), (pRadius * sin((pPosition + pArcOffset))), pheight])
end

on updateObject me 
  pPosition = (pPosition + float((pArcSpeed / float(getIntVariable("system.tempo", 30)))))
end

on addChild me, tObject 
  pChildren.add(tObject)
end

on getChildren me 
  return(pChildren)
end

on updateSprite me 
  pAnimOffset = (pAnimOffset + 1)
  if pAnimOffset > pFrameList.count then
    pAnimOffset = 1
  end if
  pLocalSprite.member = pAnimation.getAt(pFrameList.getAt(pAnimOffset))
  pLocalSprite.ink = pInk
  pLocalSprite.visible = 1
  pLocalSprite.width = pLocalSprite.member.width
  pLocalSprite.height = pLocalSprite.member.height
  if pBlend <> 100 then
    pLocalSprite.blend = pBlend
  end if
end

on getSprite me 
  return(pLocalSprite)
end

on getZShift me 
  return(pZshift)
end

on setProps me, tProps 
  pRadius = float(tProps.getAt(#radius))
  pArcSpeed = float((((tProps.getAt(#arcspeed) * pi()) * 2) / 360))
  pArcOffset = float((((tProps.getAt(#arcoffset) * pi()) * 2) / 360))
  pFrameList = value(tProps.getAt(#frameList))
  pInk = integer(tProps.getAt(#ink))
  pBlend = (100 - integer(tProps.getAt(#blend)))
  pZshift = integer(tProps.getAt(#zshift))
  pheight = integer(tProps.getAt(#height))
  tAnimation = value(tProps.getAt(#sprites))
  repeat while tAnimation <= undefined
    tMemberName = getAt(undefined, tProps)
    if pGeometry.pXFactor < 64 then
      tMemberName = "s_" & tMemberName
    end if
    pAnimation.add(getMember(tMemberName))
  end repeat
end
