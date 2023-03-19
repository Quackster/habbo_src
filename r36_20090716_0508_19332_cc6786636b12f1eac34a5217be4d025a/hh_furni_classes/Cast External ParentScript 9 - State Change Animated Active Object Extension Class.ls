property pStateSequenceList, pStateIndex, pState, pStateStringList, pPendingState, pLayerDataList, pFrameSequenceNumberList, pFrameNumberList, pFrameNumberList2, pLoopCountList, pFrameRepeatList, pPaletteFramesLayers, pBlendList, pInkList, pIsAnimatingList, pNameBase, pInitialized, pPseudoStates, pStateChangeActive

on deconstruct me
  pStateSequenceList = []
  pStateIndex = 1
  pState = 1
  pPendingState = 1
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
  pPseudoStates = [:]
  pStateChangeActive = 0
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
  pPseudoStates = [:]
  pStateChangeActive = 0
  tClass = tProps[#class]
  tOffset = offset("*", tClass)
  if tOffset > 0 then
    tClass = tClass.char[1..tOffset - 1]
  end if
  pNameBase = tClass
  if getThread(#room).getInterface().getGeometry().pXFactor = 32 then
    pNameBase = "s_" & pNameBase
  end if
  tDataName = pNameBase & ".data"
  if memberExists(tDataName) then
    tText = member(getmemnum(tDataName)).text
    tText = replaceChunks(tText, RETURN, EMPTY)
    tdata = value(tText)
    if not voidp(tdata) then
      if tdata.ilk = #propList then
        pStateSequenceList = tdata[#states]
        pLayerDataList = tdata[#layers]
        if voidp(pLayerDataList) then
          pLayerDataList = [:]
        end if
        repeat with i = pLayerDataList.count down to 1
          tFullId = string(pLayerDataList.getPropAt(i))
          tCount = tFullId.length
          if tCount > 1 then
            tValue = pLayerDataList[i]
            pLayerDataList.deleteAt(i)
            repeat with j = 1 to tCount
              tID = symbol(tFullId.char[j])
              pLayerDataList.setaProp(tID, tValue)
            end repeat
          end if
        end repeat
        pLayerDataList.sort()
        tLayerDataList = [:]
        repeat with i = 1 to pLayerDataList.count
          tProp = string(pLayerDataList.getPropAt(i))
          if charToNum(tProp) < charToNum("a") then
            tProp = numToChar(charToNum("a") + (charToNum(tProp) - charToNum("A")))
          end if
          tLayerData = pLayerDataList[i]
          tLayerDataList.addProp(tProp, tLayerData)
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
        if not voidp(tdata[#transitions]) and not voidp(tdata[#transitionlayers]) then
          tTransitionList = tdata[#transitions]
          tTransitionLayers = tdata[#transitionlayers]
          repeat with i = 1 to tTransitionList.count
            pPseudoStates.addProp(i, tTransitionList[i])
          end repeat
          repeat with i = 1 to tTransitionLayers.count
            tProp = string(tTransitionLayers.getPropAt(i))
            if charToNum(tProp) < charToNum("a") then
              tProp = numToChar(charToNum("a") + (charToNum(tProp) - charToNum("A")))
            end if
            repeat with j = 1 to tTransitionLayers[i].count
              pLayerDataList[tProp].add(tTransitionLayers[i][j])
            end repeat
          end repeat
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
  repeat with tLayer = 1 to tCount
    tLayerName = EMPTY
    if pLayerDataList.count >= tLayer then
      tLayerName = pLayerDataList.getPropAt(tLayer)
    end if
    pInkList[tLayer] = me.solveInk(tLayerName, pNameBase)
    pBlendList[tLayer] = me.solveBlend(tLayerName, pNameBase)
  end repeat
  pInitialized = 0
  return callAncestor(#define, [me], tProps)
end

on prepare me, tdata
  tstate = tdata[#stuffdata]
  if pStateStringList.findPos(tstate) > 0 then
    tstate = pStateStringList.findPos(tstate)
  end if
  me.setState(tstate)
  me.resetFrameNumbers()
  callAncestor(#prepare, [me], tdata)
  return 1
end

on select me
  if the doubleClick then
    me.getNextState()
  else
    return 0
  end if
  callAncestor(#select, [me])
  return 1
end

on update me
  if pIsAnimatingList.findPos(1) = 0 then
    return 1
  end if
  tIsAnimatingList = []
  repeat with tLayer = 1 to pLayerDataList.count
    tFrameList = me.getFrameList(pLayerDataList.getPropAt(tLayer))
    tIsAnimatingList[tLayer] = pIsAnimatingList[tLayer]
    if not voidp(tFrameList) and tIsAnimatingList[tLayer] then
      if not voidp(tFrameList[#frames]) or not voidp(tFrameList[#sequences]) then
        tDelay = tFrameList[#delay]
        if voidp(tDelay) or voidp(integer(tDelay)) or (tDelay < 1) then
          tDelay = 1
        end if
        if pFrameRepeatList[tLayer] >= tDelay then
          tLoop = 1
          tFrameCount = 0
          tSequenceCount = 0
          if tFrameList.findPos(#frames) > 0 then
            tFrameCount = tFrameList[#frames].count
          else
            tSequences = tFrameList.getaProp(#sequences)
            if listp(tSequences) then
              if tSequences.count >= pFrameSequenceNumberList[tLayer] then
                tFrameCount = tSequences[pFrameSequenceNumberList[tLayer]].count
                tSequenceCount = tSequences.count
              end if
            end if
          end if
          if tFrameCount > 0 then
            if pFrameNumberList[tLayer] = tFrameCount then
              if pLoopCountList[tLayer] > 0 then
                pLoopCountList[tLayer] = pLoopCountList[tLayer] - 1
              end if
              tLoop = pLoopCountList[tLayer]
              if pLoopCountList[tLayer] = 0 then
                tIsAnimatingList[tLayer] = 0
              end if
            end if
            if (pFrameNumberList[tLayer] < tFrameCount) or tLoop then
              if (tSequenceCount > 0) and (pFrameNumberList[tLayer] = tFrameCount) then
                pFrameSequenceNumberList[tLayer] = random(tSequenceCount)
                pFrameNumberList[tLayer] = 1
              else
                pFrameNumberList[tLayer] = (pFrameNumberList[tLayer] mod tFrameCount) + 1
              end if
              tRandom = 0
              if not voidp(tFrameList[#random]) then
                tRandom = 1
              end if
              if tRandom and (tFrameCount > 1) then
                tValue = random(tFrameCount)
                if tValue = pFrameNumberList2[tLayer] then
                  tValue = (pFrameNumberList2[tLayer] mod tFrameCount) + 1
                end if
                pFrameNumberList2[tLayer] = tValue
              else
                pFrameNumberList2[tLayer] = pFrameNumberList[tLayer]
              end if
              if not voidp(tFrameList[#blend]) then
                tBlendList = tFrameList[#blend]
                if tBlendList.count >= pFrameNumberList2[tLayer] then
                  me.pSprList[tLayer].blend = tBlendList[pFrameNumberList2[tLayer]]
                end if
              end if
            end if
          end if
          pFrameRepeatList[tLayer] = 1
          next repeat
        end if
        pFrameRepeatList[tLayer] = pFrameRepeatList[tLayer] + 1
      end if
    end if
  end repeat
  me.solveMembers()
  repeat with tLayer = 1 to pLayerDataList.count
    pIsAnimatingList[tLayer] = tIsAnimatingList[tLayer]
  end repeat
  tLoopsFinished = 1
  repeat with i = 1 to pIsAnimatingList.count
    if pIsAnimatingList[i] > 0 then
      tLoopsFinished = 0
    end if
  end repeat
  if pStateChangeActive and tLoopsFinished then
    pStateChangeActive = 0
    me.setState(pPendingState - 1)
  end if
  return 1
end

on solveMembers me
  if not pInitialized then
    callAncestor(#solveMembers, [me])
  end if
  tMembersFound = 0
  tCount = me.pLocShiftList.count
  if pLayerDataList.count > 0 then
    tCount = pLayerDataList.count
  end if
  repeat with tLayer = 1 to tCount
    tAnimating = 1
    if pIsAnimatingList.count >= tLayer then
      tAnimating = pIsAnimatingList[tLayer]
    end if
    if tAnimating then
      tLayerName = numToChar(charToNum("a") + tLayer - 1)
      if pLayerDataList.count >= tLayer then
        tLayerName = pLayerDataList.getPropAt(tLayer)
      end if
      tMemName = me.getMemberName(tLayerName)
      if me.pSprList.count < tLayer then
        tSpr = sprite(reserveSprite(me.getID()))
        tTargetID = getThread(#room).getInterface().getID()
        tLayerName = pLayerDataList.getPropAt(tLayer)
        if me.solveTransparency(tLayerName) = 0 then
          setEventBroker(tSpr.spriteNum, me.getID())
          tSpr.registerProcedure(#eventProcItemObj, tTargetID, #mouseDown)
          tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseEnter)
          tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseLeave)
        end if
        me.pSprList.add(tSpr)
      else
        tSpr = me.pSprList[tLayer]
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
          pInkList[tLayer] = me.solveInk(tLayerName, pNameBase)
        end if
        if pBlendList.count < tLayer then
          pBlendList[tLayer] = me.solveBlend(tLayerName, pNameBase)
        end if
        tSpr.ink = pInkList[tLayer]
        tSpr.blend = pBlendList[tLayer]
      end if
      me.postProcessLayer(tLayer)
      if pInitialized then
        me.animatePaletteForLayer(tLayer, tSpr)
      end if
      if tUpdateLocation then
        me.updateLocation()
      end if
      next repeat
    end if
    if me.pSprList.count >= tLayer then
      tSpr = me.pSprList[tLayer]
      if tSpr.castNum <> 0 then
        tMembersFound = tMembersFound + 1
      end if
    end if
  end repeat
  pInitialized = 1
  if tMembersFound = 0 then
    return 0
  else
    return 1
  end if
end

on postProcessLayer me, tLayer
  return 1
end

on animatePaletteForLayer me, tLayerIndex, tSpr
  if pLayerDataList.count = 0 then
    return 1
  end if
  tFrameList = me.getFrameList(tLayerIndex)
  if not (tFrameList.findPos(#paletteFrames) > 0) then
    return 1
  end if
  tFrames = tFrameList.getaProp(#paletteFrames)
  tPalettes = tFrameList.getaProp(#paletteIndex)
  tFrame = 0
  if not voidp(tFrameList) and not voidp(tLayerIndex) then
    if tFrameList.findPos(#frames) > 0 then
      tFrameSequence = tFrameList[#frames]
    else
      tSequences = tFrameList.getaProp(#sequences)
      if listp(tSequences) then
        if tSequences.count >= pFrameSequenceNumberList[tLayerIndex] then
          tFrameSequence = tSequences[pFrameSequenceNumberList[tLayerIndex]]
        end if
      end if
    end if
    if not voidp(tFrameSequence) then
      tFrameNumber = pFrameNumberList2[tLayerIndex]
      tFrame = tFrameSequence[tFrameNumber]
      if tFrame < 0 then
        tFrame = random(abs(tFrame))
      end if
    end if
  end if
  if tFrameNumber > tPalettes.count then
    return 0
  end if
  if tFrameNumber < 1 then
    return 0
  end if
  tPalette = tPalettes[tFrameNumber]
  tMemNum = getmemnum(tPalette)
  if tMemNum = 0 then
    return 0
  end if
  tSpr.member.paletteRef = member(tMemNum)
  return 1
end

on getMemberName me, tLayer
  tName = pNameBase
  tLayerIndex = pLayerDataList.findPos(tLayer)
  tFrameList = me.getFrameList(tLayer)
  tDirection = 0
  if not voidp(me.pDirection) then
    if me.pDirection.count >= 1 then
      tDirection = me.pDirection[1]
    end if
  end if
  tFrame = 0
  if not voidp(tFrameList) and not voidp(tLayerIndex) then
    if tFrameList.findPos(#frames) > 0 then
      tFrameSequence = tFrameList[#frames]
    else
      tSequences = tFrameList.getaProp(#sequences)
      if listp(tSequences) then
        if tSequences.count >= pFrameSequenceNumberList[tLayerIndex] then
          tFrameSequence = tSequences[pFrameSequenceNumberList[tLayerIndex]]
        end if
      end if
    end if
    if not voidp(tFrameSequence) then
      tFrameNumber = pFrameNumberList2[tLayerIndex]
      tFrame = tFrameSequence[tFrameNumber]
      if tFrame < 0 then
        tFrame = random(abs(tFrame))
      end if
    end if
  end if
  tName = tName & "_" & tLayer & "_0_" & me.pDimensions[1] & "_" & me.pDimensions[2] & "_" & tDirection & "_" & tFrame
  return tName
end

on getFrameList me, tLayer
  if not voidp(tLayer) then
    if not voidp(pLayerDataList[tLayer]) then
      tLayerData = pLayerDataList[tLayer]
      tAction = pState
      if tAction > tLayerData.count then
        tAction = 1
      end if
      if (tAction >= 1) and (tAction <= tLayerData.count) then
        tActionData = tLayerData[tAction]
        return tActionData
      end if
    end if
  end if
  return VOID
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

on findTransition me, tOldState, tNewState
  repeat with i = 1 to pPseudoStates.count
    if (pPseudoStates[i]["from"] = tOldState) and (pPseudoStates[i]["to"] = tNewState) then
      return pPseudoStates.getPropAt(i)
    end if
  end repeat
  return 0
end

on setState me, tNewState
  repeat with tLayer = 1 to pLayerDataList.count
    pLoopCountList[tLayer] = 0
  end repeat
  if tNewState = EMPTY then
    tNewState = 1
  end if
  if ilk(integer(tNewState)) <> #integer then
    return 0
  end if
  tNewState = integer(tNewState)
  tNewState = tNewState + 1
  tNewIndex = 0
  repeat with tIndex = 1 to pStateSequenceList.count
    tstate = pStateSequenceList[tIndex]
    if ilk(tstate) = #list then
      repeat with tIndex2 = 1 to tstate.count
        if tstate[tIndex2] = tNewState then
          tNewIndex = tIndex
          exit repeat
        end if
      end repeat
    else
      if tstate = tNewState then
        tNewIndex = tIndex
      end if
    end if
    if tNewIndex <> 0 then
      exit repeat
    end if
  end repeat
  if tNewIndex = 0 then
    if pStateSequenceList.count > 0 then
      tstate = pStateSequenceList[1]
      if ilk(tstate) = #list then
        if tstate.count > 0 then
          tNewState = tstate[1]
          tNewIndex = 1
        end if
      else
        tNewState = tstate
        tNewIndex = 1
      end if
    end if
  end if
  if tNewState <> pState then
    tTransitionState = me.findTransition(pState, tNewState)
    if tTransitionState then
      pPendingState = tNewState
      pStateChangeActive = tTransitionState
      tNewState = pStateSequenceList.count + tTransitionState
      tNewIndex = pStateSequenceList.count + tTransitionState
    end if
  end if
  if tNewIndex <> 0 then
    pStateIndex = tNewIndex
    pState = tNewState
    me.resetFrameNumbers()
    repeat with tLayer = 1 to pLayerDataList.count
      tFrameList = me.getFrameList(pLayerDataList.getPropAt(tLayer))
      if not voidp(tFrameList) then
        tLoop = 1
        if not voidp(tFrameList[#loop]) then
          tLoop = tFrameList[#loop] - 1
        end if
        pLoopCountList[tLayer] = tLoop
      end if
    end repeat
    me.solveMembers()
    me.updateLocation()
    return 1
  end if
  return 0
end

on getNextState me
  return getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer: integer(me.getID()), #integer: 0])
end

on validateStateSequenceList me
  tstatelist = []
  repeat with tIndex = 1 to pStateSequenceList.count
    tstate = pStateSequenceList[tIndex]
    if ilk(tstate) = #list then
      if tstate.count < 1 then
        return error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList, #major)
      end if
      repeat with tIndex2 = 1 to tstate.count
        tState2 = tstate[tIndex2]
        if tState2 < 1 then
          return error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList, #major)
        end if
        if tstatelist.count < tState2 then
          tstatelist[tState2] = 1
          next repeat
        end if
        if tstatelist[tState2] > 0 then
          return error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList, #major)
        end if
      end repeat
      next repeat
    end if
    if tstate < 1 then
      return error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList, #major)
    end if
    if tstatelist.count < tstate then
      tstatelist[tstate] = 1
      next repeat
    end if
    if tstatelist[tstate] > 0 then
      return error(me, "Invalid state sequence list for item" && me.pNameBase, #validateStateSequenceList, #major)
      next repeat
    end if
    tstatelist[tstate] = 1
  end repeat
  return 1
end

on resetFrameNumbers me
  pFrameRepeatList = []
  pIsAnimatingList = []
  pFrameNumberList = []
  pFrameNumberList2 = []
  pFrameSequenceNumberList = []
  repeat with i = 1 to max(me.pLocShiftList.count, pLayerDataList.count)
    pFrameSequenceNumberList[i] = 1
    pFrameNumberList[i] = 1
    pFrameNumberList2[i] = 1
    pFrameRepeatList[i] = 1
    pIsAnimatingList[i] = 1
  end repeat
end

on solveTransparency me, tPart
  tName = pNameBase
  if memberExists(tName & ".props") then
    tPropList = value(member(getmemnum(tName & ".props")).text)
    if ilk(tPropList) <> #propList then
      error(me, tName & ".props is not valid!", #solveInk, #minor)
    else
      if tPropList[tPart] <> VOID then
        if tPropList[tPart][#transparent] <> VOID then
          return tPropList[tPart][#transparent]
        end if
      end if
    end if
  end if
  return 0
end
