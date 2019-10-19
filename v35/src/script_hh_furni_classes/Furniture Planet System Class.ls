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
  if not variableExists(me.pClass & ".planetsystem.props.confdumped") then
    me.dumpVariableField(me.pClass & ".planetsystem.props", void(), void(), me.pClass & ".")
    setVariable(me.pClass & ".planetsystem.props.confdumped", 1)
  end if
  tObjectCount = getIntVariable(me.pClass & "." & "object.count")
  i = 1
  repeat while i <= tObjectCount
    tProps = [:]
    tProps.setAt(#name, getStringVariable(me.pClass & "." & "object." & i & ".name"))
    if variableExists(me.pClass & "." & "object." & i & ".parent") then
      tProps.setAt(#parent, getStringVariable(me.pClass & "." & "object." & i & ".parent"))
    else
      tProps.setAt(#parent, "")
    end if
    if variableExists(me.pClass & "." & "object." & i & ".radius") then
      tProps.setAt(#radius, float(getStringVariable(me.pClass & "." & "object." & i & ".radius")))
    else
      tProps.setAt(#radius, "")
    end if
    if variableExists(me.pClass & "." & "object." & i & ".arcspeed") then
      tProps.setAt(#arcspeed, float(getStringVariable(me.pClass & "." & "object." & i & ".arcspeed")))
    else
      tProps.setAt(#arcspeed, "")
    end if
    if variableExists(me.pClass & "." & "object." & i & ".arcoffset") then
      tProps.setAt(#arcoffset, float(getStringVariable(me.pClass & "." & "object." & i & ".arcoffset")))
    else
      tProps.setAt(#arcoffset, "")
    end if
    if variableExists(me.pClass & "." & "object." & i & ".sprites") then
      tProps.setAt(#sprites, getStructVariable(me.pClass & "." & "object." & i & ".sprites"))
    else
      tProps.setAt(#sprites, [:])
    end if
    if variableExists(me.pClass & "." & "object." & i & ".framelist") then
      tProps.setAt(#frameList, getStructVariable(me.pClass & "." & "object." & i & ".framelist"))
    else
      tProps.setAt(#frameList, [])
    end if
    if variableExists(me.pClass & "." & "object." & i & ".ink") then
      tProps.setAt(#ink, integer(getStringVariable(me.pClass & "." & "object." & i & ".ink")))
    else
      tProps.setAt(#ink, 36)
    end if
    if variableExists(me.pClass & "." & "object." & i & ".blend") then
      tProps.setAt(#blend, integer(getStringVariable(me.pClass & "." & "object." & i & ".blend")))
    else
      tProps.setAt(#blend, 0)
    end if
    if variableExists(me.pClass & "." & "object." & i & ".zshift") then
      tProps.setAt(#zshift, integer(getStringVariable(me.pClass & "." & "object." & i & ".zshift")))
    else
      tProps.setAt(#zshift, 0)
    end if
    if variableExists(me.pClass & "." & "object." & i & ".height") then
      tProps.setAt(#height, float(getStringVariable(me.pClass & "." & "object." & i & ".height")))
    else
      tProps.setAt(#height, "")
    end if
    if tProps.getAt(#radius) = "" then
      tProps.setAt(#radius, 0)
    end if
    if tProps.getAt(#arcspeed) = "" then
      tProps.setAt(#arcspeed, 0)
    end if
    if tProps.getAt(#arcoffset) = "" then
      tProps.setAt(#arcoffset, 0)
    end if
    if tProps.getAt(#height) = "" then
      tProps.setAt(#height, 0)
    end if
    tProps.setAt(#arcoffset, tProps.getAt(#arcoffset) + tArcRandom)
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
  if not tParentName = "" then
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
  tRootPos.setAt(1, tRootPos.getAt(1) + (pGeometry.pXFactor / 2))
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

on dumpVariableField me, tField, tDelimiter, tOverride, tPrefix 
  tStr = field(0)
  tDelim = the itemDelimiter
  if voidp(tDelimiter) then
    tDelimiter = "\r"
  end if
  the itemDelimiter = tDelimiter
  if voidp(tOverride) then
    tOverride = 1
  end if
  i = 1
  repeat while i <= tStr.count(#item)
    tPair = tStr.getProp(#item, i)
    if tPair.getPropRef(#word, 1).getProp(#char, 1) <> "#" and tPair <> "" then
      the itemDelimiter = "="
      tProp = tPair.getPropRef(#item, 1).getProp(#word, 1, tPair.getPropRef(#item, 1).count(#word))
      tValue = tPair.getProp(#item, 2, tPair.count(#item))
      tValue = tValue.getProp(#word, 1, tValue.count(#word))
      if not voidp(tPrefix) then
        tProp = tPrefix & tProp
      end if
      if not tValue contains space() then
        if tValue.getProp(#char, 1) = "#" then
          tValue = symbol(chars(tValue, 2, length(tValue)))
        end if
      end if
      if stringp(tValue) then
        j = 1
        repeat while j <= length(tValue)
          j = 1 + j
        end repeat
      end if
      tExists = variableExists(tProp)
      if tOverride or not tExists then
        setVariable(tProp, tValue)
      end if
      the itemDelimiter = tDelimiter
    end if
    i = 1 + i
  end repeat
  the itemDelimiter = tDelim
  return(1)
end
