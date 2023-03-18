property pGeometry, pScene, pThisSystem, pObjectMoverSprite

on construct me
  pGeometry = getThread(#room).getInterface().getGeometry()
  pThisSystem = getUniqueID()
  pScene = VOID
  pObjectMoverSprite = VOID
  return 1
end

on deconstruct me
  me.releaseScene(pScene)
end

on define me, tdata
  callAncestor(#define, [me], tdata)
  tFieldName = me.pClass & ".planetsystem.props"
  tConfField = getMember(tFieldName)
  if ilk(tConfField) <> #member then
    return error(me, "Unable to find planet system configuration", #define, #major)
  end if
  tArcRandom = random(360)
  tObjectCount = readValueFromField(tFieldName, RETURN, "object.count")
  repeat with i = 1 to tObjectCount
    tProps = [:]
    tProps[#name] = readValueFromField(tFieldName, RETURN, "object." & i & ".name")
    tProps[#parent] = readValueFromField(tFieldName, RETURN, "object." & i & ".parent")
    tProps[#radius] = readValueFromField(tFieldName, RETURN, "object." & i & ".radius")
    tProps[#arcspeed] = readValueFromField(tFieldName, RETURN, "object." & i & ".arcspeed")
    tProps[#arcoffset] = readValueFromField(tFieldName, RETURN, "object." & i & ".arcoffset") + tArcRandom
    tProps[#sprites] = readValueFromField(tFieldName, RETURN, "object." & i & ".sprites")
    tProps[#frameList] = readValueFromField(tFieldName, RETURN, "object." & i & ".framelist")
    tProps[#ink] = readValueFromField(tFieldName, RETURN, "object." & i & ".ink")
    tProps[#blend] = readValueFromField(tFieldName, RETURN, "object." & i & ".blend")
    tProps[#zshift] = readValueFromField(tFieldName, RETURN, "object." & i & ".zshift")
    tProps[#height] = readValueFromField(tFieldName, RETURN, "object." & i & ".height")
    me.addPlanet(tProps[#name], tProps[#parent], tProps)
  end repeat
  if not voidp(pObjectMoverSprite) then
    releaseSprite(pObjectMoverSprite.spriteNum)
    pObjectMoverSprite = VOID
  end if
  return 1
end

on addPlanet me, tName, tParentName, tProps
  if not (tParentName = 0) then
    tParent = me.getPlanetByName(tParentName, pScene)
    if voidp(tParent) then
      return error(me, "Unable to find parent planet!", #addPlanet, #major)
    end if
  else
    if not objectExists(tName & pThisSystem) then
      tObject = createObject(tName & pThisSystem, ["Planet System Object Class"])
      if not objectp(tObject) then
        return error(me, "Unable to create planet system object!", #addPlanet, #major)
      end if
      tObject.setProps(tProps)
      pScene = tObject
      tTargetID = getThread(#room).getInterface().getID()
      tSpr = tObject.getSprite()
      setEventBroker(tSpr.spriteNum, me.getID())
      tSpr.registerProcedure(#eventProcActiveObj, tTargetID, #mouseDown)
      tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseEnter)
      tSpr.registerProcedure(#eventProcActiveRollOver, tTargetID, #mouseLeave)
      return 
    end if
  end if
  if not objectExists(tName & pThisSystem) then
    tObject = createObject(tName & pThisSystem, ["Planet System Object Class"])
    if not objectp(tObject) then
      return error(me, "Unable to create planet system object!", #addPlanet, #major)
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
  if tTarget.getID() = (tName & pThisSystem) then
    return tTarget
  else
    repeat with tItem in tTarget.getChildren()
      tOut = me.getPlanetByName(tName, tItem)
      if not voidp(tOut) then
        return tOut
      end if
    end repeat
  end if
end

on releaseScene me, tTarget
  tSpr = tTarget.getSprite()
  removeEventBroker(tSpr.spriteNum)
  tChildren = tTarget.getChildren().duplicate()
  repeat with tItem in tChildren
    me.releaseScene(tItem)
  end repeat
  removeObject(tTarget.getID())
end

on updateScene me, tTarget
  tTarget.updateObject()
  repeat with tItem in tTarget.getChildren()
    me.updateScene(tItem)
  end repeat
end

on getScenePos me, tRootPos, tTarget, tPosTable
  tItemID = tTarget.getID()
  tItemPos = tTarget.getWorldPosition()
  tNewPos = [tRootPos[1] + tItemPos[1], tRootPos[2] + tItemPos[2], tRootPos[3] + tItemPos[3]]
  tPosTable.setaProp(tItemID, tNewPos)
  repeat with tItem in tTarget.getChildren()
    me.getScenePos(tNewPos, tItem, tPosTable)
  end repeat
end

on getProjectedPosition me, tloc
  tXOffset = pGeometry.pXOffset
  tYOffset = pGeometry.pYOffset
  tZOffset = pGeometry.pZOffset
  tloc = pGeometry.getScreenCoordinate(tloc[1], tloc[2], tloc[3])
  return [tloc[1] - tXOffset, tloc[2] - tYOffset, tloc[3] - tZOffset]
end

on updateSprites me, tRootPos, tTarget, tPosTable
  tTarget.updateSprite()
  tsprite = tTarget.getSprite()
  if not voidp(tsprite) then
    tProj = me.getProjectedPosition(tPosTable[tTarget.getID()])
    tloc = [tProj[1] + tRootPos[1], tProj[2] + tRootPos[2], tProj[3] + tRootPos[3]]
    tsprite.loc = point(integer(tloc[1]), integer(tloc[2]))
    tsprite.locZ = integer(tloc[3]) + tTarget.getZShift()
  end if
  repeat with tItem in tTarget.getChildren()
    me.updateSprites(tRootPos, tItem, tPosTable)
  end repeat
end

on render me
  tPosTable = [:]
  tPosTable.sort()
  me.getScenePos([0.0, 0.0, 0.0], pScene, tPosTable)
  tRootPos = pGeometry.getScreenCoordinate(me.pLocX, me.pLocY, me.pLocH)
  tRootPos[1] = tRootPos[1] + (pGeometry.pXFactor / 2)
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
  return [pObjectMoverSprite]
end
