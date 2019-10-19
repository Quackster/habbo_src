property pGeometry, pPeopleSize, pPartListSubSet, pPartListFull, pFlipPartList, pSprite, pMatteSpr, pShadowSpr, pTypingSprite, pFXManager, pExtraObjs, pDrinkEatTimeoutList, pCanvasSize, pMember, pInfoStruct, pName, pClass, pCustom, pAnimating, pDirection, pXFactor, pLocX, pLocY, pLocH, pHeadDir, pQueuesWithObj, pSync, pPreviousLoc, pDancing, pFx, pExtraObjsActive, pPartList, pMainAction, pCarrying, pDrinkEatParams, pGesture, pScreenLoc, pPartIndex, pCtrlType, pTrading, pXP, pWebID, pGroupId, pStatusInGroup, pUserIsTyping, pCurrentAnim, pFrozenAnimFrame, pAnimCounter, pEyesClosed, pSleeping, pTalking, pMoving, pMoveStart, pMoveTime, pDestLScreen, pStartLScreen, pWaving, pUserTypingStartTime, pChanges, pFlipList, pDefShadowMem, pBuffer, pCorrectLocZ, pRestingHeight, pShadowFix, pBaseLocZ, pAlphaColor, pUpdateRect, pRawFigure, pPartActionList, pColors, pLeftHandUp, pRightHandUp, pPartOrderOld, pCanvasName, pPartClass, pLayingDown, pSitting, pPersistedFX

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
  pFx = 0
  pWaving = 0
  pTrading = 0
  pCtrlType = 0
  pAnimating = 0
  pSwim = 0
  pBadges = [:]
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
  pFlipPartList = getVariable("human.parts.flipList")
  if ilk(pFlipPartList) <> #propList then
    pFlipPartList = [:]
  end if
  pDrinkEatParams = [:]
  pPartActionList = void()
  pLeftHandUp = 0
  pRightHandUp = 0
  pDrinkEatTimeoutList = []
  pCarryItemCode = void()
  pGesture = 0
  pSitting = 0
  pLayingDown = 0
  pPersistedFX = 0
  return(1)
end

