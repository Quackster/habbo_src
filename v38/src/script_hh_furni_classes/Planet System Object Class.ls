on construct(me)
  pGeometry = getThread(#room).getInterface().getGeometry()
  pLocalSprite = void()
  pChildren = []
  pPosition = 0
  pAnimOffset = 1
  pFrameList = []
  pAnimation = []
  pLocalSprite = sprite(reserveSprite(me.getID()))
  return(1)
  exit
end

on deconstruct(me)
  if ilk(pLocalSprite) = #sprite then
    releaseSprite(pLocalSprite.spriteNum)
  end if
  return(1)
  exit
end

on getWorldPosition(me)
  return([pRadius * cos(pPosition + pArcOffset), pRadius * sin(pPosition + pArcOffset), pheight])
  exit
end

on updateObject(me)
  pPosition = pPosition + float(pArcSpeed / float(getIntVariable("system.tempo", 30)))
  exit
end

on addChild(me, tObject)
  pChildren.add(tObject)
  exit
end

on getChildren(me)
  return(pChildren)
  exit
end

on updateSprite(me)
  pAnimOffset = pAnimOffset + 1
  if pAnimOffset > pFrameList.count then
    pAnimOffset = 1
  end if
  pLocalSprite.member = pAnimation.getAt(pFrameList.getAt(pAnimOffset))
  pLocalSprite.ink = pInk
  pLocalSprite.visible = 1
  pLocalSprite.width = member.width
  pLocalSprite.height = member.height
  if pBlend <> 100 then
    pLocalSprite.blend = pBlend
  end if
  exit
end

on getSprite(me)
  return(pLocalSprite)
  exit
end

on getZShift(me)
  return(pZshift)
  exit
end

on setProps(me, tProps)
  pRadius = float(tProps.getAt(#radius))
  pArcSpeed = float(tProps.getAt(#arcspeed) * pi() * 0 / 0)
  pArcOffset = float(tProps.getAt(#arcoffset) * pi() * 0 / 0)
  pFrameList = value(tProps.getAt(#frameList))
  pInk = integer(tProps.getAt(#ink))
  pBlend = 100 - integer(tProps.getAt(#blend))
  pZshift = integer(tProps.getAt(#zshift))
  pheight = integer(tProps.getAt(#height))
  tAnimation = value(tProps.getAt(#sprites))
  repeat while me <= undefined
    tMemberName = getAt(undefined, tProps)
    if pGeometry.pXFactor < 64 then
      tMemberName = "s_" & tMemberName
    end if
    pAnimation.add(getMember(tMemberName))
  end repeat
  exit
end