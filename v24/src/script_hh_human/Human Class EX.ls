property pGeometry, pPeopleSize, pPartListSubSet, pPartListFull, pSprite, pMatteSpr, pShadowSpr, pTypingSprite, pExtraObjs, pCanvasSize, pMember, pInfoStruct, pName, pClass, pCustom, pAnimating, pDirection, pXFactor, pLocX, pLocY, pLocH, pHeadDir, pQueuesWithObj, pSync, pPreviousLoc, pExtraObjsActive, pPartList, pDancing, pMainAction, pScreenLoc, pPartIndex, pCtrlType, pTrading, pCarrying, pXP, pWebID, pGroupId, pStatusInGroup, pUserIsTyping, pCurrentAnim, pFrozenAnimFrame, pAnimCounter, pEyesClosed, pSleeping, pTalking, pMoving, pMoveStart, pMoveTime, pDestLScreen, pStartLScreen, pWaving, pUserTypingStartTime, pChanges, pFlipList, pDefShadowMem, pBuffer, pCorrectLocZ, pRestingHeight, pShadowFix, pBaseLocZ, pAlphaColor, pUpdateRect, pRawFigure, pPartActionList, pColors, pLeftHandUp, pRightHandUp, pPartOrderOld, pCanvasName, pPartClass

on construct me 
  pFrozenAnimFrame = 0
  pID = 0
  pWebID = void()
  pName = ""
  pPartList = []
  pPartIndex = [:]
  pFlipList = [0, 1, 2, 3, 2, 1, 0, 7]
  pLocFix = point(0, 0)
  pUpdateRect = rect(0, 0, 0, 0)
  pScreenLoc = [0, 0, 0]
  pStartLScreen = [0, 0, 0]
  pDestLScreen = [0, 0, 0]
  pPreviousLoc = [0, 0, 0]
  pRestingHeight = 0
  pAnimCounter = 0
  pMoveStart = 0
  pMoveTime = 500
  pEyesClosed = 0
  pSync = 1
  pChanges = 1
  pMainAction = "std"
  pMoving = 0
  pTalking = 0
  pCarrying = 0
  pSleeping = 0
  pDancing = 0
  pWaving = 0
  pTrading = 0
  pCtrlType = 0
  pAnimating = 0
  pSwim = 0
  pBadge = space()
  pCurrentAnim = ""
  pAlphaColor = rgb(255, 255, 255)
  pSync = 1
  pColors = [:]
  pModState = 0
  pExtraObjs = [:]
  pExtraObjsActive = [:]
  pDefShadowMem = member(0)
  pInfoStruct = [:]
  pQueuesWithObj = 0
  pXP = 0
  pGeometry = getThread(#room).getInterface().getGeometry()
  pXFactor = pGeometry.pXFactor
  pYFactor = pGeometry.pYFactor
  pHFactor = pGeometry.pHFactor
  pCorrectLocZ = 0
  pPartClass = value(getThread(#room).getComponent().getClassContainer().GET("bodypart"))
  pGroupId = void()
  pStatusInGroup = void()
  pBaseLocZ = 0
  pPeopleSize = getVariable("human.size.64")
  pRawFigure = [:]
  pPartOrderOld = ""
  pUserIsTyping = 0
  pUserTypingStartTime = 0
  pCanvasName = "Canvas:" & getUniqueID()
  tSubSetList = ["figure", "head", "speak", "gesture", "eye", "handRight", "handLeft", "walk", "sit", "itemRight"]
  pPartListSubSet = [:]
  repeat while tSubSetList <= undefined
    tSubSet = getAt(undefined, undefined)
    tSetName = "human.partset." & tSubSet & "." & pPeopleSize
    if not variableExists(tSetName) then
      pPartListSubSet.setAt(tSubSet, [])
      error(me, tSetName && "not found!", #construct, #major)
    else
      pPartListSubSet.setAt(tSubSet, getVariableValue(tSetName))
    end if
  end repeat
  pPartListFull = getVariableValue("human.parts." & pPeopleSize)
  if ilk(pPartListFull) <> #list then
    pPartListFull = []
  end if
  pPartActionList = void()
  pLeftHandUp = 0
  pRightHandUp = 0
  return TRUE
end

on deconstruct me 
  pGeometry = void()
  pPartList = []
  pInfoStruct = [:]
  if not voidp(pSprite) then
    releaseSprite(pSprite.spriteNum)
  end if
  if not voidp(pMatteSpr) then
    releaseSprite(pMatteSpr.spriteNum)
  end if
  if not voidp(pShadowSpr) then
    releaseSprite(pShadowSpr.spriteNum)
  end if
  if not voidp(pTypingSprite) then
    releaseSprite(pTypingSprite.spriteNum)
  end if
  if memberExists(me.getCanvasName()) then
    removeMember(me.getCanvasName())
  end if
  call(#deconstruct, pExtraObjs)
  pExtraObjsActive = [:]
  pExtraObjs = void()
  pShadowSpr = void()
  pMatteSpr = void()
  pSprite = void()
  return TRUE
end

on define me, tdata 
  me.setup(tdata)
  if not memberExists(me.getCanvasName()) then
    createMember(me.getCanvasName(), #bitmap)
  end if
  tSize = pCanvasSize.getAt(#std)
  pMember = member(getmemnum(me.getCanvasName()))
  pMember.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
  pMember.regPoint = point(0, (pMember.image.height + tSize.getAt(4)))
  pBuffer = pMember.image.duplicate()
  pSprite = sprite(reserveSprite(me.getID()))
  pSprite.castNum = pMember.number
  pSprite.width = pMember.width
  pSprite.height = pMember.height
  pSprite.ink = 36
  pMatteSpr = sprite(reserveSprite(me.getID()))
  pMatteSpr.castNum = pMember.number
  pMatteSpr.ink = 8
  pMatteSpr.blend = 0
  pShadowFix = 0
  pDefShadowMem = member(getmemnum(pPeopleSize & "_std_sd_1_0_0"))
  tTargetID = getThread(#room).getInterface().getID()
  setEventBroker(pMatteSpr.spriteNum, me.getID())
  pMatteSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseEnter)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseLeave)
  pShadowSpr = sprite(reserveSprite(me.getID()))
  if (ilk(pShadowSpr) = #sprite) then
    pShadowSpr.blend = 16
    pShadowSpr.ink = 8
    setEventBroker(pShadowSpr.spriteNum, me.getID())
    pShadowSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  end if
  pInfoStruct.setAt(#name, pName)
  pInfoStruct.setAt(#class, pClass)
  pInfoStruct.setAt(#custom, pCustom)
  pInfoStruct.setAt(#image, me.getPicture())
  pInfoStruct.setAt(#ctrl, "furniture")
  pInfoStruct.setAt(#badge, " ")
  tThread = getThread(#room)
  if tThread <> 0 then
    tInterface = tThread.getInterface()
    if tInterface <> 0 then
      tViz = tThread.getInterface().getRoomVisualizer()
      if tViz <> 0 then
        tPart = tViz.getPartAtLocation(tdata.getAt(#x), tdata.getAt(#y), [#wallleft, #wallright])
        if not (tPart = 0) then
          pBaseLocZ = (tPart.getAt(#locZ) - 1000)
        end if
      end if
    end if
  end if
  return TRUE
end

on changeFigureAndData me, tdata 
  pSex = tdata.getAt(#sex)
  pCustom = tdata.getAt(#custom)
  tmodels = tdata.getAt(#figure)
  me.setPartLists(tmodels)
  pPartOrderOld = ""
  me.arrangeParts()
  tAnimating = pAnimating
  me.resumeAnimation()
  pAnimating = tAnimating
  pChanges = 1
  me.render(1)
  me.reDraw()
  pInfoStruct.setAt(#image, me.getPicture())
end

on setup me, tdata 
  pName = tdata.getAt(#name)
  pClass = tdata.getAt(#class)
  pCustom = tdata.getAt(#custom)
  pSex = tdata.getAt(#sex)
  pDirection = tdata.getAt(#direction).getAt(1)
  pHeadDir = pDirection
  pLastDir = pDirection
  pLocX = tdata.getAt(#x)
  pLocY = tdata.getAt(#y)
  pLocH = tdata.getAt(#h)
  pBadge = tdata.getAt(#badge)
  pGroupId = tdata.getAt(#groupID)
  pStatusInGroup = tdata.getAt(#groupstatus)
  pXP = tdata.getaProp(#xp)
  if not voidp(tdata.getaProp(#webID)) then
    pWebID = tdata.getAt(#webID)
  end if
  pPeopleSize = getVariable("human.size." & integer(pXFactor))
  if not pPeopleSize then
    error(me, "People size not found, using default!", #setup, #minor)
    pPeopleSize = "h"
  end if
  pCorrectLocZ = (pPeopleSize = "h")
  pCanvasSize = value(getVariable("human.canvas." & pPeopleSize))
  if not pCanvasSize then
    error(me, "Canvas size not found, using default!", #setup, #minor)
    pCanvasSize = [#std:[64, 102, 32, -10], #lay:[89, 102, 32, -8]]
  end if
  if not me.setPartLists(tdata.getAt(#figure)) then
    return(error(me, "Couldn't create part lists!", #setup, #major))
  end if
  me.resetValues(pLocX, pLocY, pLocH, pHeadDir, pDirection)
  me.Refresh(pLocX, pLocY, pLocH, pDirection)
  pSync = 0
end

on update me 
  if pQueuesWithObj then
    me.prepare()
    me.render()
  else
    pSync = not pSync
    if pSync then
      me.prepare()
    else
      me.render()
    end if
  end if
end

on resetValues me, tX, tY, tH, tDirHead, tDirBody 
  if pQueuesWithObj and (pPreviousLoc = [tX, tY, tH]) then
    return TRUE
  end if
  pMoving = 0
  pDancing = 0
  pTalking = 0
  pCarrying = 0
  pWaving = 0
  pTrading = 0
  pCtrlType = 0
  pAnimating = 0
  pModState = 0
  pSleeping = 0
  pQueuesWithObj = 0
  i = 1
  repeat while i <= pExtraObjsActive.count
    pExtraObjsActive.setAt(i, 0)
    i = (1 + i)
  end repeat
  pLocFix = point(-1, 2)
  call(#reset, pPartList)
  if pGeometry <> void() then
    pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH)
  end if
  pLocX = tX
  pLocY = tY
  pLocH = tH
  pRestingHeight = 0
  pDirection = tDirBody
  pHeadDir = tDirHead
  me.resetAction()
  if pExtraObjs.count > 0 then
    call(#Refresh, pExtraObjs)
  end if
end

on Refresh me, tX, tY, tH 
  if pQueuesWithObj and (pPreviousLoc = [tX, tY, tH]) then
    return TRUE
  end if
  if pDancing > 0 or (pMainAction = "lay") then
    pHeadDir = pDirection
  end if
  call(#defineDir, pPartList, pDirection)
  call(#defineDirMultiple, pPartList, pHeadDir, pPartListSubSet.getAt("head"))
  me.arrangeParts()
  i = 1
  repeat while i <= pExtraObjsActive.count
    if (pExtraObjsActive.getAt(i) = 0) then
      pExtraObjs.getAt(i).deconstruct()
      pExtraObjs.deleteAt(i)
      pExtraObjsActive.deleteAt(i)
      next repeat
    end if
    i = (i + 1)
  end repeat
  pChanges = 1
end

on select me 
  return TRUE
end

on getName me 
  return(pName)
end

on getClass me 
  return("user")
end

on getCustom me 
  return(pCustom)
end

on getLocation me 
  return([pLocX, pLocY, pLocH])
end

on getScrLocation me 
  return(pScreenLoc)
end

on getTileCenter me 
  return(point((pScreenLoc.getAt(1) + (pXFactor / 2)), pScreenLoc.getAt(2)))
end

on getPartLocation me, tPart 
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  tPartLoc = pPartList.getAt(pPartIndex.getAt(tPart)).getLocation()
  if pMainAction <> "lay" then
    tloc = (pSprite.loc + tPartLoc)
  else
    tloc = point((pSprite.getProp(#rect, 1) + (pSprite.width / 2)), (pSprite.getProp(#rect, 2) + (pSprite.height / 2)))
  end if
  return(tloc)
end

on getDirection me 
  return(pDirection)
end

on getPartColor me, tPart 
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  return(pPartList.getAt(pPartIndex.getAt(tPart)).getColor())
end

on getPicture me, tImg 
  return(me.getPartialPicture(#Full, tImg, 4, "h"))
end

on getPartialPicture me, tPartList, tImg, tDirection, tPeopleSize 
  if tPartList.ilk <> #list then
    tPartName = ""
    if (tPartList = #head) then
      tPartList = pPartListSubSet.getAt("head")
    else
      if (tPartList = #Full) then
        tPartName = "human.parts." & pPeopleSize
      else
        if (tPartList = #swimmer) then
          tPartName = "swimmer.parts." & pPeopleSize
        end if
      end if
      if variableExists(tPartName) then
        tPartList = value(getVariable(tPartName))
      end if
    end if
    if tPartList.ilk <> #list then
      return(tImg)
    end if
  end if
  if voidp(tImg) then
    tCanvas = image(64, 102, 32)
  else
    tCanvas = tImg
  end if
  if voidp(tDirection) then
    tDirection = pDirection
  end if
  if voidp(tPeopleSize) then
    tPeopleSize = pPeopleSize
  end if
  tDirData = "." & tDirection
  tTempPartList = []
  tPartOrder = "human.parts." & pPeopleSize & tDirData
  if not variableExists(tPartOrder) then
    error(me, "No human part order found" && tPartOrder, #getPartialPicture, #major)
    i = 1
    repeat while i <= pPartIndex.count
      tPartSymbol = pPartIndex.getPropAt(i)
      if tPartList.findPos(tPartSymbol) > 0 then
        tTempPartList.append(pPartList.getAt(pPartIndex.getAt(tPartSymbol)))
      end if
      i = (1 + i)
    end repeat
    exit repeat
  end if
  tPartDefinition = getVariableValue(tPartOrder)
  repeat while tPartDefinition <= tImg
    tPartSymbol = getAt(tImg, tPartList)
    if not voidp(pPartIndex.getAt(tPartSymbol)) then
      if tPartList.findPos(tPartSymbol) > 0 then
        tTempPartList.append(pPartList.getAt(pPartIndex.getAt(tPartSymbol)))
      end if
    end if
  end repeat
  call(#copyPicture, tTempPartList, tCanvas, tDirection, tPeopleSize)
  return(tCanvas)
end

on getInfo me 
  if (pCtrlType = "") then
    pInfoStruct.setAt(#ctrl, "furniture")
  else
    pInfoStruct.setAt(#ctrl, pCtrlType)
  end if
  pInfoStruct.setAt(#badge, me.pBadge)
  pInfoStruct.setAt(#groupID, me.pGroupId)
  if pTrading then
    pInfoStruct.setAt(#custom, pCustom & "\r" & getText("human_trading", "Trading"))
  else
    if pCarrying <> 0 then
      pInfoStruct.setAt(#custom, pCustom & "\r" & getText("human_carrying", "Carrying:") && pCarrying)
    else
      pInfoStruct.setAt(#custom, pCustom)
    end if
  end if
  pInfoStruct.setaProp(#xp, pXP)
  return(pInfoStruct)
end

on getWebID me 
  return(pWebID)
end

on getSprites me 
  if (ilk(pShadowSpr) = #sprite) then
    return([pSprite, pShadowSpr, pMatteSpr])
  else
    return([pSprite, pMatteSpr])
  end if
end

on getProperty me, tPropID 
  if (tPropID = #dancing) then
    return(pDancing)
  else
    if (tPropID = #carrying) then
      return(pCarrying)
    else
      if (tPropID = #loc) then
        return([pLocX, pLocY, pLocH])
      else
        if (tPropID = #mainAction) then
          return(pMainAction)
        else
          if (tPropID = #moving) then
            return(me.pMoving)
          else
            if (tPropID = #badge) then
              return(me.pBadge)
            else
              if (tPropID = #swimming) then
                return(me.pSwim)
              else
                if (tPropID = #groupID) then
                  return(pGroupId)
                else
                  if (tPropID = #groupstatus) then
                    return(pStatusInGroup)
                  else
                    if (tPropID = #typing) then
                      return(pUserIsTyping)
                    else
                      if (tPropID = #peoplesize) then
                        return(pPeopleSize)
                      else
                        if (tPropID = #locZ) then
                          if (pSprite.ilk = #sprite) then
                            return(pSprite.locZ)
                          end if
                        else
                          return FALSE
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on setProperty me, tPropID, tValue 
  if (tPropID = #groupID) then
    pGroupId = tValue
  else
    if (tPropID = #groupstatus) then
      pStatusInGroup = tValue
    else
      return FALSE
    end if
  end if
end

on setUserTypingStatus me, tValue 
  if (tValue = 1) then
    if ilk(pTypingSprite) <> #sprite then
      pTypingSprite = sprite(reserveSprite(me.getID()))
    end if
    if (ilk(pTypingSprite) = #sprite) then
      if (pPeopleSize = "sh") then
        pTypingSprite.member = getMember("chat_typing_bubble_small")
      else
        pTypingSprite.member = getMember("chat_typing_bubble")
      end if
      pTypingSprite.ink = 8
      me.updateTypingSpriteLoc()
    end if
    pUserTypingStartTime = the milliSeconds
  else
    if (ilk(pTypingSprite) = #sprite) then
      releaseSprite(pTypingSprite.spriteNum)
      pTypingSprite = void()
      pUserTypingStartTime = 0
    end if
  end if
end

on updateTypingSpriteLoc me 
  if (ilk(pTypingSprite) = #sprite) and (ilk(pSprite) = #sprite) then
    tOffset = point(57, -75)
    tOffsetLocZ = 30
    if (pPeopleSize = "sh") then
      tOffset = point(33, -40)
    end if
    pTypingSprite.loc = (pSprite.loc + tOffset)
    pTypingSprite.visible = pSprite.visible
    pTypingSprite.locZ = (pSprite.locZ + tOffsetLocZ)
  end if
end

on getPartCarrying me, tPart 
  if pPartListSubSet.getAt("handRight").findPos(tPart) and me.getProperty(#carrying) then
    return TRUE
  end if
  return FALSE
end

on isInSwimsuit me 
  return FALSE
end

on closeEyes me 
  if (pMainAction = "lay") then
    me.definePartListAction(pPartListSubSet.getAt("eye"), "ley")
  else
    me.definePartListAction(pPartListSubSet.getAt("eye"), "eyb")
  end if
  pEyesClosed = 1
  pChanges = 1
end

on openEyes me 
  if (pMainAction = "lay") then
    me.definePartListAction(pPartListSubSet.getAt("eye"), "lay")
  else
    me.definePartListAction(pPartListSubSet.getAt("eye"), "std")
  end if
  pEyesClosed = 0
  pChanges = 1
end

on startAnimation me, tMemName 
  if (tMemName = "dance.2") then
    pLeftHandUp = 1
  end if
  if (tMemName = pCurrentAnim) then
    return FALSE
  end if
  if not memberExists(tMemName) then
    return FALSE
  end if
  tmember = member(getmemnum(tMemName))
  tList = tmember.text
  tTempDelim = the itemDelimiter
  the itemDelimiter = "/"
  i = 1
  repeat while i <= tList.count(#line)
    tPart = tList.getPropRef(#line, i).getProp(#item, 1)
    tAnim = tList.getPropRef(#line, i).getProp(#item, 2)
    call(#setAnimation, pPartList, tPart, tAnim)
    i = (1 + i)
  end repeat
  the itemDelimiter = tTempDelim
  pAnimating = 1
  pCurrentAnim = tMemName
end

on stopAnimation me 
  pAnimating = 0
  pCurrentAnim = ""
  call(#remAnimation, pPartList)
end

on resumeAnimation me 
  tMemName = pCurrentAnim
  pCurrentAnim = ""
  me.startAnimation(tMemName)
end

on show me 
  pSprite.visible = 1
  pMatteSpr.visible = 1
  if (ilk(pShadowSpr) = #sprite) then
    pShadowSpr.visible = 1
  end if
  me.updateTypingSpriteLoc()
end

on hide me 
  pSprite.visible = 0
  pMatteSpr.visible = 0
  if (ilk(pShadowSpr) = #sprite) then
    pShadowSpr.visible = 0
  end if
  me.updateTypingSpriteLoc()
end

on draw me, tRGB 
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  pMember.image.draw(pMember.image.rect, [#shapeType:#rect, #color:tRGB])
end

on prepare me 
  if not pFrozenAnimFrame then
    pAnimCounter = ((pAnimCounter + 1) mod 4)
  else
    pAnimCounter = (pFrozenAnimFrame - 1)
  end if
  if pEyesClosed and not pSleeping then
    me.openEyes()
  else
    if (random(30) = 3) then
      me.closeEyes()
    end if
  end if
  if pTalking and random(3) > 1 then
    if (pMainAction = "lay") then
      me.definePartListAction(pPartListSubSet.getAt("speak"), "lsp")
    else
      me.definePartListAction(pPartListSubSet.getAt("speak"), "spk")
    end if
    pChanges = 1
  end if
  if pMoving then
    tFactor = (float((the milliSeconds - pMoveStart)) / pMoveTime)
    if tFactor > 1 then
      tFactor = 1
    end if
    pScreenLoc = (((pDestLScreen - pStartLScreen) * tFactor) + pStartLScreen)
    pChanges = 1
  end if
  if pWaving and pMainAction <> "lay" then
    me.definePartListAction(pPartListSubSet.getAt("handLeft"), "wav")
    pChanges = 1
  end if
  if pDancing then
    pAnimating = 1
    pChanges = 1
  end if
  tTimeNow = the milliSeconds
  tMaxTypingTime = 30000
  if (tTimeNow - pUserTypingStartTime) > tMaxTypingTime and pUserTypingStartTime <> 0 then
    pUserTypingStartTime = 0
    me.setUserTypingStatus(0)
  end if
end

on render me, tForceUpdate 
  call(#update, pExtraObjs)
  if not pChanges then
    return()
  end if
  if (pPeopleSize = "sh") then
    tSkipFreq = 4
  else
    tSkipFreq = 5
  end if
  if (random(tSkipFreq) = 2) and not pMoving and not tForceUpdate then
    call(#skipAnimationFrame, pPartList)
    return TRUE
  end if
  pChanges = 0
  if (pMainAction = "lay") then
    tSize = pCanvasSize.getAt(#lay)
  else
    tSize = pCanvasSize.getAt(#std)
  end if
  if (ilk(pShadowSpr) = #sprite) then
    if (pMainAction = "sit") then
      pShadowSpr.castNum = getmemnum(pPeopleSize & "_sit_sd_1_" & pFlipList.getAt((pDirection + 1)) & "_0")
    else
      if (pMainAction = "lay") then
        pShadowSpr.castNum = 0
        pShadowFix = 0
      else
        if pShadowSpr.member <> pDefShadowMem then
          pShadowSpr.member = pDefShadowMem
        end if
      end if
    end if
  end if
  if pBuffer.width <> tSize.getAt(1) or pBuffer.height <> tSize.getAt(2) then
    pMember.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    pMember.regPoint = point(0, (tSize.getAt(2) + tSize.getAt(4)))
    pSprite.width = tSize.getAt(1)
    pSprite.height = tSize.getAt(2)
    pMatteSpr.width = tSize.getAt(1)
    pMatteSpr.height = tSize.getAt(2)
    pBuffer = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
  end if
  pMember.regPoint = point(0, pMember.getProp(#regPoint, 2))
  pShadowFix = 0
  if pSprite.flipH then
    pSprite.flipH = 0
    pMatteSpr.flipH = 0
  end if
  if (ilk(pShadowSpr) = #sprite) then
    pShadowSpr.flipH = 0
  end if
  if pCorrectLocZ then
    tOffZ = (((pLocH + pRestingHeight) * 1000) + 2)
  else
    tOffZ = 2
  end if
  pSprite.locH = pScreenLoc.getAt(1)
  pSprite.locV = pScreenLoc.getAt(2)
  pMatteSpr.loc = pSprite.loc
  if (ilk(pShadowSpr) = #sprite) then
    pShadowSpr.loc = (pSprite.loc + [pShadowFix, 0])
  end if
  if pBaseLocZ <> 0 then
    pSprite.locZ = pBaseLocZ
  else
    pSprite.locZ = ((pScreenLoc.getAt(3) + tOffZ) + pBaseLocZ)
  end if
  pMatteSpr.locZ = (pSprite.locZ + 1)
  if (ilk(pShadowSpr) = #sprite) then
    pShadowSpr.locZ = (pSprite.locZ - 3)
  end if
  me.updateTypingSpriteLoc()
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  repeat while pPartList <= undefined
    tPart = getAt(undefined, tForceUpdate)
    tRectMod = [0, 0, 0, 0]
    if (tPart.pPart = "ey") then
      if pTalking then
        if pMainAction <> "lay" and ((pAnimCounter mod 2) = 0) then
          tRectMod = [0, -1, 0, -1]
        end if
      end if
    end if
    tPart.update(tForceUpdate, tRectMod)
  end repeat
  pMember.image.copyPixels(pBuffer, pUpdateRect, pUpdateRect)
  pUpdateRect = rect(0, 0, 0, 0)
end

on reDraw me 
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#render, pPartList)
  pMember.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
end

on getClearedFigurePartList me, tmodels 
  return(me.getSpecificClearedFigurePartList(tmodels, me.getPartListNameBase()))
end

on getSpecificClearedFigurePartList me, tmodels, tListName 
  tPartList = getVariableValue(tListName & "." & pPeopleSize)
  if tPartList.ilk <> #list then
    return([])
  end if
  tPartListLegal = tPartList.duplicate()
  repeat while pPartListSubSet.getAt("figure") <= tListName
    tPart = getAt(tListName, tmodels)
    tPos = tPartList.findPos(tPart)
    if tPos > 0 then
      tPartList.deleteAt(tPos)
    end if
  end repeat
  i = 1
  repeat while i <= tmodels.count
    tPartName = tmodels.getPropAt(i)
    if (tPartList.findPos(tPartName) = 0) and tPartListLegal.findPos(tPartName) > 0 then
      tPartList.add(tPartName)
    end if
    i = (1 + i)
  end repeat
  return(tPartList)
end

on getRawFigure me 
  return(pRawFigure)
end

on setPartLists me, tmodels 
  if voidp(pPartActionList) then
    me.resetAction()
  end if
  tmodels = tmodels.duplicate()
  pRawFigure = tmodels
  tPartDefinition = me.getClearedFigurePartList(tmodels)
  tCurrentPartList = [:]
  i = pPartList.count
  repeat while i >= 1
    tPartObj = pPartList.getAt(i)
    tPartType = tPartObj.pPart
    if (tPartDefinition.findPos(tPartType) = 0) and pPartListSubSet.getAt("figure").findPos(tPartType) then
      pPartList.getAt(i).clearGraphics()
      pPartList.deleteAt(i)
    else
      tCurrentPartList.addProp(tPartType, tPartObj)
    end if
    i = (255 + i)
  end repeat
  pPartIndex = [:]
  pColors = [:]
  tFlipList = getVariable("human.parts.flipList")
  if ilk(tFlipList) <> #propList then
    tFlipList = [:]
  end if
  tAnimationList = getVariable("human.parts.animationList")
  if ilk(tAnimationList) <> #propList then
    tAnimationList = [:]
  end if
  i = 1
  repeat while i <= tPartDefinition.count
    tPartSymbol = tPartDefinition.getAt(i)
    tmodel = [:]
    tmodel.setAt("model", [])
    tmodel.setAt("color", [])
    if not voidp(tmodels.getAt(tPartSymbol)) then
      j = 1
      repeat while j <= tmodels.count
        if (tmodels.getPropAt(j) = tPartSymbol) then
          tmodel.getAt("model").add(tmodels.getAt(j).getAt("model"))
          tmodel.getAt("color").add(tmodels.getAt(j).getAt("color"))
        end if
        j = (1 + j)
      end repeat
    end if
    j = 1
    repeat while j <= tmodel.getAt("color").count
      tColor = tmodel.getAt("color").getAt(j)
      if voidp(tColor) then
        tColor = rgb("EEEEEE")
      end if
      if stringp(tColor) then
        tColor = value("rgb(" & tColor & ")")
      end if
      if tColor.ilk <> #color then
        tColor = rgb("EEEEEE")
      end if
      if ((tColor.red + tColor.green) + tColor.blue) > (238 * 3) then
        tColor = rgb("EEEEEE")
      end if
      tmodel.getAt("color").setAt(j, tColor)
      j = (1 + j)
    end repeat
    tFlipPart = tFlipList.getAt(tPartSymbol)
    tAction = pPartActionList.getAt(tPartSymbol)
    if voidp(tAction) then
      tAction = "std"
      error(me, "Missing action for part" && tPartSymbol, #setPartLists, #major)
    end if
    if (tCurrentPartList.findPos(tPartSymbol) = 0) then
      tPartClass = me.getPartClass(tPartSymbol)
      tPartObj = createObject(#temp, tPartClass)
      tDirection = pDirection
      if pPartListSubSet.getAt("head").findPos(tPartSymbol) > 0 then
        tDirection = pHeadDir
      end if
      tPartObj.define(tPartSymbol, tmodel.getAt("model"), tmodel.getAt("color"), tDirection, tAction, me, tFlipPart)
      tPartObj.setAnimations(tAnimationList.getAt(tPartSymbol))
      pPartList.add(tPartObj)
    else
      if tmodel.getAt("model").count > 0 then
        pPartList.getAt(i).clearGraphics()
        tCurrentPartList.getAt(tPartSymbol).changePartData(tmodel.getAt("model"), tmodel.getAt("color"))
      end if
    end if
    if tmodel.getAt("color").count > 0 then
      pColors.setaProp(tPartSymbol, tmodel.getAt("color"))
    end if
    i = (1 + i)
  end repeat
  i = 1
  repeat while i <= pPartList.count
    pPartIndex.setAt(pPartList.getAt(i).pPart, i)
    i = (1 + i)
  end repeat
  return TRUE
end

on arrangeParts me, tOrderName 
  tPartOrder = ""
  tDirData = ""
  if not voidp(pDirection) then
    tDirData = "." & pDirection
  end if
  if voidp(tOrderName) then
    tOrderName = "human.parts"
  end if
  tPartOrder = tOrderName & "." & pPeopleSize
  tPartOrderAction = tPartOrder & "." & pMainAction
  if variableExists(tPartOrderAction & tDirData) then
    tPartOrder = tPartOrderAction
  end if
  if pLeftHandUp then
    tPartOrderLeftHand = tPartOrder & ".lh-up"
    if variableExists(tPartOrderLeftHand & tDirData) then
      tPartOrder = tPartOrderLeftHand
    end if
  end if
  if pRightHandUp then
    tPartOrderRightHand = tPartOrder & ".rh-up"
    if variableExists(tPartOrderRightHand & tDirData) then
      tPartOrder = tPartOrderRightHand
    end if
  end if
  tPartOrder = tPartOrder & tDirData
  if (tPartOrder = pPartOrderOld) then
    return TRUE
  end if
  if not variableExists(tPartOrder) then
    error(me, "No human part order found" && tPartOrder, #arrangeParts, #major)
  else
    tPartDefinition = getVariableValue(tPartOrder)
    tTempPartList = []
    repeat while tPartDefinition <= undefined
      tPartSymbol = getAt(undefined, tOrderName)
      if not voidp(pPartIndex.getAt(tPartSymbol)) then
        tTempPartList.append(pPartList.getAt(pPartIndex.getAt(tPartSymbol)))
      end if
    end repeat
    if tTempPartList.count <> pPartList.count then
      return(error(me, "Invalid human part order" && tPartOrder, #arrangeParts, #major))
    end if
    pPartList = tTempPartList
    pPartOrderOld = tPartOrder
  end if
  i = 1
  repeat while i <= pPartList.count
    pPartIndex.setAt(pPartList.getAt(i).pPart, i)
    i = (1 + i)
  end repeat
end

on flipImage me, tImg_a 
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return(tImg_b)
end

on getCanvasName me 
  return(pCanvasName)
end

on getDefinedPartList me, tPartNameList 
  tPartList = []
  repeat while tPartNameList <= undefined
    tPartName = getAt(undefined, tPartNameList)
    if not voidp(pPartIndex.getAt(tPartName)) then
      tPos = pPartIndex.getAt(tPartName)
      tPartList.append(pPartList.getAt(tPos))
    end if
  end repeat
  return(tPartList)
end

on definePartListAction me, tPartList, tAction 
  if voidp(pPartActionList) then
    me.resetAction()
  end if
  repeat while tPartList <= tAction
    tPart = getAt(tAction, tPartList)
    pPartActionList.setAt(tPart, tAction)
  end repeat
  call(#defineAct, me.getDefinedPartList(tPartList), tAction)
end

on resetAction me 
  pMainAction = "std"
  pLeftHandUp = 0
  pRightHandUp = 0
  if voidp(pPartActionList) then
    pPartActionList = [:]
  end if
  if (pPartActionList.count = 0) then
    tPartList = getVariableValue(me.getPartListNameBase() & "." & pPeopleSize)
    if (tPartList.ilk = #list) then
      repeat while tPartList <= undefined
        tPart = getAt(undefined, undefined)
        pPartActionList.setAt(tPart, pMainAction)
      end repeat
    end if
  else
    i = 1
    repeat while i <= pPartActionList.count
      pPartActionList.setAt(i, pMainAction)
      i = (1 + i)
    end repeat
  end if
  call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), "0")
end

on getPartClass me, tPartSymbol 
  return(pPartClass)
end

on getPartListNameBase me 
  return("human.parts")
end

on releaseShadowSprite me 
  if (ilk(pShadowSpr) = #sprite) then
    releaseSprite(pShadowSpr.spriteNum)
    pShadowSpr = void()
  end if
end

on action_mv me, tProps 
  pMainAction = "wlk"
  pMoving = 1
  pBaseLocZ = 0
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = getLocalFloat(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  pMoveStart = the milliSeconds
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH)
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  me.definePartListAction(pPartListSubSet.getAt("walk"), "wlk")
end

on action_sld me, tProps 
  pMoving = 1
  pBaseLocZ = 0
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = getLocalFloat(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  pQueuesWithObj = integer(tProps.getProp(#word, 3))
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, (pLocH + pRestingHeight))
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  pPreviousLoc = [pLocX, pLocY, pLocH]
  tStartTime = tProps.getProp(#word, 4)
  if voidp(tStartTime) then
    pMoveStart = the milliSeconds
  else
    pMoveStart = tStartTime
  end if
end

on action_sit me, tProps 
  me.definePartListAction(pPartListSubSet.getAt("sit"), "sit")
  pMainAction = "sit"
  pRestingHeight = (getLocalFloat(tProps.getProp(#word, 2)) - 1)
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, (pLocH + pRestingHeight))
  tIsInQueue = integer(tProps.getProp(#word, 3))
  pQueuesWithObj = tIsInQueue
end

on action_lay me, tProps 
  pMainAction = "lay"
  pCarrying = 0
  tRestingHeight = getLocalFloat(tProps.getProp(#word, 2))
  if tRestingHeight < 0 then
    pRestingHeight = (abs(tRestingHeight) - 1)
    tZOffset = 0
  else
    pRestingHeight = (tRestingHeight - 1)
    tZOffset = 2000
  end if
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, (pLocH + pRestingHeight))
  if pXFactor < 33 then
    if (pFlipList.getAt((pDirection + 1)) = 2) then
      pScreenLoc = (pScreenLoc + [-10, 18, tZOffset])
    else
      if (pFlipList.getAt((pDirection + 1)) = 0) then
        pScreenLoc = (pScreenLoc + [-17, 18, tZOffset])
      end if
    end if
  else
    if (pFlipList.getAt((pDirection + 1)) = 2) then
      pScreenLoc = (pScreenLoc + [10, 30, tZOffset])
    else
      if (pFlipList.getAt((pDirection + 1)) = 0) then
        pScreenLoc = (pScreenLoc + [-47, 32, tZOffset])
      end if
    end if
  end if
  if pXFactor > 32 then
    pLocFix = point(30, -10)
  else
    pLocFix = point(35, -5)
  end if
  me.definePartListAction(pPartListFull, "lay")
  if (pDirection = 0) then
    pDirection = 4
    pHeadDir = 4
  end if
  call(#defineDir, pPartList, pDirection)
end

on carryObject me, tProps, tDefaultItem, tDefaultItemPublic 
  tItem = tProps.getProp(#word, 2)
  if value(tItem) > 0 then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, string(tDefaultItem))
    else
      tCarryItm = string(tDefaultItem)
    end if
    me.definePartListAction(pPartListSubSet.getAt("handRight"), "crr")
    call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = string(tDefaultItemPublic)
      me.definePartListAction(pPartListSubSet.getAt("handRight"), "crr")
      call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    end if
  end if
end

on action_carryd me, tProps 
  me.carryObject(tProps, "1", "1")
end

on action_carryf me, tProps 
  me.carryObject(tProps, "1", "4")
end

on action_cri me, tProps 
  me.carryObject(tProps, "75", "1")
end

on useObject me, tProps, tDefaultItem, tDefaultItemPublic 
  tItem = tProps.getProp(#word, 2)
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, string(tDefaultItem))
    else
      tCarryItm = string(tDefaultItem)
    end if
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
    me.definePartListAction(pPartListSubSet.getAt("handRight"), "drk")
    call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    pRightHandUp = 1
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = string(tDefaultItemPublic)
      me.definePartListAction(pPartListSubSet.getAt("handRight"), "drk")
      call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
      pRightHandUp = 1
    end if
  end if
end

on action_usei me, tProps 
  me.useObject(tProps, "1", "1")
end

on action_drink me, tProps 
  me.useObject(tProps, "1", "1")
end

on action_eat me, tProps 
  me.useObject(tProps, "1", "4")
end

on action_talk me, tProps 
  if (pPeopleSize = "sh") then
    if (pMainAction = "lay") then
      return FALSE
    end if
  end if
  pTalking = 1
end

on action_gest me, tProps 
  if (pPeopleSize = "sh") then
    return FALSE
  end if
  tGesture = tProps.getProp(#word, 2)
  if (tGesture = "spr") then
    tGesture = "srp"
  end if
  if (pMainAction = "lay") then
    tGesture = "l" & tGesture.getProp(#char, 1, 2)
    me.definePartListAction(pPartListSubSet.getAt("gesture"), tGesture)
  else
    me.definePartListAction(pPartListSubSet.getAt("gesture"), tGesture)
    if (tGesture = "ohd") then
      me.definePartListAction(pPartListSubSet.getAt("head"), "ohd")
    end if
  end if
end

on action_wave me, tProps 
  pWaving = 1
  pLeftHandUp = 1
end

on action_dance me, tProps 
  tStyleNum = tProps.getProp(#word, 2)
  pDancing = integer(tStyleNum)
  if (pDancing = void()) then
    pDancing = 1
  end if
  tStyle = "dance." & pDancing
  me.startAnimation(tStyle)
end

on action_ohd me 
  me.definePartListAction(pPartListSubSet.getAt("head"), "ohd")
  me.definePartListAction(pPartListSubSet.getAt("handRight"), "ohd")
end

on action_trd me 
  pTrading = 1
end

on action_sleep me 
  pSleeping = 1
end

on action_flatctrl me, tProps 
  pCtrlType = tProps.getProp(#word, 2)
end

on action_mod me, tProps 
  pModState = tProps.getProp(#word, 2)
end

on action_sign me, props 
  tSignMem = "sign" & props.getProp(#word, 2)
  if (getmemnum(tSignMem) = 0) then
    return FALSE
  end if
  me.definePartListAction(pPartListSubSet.getAt("handLeft"), "sig")
  tSignObjID = "SIGN_EXTRA"
  pExtraObjsActive.setaProp(tSignObjID, 1)
  if voidp(pExtraObjs.getAt(tSignObjID)) then
    pExtraObjs.addProp(tSignObjID, createObject(#temp, "HumanExtra Sign Class"))
  end if
  call(#show_sign, pExtraObjs, ["sprite":pSprite, "direction":pDirection, "signmember":tSignMem])
  pLeftHandUp = 1
end

on action_joingame me, tProps 
  if tProps.count(#word) < 3 then
    return FALSE
  end if
  tSignObjID = "IG_ICON"
  pExtraObjsActive.setaProp(tSignObjID, 1)
  if (pExtraObjs.findPos(tSignObjID) = 0) then
    tObject = createObject(#temp, "IG HumanIcon Class")
    if (tObject = 0) then
      return FALSE
    end if
    pExtraObjs.setaProp(tSignObjID, tObject)
  end if
  call(#show_ig_icon, pExtraObjs, ["userid":me.getID(), "gameid":tProps.getProp(#word, 2), "gametype":tProps.getProp(#word, 3), "locz":pSprite.locZ])
end
