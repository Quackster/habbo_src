property pScene, pObjectMoverSprite, pThisSystem, pGeometry

on construct me 
  pGeometry = getThread(#room).getInterface().getGeometry()
  pThisSystem = getUniqueID()
  pScene = void()
  pObjectMoverSprite = void()
  return(1)
end

on deconstruct me 
  me.releaseScene(pScene)
end

on define me, tdata 
  callAncestor(#define, [me], tdata)
  tFieldName = me.pClass & ".planetsystem.props"
  tConfField = getMember(tFieldName)
  if ilk(tConfField) <> #member then
    return(error(me, "Unable to find planet system configuration", #define, #major))
  end if
  tArcRandom = random(360)
  tObjectCount = readValueFromField(tFieldName, "\r", "object.count")
  i = 1
  repeat while i <= tObjectCount
    tProps = [:]
    tProps.setAt(#name, readValueFromField(tFieldName, "\r", "object." & i & ".name"))
    tProps.setAt(#parent, readValueFromField(tFieldName, "\r", "object." & i & ".parent"))
    tProps.setAt(#radius, readValueFromField(tFieldName, "\r", "object." & i & ".radius"))
    tProps.setAt(#arcspeed, readValueFromField(tFieldName, "\r", "object." & i & ".arcspeed"))
    tProps.setAt(#arcoffset, readValueFromField(tFieldName, "\r", "object." & i & ".arcoffset") + tArcRandom)
    tProps.setAt(#sprites, readValueFromField(tFieldName, "\r", "object." & i & ".sprites"))
    tProps.setAt(#frameList, readValueFromField(tFieldName, "\r", "object." & i & ".framelist"))
    tProps.setAt(#ink, readValueFromField(tFieldName, "\r", "object." & i & ".ink"))
    tProps.setAt(#blend, readValueFromField(tFieldName, "\r", "object." & i & ".blend"))
    tProps.setAt(#zshift, readValueFromField(tFieldName, "\r", "object." & i & ".zshift"))
    tProps.setAt(#height, readValueFromField(tFieldName, "\r", "object." & i & ".height"))
    me.addPlanet(tProps.getAt(#name), tProps.getAt(#parent), tProps)
    i = 1 + i
  end repeat
  if not voidp(pObjectMoverSprite) then
    releaseSprite(pObjectMoverSprite.spriteNum)
    pObjectMoverSprite = void()
  end if
  return(1)
end

on addPlanet me, tName, tParentName, tProps 
  if not tParentName = 0 then
    tParent = me.getPlanetByName(tParentName, pScene)
    if voidp(tParent) then
      return(error(me, "Unable to find parent planet!", #addPlanet, #major))
    end if
  else
    if not objectExists(tName & pThisSystem) then
      tObject = createObject(tName & pThisSystem, ["Planet System Object Class"])
      if not objectp(tObject) then
        return(error(me, "Unable to create planet system object!", #addPlanet, #major))
      end if
      tObject.setProps(tProps)
      pScene = tObject
      tTargetID = getThread(#room).getInterface().getID()
      tSpr = tObject.getSprite()
      setEventBroker(tSpr.spriteNum, me.getID())
      tSpr.registerProcedure(#eventProcActiveObj, tTargetID, #mouseDown)
      tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseEnter)
      tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseLeave)
      return()
    end if
  end if
  if not objectExists(tName & pThisSystem) then
    tObject = createObject(tName & pThisSystem, ["Planet System Object Class"])
    if not objectp(tObject) then
      return(error(me, "Unable to create planet system object!", #addPlanet, #major))
    end if
    tObject.setProps(tProps)
    tParent.addChild(tObject)
    tTargetID = getThread(#room).getInterface().getID()
    tSpr = tObject.getSprite()
    setEventBroker(tSpr.spriteNum, me.getID())
    tSpr.registerProcedure(#eventProcActiveObj, tTargetID, #mouseDown)
    tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseEnter)
    tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseLeave)
  end if
end

on getPlanetByName me, tName, tTarget 
  if tTarget.getID() = tName & pThisSystem then
    return(tTarget)
  else
    repeat while tTarget.getChildren() <= tTarget
      tItem = getAt(tTarget, tName)
      tOut = me.getPlanetByName(tName, tItem)
      if not voidp(tOut) then
        return(tOut)
      end if
    end repeat
  end if
end

on releaseScene me, tTarget 
  tSpr = tTarget.getSprite()
  removeEventBroker(tSpr.spriteNum)
  tChildren = tTarget.getChildren().duplicate()
  repeat while tChildren <= undefined
    tItem = getAt(undefined, tTarget)
    me.releaseScene(tItem)
  end repeat
  removeObject(tTarget.getID())
end

on updateScene me, tTarget 
  tTarget.updateObject()
  repeat while tTarget.getChildren() <= undefined
    tItem = getAt(undefined, tTarget)
    me.updateScene(tItem)
  end repeat
end

on getScenePos me, tRootPos, tTarget, tPosTable 
  tItemID = tTarget.getID()
  tItemPos = tTarget.getWorldPosition()
  tNewPos = [tRootPos.getAt(1) + tItemPos.getAt(1), tRootPos.getAt(2) + tItemPos.getAt(2), tRootPos.getAt(3) + tItemPos.getAt(3)]
  tPosTable.setaProp(tItemID, tNewPos)
  repeat while tTarget.getChildren() <= tTarget
    tItem = getAt(tTarget, tRootPos)
    me.getScenePos(tNewPos, tItem, tPosTable)
  end repeat
end

on getProjectedPosition me, tloc 
  tXOffset = pGeometry.pXOffset
  tYOffset = pGeometry.pYOffset
  tZOffset = pGeometry.pZOffset
  tloc = pGeometry.getScreenCoordinate(tloc.getAt(1), tloc.getAt(2), tloc.getAt(3))
  return([tloc.getAt(1) - tXOffset, tloc.getAt(2) - tYOffset, tloc.getAt(3) - tZOffset])
end

on updateSprites me, tRootPos, tTarget, tPosTable 
  tTarget.updateSprite()
  tsprite = tTarget.getSprite()
  if not voidp(tsprite) then
    tProj = me.getProjectedPosition(tPosTable.getAt(tTarget.getID()))
    tloc = [tProj.getAt(1) + tRootPos.getAt(1), tProj.getAt(2) + tRootPos.getAt(2), tProj.getAt(3) + tRootPos.getAt(3)]
    tsprite.loc = point(integer(tloc.getAt(1)), integer(tloc.getAt(2)))
    tsprite.locZ = integer(tloc.getAt(3)) + tTarget.getZShift()
  end if
  repeat while tTarget.getChildren() <= tTarget
    tItem = getAt(tTarget, tRootPos)
    me.updateSprites(tRootPos, tItem, tPosTable)
  end repeat
end

on render me 
  tPosTable = [:]
  tPosTable.sort()
  me.getScenePos([0, 0, 0], pScene, tPosTable)
  tRootPos = pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  tRootPos.setAt(1, tRootPos.getAt(1) + pGeometry.pXFactor / 2)
  me.updateSprites(tRootPos, pScene, tPosTable)
end

on update me 
  me.updateScene(pScene)
  me.render()
end

on getSprites me 
  if voidp(pObjectMoverSprite) then
    pObjectMoverSprite = sprite(reserveSprite(me.getID()))
    pObjectMoverSprite.member = getMember("planet_of_love_small")
    pObjectMoverSprite.ink = 36
  end if
  return([pObjectMoverSprite])
end
