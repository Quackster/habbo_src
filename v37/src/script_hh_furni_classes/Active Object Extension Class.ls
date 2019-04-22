property pNameBase, pLayerDataList, pStateSequenceList, pStateStringList, pInkList, pBlendList, pIsAnimatingList, pLoopCountList, pFrameNumberList, pFrameNumberList2, pFrameSequenceNumberList, pFrameRepeatList, pInitialized, pState

on deconstruct me 
  pStateSequenceList = []
  pStateIndex = 1
  pState = 1
  pLayerDataList = [:]
  pStateStringList = []
  pFrameSequenceNumberList = []
  pFrameNumberList = []
  pFrameNumberList2 = []
  pLoopCountList = []
  pPaletteFramesLayers = []
  pBlendList = []
  pInkList = []
  pLoczList = []
  pLocShiftList = []
  pFrameRepeatList = []
  pIsAnimatingList = []
  pInitialized = 0
  callAncestor(#deconstruct, [me])
end

on define me, tProps 
  pStateSequenceList = []
  pStateIndex = 1
  pState = 1
  pLayerDataList = [:]
  pStateStringList = []
  pFrameSequenceNumberList = []
  pFrameNumberList = []
  pFrameNumberList2 = []
  pLoopCountList = []
  pPaletteFramesLayers = []
  pBlendList = []
  pInkList = []
  pLoczList = []
  pLocShiftList = []
  pFrameRepeatList = []
  pIsAnimatingList = []
  tClass = tProps.getAt(#class)
  tOffset = offset("*", tClass)
  if tOffset > 0 then
    tClass = tClass.getProp(#char, 1, tOffset - 1)
  end if
  pNameBase = tClass
  if getThread(#room).getInterface().getGeometry().pXFactor = 32 then
    pNameBase = "s_" & pNameBase
  end if
  tDataName = pNameBase & ".data"
  if memberExists(tDataName) then
    tText = member(getmemnum(tDataName)).text
    tText = replaceChunks(tText, "\r", "")
    tdata = value(tText)
    if not voidp(tdata) then
      if tdata.ilk = #propList then
        pStateSequenceList = tdata.getAt(#states)
        pLayerDataList = tdata.getAt(#layers)
        if voidp(pLayerDataList) then
          pLayerDataList = [:]
        end if
        i = pLayerDataList.count
        repeat while i >= 1
          tFullId = string(pLayerDataList.getPropAt(i))
          tCount = tFullId.length
          if tCount > 1 then
            tValue = pLayerDataList.getAt(i)
            pLayerDataList.deleteAt(i)
            j = 1
            repeat while j <= tCount
              tID = symbol(tFullId.getProp(#char, j))
              pLayerDataList.setaProp(tID, tValue)
              j = 1 + j
            end repeat
          end if
          i = 255 + i
        end repeat
        pLayerDataList.sort()
        tLayerDataList = [:]
        i = 1
        repeat while i <= pLayerDataList.count
          tProp = string(pLayerDataList.getPropAt(i))
          if charToNum(tProp) < charToNum("a") then
            tProp = numToChar(charToNum("a") + charToNum(tProp) - charToNum("A"))
          end if
          tLayerData = pLayerDataList.getAt(i)
          tLayerDataList.addProp(tProp, tLayerData)
          i = 1 + i
        end repeat
        pLayerDataList = tLayerDataList
        if voidp(pStateSequenceList) then
          pStateSequenceList = []
        end if
        if voidp(pStateStringList) then
          pStateStringList = []
        end if
        if not me.validateStateSequenceList() then
          pStateSequenceList = []
        end if
      end if
    else
      outputList(tText)
    end if
  end if
  me.resetFrameNumbers()
  tCount = 1
  if pLayerDataList.count > 0 then
    tCount = pLayerDataList.count
  end if
  tLayer = 1
  repeat while tLayer <= tCount
    tLayerName = ""
    if pLayerDataList.count >= tLayer then
      tLayerName = pLayerDataList.getPropAt(tLayer)
    end if
    pInkList.setAt(tLayer, me.solveInk(tLayerName, pNameBase))
    pBlendList.setAt(tLayer, me.solveBlend(tLayerName, pNameBase))
    tLayer = 1 + tLayer
  end repeat
  pInitialized = 0
  return(callAncestor(#define, [me], tProps))
end

on prepare me, tdata 
  tstate = tdata.getAt(#stuffdata)
  if pStateStringList.findPos(tstate) > 0 then
    tstate = pStateStringList.findPos(tstate)
  end if
  me.setState(tstate)
  me.resetFrameNumbers()
  callAncestor(#prepare, [me], tdata)
  return(1)
end

on select me 
  if the doubleClick then
    me.getNextState()
  else
    return(0)
  end if
  callAncestor(#select, [me])
  return(1)
end

on update me 
  if pIsAnimatingList.findPos(1) = 0 then
    return(1)
  end if
  tIsAnimatingList = []
  tLayer = 1
  repeat while tLayer <= pLayerDataList.count
    tFrameList = me.getFrameList(pLayerDataList.getPropAt(tLayer))
    tIsAnimatingList.setAt(tLayer, pIsAnimatingList.getAt(tLayer))
    tValidConfs = 1
    if pLoopCountList.count < tLayer then
      tValidConfs = 0
    end if
    if pFrameNumberList.count < tLayer then
      tValidConfs = 0
    end if
    if pFrameNumberList2.count < tLayer then
      tValidConfs = 0
    end if
    if pFrameSequenceNumberList.count < tLayer then
      tValidConfs = 0
    end if
    if pFrameRepeatList.count < tLayer then
      tValidConfs = 0
    end if
    if not voidp(tFrameList) and tIsAnimatingList.getAt(tLayer) and tValidConfs then
      if not voidp(tFrameList.getAt(#frames)) or not voidp(tFrameList.getAt(#sequences)) then
        tDelay = tFrameList.getAt(#delay)
        if voidp(tDelay) or voidp(integer(tDelay)) or tDelay < 1 then
          tDelay = 1
        end if
        if pFrameRepeatList.getAt(tLayer) >= tDelay then
          tLoop = 1
          tFrameCount = 0
          tSequenceCount = 0
          if tFrameList.findPos(#frames) > 0 then
            tFrameCount = tFrameList.getAt(#frames).count
          else
            tSequences = tFrameList.getaProp(#sequences)
            if listp(tSequences) then
              if tSequences.count >= pFrameSequenceNumberList.getAt(tLayer) then
                tFrameCount = tSequences.getAt(pFrameSequenceNumberList.getAt(tLayer)).count
                tSequenceCount = tSequences.count
              end if
            end if
          end if
          if tFrameCount > 0 then
            if pFrameNumberList.getAt(tLayer) = tFrameCount then
              if pLoopCountList.getAt(tLayer) > 0 then
                pLoopCountList.setAt(tLayer, pLoopCountList.getAt(tLayer) - 1)
              end if
              tLoop = pLoopCountList.getAt(tLayer)
              if pLoopCountList.getAt(tLayer) = 0 then
                tIsAnimatingList.setAt(tLayer, 0)
              end if
            end if
            if pFrameNumberList.getAt(tLayer) < tFrameCount or tLoop then
              if tSequenceCount > 0 and pFrameNumberList.getAt(tLayer) = tFrameCount then
                pFrameSequenceNumberList.setAt(tLayer, random(tSequenceCount))
                pFrameNumberList.setAt(tLayer, 1)
              else
                pFrameNumberList.setAt(tLayer, pFrameNumberList.getAt(tLayer) mod tFrameCount + 1)
              end if
              tRandom = 0
              if not voidp(tFrameList.getAt(#random)) then
                tRandom = 1
              end if
              if tRandom and tFrameCount > 1 then
                tValue = random(tFrameCount)
                if tValue = pFrameNumberList2.getAt(tLayer) then
                  tValue = pFrameNumberList2.getAt(tLayer) mod tFrameCount + 1
                end if
                pFrameNumberList2.setAt(tLayer, tValue)
              else
                pFrameNumberList2.setAt(tLayer, pFrameNumberList.getAt(tLayer))
              end if
              if not voidp(tFrameList.getAt(#blend)) then
                tBlendList = tFrameList.getAt(#blend)
                if tBlendList.count >= pFrameNumberList2.getAt(tLayer) then
                  me.getPropRef(#pSprList, tLayer).blend = tBlendList.getAt(pFrameNumberList2.getAt(tLayer))
                end if
              end if
            end if
          end if
          pFrameRepeatList.setAt(tLayer, 1)
        else
          pFrameRepeatList.setAt(tLayer, pFrameRepeatList.getAt(tLayer) + 1)
        end if
      end if
    end if
    tLayer = 1 + tLayer
  end repeat
  me.solveMembers()
  tLayer = 1
  repeat while tLayer <= pLayerDataList.count
    pIsAnimatingList.setAt(tLayer, tIsAnimatingList.getAt(tLayer))
    tLayer = 1 + tLayer
  end repeat
  return(1)
end

on solveMembers me 
  if not pInitialized then
    callAncestor(#solveMembers, [me])
  end if
  tMembersFound = 0
  tCount = me.count(#pLocShiftList)
  if pLayerDataList.count > 0 then
    tCount = pLayerDataList.count
  end if
  tLayer = 1
  repeat while tLayer <= tCount
    tAnimating = 1
    if pIsAnimatingList.count >= tLayer then
      tAnimating = pIsAnimatingList.getAt(tLayer)
    end if
    if tAnimating then
      tLayerName = numToChar(charToNum("a") + tLayer - 1)
      if pLayerDataList.count >= tLayer then
        tLayerName = pLayerDataList.getPropAt(tLayer)
      end if
      tMemName = me.getMemberName(tLayerName)
      if me.count(#pSprList) < tLayer then
        tSpr = sprite(reserveSprite(me.getID()))
        tTargetID = getThread(#room).getInterface().getID()
        tLayerName = pLayerDataList.getPropAt(tLayer)
        if me.solveTransparency(tLayerName) = 0 then
          setEventBroker(tSpr.spriteNum, me.getID())
          tSpr.registerProcedure(#eventProcItemObj, tTargetID, #mouseDown)
          tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseEnter)
          tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseLeave)
        end if
        pSprList.add(tSpr)
      else
        tSpr = pSprList.getAt(tLayer)
        if not pInitialized then
          if me.solveTransparency(tLayerName) then
            removeEventBroker(tSpr.spriteNum)
          end if
        end if
      end if
      tMemNum = getmemnum(tMemName)
      if tMemNum <> 0 then
        tMembersFound = tMembersFound + 1
        tOldRect = tSpr.rect
        if tMemNum < 1 then
          tMemNum = abs(tMemNum)
          tSpr.rotation = 180
          tSpr.skew = 180
        else
          tSpr.rotation = 0
          tSpr.skew = 0
        end if
        if tOldRect <> tSpr.rect then
          tUpdateLocation = 1
        end if
        tSpr.castNum = tMemNum
        tSpr.width = member(tMemNum).width
        tSpr.height = member(tMemNum).height
      else
        tSpr.width = 0
        tSpr.height = 0
        tSpr.castNum = 0
      end if
      if not pInitialized then
        if pInkList.count < tLayer then
          pInkList.setAt(tLayer, me.solveInk(tLayerName, pNameBase))
        end if
        if pBlendList.count < tLayer then
          pBlendList.setAt(tLayer, me.solveBlend(tLayerName, pNameBase))
        end if
        tSpr.ink = pInkList.getAt(tLayer)
        tSpr.blend = pBlendList.getAt(tLayer)
      end if
      me.postProcessLayer(tLayer)
      if pInitialized then
        me.animatePaletteForLayer(tLayer, tSpr)
      end if
      if tUpdateLocation then
        me.updateLocation()
      end if
    else
      if me.count(#pSprList) >= tLayer then
        tSpr = pSprList.getAt(tLayer)
        if tSpr.castNum <> 0 then
          tMembersFound = tMembersFound + 1
        end if
      end if
    end if
    tLayer = 1 + tLayer
  end repeat
  pInitialized = 1
  if tMembersFound = 0 then
    return(0)
  else
    return(1)
  end if
end

on postProcessLayer me, tLayer 
  return(1)
end

on animatePaletteForLayer me, tLayerIndex, tSpr 
  if pLayerDataList.count = 0 then
    return(1)
  end if
  tFrameList = me.getFrameList(tLayerIndex)
  if not tFrameList.findPos(#paletteFrames) > 0 then
    return(1)
  end if
  tFrames = tFrameList.getaProp(#paletteFrames)
  tPalettes = tFrameList.getaProp(#paletteIndex)
  tFrame = 0
  if not voidp(tFrameList) and not voidp(tLayerIndex) then
    if tFrameList.findPos(#frames) > 0 then
      tFrameSequence = tFrameList.getAt(#frames)
    else
      tSequences = tFrameList.getaProp(#sequences)
      if listp(tSequences) then
        if tSequences.count >= pFrameSequenceNumberList.getAt(tLayerIndex) then
          tFrameSequence = tSequences.getAt(pFrameSequenceNumberList.getAt(tLayerIndex))
        end if
      end if
    end if
    if not voidp(tFrameSequence) then
      tFrameNumber = pFrameNumberList2.getAt(tLayerIndex)
      tFrame = tFrameSequence.getAt(tFrameNumber)
      if tFrame < 0 then
        tFrame = random(abs(tFrame))
      end if
    end if
  end if
  if tFrameNumber > tPalettes.count then
    return(0)
  end if
  if tFrameNumber < 1 then
    return(0)
  end if
  tPalette = tPalettes.getAt(tFrameNumber)
  tMemNum = getmemnum(tPalette)
  if tMemNum = 0 then
    return(0)
  end if
  member.paletteRef = member(tMemNum)
  return(1)
end

on getMemberName me, tLayer 
  tName = pNameBase
  tLayerIndex = pLayerDataList.findPos(tLayer)
  tFrameList = me.getFrameList(tLayer)
  tDirection = 0
  if not voidp(me.pDirection) then
    if me.count(#pDirection) >= 1 then
      tDirection = me.getProp(#pDirection, 1)
    end if
  end if
  tFrame = 0
  if not voidp(tFrameList) and not voidp(tLayerIndex) then
    if tFrameList.findPos(#frames) > 0 then
      tFrameSequence = tFrameList.getAt(#frames)
    else
      tSequences = tFrameList.getaProp(#sequences)
      if listp(tSequences) then
        if tSequences.count >= pFrameSequenceNumberList.getAt(tLayerIndex) then
          tFrameSequence = tSequences.getAt(pFrameSequenceNumberList.getAt(tLayerIndex))
        end if
      end if
    end if
    if not voidp(tFrameSequence) then
      tFrameNumber = pFrameNumberList2.getAt(tLayerIndex)
      tFrame = tFrameSequence.getAt(tFrameNumber)
      if tFrame < 0 then
        tFrame = random(abs(tFrame))
      end if
    end if
  end if
  tName = tName & "_" & tLayer & "_0_" & me.getProp(#pDimensions, 1) & "_" & me.getProp(#pDimensions, 2) & "_" & tDirection & "_" & tFrame
  return(tName)
end

on getFrameList me, tLayer 
  if not voidp(tLayer) then
    if not voidp(pLayerDataList.getAt(tLayer)) then
      tLayerData = pLayerDataList.getAt(tLayer)
      tAction = pState
      if tAction > tLayerData.count then
        tAction = 1
      end if
      if tAction >= 1 and tAction <= tLayerData.count then
        tActionData = tLayerData.getAt(tAction)
        return(tActionData)
      end if
    end if
  end if
  return(void())
end

on updateStuffdata me, tValue 
  if ilk(tValue) = #string then
    if pStateStringList.findPos(tValue) > 0 then
      tValue = pStateStringList.findPos(tValue)
    end if
  end if
  tstate = integer(tValue)
  if not integerp(tstate) then
    tstate = tValue
  end if
  me.setState(tValue)
end

on setState me, tNewState 
  tLayer = 1
  repeat while tLayer <= pLayerDataList.count
    pLoopCountList.setAt(tLayer, 0)
    tLayer = 1 + tLayer
  end repeat
  if tNewState = "" then
    tNewState = 0
  end if
  if ilk(integer(tNewState)) <> #integer then
    return(0)
  end if
  tNewState = integer(tNewState)
  tNewState = tNewState + 1
  tNewIndex = 0
  tIndex = 1
  repeat while tIndex <= pStateSequenceList.count
    tstate = pStateSequenceList.getAt(tIndex)
    if ilk(tstate) = #list then
      tIndex2 = 1
      repeat while tIndex2 <= tstate.count
        if tstate.getAt(tIndex2) = tNewState then
          tNewIndex = tIndex
        else
          tIndex2 = 1 + tIndex2
        end if
      end repeat
      exit repeat
    end if
    if tstate = tNewState then
      tNewIndex = tIndex
    end if
    if tNewIndex <> 0 then
    else
      tIndex = 1 + tIndex
    end if
  end repeat
  if tNewIndex = 0 then
    if pStateSequenceList.count > 0 then
      tstate = pStateSequenceList.getAt(1)
      if ilk(tstate) = #list then
        if tstate.count > 0 then
          tNewState = tstate.getAt(1)
          tNewIndex = 1
        end if
      else
        tNewState = tstate
        tNewIndex = 1
      end if
    end if
  end if
  if tNewIndex <> 0 then
    pStateIndex = tNewIndex
    pState = tNewState
    me.resetFrameNumbers()
    tLayer = 1
    repeat while tLayer <= pLayerDataList.count
      tFrameList = me.getFrameList(pLayerDataList.getPropAt(tLayer))
      if not voidp(tFrameList) then
        tLoop = 1
        if not voidp(tFrameList.getAt(#loop)) then
          tLoop = tFrameList.getAt(#loop) - 1
        end if
        pLoopCountList.setAt(tLayer, tLoop)
      end if
      tLayer = 1 + tLayer
    end repeat
    me.solveMembers()
    me.updateLocation()
    return(1)
  end if
  return(0)
end

on getNextState me 
  return(getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0]))
end

on validateStateSequenceList me 
  tstatelist = []
  tIndex = 1
  repeat while tIndex <= pStateSequenceList.count
    tstate = pStateSequenceList.getAt(tIndex)
    if ilk(tstate) = #list then
      if tstate.count < 1 then
        return(error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList, #major))
      end if
      tIndex2 = 1
      repeat while tIndex2 <= tstate.count
        tState2 = tstate.getAt(tIndex2)
        if tState2 < 1 then
          return(error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList, #major))
        end if
        if tstatelist.count < tState2 then
          tstatelist.setAt(tState2, 1)
        else
          if tstatelist.getAt(tState2) > 0 then
            return(error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList, #major))
          end if
        end if
        tIndex2 = 1 + tIndex2
      end repeat
      exit repeat
    end if
    if tstate < 1 then
      return(error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList, #major))
    end if
    if tstatelist.count < tstate then
      tstatelist.setAt(tstate, 1)
    else
      if tstatelist.getAt(tstate) > 0 then
        return(error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList, #major))
      else
        tstatelist.setAt(tstate, 1)
      end if
    end if
    tIndex = 1 + tIndex
  end repeat
  return(1)
end

on resetFrameNumbers me 
  pFrameRepeatList = []
  pIsAnimatingList = []
  pFrameNumberList = []
  pFrameNumberList2 = []
  pFrameSequenceNumberList = []
  i = 1
  repeat while i <= max(me.count(#pLocShiftList), pLayerDataList.count)
    pFrameSequenceNumberList.setAt(i, 1)
    pFrameNumberList.setAt(i, 1)
    pFrameNumberList2.setAt(i, 1)
    pFrameRepeatList.setAt(i, 1)
    pIsAnimatingList.setAt(i, 1)
    i = 1 + i
  end repeat
end

on solveTransparency me, tPart 
  tName = pNameBase
  if memberExists(tName & ".props") then
    tPropList = value(member(getmemnum(tName & ".props")).text)
    if ilk(tPropList) <> #propList then
      error(me, tName & ".props is not valid!", #solveInk, #minor)
    else
      if tPropList.getAt(tPart) <> void() then
        if tPropList.getAt(tPart).getAt(#transparent) <> void() then
          return(tPropList.getAt(tPart).getAt(#transparent))
        end if
      end if
    end if
  end if
  return(0)
end
