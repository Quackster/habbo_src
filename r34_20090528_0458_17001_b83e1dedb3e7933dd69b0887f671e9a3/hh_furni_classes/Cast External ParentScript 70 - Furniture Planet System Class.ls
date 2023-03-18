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
  if not variableExists(me.pClass & ".planetsystem.props.confdumped") then
    me.dumpVariableField(me.pClass & ".planetsystem.props", VOID, VOID, me.pClass & ".")
    setVariable(me.pClass & ".planetsystem.props.confdumped", 1)
  end if
  tObjectCount = getIntVariable(me.pClass & "." & "object.count")
  repeat with i = 1 to tObjectCount
    tProps = [:]
    tProps[#name] = getStringVariable(me.pClass & "." & "object." & i & ".name")
    if variableExists(me.pClass & "." & "object." & i & ".parent") then
      tProps[#parent] = getStringVariable(me.pClass & "." & "object." & i & ".parent")
    else
      tProps[#parent] = EMPTY
    end if
    if variableExists(me.pClass & "." & "object." & i & ".radius") then
      tProps[#radius] = float(getStringVariable(me.pClass & "." & "object." & i & ".radius"))
    else
      tProps[#radius] = EMPTY
    end if
    if variableExists(me.pClass & "." & "object." & i & ".arcspeed") then
      tProps[#arcspeed] = float(getStringVariable(me.pClass & "." & "object." & i & ".arcspeed"))
    else
      tProps[#arcspeed] = EMPTY
    end if
    if variableExists(me.pClass & "." & "object." & i & ".arcoffset") then
      tProps[#arcoffset] = float(getStringVariable(me.pClass & "." & "object." & i & ".arcoffset"))
    else
      tProps[#arcoffset] = EMPTY
    end if
    if variableExists(me.pClass & "." & "object." & i & ".sprites") then
      tProps[#sprites] = getStructVariable(me.pClass & "." & "object." & i & ".sprites")
    else
      tProps[#sprites] = [:]
    end if
    if variableExists(me.pClass & "." & "object." & i & ".framelist") then
      tProps[#frameList] = getStructVariable(me.pClass & "." & "object." & i & ".framelist")
    else
      tProps[#frameList] = []
    end if
    if variableExists(me.pClass & "." & "object." & i & ".ink") then
      tProps[#ink] = integer(getStringVariable(me.pClass & "." & "object." & i & ".ink"))
    else
      tProps[#ink] = 36
    end if
    if variableExists(me.pClass & "." & "object." & i & ".blend") then
      tProps[#blend] = integer(getStringVariable(me.pClass & "." & "object." & i & ".blend"))
    else
      tProps[#blend] = 0
    end if
    if variableExists(me.pClass & "." & "object." & i & ".zshift") then
      tProps[#zshift] = integer(getStringVariable(me.pClass & "." & "object." & i & ".zshift"))
    else
      tProps[#zshift] = 0
    end if
    if variableExists(me.pClass & "." & "object." & i & ".height") then
      tProps[#height] = float(getStringVariable(me.pClass & "." & "object." & i & ".height"))
    else
      tProps[#height] = EMPTY
    end if
    if tProps[#radius] = EMPTY then
      tProps[#radius] = 0.0
    end if
    if tProps[#arcspeed] = EMPTY then
      tProps[#arcspeed] = 0.0
    end if
    if tProps[#arcoffset] = EMPTY then
      tProps[#arcoffset] = 0.0
    end if
    if tProps[#height] = EMPTY then
      tProps[#height] = 0.0
    end if
    tProps[#arcoffset] = tProps[#arcoffset] + tArcRandom
    me.addPlanet(tProps[#name], tProps[#parent], tProps)
  end repeat
  if not voidp(pObjectMoverSprite) then
    releaseSprite(pObjectMoverSprite.spriteNum)
    pObjectMoverSprite = VOID
  end if
  return 1
end

on addPlanet me, tName, tParentName, tProps
  if not (tParentName = EMPTY) then
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

on dumpVariableField me, tField, tDelimiter, tOverride, tPrefix
  tStr = field(tField)
  tDelim = the itemDelimiter
  if voidp(tDelimiter) then
    tDelimiter = RETURN
  end if
  the itemDelimiter = tDelimiter
  if voidp(tOverride) then
    tOverride = 1
  end if
  repeat with i = 1 to tStr.item.count
    tPair = tStr.item[i]
    if (tPair.word[1].char[1] <> "#") and (tPair <> EMPTY) then
      the itemDelimiter = "="
      tProp = tPair.item[1].word[1..tPair.item[1].word.count]
      tValue = tPair.item[2..tPair.item.count]
      tValue = tValue.word[1..tValue.word.count]
      if not voidp(tPrefix) then
        tProp = tPrefix & tProp
      end if
      if not (tValue contains SPACE) then
        if tValue.char[1] = "#" then
          tValue = symbol(chars(tValue, 2, length(tValue)))
        end if
      end if
      if stringp(tValue) then
        repeat with j = 1 to length(tValue)
          case charToNum(tValue.char[j]) of
          end case
        end repeat
      end if
      tExists = variableExists(tProp)
      if tOverride or not tExists then
        setVariable(tProp, tValue)
      end if
      the itemDelimiter = tDelimiter
    end if
  end repeat
  the itemDelimiter = tDelim
  return 1
end
