property pRadius, pArcSpeed, pArcOffset, pFrameList, pAnimation, pInk, pBlend, pheight, pZshift, pChildren, pPosition, pAnimOffset, pGeometry, pLocalSprite

on construct me
  pGeometry = getThread(#room).getInterface().getGeometry()
  pLocalSprite = VOID
  pChildren = []
  pPosition = 0.0
  pAnimOffset = 1
  pFrameList = []
  pAnimation = []
  pLocalSprite = sprite(reserveSprite(me.getID()))
  return 1
end

on deconstruct me
  if ilk(pLocalSprite) = #sprite then
    releaseSprite(pLocalSprite.spriteNum)
  end if
  return 1
end

on getWorldPosition me
  return [pRadius * cos(pPosition + pArcOffset), pRadius * sin(pPosition + pArcOffset), pheight]
end

on updateObject me
  pPosition = pPosition + float(pArcSpeed / float(getIntVariable("system.tempo", 30)))
end

on addChild me, tObject
  pChildren.add(tObject)
end

on getChildren me
  return pChildren
end

on updateSprite me
  pAnimOffset = pAnimOffset + 1
  if pAnimOffset > pFrameList.count then
    pAnimOffset = 1
  end if
  pLocalSprite.member = pAnimation[pFrameList[pAnimOffset]]
  pLocalSprite.ink = pInk
  pLocalSprite.visible = 1
  pLocalSprite.width = pLocalSprite.member.width
  pLocalSprite.height = pLocalSprite.member.height
  if pBlend <> 100 then
    pLocalSprite.blend = pBlend
  end if
end

on getSprite me
  return pLocalSprite
end

on getZShift me
  return pZshift
end

on setProps me, tProps
  pRadius = float(tProps[#radius])
  pArcSpeed = float(tProps[#arcspeed] * PI * 2.0 / 360.0)
  pArcOffset = float(tProps[#arcoffset] * PI * 2.0 / 360.0)
  pFrameList = value(tProps[#frameList])
  pInk = integer(tProps[#ink])
  pBlend = 100 - integer(tProps[#blend])
  pZshift = integer(tProps[#zshift])
  pheight = integer(tProps[#height])
  tAnimation = value(tProps[#sprites])
  repeat with tMemberName in tAnimation
    if pGeometry.pXFactor < 64 then
      tMemberName = "s_" & tMemberName
    end if
    pAnimation.add(getMember(tMemberName))
  end repeat
end