on deconstruct me 
  pGeometry = void()
  pPartList = []
  pPartIndex = [:]
  pInfoStruct = [:]
  me.resetSpriteColors()
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
  if objectp(pFXManager) then
    pFXManager.deconstruct()
  end if
  pFXManager = void()
  pFx = 0
  call(#deconstruct, pExtraObjs)
  pExtraObjsActive = [:]
  pExtraObjs = void()
  pShadowSpr = void()
  pMatteSpr = void()
  pSprite = void()
  timeout("wavetimeout" & me.getID()).forget()
  repeat while pDrinkEatTimeoutList <= undefined
    tName = getAt(undefined, undefined)
    timeout(tName).forget()
  end repeat
  return(1)
end

on define me, tdata 
  me.setup(tdata)
  if not memberExists(me.getCanvasName()) then
    createMember(me.getCanvasName(), #bitmap)
  end if
  tSize = pCanvasSize.getAt(#std)
  pMember = member(getmemnum(me.getCanvasName()))
  pMember.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
  0.regPoint = point(pMember, image.height + tSize.getAt(4))
  pBuffer = image.duplicate()
  pSprite = sprite(reserveSprite(me.getID()))
  pSprite.castNum = pMember.number
  pSprite.width = pMember.width
  pSprite.height = pMember.height
  pMatteSpr = sprite(reserveSprite(me.getID()))
  pMatteSpr.castNum = pMember.number
  pShadowFix = 0
  pDefShadowMem = member(getmemnum(pPeopleSize & "_std_sd_1_0_0"))
  tTargetID = getThread(#room).getInterface().getID()
  setEventBroker(pMatteSpr.spriteNum, me.getID())
  pMatteSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseEnter)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseLeave)
  pShadowSpr = sprite(reserveSprite(me.getID()))
  if ilk(pShadowSpr) = #sprite then
    setEventBroker(pShadowSpr.spriteNum, me.getID())
    pShadowSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  end if
  me.resetSpriteColors()
  pInfoStruct.setAt(#name, pName)
  pInfoStruct.setAt(#class, pClass)
  pInfoStruct.setAt(#custom, pCustom)
  pInfoStruct.setAt(#image, me.getPicture())
  pInfoStruct.setAt(#ctrl, "furniture")
  pInfoStruct.setAt(#badges, [:])
  tThread = getThread(#room)
  if tThread <> 0 then
    tInterface = tThread.getInterface()
    if tInterface <> 0 then
      tViz = tThread.getInterface().getRoomVisualizer()
      if tViz <> 0 then
        tPart = tViz.getPartAtLocation(tdata.getAt(#x), tdata.getAt(#y), [#wallleft, #wallright])
        if not tPart = 0 then
          pBaseLocZ = tPart.getAt(#locZ) - 1000
        end if
      end if
    end if
  end if
  return(1)
end

on changeFigureAndData me, tdata 
  if tdata <> void() then
    pSex = tdata.getAt(#sex)
    pCustom = tdata.getAt(#custom)
    tmodels = tdata.getAt(#figure)
    me.setPartLists(tmodels)
  else
    me.setPartLists()
  end if
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
  pBadges = tdata.getAt(#badge)
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
  tRoomStruct = getObject(#session).GET("lastroom")
  if not listp(tRoomStruct) then
    error(me, "Room struct not saved in #session!", #construct)
    ttype = #public
  else
    ttype = tRoomStruct.getaProp(#type)
  end if
  if ttype = #private then
    pCorrectLocZ = 1
  else
    pCorrectLocZ = 0
  end if
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

on resetSpriteColors me 
  if ilk(pSprite) = #sprite then
    pSprite.ink = 36
    pSprite.blend = 100
    pSprite.bgColor = paletteIndex(0)
    pSprite.foreColor = 255
  end if
  if ilk(pMatteSpr) = #sprite then
    pMatteSpr.ink = 8
    pMatteSpr.blend = 0
    pMatteSpr.bgColor = paletteIndex(0)
    pMatteSpr.foreColor = 255
  end if
  if ilk(pShadowSpr) = #sprite then
    pShadowSpr.blend = 16
    pShadowSpr.ink = 8
    pShadowSpr.bgColor = paletteIndex(0)
    pShadowSpr.foreColor = 255
  end if
end

on resetValues me, tX, tY, tH, tDirHead, tDirBody, tActionList 
  if tActionList = void() then
    tActionList = []
  end if
  if pQueuesWithObj and pPreviousLoc = [tX, tY, tH] then
    return(1)
  end if
  tWasDancing = pDancing
  pMoving = 0
  pTrading = tActionList.findPos("trd") > 0
  pCtrlType = 0
  pAnimating = pDancing or pFx
  pModState = 0
  pQueuesWithObj = 0
  if tWasDancing and not pDancing then
    executeMessage(#updateInfoStandButtons)
  end if
  i = 1
  repeat while i <= pExtraObjsActive.count
    if pExtraObjsActive.getPropAt(i) <> "IG_ICON" then
      pExtraObjsActive.setAt(i, 0)
    end if
    i = 1 + i
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
  pDirection = (tDirBody + me.getEffectDirOffset() mod 8)
  pHeadDir = (tDirHead + me.getEffectDirOffset() mod 8)
  me.resetAction()
  if pExtraObjs.count > 0 then
    call(#Refresh, pExtraObjs)
  end if
end

on Refresh me, tX, tY, tH 
  if pQueuesWithObj and pPreviousLoc = [tX, tY, tH] then
    return(1)
  end if
  if pFx > 0 or pDancing > 0 or pMainAction = "lay" then
    pHeadDir = pDirection
  end if
  call(#defineDir, pPartList, pDirection)
  call(#defineDirMultiple, pPartList, pHeadDir, pPartListSubSet.getAt("head"))
  if pCarrying <> 0 then
    call("action_" & pDrinkEatParams.getAt(#action), [me], pDrinkEatParams.getAt(#action) && pDrinkEatParams.getAt(#params))
  end if
  if pGesture <> 0 then
    call("action_gest", [me], "gest " && pGesture)
  end if
  me.arrangeParts()
  i = 1
  repeat while i <= pExtraObjsActive.count
    if pExtraObjsActive.getAt(i) = 0 then
      pExtraObjs.getAt(i).deconstruct()
      pExtraObjs.deleteAt(i)
      pExtraObjsActive.deleteAt(i)
      next repeat
    end if
    i = i + 1
  end repeat
  pChanges = 1
end

on select me 
  return(1)
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
  return(point(pScreenLoc.getAt(1) + (pXFactor / 2), pScreenLoc.getAt(2)))
end

on getPartLocation me, tPart 
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  tPartLoc = pPartList.getAt(pPartIndex.getAt(tPart)).getLocation()
  if pMainAction <> "lay" then
    tloc = pSprite.loc + tPartLoc
  else
    tloc = point(pSprite.getProp(#rect, 1) + (pSprite.width / 2), pSprite.getProp(#rect, 2) + (pSprite.height / 2))
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
    if tPartList = #head then
      tPartList = pPartListSubSet.getAt("head")
    else
      if tPartList = #Full then
        tPartName = "human.parts." & pPeopleSize
      else
        if tPartList = #swimmer then
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
      i = 1 + i
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
  if pCtrlType = "" then
    pInfoStruct.setAt(#ctrl, "furniture")
  else
    pInfoStruct.setAt(#ctrl, pCtrlType)
  end if
  pInfoStruct.setAt(#badges, me.pBadges)
  pInfoStruct.setAt(#groupID, me.pGroupId)
  if pCustom = "" then
    tPrefix = ""
  else
    tPrefix = pCustom & "\r" & "\r"
  end if
  if pTrading then
    pInfoStruct.setAt(#custom, tPrefix & getText("human_trading", "Trading"))
  else
    if pCarrying <> 0 then
      pInfoStruct.setAt(#custom, tPrefix & getText("human_carrying", "Carrying:") && pCarrying)
    else
      pInfoStruct.setAt(#custom, pCustom)
    end if
  end if
  pInfoStruct.setaProp(#xp, pXP)
  pInfoStruct.setaProp(#FX, me.getCurrentEffectState())
  return(pInfoStruct)
end

on getWebID me 
  return(pWebID)
end

on getSprites me 
  if ilk(pShadowSpr) = #sprite then
    return([pSprite, pShadowSpr, pMatteSpr])
  else
    return([pSprite, pMatteSpr])
  end if
end

on getProperty me, tPropID 
  if tPropID = #carrying then
    return(pCarrying)
  else
    if tPropID = #direction then
      return(pDirection)
    else
      if tPropID = #dancing then
        return(pDancing)
      else
        if tPropID = #FX then
          return(pFx)
        else
          if tPropID = #loc then
            return([pLocX, pLocY, pLocH])
          else
            if tPropID = #mainAction then
              return(pMainAction)
            else
              if tPropID = #moving then
                return(me.pMoving)
              else
                if tPropID = #badges then
                  return(me.pBadges)
                else
                  if tPropID = #swimming then
                    return(me.pSwim)
                  else
                    if tPropID = #groupID then
                      return(pGroupId)
                    else
                      if tPropID = #groupstatus then
                        return(pStatusInGroup)
                      else
                        if tPropID = #typing then
                          return(pUserIsTyping)
                        else
                          if tPropID = #peoplesize then
                            return(pPeopleSize)
                          else
                            if tPropID = #locZ then
                              if pSprite.ilk = #sprite then
                                return(pSprite.locZ)
                              end if
                            else
                              return(0)
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
    end if
  end if
end

on setProperty me, tPropID, tValue 
  if tPropID = #groupID then
    pGroupId = tValue
  else
    if tPropID = #groupstatus then
      pStatusInGroup = tValue
    else
      return(0)
    end if
  end if
end

on setUserTypingStatus me, tValue 
  if tValue = 1 then
    if ilk(pTypingSprite) <> #sprite then
      pTypingSprite = sprite(reserveSprite(me.getID()))
    end if
    if ilk(pTypingSprite) = #sprite then
      if pPeopleSize = "sh" then
        pTypingSprite.member = getMember("chat_typing_bubble_small")
      else
        pTypingSprite.member = getMember("chat_typing_bubble")
      end if
      pTypingSprite.ink = 8
      me.updateTypingSpriteLoc()
    end if
    pUserTypingStartTime = the milliSeconds
  else
    if ilk(pTypingSprite) = #sprite then
      releaseSprite(pTypingSprite.spriteNum)
      pTypingSprite = void()
      pUserTypingStartTime = 0
    end if
  end if
end

on updateTypingSpriteLoc me 
  if ilk(pTypingSprite) = #sprite and ilk(pSprite) = #sprite then
    tOffset = point(57, -75)
    tOffsetLocZ = 30
    if pPeopleSize = "sh" then
      tOffset = point(33, -40)
    end if
    pTypingSprite.loc = pSprite.loc + tOffset
    pTypingSprite.visible = pSprite.visible
    pTypingSprite.locZ = pSprite.locZ + tOffsetLocZ
  end if
end

on getPartCarrying me, tPart 
  if pPartListSubSet.getAt("handRight").findPos(tPart) and me.getProperty(#carrying) then
    return(1)
  end if
  return(0)
end

on isInSwimsuit me 
  return(0)
end

on closeEyes me 
  if pMainAction = "lay" then
    me.definePartListAction(pPartListSubSet.getAt("eye"), "ley")
  else
    me.definePartListAction(pPartListSubSet.getAt("eye"), "eyb")
  end if
  pEyesClosed = 1
  pChanges = 1
end

on openEyes me 
  if pMainAction = "lay" then
    me.definePartListAction(pPartListSubSet.getAt("eye"), "lay")
  else
    me.definePartListAction(pPartListSubSet.getAt("eye"), "std")
  end if
  pEyesClosed = 0
  pChanges = 1
end

on startAnimation me, tMemName 
  if tMemName = pCurrentAnim then
    return(0)
  end if
  if not memberExists(tMemName) then
    return(0)
  end if
  tmember = member(getmemnum(tMemName))
  tList = tmember.text
  tTempDelim = the itemDelimiter
  the itemDelimiter = "/"
  i = 1
  repeat while i <= tList.count(#line)
    tChar = tList.getPropRef(#line, i).getProp(#char, 1)
    if tChar <> "#" and tChar <> "" then
      tPart = tList.getPropRef(#line, i).getProp(#item, 1)
      tAnim = tList.getPropRef(#line, i).getProp(#item, 2)
      if tPart = "leftHandUp" then
        pLeftHandUp = 1
      else
        if tPart = "all" then
          call(#setAnimation, pPartList, "all", tAnim)
          call(#setAnimation, [pFXManager], "all", tAnim)
        else
          call(#setAnimation, pPartList, tPart, tAnim)
          call(#setAnimation, [pFXManager], tPart, tAnim)
        end if
      end if
    end if
    i = 1 + i
  end repeat
  the itemDelimiter = tTempDelim
  pAnimating = 1
  pCurrentAnim = tMemName
end

on stopAnimation me 
  pAnimating = 0
  pCurrentAnim = ""
  call(#remAnimation, pPartList)
  me.resetSpriteColors()
end

on resumeAnimation me 
  tMemName = pCurrentAnim
  pCurrentAnim = ""
  me.startAnimation(tMemName)
end

on show me 
  pSprite.visible = 1
  pMatteSpr.visible = 1
  if ilk(pShadowSpr) = #sprite then
    pShadowSpr.visible = 1
  end if
  me.updateTypingSpriteLoc()
  tFXSprites = me.getEffectSpriteProps()
  repeat while tFXSprites <= undefined
    tProps = getAt(undefined, undefined)
    tsprite = tProps.getaProp(#sprite)
    tsprite.visible = 1
  end repeat
end

on hide me 
  pSprite.visible = 0
  pMatteSpr.visible = 0
  if ilk(pShadowSpr) = #sprite then
    pShadowSpr.visible = 0
  end if
  me.updateTypingSpriteLoc()
  tFXSprites = me.getEffectSpriteProps()
  repeat while tFXSprites <= undefined
    tProps = getAt(undefined, undefined)
    tsprite = tProps.getaProp(#sprite)
    tsprite.visible = 0
  end repeat
end

on draw me, tRGB 
  if ilk(tRGB) <> #color then
    tRGB = rgb(255, 0, 0)
  end if
  pMember.draw(image.rect, [#shapeType:#rect, #color:tRGB])
end

on prepare me 
  if not pFrozenAnimFrame then
    pAnimCounter = (pAnimCounter + 1 mod 4)
  else
    pAnimCounter = pFrozenAnimFrame - 1
  end if
  if pEyesClosed and not pSleeping then
    me.openEyes()
  else
    if random(30) = 3 then
      me.closeEyes()
    end if
  end if
  if pTalking and random(3) > 1 then
    if pMainAction = "lay" then
      me.definePartListAction(pPartListSubSet.getAt("speak"), "lsp")
    else
      me.definePartListAction(pPartListSubSet.getAt("speak"), "spk")
    end if
    pChanges = 1
  else
    if pMainAction = "lay" then
      me.definePartListAction(pPartListSubSet.getAt("speak"), "lay")
    else
      me.definePartListAction(pPartListSubSet.getAt("speak"), "std")
    end if
  end if
  if pMoving then
    tFactor = (float(the milliSeconds - pMoveStart) / pMoveTime)
    if tFactor > 1 then
      tFactor = 1
    end if
    pScreenLoc = (pDestLScreen - pStartLScreen * tFactor) + pStartLScreen
    pChanges = 1
  end if
  if pWaving and pMainAction <> "lay" then
    me.definePartListAction(pPartListSubSet.getAt("handLeft"), "wav")
    pChanges = 1
  end if
  if pDancing or pFx then
    pAnimating = 1
    pChanges = 1
  end if
  tTimeNow = the milliSeconds
  tMaxTypingTime = 30000
  if tTimeNow - pUserTypingStartTime > tMaxTypingTime and pUserTypingStartTime <> 0 then
    pUserTypingStartTime = 0
    me.setUserTypingStatus(0)
  end if
end

on render me, tForceUpdate 
  call(#update, pExtraObjs)
  if not pChanges then
    return()
  end if
  if not me.pFx or me.pMoving or tForceUpdate then
    if pPeopleSize = "sh" then
      tSkipFreq = 4
    else
      tSkipFreq = 5
    end if
    if random(tSkipFreq) = 2 then
      call(#skipAnimationFrame, pPartList)
      return(1)
    end if
  end if
  pChanges = 0
  if pMainAction = "lay" then
    tSize = pCanvasSize.getAt(#lay)
  else
    tSize = pCanvasSize.getAt(#std)
  end if
  if pFXManager <> 0 then
    tSize = tSize.duplicate()
    tEffectSize = pFXManager.getEffectSizeParams()
    if tEffectSize <> 0 then
      if tEffectSize.getAt(1) > tSize.getAt(1) then
        tSize.setAt(1, tEffectSize.getAt(1))
      end if
      if tEffectSize.getAt(2) > tSize.getAt(2) then
        tSize.setAt(2, tEffectSize.getAt(2))
      end if
    end if
  end if
  if ilk(pShadowSpr) = #sprite then
    if pMainAction = "sit" then
      pShadowSpr.castNum = getmemnum(pPeopleSize & "_sit_sd_1_" & pFlipList.getAt(pDirection + 1) & "_0")
    else
      if pMainAction = "lay" then
        pShadowSpr.castNum = 0
        pShadowFix = 0
      else
        if me.pFx then
          tShadowMem = me.getEffectShadowName()
          if tShadowMem <> void() then
            tMemNum = getmemnum(pPeopleSize & "_" & tShadowMem & "_" & pDirection & "_0")
            if tMemNum = 0 then
              tMemNum = getmemnum(pPeopleSize & "_" & tShadowMem & "_" & pFlipList.getAt(pDirection + 1) & "_0")
            end if
            pShadowSpr.castNum = tMemNum
          end if
        end if
        if tShadowMem = void() then
          if pShadowSpr.member <> pDefShadowMem then
            pShadowSpr.member = pDefShadowMem
          end if
        end if
      end if
    end if
  end if
  if pBuffer.width <> tSize.getAt(1) or pBuffer.height <> tSize.getAt(2) then
    pMember.image = image(tSize.getAt(1), tSize.getAt(2), tSize.getAt(3))
    pMember.regPoint = point(0, tSize.getAt(2) + tSize.getAt(4))
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
  if ilk(pShadowSpr) = #sprite then
    pShadowSpr.flipH = 0
  end if
  if pCorrectLocZ then
    tOffZ = (pLocH + pRestingHeight * 1000) + 2
  else
    tOffZ = 2
  end if
  pSprite.locH = pScreenLoc.getAt(1)
  pSprite.locV = pScreenLoc.getAt(2)
  pMatteSpr.loc = pSprite.loc
  if ilk(pShadowSpr) = #sprite then
    pShadowSpr.loc = pSprite.loc + [pShadowFix, 0]
  end if
  if pBaseLocZ <> 0 then
    pSprite.locZ = pBaseLocZ
  else
    pSprite.locZ = pScreenLoc.getAt(3) + tOffZ + pBaseLocZ
  end if
  pMatteSpr.locZ = pSprite.locZ + 1
  if ilk(pShadowSpr) = #sprite then
    pShadowSpr.locZ = pSprite.locZ - 3
  end if
  me.updateTypingSpriteLoc()
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  repeat while pPartList <= undefined
    tPart = getAt(undefined, tForceUpdate)
    tRectMod = [0, 0, 0, 0]
    if tPart.pPart = "ey" then
      if pTalking then
        if pMainAction <> "lay" and (pAnimCounter mod 2) = 0 then
          tRectMod = [0, -1, 0, -1]
        end if
      end if
    end if
    tPart.update(tForceUpdate, tRectMod)
  end repeat
  image.copyPixels(pBuffer, pUpdateRect, pUpdateRect)
  pUpdateRect = rect(0, 0, 0, 0)
  me.updateEffects()
end

on reDraw me 
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#render, pPartList)
  image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
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
    if tPartList.findPos(tPartName) = 0 and tPartListLegal.findPos(tPartName) > 0 then
      tPartList.add(tPartName)
    end if
    i = 1 + i
  end repeat
  tEffectParts = me.getEffectAddedPartIndex()
  i = 1
  repeat while i <= tEffectParts.count
    tPartName = tEffectParts.getAt(i)
    if tPartList.findPos(tPartName) = 0 then
      tPartList.add(tPartName)
    end if
    i = 1 + i
  end repeat
  tExcludedParts = me.getEffectExcludedPartIndex()
  repeat while pPartListSubSet.getAt("figure") <= tListName
    tPartId = getAt(tListName, tmodels)
    tPartList.deleteOne(tPartId)
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
  if tmodels = void() then
    tmodels = pRawFigure
  else
    tmodels = tmodels.duplicate()
    pRawFigure = tmodels
  end if
  tPartDefinition = me.getClearedFigurePartList(tmodels)
  tCurrentPartList = [:]
  i = pPartList.count
  repeat while i >= 1
    tPartObj = pPartList.getAt(i)
    tPartType = tPartObj.pPart
    if tPartDefinition.findPos(tPartType) = 0 and pPartListSubSet.getAt("figure").findPos(tPartType) then
      pPartList.getAt(i).clearGraphics()
      pPartList.deleteAt(i)
    else
      tCurrentPartList.addProp(tPartType, tPartObj)
    end if
    i = 255 + i
  end repeat
  pPartIndex = [:]
  pColors = [:]
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
        if tmodels.getPropAt(j) = tPartSymbol then
          tmodel.getAt("model").add(tmodels.getAt(j).getAt("model"))
          tmodel.getAt("color").add(tmodels.getAt(j).getAt("color"))
        end if
        j = 1 + j
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
      if tColor.red + tColor.green + tColor.blue > (238 * 3) then
        tColor = rgb("EEEEEE")
      end if
      tmodel.getAt("color").setAt(j, tColor)
      j = 1 + j
    end repeat
    if tmodels.findPos(tPartSymbol) > 0 then
      tPartModels = tmodels.getAt(tPartSymbol)
      k = 1
      repeat while k <= tPartModels.count
        tPropKey = tPartModels.getPropAt(k)
        if tmodel.findPos(tPropKey) = 0 then
          tmodel.setaProp(tPropKey, tPartModels.getAt(k))
        end if
        k = 1 + k
      end repeat
    end if
    tFlipPart = pFlipPartList.getAt(tPartSymbol)
    tAction = pPartActionList.getAt(tPartSymbol)
    if voidp(tAction) then
      tAction = "std"
      error(me, "Missing action for part" && tPartSymbol, #setPartLists, #major)
    end if
    if tCurrentPartList.findPos(tPartSymbol) = 0 then
      tPartClass = me.getPartClass(tPartSymbol)
      tPartObj = createObject(#temp, tPartClass)
      tDirection = pDirection
      if pPartListSubSet.getAt("head").findPos(tPartSymbol) > 0 then
        tDirection = pHeadDir
      end if
      tPartObj.define(tPartSymbol, tmodel.getAt("model"), tmodel.getAt("color"), tDirection, tAction, me, tFlipPart, tmodel.getaProp("ink"))
      if tmodel.findPos("blend") > 0 then
        tPartObj.defineBlend(tmodel.getaProp("blend"))
      end if
      tPartObj.setAnimations(tAnimationList.getAt(tPartSymbol))
      pPartList.add(tPartObj)
    else
      if tmodel.getAt("model").count > 0 then
        pPartList.getAt(i).clearGraphics()
        tPartObj = tCurrentPartList.getAt(tPartSymbol)
        tPartObj.changePartData(tmodel.getAt("model"), tmodel.getAt("color"))
        if tmodel.findPos("blend") > 0 then
          tPartObj.defineBlend(tmodel.getaProp("blend"))
        end if
        if tmodel.findPos("ink") > 0 then
          tPartObj.defineInk(tmodel.getaProp("ink"))
        end if
        tPartObj.setAnimations(tAnimationList.getAt(tPartSymbol))
      end if
    end if
    if tmodel.getAt("color").count > 0 then
      pColors.setaProp(tPartSymbol, tmodel.getAt("color"))
    end if
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= pPartList.count
    pPartIndex.setAt(pPartList.getAt(i).pPart, i)
    i = 1 + i
  end repeat
  return(1)
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
  if tPartOrder = pPartOrderOld then
    return(1)
  end if
  if not variableExists(tPartOrder) then
    error(me, "No human part order found" && tPartOrder, #arrangeParts, #major)
  else
    tPartDefinition = getVariableValue(tPartOrder)
    if pFXManager <> 0 then
      pFXManager.alignEffectBodyparts(tPartDefinition, pDirection)
    end if
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
    i = 1 + i
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
  if pPartActionList.count = 0 then
    tPartList = getVariableValue(me.getPartListNameBase() & "." & pPeopleSize)
    if tPartList.ilk = #list then
      repeat while tPartList <= undefined
        tPart = getAt(undefined, undefined)
        pPartActionList.setAt(tPart, pMainAction)
      end repeat
    end if
  else
    i = 1
    repeat while i <= pPartActionList.count
      pPartActionList.setAt(i, pMainAction)
      i = 1 + i
    end repeat
  end if
end

on getPartClass me, tPartSymbol 
  return(pPartClass)
end

on getPartListNameBase me 
  return("human.parts")
end

on releaseShadowSprite me 
  if ilk(pShadowSpr) = #sprite then
    releaseSprite(pShadowSpr.spriteNum)
    pShadowSpr = void()
  end if
end

on action_std me, tProps 
  if pLayingDown or pSitting and pPersistedFX <> 0 then
    tReactivateFX = 1
  else
    tReactivateFX = 0
  end if
  pLayingDown = 0
  pSitting = 0
  if tReactivateFX then
    me.action_fx("fx" && pPersistedFX)
  end if
end

on action_mv me, tProps 
  if pLayingDown or pSitting and pPersistedFX <> 0 then
    tReactivateFX = 1
  else
    tReactivateFX = 0
  end if
  pLayingDown = 0
  pSitting = 0
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
  if tReactivateFX then
    me.action_fx("fx" && pPersistedFX)
  end if
end

on action_sld me, tProps 
  pLayingDown = 0
  pSitting = 0
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
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
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
  pLayingDown = 0
  pSitting = 1
  if pDancing then
    me.stop_action_dance()
  end if
  me.definePartListAction(pPartListSubSet.getAt("sit"), "sit")
  pMainAction = "sit"
  pRestingHeight = getLocalFloat(tProps.getProp(#word, 2)) - 1
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  tIsInQueue = integer(tProps.getProp(#word, 3))
  pQueuesWithObj = tIsInQueue
  if pCarrying <> 0 then
    call("action_" & pDrinkEatParams.getAt(#action), [me], pDrinkEatParams.getAt(#action) && pDrinkEatParams.getAt(#params))
  end if
end

on action_lay me, tProps 
  if pDancing then
    me.stop_action_dance()
  end if
  if pCarrying <> 0 then
    me.stop_action_carry()
  end if
  pLayingDown = 1
  pSitting = 0
  pMainAction = "lay"
  pCarrying = 0
  tRestingHeight = getLocalFloat(tProps.getProp(#word, 2))
  if tRestingHeight < 0 then
    pRestingHeight = abs(tRestingHeight) - 1
    tZOffset = 0
  else
    pRestingHeight = tRestingHeight - 1
    tZOffset = 2000
  end if
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  if pXFactor < 33 then
    if pFlipList.getAt(pDirection + 1) = 2 then
      pScreenLoc = pScreenLoc + [-10, 18, tZOffset]
    else
      if pFlipList.getAt(pDirection + 1) = 0 then
        pScreenLoc = pScreenLoc + [-17, 18, tZOffset]
      end if
    end if
  else
    if pFlipList.getAt(pDirection + 1) = 2 then
      pScreenLoc = pScreenLoc + [10, 30, tZOffset]
    else
      if pFlipList.getAt(pDirection + 1) = 0 then
        pScreenLoc = pScreenLoc + [-47, 32, tZOffset]
      end if
    end if
  end if
  if pXFactor > 32 then
    pLocFix = point(30, -10)
  else
    pLocFix = point(35, -5)
  end if
  me.definePartListAction(pPartListFull, "lay")
  if pDirection = 0 then
    pDirection = 4
    pHeadDir = 4
  end if
  call(#defineDir, pPartList, pDirection)
end

on carryObject me, tProps, tDefaultItem, tDefaultItemPublic 
  tItem = tProps.getProp(#word, 2)
  tItemInt = integer(tItem)
  tItemString = string(tItem)
  tIsInteger = string(tItemInt) = tItemString
  if tIsInteger and tItemInt > 0 then
    tItem = tItemInt
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, string(tDefaultItem))
    else
      tCarryItm = string(tDefaultItem)
    end if
    me.definePartListAction(pPartListSubSet.getAt("handRight"), "crr")
    call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    pCarrying = getText("handitem" & tCarrying)
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

on stop_action_carry me, tProps 
  pCarrying = 0
  repeat while pDrinkEatTimeoutList <= undefined
    tName = getAt(undefined, tProps)
    timeout(tName).forget()
  end repeat
  pDrinkEatTimeoutList = []
  if not me.pFx then
    me.resetAction()
  end if
  me.definePartListAction(pPartListSubSet.getAt("handRight"), "std")
  call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), "std")
  me.arrangeParts()
  pChanges = 1
  me.render(1)
end

on stop_action_carryd me, tProps 
  me.stop_action_carry(tProps)
end

on stop_action_carryf me, tProps 
  me.stop_action_carry(tProps)
end

on stop_action_cri me, tProps 
  me.stop_action_carry(tProps)
end

on useObject me, tProps, tDefaultItem, tDefaultItemPublic 
  tItem = tProps.getProp(#word, 2)
  tItemInt = integer(tItem)
  tItemString = string(tItem)
  tIsInteger = string(tItemInt) = tItemString
  if tIsInteger and tItemInt > 0 then
    tItem = tItemInt
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
    me.arrangeParts()
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = string(tDefaultItemPublic)
      me.definePartListAction(pPartListSubSet.getAt("handRight"), "drk")
      call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
      pRightHandUp = 1
      me.arrangeParts()
    end if
  end if
end

on action_usei me, tProps 
  if not me.pFx then
    me.useObject(tProps, "1", "1")
  end if
end

on stop_action_usei me, tProps 
  if not me.pFx then
    me.resetAction()
  end if
  pChanges = 1
  me.render(1)
end

on action_drink me, tProps 
  if not me.pFx then
    me.useObject(tProps, "1", "1")
  end if
end

on action_eat me, tProps 
  if not me.pFx then
    me.useObject(tProps, "1", "4")
  end if
end

on action_talk me, tProps 
  if pPeopleSize = "sh" then
    if pMainAction = "lay" then
      pTalking = 0
      return(0)
    end if
  end if
  pTalking = 1
end

on stop_action_talk me, tProps 
  pTalking = 0
  if pMainAction = "lay" then
    me.definePartListAction(pPartListSubSet.getAt("head"), "lay")
  else
    me.definePartListAction(pPartListSubSet.getAt("head"), "std")
  end if
  pChanges = 1
  me.render(1)
end

on action_gest me, tProps 
  if pPeopleSize = "sh" then
    return(0)
  end if
  tGesture = tProps.getProp(#word, 2)
  if tGesture = "spr" then
    tGesture = "srp"
  end if
  if pMainAction = "lay" then
    tGesture = "l" & tGesture.getProp(#char, 1, 2)
    me.definePartListAction(pPartListSubSet.getAt("gesture"), tGesture)
  else
    me.definePartListAction(pPartListSubSet.getAt("gesture"), tGesture)
    if tGesture = "ohd" then
      me.definePartListAction(pPartListSubSet.getAt("head"), "ohd")
    end if
  end if
  pGesture = tGesture
  pChanges = 1
  me.render(1)
end

on stop_action_gest me, tProps 
  me.action_gest("gest std")
  pGesture = 0
end

on action_wave me, tProps 
  pWaving = 1
  pLeftHandUp = 1
  timeout("wavetimeout" & me.getID()).new(2000, #stop_action_wave, me)
  me.stopAnimation()
end

on stop_action_wave me 
  timeout("wavetimeout" & me.getID()).forget()
  pWaving = 0
  pLeftHandUp = 0
  if not me.pAnimating then
    me.definePartListAction(pPartListSubSet.getAt("handLeft"), pMainAction)
  end if
  pChanges = 1
end

on action_dance me, tProps 
  if not me.allowDancing() then
    return(1)
  end if
  me.clearEffects()
  tStyleNum = tProps.getProp(#word, 2)
  pDancing = integer(tStyleNum)
  if pDancing = void() then
    pDancing = 1
  end if
  tStyle = "dance." & pDancing
  if tStyleNum <> "0" then
    me.stop_action_carry("")
    me.stop_action_wave()
    me.startAnimation(tStyle)
  else
    me.stopAnimation()
    pDancing = 0
    me.resetAction()
    pChanges = 1
    me.render(1)
  end if
  executeMessage(#updateInfostandAvatar)
end

on allowDancing me 
  if pMainAction = "lay" then
    return(0)
  end if
  if pMainAction = "sit" then
    return(0)
  end if
  return(1)
end

on stop_action_dance me, tProps 
  me.action_dance("dance 0")
  me.resetAction()
  pChanges = 1
end

on action_ohd me 
  if not me.pFx then
    me.definePartListAction(pPartListSubSet.getAt("head"), "ohd")
    me.definePartListAction(pPartListSubSet.getAt("handRight"), "ohd")
  end if
end

on action_trd me 
  pTrading = 1
end

on action_sleep me, tSleep 
  pSleeping = tSleep
end

on action_flatctrl me, tProps 
  pCtrlType = tProps.getProp(#word, 2)
end

on action_mod me, tProps 
  pModState = tProps.getProp(#word, 2)
end

on action_sign me, props 
  if not me.pFx then
    tSignMem = "sign" & props.getProp(#word, 2)
    if getmemnum(tSignMem) = 0 then
      return(0)
    end if
    me.definePartListAction(pPartListSubSet.getAt("handLeft"), "sig")
    tSignObjID = "SIGN_EXTRA"
    pExtraObjsActive.setaProp(tSignObjID, 1)
    if voidp(pExtraObjs.getAt(tSignObjID)) then
      pExtraObjs.addProp(tSignObjID, createObject(#temp, "HumanExtra Sign Class"))
    end if
    call(#show_sign, pExtraObjs, ["sprite":pSprite, "direction":pDirection, "signmember":tSignMem])
    pLeftHandUp = 1
  end if
end

on action_joingame me, tProps 
  if tProps.count(#word) < 3 then
    return(0)
  end if
  tSignObjID = "IG_ICON"
  pExtraObjsActive.setaProp(tSignObjID, 1)
  if tProps.length = string("joingame").length then
    pExtraObjsActive.setaProp(tSignObjID, 0)
    return()
  end if
  if pExtraObjs.findPos(tSignObjID) = 0 then
    tObject = createObject(#temp, "IG HumanIcon Class")
    if tObject = 0 then
      return(0)
    end if
    pExtraObjs.setaProp(tSignObjID, tObject)
  end if
  call(#show_ig_icon, pExtraObjs, ["userid":me.getID(), "gameid":tProps.getProp(#word, 2), "gametype":tProps.getProp(#word, 3), "locz":pSprite.locZ])
end

on action_fx me, tProps 
  me.pPersistedFX = 0
  if tProps = void() then
    return(0)
  end if
  if tProps.length < 4 then
    return(0)
  end if
  tID = integer(tProps.getProp(#char, 4, tProps.length))
  tManager = me.getEffectManager()
  if tManager = 0 then
    return(0)
  end if
  if tID = 0 then
    me.clearEffects()
    me.pFx = tID
    me.pPersistedFX = 0
    executeMessage(#updateInfostandAvatar)
    return(1)
  end if
  if tManager.effectExists(tID) then
    return(1)
  end if
  me.clearEffects()
  if not tManager.constructEffect(me, tID) then
    return(error(me, "Can not construct effect:" && tID, #action_fx, #minor))
  end if
  me.pFx = tID
  executeMessage(#updateInfostandAvatar)
  return(1)
end

on persist_fx me, ttype 
  me.pPersistedFX = ttype
end

on handle_user_carry_object me, tItemType, tItemName 
  tAction = "carryd"
  if tItemType = 20 then
    tAction = "cri"
  end if
  if tItemType = 101 then
    tAction = "carryf"
  end if
  tParams = string(tItemType)
  if tItemType = 100 or tItemType = 101 then
    tParams = tItemName
  end if
  call("action_" & tAction, [me], tAction && tParams)
  pChanges = 1
  me.render(1)
  pCarryItemCode = tItemType
  if tItemType = 0 or tItemType = 20 then
    pDrinkEatParams = [:]
    return()
  end if
  tHandler = #execute_drink
  if tItemType = 101 then
    tHandler = #execute_eat
  end if
  pDrinkEatParams = [#params:tParams, #action:tAction]
  i = 1
  repeat while i <= 10
    tID = getUniqueID()
    timeout(tID).new(((i * 10) * 1000), tHandler, me)
    pDrinkEatTimeoutList.add(tID)
    i = 1 + i
  end repeat
  tID = getUniqueID()
  timeout(tID).new(((10 * 10) * 1000) + 1000, #stop_action_carry, me)
  pDrinkEatTimeoutList.add(tID)
end

on execute_eat me, tTimeout 
  pDrinkEatTimeoutList.deleteOne(tTimeout.name)
  timeout(tTimeout.name).forget()
  me.action_eat("eat " & pDrinkEatParams.getAt(#params))
  pChanges = 1
  me.render(1)
  tID = getUniqueID()
  timeout(tID).new(500, #execute_continue_carry, me)
  pDrinkEatTimeoutList.add(tID)
end

on execute_drink me, tTimeout 
  pDrinkEatTimeoutList.deleteOne(tTimeout.name)
  timeout(tTimeout.name).forget()
  me.action_drink("drink " & pDrinkEatParams.getAt(#params))
  pChanges = 1
  me.render(1)
  tID = getUniqueID()
  timeout(tID).new(500, #execute_continue_carry, me)
  pDrinkEatTimeoutList.add(tID)
end

on execute_continue_carry me, tTimeout 
  pDrinkEatTimeoutList.deleteOne(tTimeout.name)
  timeout(tTimeout.name).forget()
  call("action_" & pDrinkEatParams.getAt(#action), [me], pDrinkEatParams.getAt(#action) && pDrinkEatParams.getAt(#params))
  pChanges = 1
  me.render(1)
end

on handle_user_use_object me, tItemType 
  if tItemType <> 0 then
    me.action_usei("usei " & tItemType)
  else
    me.stop_action_usei("")
  end if
end

on validateFxForActionList me, tActionDefs, tActionIndex 
  if ilk(tActionDefs) <> #list then
    return(0)
  end if
  if ilk(tActionIndex) <> #list then
    return(0)
  end if
  tEffectID = void()
  if pFx <> 0 then
    tEffectID = pFx
  end if
  tActions = []
  repeat while tActionDefs <= tActionIndex
    tAction = getAt(tActionIndex, tActionDefs)
    if ilk(tAction) = #propList then
      if tAction.getaProp(#name) = "fx" then
        tEffectID = tAction.getaProp(#params).getProp(#word, 2)
      else
        tActions.add(tAction.getaProp(#name))
      end if
    end if
  end repeat
  if pDrinkEatParams.ilk = #propList then
    if pCarrying <> 0 then
      tActions.add(pDrinkEatParams.getAt(#action))
    end if
  end if
  if pSitting <> 0 then
    tActions.add("sit")
  end if
  if pLayingDown <> 0 then
    tActions.add("lay")
  end if
  if pDancing <> 0 then
    tActions.add("dance")
  end if
  if tEffectID = void() then
    if pFx then
      me.clearEffects()
    end if
    return(0)
  end if
  tVarName = "fx.blacklist." & tEffectID
  if not variableExists(tVarName) then
    return(1)
  end if
  tBlackList = getVariableValue(tVarName)
  if ilk(tBlackList) <> #list then
    return(1)
  end if
  if variableExists("fx.whitelist." & tEffectID) then
    tWhiteList = getVariableValue("fx.whitelist." & tEffectID)
  end if
  if ilk(tWhiteList) <> #list then
    tWhiteList = []
  end if
  tAllow = 1
  tRemovedActions = []
  repeat while tActionDefs <= tActionIndex
    tAction = getAt(tActionIndex, tActionDefs)
    if tBlackList.getOne(tAction) then
      if tWhiteList.getOne(tAction) then
        tRemovedActions.add(tAction)
        call("stop_action_" & tAction, [me], "")
      else
        if pFx then
          me.clearEffects(1)
        end if
        tAllow = 0
      end if
    end if
  end repeat
  tNumAction = tActionDefs.count
  repeat while tNumAction >= 1
    tAction = tActionDefs.getAt(tNumAction)
    if ilk(tAction) <> #propList then
    else
      if tRemovedActions.getOne(tAction.getAt(#name)) then
        tActionDefs.deleteAt(tNumAction)
        tPos = tActionIndex.getPos(tAction.getAt(#name))
        if tPos > 0 then
          tActionIndex.deleteAt(tPos)
        end if
      end if
    end if
    tNumAction = 255 + tNumAction
  end repeat
  if pCarrying <> 0 then
    tActions.deleteOne(pDrinkEatParams.getAt(#action))
  end if
  if pSitting <> 0 then
    tActions.deleteOne("sit")
  end if
  if pLayingDown <> 0 then
    tActions.deleteOne("lay")
  end if
  if pDancing <> 0 then
    tActions.deleteOne("dance")
  end if
  return(tAllow)
end

on validateCarryForCurrentState me 
  tEffectID = void()
  if pFx <> 0 then
    tEffectID = pFx
  else
    return(1)
  end if
  tVarName = "fx.blacklist." & tEffectID
  if not variableExists(tVarName) then
    return(1)
  end if
  tBlackList = getVariableValue(tVarName)
  if ilk(tBlackList) <> #list then
    return(1)
  end if
  if tBlackList.getPos("carryd") or tBlackList.getPos("carryf") or tBlackList.getPos("cri") then
    return(0)
  else
    return(1)
  end if
end

on getEffectDirOffset me 
  if pFXManager = 0 then
    return(0)
  end if
  return(pFXManager.getEffectDirOffset())
end

on getEffectShadowName me 
  if pFXManager = 0 then
    return([])
  end if
  return(pFXManager.getEffectShadowName())
end

on getEffectSpriteProps me 
  if pFXManager = 0 then
    return([])
  end if
  return(pFXManager.getEffectSpriteProps())
end

on getEffectAddedPartIndex me 
  if pFXManager = 0 then
    return([])
  end if
  return(pFXManager.getEffectAddedPartIndex())
end

on getEffectExcludedPartIndex me 
  if pFXManager = 0 then
    return([])
  end if
  return(pFXManager.getEffectExcludedPartIndex())
end

on updateEffects me 
  if pFXManager = 0 then
    return(1)
  end if
  pFXManager.updateEffects(me)
end

on clearEffects me, tTemp 
  if tTemp <> 0 then
    me.pPersistedFX = me.pFx
  end if
  if pFXManager <> 0 then
    pFXManager.clearEffects(me)
  end if
  me.pFx = 0
  me.pChanges = 1
  return(1)
end

on getCurrentEffectState me 
  if pFXManager = 0 then
    return(void())
  end if
  return(pFXManager.getCurrentEffectState())
end

on getEffectManager me 
  if objectp(pFXManager) then
    return(pFXManager)
  end if
  pFXManager = createObject(#temp, "Avatar Effect Manager")
  return(pFXManager)
end
