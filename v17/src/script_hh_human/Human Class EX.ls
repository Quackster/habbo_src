on construct(me)
  pID = 0
  pWebID = void()
  pName = ""
  pPartList = []
  pPartIndex = []
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
  pColors = []
  pModState = 0
  pExtraObjs = []
  pDefShadowMem = member(0)
  pInfoStruct = []
  pQueuesWithObj = 0
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
  pPartOrderOld = ""
  tSubSetList = ["head", "speak", "gesture", "eye", "handRight", "handLeft", "walk", "sit", "itemRight"]
  pPartListSubSet = []
  repeat while me <= undefined
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
  me.resetAction()
  return(1)
  exit
end

on deconstruct(me)
  pGeometry = void()
  pPartList = []
  pInfoStruct = []
  if not voidp(pSprite) then
    releaseSprite(pSprite.spriteNum)
  end if
  if not voidp(pMatteSpr) then
    releaseSprite(pMatteSpr.spriteNum)
  end if
  if not voidp(pShadowSpr) then
    releaseSprite(pShadowSpr.spriteNum)
  end if
  if memberExists(me.getCanvasName()) then
    removeMember(me.getCanvasName())
  end if
  call(#deconstruct, pExtraObjs)
  pExtraObjs = void()
  pShadowSpr = void()
  pMatteSpr = void()
  pSprite = void()
  return(1)
  exit
end

on define(me, tdata)
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
  pSprite.ink = 36
  pMatteSpr = sprite(reserveSprite(me.getID()))
  pMatteSpr.castNum = pMember.number
  pMatteSpr.ink = 8
  pMatteSpr.blend = 0
  pShadowSpr = sprite(reserveSprite(me.getID()))
  pShadowSpr.blend = 16
  pShadowSpr.ink = 8
  pShadowFix = 0
  pDefShadowMem = member(getmemnum(pPeopleSize & "_std_sd_001_0_0"))
  tTargetID = getThread(#room).getInterface().getID()
  setEventBroker(pMatteSpr.spriteNum, me.getID())
  pMatteSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseEnter)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseLeave)
  setEventBroker(pShadowSpr.spriteNum, me.getID())
  pShadowSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
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
        if not tPart = 0 then
          pBaseLocZ = tPart.getAt(#locZ) - 1000
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on changeFigureAndData(me, tdata)
  pSex = tdata.getAt(#sex)
  pCustom = tdata.getAt(#custom)
  tmodels = tdata.getAt(#figure)
  me.setPartLists(tmodels)
  pPartOrderOld = ""
  me.arrangeParts()
  pChanges = 1
  me.render(1)
  me.reDraw()
  pInfoStruct.setAt(#image, me.getPicture())
  exit
end

on setup(me, tdata)
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
  pGroupId = tdata.getAt(#groupid)
  pStatusInGroup = tdata.getAt(#groupstatus)
  if not voidp(tdata.getaProp(#webID)) then
    pWebID = tdata.getAt(#webID)
  end if
  pPeopleSize = getVariable("human.size." & integer(pXFactor))
  if not pPeopleSize then
    error(me, "People size not found, using default!", #setup, #minor)
    pPeopleSize = "h"
  end if
  pCorrectLocZ = pPeopleSize = "h"
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
  exit
end

on update(me)
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
  exit
end

on resetValues(me, tX, tY, tH, tDirHead, tDirBody)
  if pQueuesWithObj and pPreviousLoc = [tX, tY, tH] then
    return(1)
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
  exit
end

on Refresh(me, tX, tY, tH)
  if pQueuesWithObj and pPreviousLoc = [tX, tY, tH] then
    return(1)
  end if
  if pDancing > 0 or pMainAction = "lay" then
    pHeadDir = pDirection
  end if
  call(#defineDir, pPartList, pDirection)
  call(#defineDirMultiple, pPartList, pHeadDir, pPartListSubSet.getAt("head"))
  me.arrangeParts()
  pChanges = 1
  exit
end

on select(me)
  return(1)
  exit
end

on getName(me)
  return(pName)
  exit
end

on getClass(me)
  return("user")
  exit
end

on setPartModel(me, tPart, tmodel)
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  pPartList.getAt(pPartIndex.getAt(tPart)).setModel(tmodel)
  exit
end

on setPartColor(me, tPart, tColor)
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  pPartList.getAt(pPartIndex.getAt(tPart)).setColor(tColor)
  exit
end

on getCustom(me)
  return(pCustom)
  exit
end

on getLocation(me)
  return([pLocX, pLocY, pLocH])
  exit
end

on getScrLocation(me)
  return(pScreenLoc)
  exit
end

on getTileCenter(me)
  return(point(pScreenLoc.getAt(1) + pXFactor / 2, pScreenLoc.getAt(2)))
  exit
end

on getPartLocation(me, tPart)
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  tPartLoc = pPartList.getAt(pPartIndex.getAt(tPart)).getLocation()
  if pMainAction <> "lay" then
    tloc = pSprite.loc + tPartLoc
  else
    tloc = point(pSprite.getProp(#rect, 1) + pSprite.width / 2, pSprite.getProp(#rect, 2) + pSprite.height / 2)
  end if
  return(tloc)
  exit
end

on getDirection(me)
  return(pDirection)
  exit
end

on getPartMember(me, tPart)
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  return(pPartList.getAt(pPartIndex.getAt(tPart)).getCurrentMember())
  exit
end

on getPartColor(me, tPart)
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  return(pPartList.getAt(pPartIndex.getAt(tPart)).getColor())
  exit
end

on getPicture(me, tImg)
  return(me.getPartialPicture(#Full, tImg, 4, "h"))
  exit
end

on getPartialPicture(me, tPartList, tImg, tDirection, tPeopleSize)
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
  repeat while me <= tImg
    tPartSymbol = getAt(tImg, tPartList)
    if not voidp(pPartIndex.getAt(tPartSymbol)) then
      if tPartList.findPos(tPartSymbol) > 0 then
        tTempPartList.append(pPartList.getAt(pPartIndex.getAt(tPartSymbol)))
      end if
    end if
  end repeat
  call(#copyPicture, tTempPartList, tCanvas, tDirection, tPeopleSize)
  return(tCanvas)
  exit
end

on getInfo(me)
  if pCtrlType = "" then
    pInfoStruct.setAt(#ctrl, "furniture")
  else
    pInfoStruct.setAt(#ctrl, pCtrlType)
  end if
  pInfoStruct.setAt(#badge, me.pBadge)
  pInfoStruct.setAt(#groupid, me.pGroupId)
  if pTrading then
    pInfoStruct.setAt(#custom, pCustom & "\r" & getText("human_trading", "Trading"))
  else
    if pCarrying <> 0 then
      pInfoStruct.setAt(#custom, pCustom & "\r" & getText("human_carrying", "Carrying:") && pCarrying)
    else
      pInfoStruct.setAt(#custom, pCustom)
    end if
  end if
  return(pInfoStruct)
  exit
end

on getWebID(me)
  return(pWebID)
  exit
end

on getSprites(me)
  return([pSprite, pShadowSpr, pMatteSpr])
  exit
end

on getProperty(me, tPropID)
  if me = #dancing then
    return(pDancing)
  else
    if me = #carrying then
      return(pCarrying)
    else
      if me = #loc then
        return([pLocX, pLocY, pLocH])
      else
        if me = #mainAction then
          return(pMainAction)
        else
          if me = #moving then
            return(me.pMoving)
          else
            if me = #badge then
              return(me.pBadge)
            else
              if me = #swimming then
                return(me.pSwim)
              else
                if me = #groupid then
                  return(pGroupId)
                else
                  if me = #groupstatus then
                    return(pStatusInGroup)
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
  exit
end

on setProperty(me, tPropID, tValue)
  if me = #groupid then
    pGroupId = tValue
  else
    if me = #groupstatus then
      pStatusInGroup = tValue
    else
      return(0)
    end if
  end if
  exit
end

on getPartCarrying(me, tPart)
  if pPartListSubSet.getAt("handRight").findPos(tPart) and me.getProperty(#carrying) then
    return(1)
  end if
  return(0)
  exit
end

on isInSwimsuit(me)
  return(0)
  exit
end

on closeEyes(me)
  if pMainAction = "lay" then
    me.definePartListAction(pPartListSubSet.getAt("eye"), "ley")
  else
    me.definePartListAction(pPartListSubSet.getAt("eye"), "eyb")
  end if
  pEyesClosed = 1
  pChanges = 1
  exit
end

on openEyes(me)
  if pMainAction = "lay" then
    me.definePartListAction(pPartListSubSet.getAt("eye"), "lay")
  else
    me.definePartListAction(pPartListSubSet.getAt("eye"), "std")
  end if
  pEyesClosed = 0
  pChanges = 1
  exit
end

on startAnimation(me, tMemName)
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
    tPart = tList.getPropRef(#line, i).getProp(#item, 1)
    tAnim = tList.getPropRef(#line, i).getProp(#item, 2)
    call(#setAnimation, pPartList, tPart, tAnim)
    i = 1 + i
  end repeat
  the itemDelimiter = tTempDelim
  pAnimating = 1
  pCurrentAnim = tMemName
  exit
end

on stopAnimation(me)
  pAnimating = 0
  pCurrentAnim = ""
  call(#remAnimation, pPartList)
  exit
end

on resumeAnimation(me)
  tMemName = pCurrentAnim
  pCurrentAnim = ""
  me.startAnimation(tMemName)
  exit
end

on show(me)
  pSprite.visible = 1
  pMatteSpr.visible = 1
  pShadowSpr.visible = 1
  exit
end

on hide(me)
  pSprite.visible = 0
  pMatteSpr.visible = 0
  pShadowSpr.visible = 0
  exit
end

on draw(me, tRGB)
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  pMember.draw(image.rect, [#shapeType:#rect, #color:tRGB])
  exit
end

on prepare(me)
  pAnimCounter = pAnimCounter + 1 mod 4
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
  end if
  if pMoving then
    tFactor = float(the milliSeconds - pMoveStart) / pMoveTime
    if tFactor > 0 then
      tFactor = 0
    end if
    pScreenLoc = pDestLScreen - pStartLScreen * tFactor + pStartLScreen
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
  exit
end

on render(me, tForceUpdate)
  if not pChanges then
    return()
  end if
  if pPeopleSize = "sh" then
    tSkipFreq = 4
  else
    tSkipFreq = 5
  end if
  if random(tSkipFreq) = 2 and not pMoving and not tForceUpdate then
    call(#skipAnimationFrame, pPartList)
    return(1)
  end if
  pChanges = 0
  if pCanvasSize.findPos(pMainAction) then
    tSize = pCanvasSize.getaProp(pMainAction)
  else
    tSize = pCanvasSize.getaProp(#std)
  end if
  if pMainAction = "sit" then
    pShadowSpr.castNum = getmemnum(pPeopleSize & "_sit_sd_001_" & pFlipList.getAt(pDirection + 1) & "_0")
  else
    if pMainAction = "lay" then
      pShadowSpr.castNum = 0
      pShadowFix = 0
    else
      if pShadowSpr.member <> pDefShadowMem then
        pShadowSpr.member = pDefShadowMem
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
    pShadowSpr.flipH = 0
  end if
  if pCorrectLocZ then
    tOffZ = pLocH + pRestingHeight * 1000 + 2
  else
    tOffZ = 2
  end if
  pSprite.locH = pScreenLoc.getAt(1)
  pSprite.locV = pScreenLoc.getAt(2)
  pMatteSpr.loc = pSprite.loc
  pShadowSpr.loc = pSprite.loc + [pShadowFix, 0]
  if pBaseLocZ <> 0 then
    pSprite.locZ = pBaseLocZ
  else
    pSprite.locZ = pScreenLoc.getAt(3) + tOffZ + pBaseLocZ
  end if
  pMatteSpr.locZ = pSprite.locZ + 1
  pShadowSpr.locZ = pSprite.locZ - 3
  pUpdateRect = rect(0, 0, 0, 0)
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#update, pPartList)
  image.copyPixels(pBuffer, pUpdateRect, pUpdateRect)
  exit
end

on reDraw(me)
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#render, pPartList)
  image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
  exit
end

on getClearedFigurePartList(me, tmodels)
  return(me.getSpecificClearedFigurePartList(tmodels, "human.parts"))
  exit
end

on getSpecificClearedFigurePartList(me, tmodels, tListName)
  tPartList = getVariableValue(tListName & "." & pPeopleSize)
  if tPartList.ilk <> #list then
    return([])
  end if
  if not objectExists("Figure_System") then
    error("No figure system!", me.getID, #getSpecificClearedFigurePartList, #critical)
    return(tPartList)
  end if
  tFigureSystem = getObject("Figure_System")
  repeat while me <= tListName
    tmodel = getAt(tListName, tmodels)
    tSetID = tmodel.getAt("setid")
    tsex = pSex
    if voidp(pSex) then
      tsex = "M"
    end if
    tPreventedParts = tFigureSystem.getPreventedPartsBySetID(tsex, tSetID)
    if tPreventedParts.count > 0 then
      repeat while me <= tListName
        tPart = getAt(tListName, tmodels)
        if tPartList.getOne(tPart) then
          tPartList.deleteOne(tPart)
        end if
      end repeat
    end if
  end repeat
  return(tPartList)
  exit
end

on setPartLists(me, tmodels)
  tPartDefinition = me.getClearedFigurePartList(tmodels)
  tCurrentPartList = []
  i = pPartList.count
  repeat while i >= 1
    tPartObj = pPartList.getAt(i)
    tPartType = tPartObj.pPart
    if tPartDefinition.findPos(tPartType) = 0 and pPartListFull.findPos(tPartType) then
      pPartList.deleteAt(i)
    else
      tCurrentPartList.addProp(tPartType, tPartObj)
    end if
    i = 255 + i
  end repeat
  if me.getProperty(#carrying) <> 0 then
    if pPartListSubSet.getAt("itemRight").count > 0 then
      tRightItem = pPartListSubSet.getAt("itemRight").getAt(1)
      tItemObject = tCurrentPartList.getAt(tRightItem)
      if voidp(tmodels.getAt(tRightItem)) and not voidp(tItemObject) then
        tmodels.setAt(tRightItem, ["model":tItemObject.getModel(), "color":tItemObject.getColor()])
      end if
    end if
  end if
  pPartIndex = []
  pColors = []
  tFlipList = getVariable("human.parts.flipList")
  if ilk(tFlipList) <> #propList then
    tFlipList = []
  end if
  tAnimationList = getVariable("human.parts.animationList")
  if ilk(tAnimationList) <> #propList then
    tAnimationList = []
  end if
  i = 1
  repeat while i <= tPartDefinition.count
    tPartSymbol = tPartDefinition.getAt(i)
    if voidp(tmodels.getAt(tPartSymbol)) then
      tmodels.setAt(tPartSymbol, [])
    end if
    if voidp(tmodels.getAt(tPartSymbol).getAt("model")) then
      tmodels.getAt(tPartSymbol).setAt("model", "000")
    end if
    if voidp(tmodels.getAt(tPartSymbol).getAt("color")) then
      tmodels.getAt(tPartSymbol).setAt("color", rgb("EEEEEE"))
    end if
    if tPartSymbol = "fc" and tmodels.getAt(tPartSymbol).getAt("model") <> "001" and pXFactor < 33 then
      tmodels.getAt(tPartSymbol).setAt("model", "001")
    end if
    if stringp(tmodels.getAt(tPartSymbol).getAt("color")) then
      tColor = value("rgb(" & tmodels.getAt(tPartSymbol).getAt("color") & ")")
    end if
    if tmodels.getAt(tPartSymbol).getAt("color").ilk <> #color then
      tColor = rgb(tmodels.getAt(tPartSymbol).getAt("color"))
    else
      tColor = tmodels.getAt(tPartSymbol).getAt("color")
    end if
    if tColor.red + tColor.green + tColor.blue > 238 * 3 then
      tColor = rgb("EEEEEE")
    end if
    tFlipPart = tFlipList.getAt(tPartSymbol)
    tAction = pPartActionList.getAt(tPartSymbol)
    if voidp(tAction) then
      tAction = "std"
      error(me, "Missing action for part" && tPartSymbol, #setPartLists, #major)
    end if
    if tCurrentPartList.findPos(tPartSymbol) = 0 then
      tPartObj = createObject(#temp, pPartClass)
      tPartObj.define(tPartSymbol, tmodels.getAt(tPartSymbol).getAt("model"), tColor, pDirection, tAction, me, tFlipPart)
      tPartObj.setAnimations(tAnimationList.getAt(tPartSymbol))
      pPartList.add(tPartObj)
    else
      tCurrentPartList.getAt(tPartSymbol).changePartData(tmodels.getAt(tPartSymbol).getAt("model"), tColor)
    end if
    pColors.setaProp(tPartSymbol, tColor)
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= pPartList.count
    pPartIndex.setAt(pPartList.getAt(i).pPart, i)
    i = 1 + i
  end repeat
  return(1)
  exit
end

on arrangeParts(me, tOrderName)
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
  if pWaving then
    tPartOrderWave = tPartOrder & ".wave"
    if variableExists(tPartOrderWave & tDirData) then
      tPartOrder = tPartOrderWave
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
    tTempPartList = []
    repeat while me <= undefined
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
  exit
end

on flipImage(me, tImg_a)
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return(tImg_b)
  exit
end

on getCanvasName(me)
  return(pClass && pName & me.getID() && "Canvas")
  exit
end

on getDefinedPartList(me, tPartNameList)
  tPartList = []
  repeat while me <= undefined
    tPartName = getAt(undefined, tPartNameList)
    if not voidp(pPartIndex.getAt(tPartName)) then
      tPos = pPartIndex.getAt(tPartName)
      tPartList.append(pPartList.getAt(tPos))
    end if
  end repeat
  return(tPartList)
  exit
end

on definePartListAction(me, tPartList, tAction)
  repeat while me <= tAction
    tPart = getAt(tAction, tPartList)
    pPartActionList.setAt(tPart, tAction)
  end repeat
  call(#defineAct, me.getDefinedPartList(tPartList), tAction)
  exit
end

on resetAction(me)
  pMainAction = "std"
  if voidp(pPartActionList) then
    pPartActionList = []
  end if
  if pPartActionList.count = 0 then
    tPartList = getVariableValue("human.parts." & pPeopleSize)
    if tPartList.ilk = #list then
      repeat while me <= undefined
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
  exit
end

on action_mv(me, tProps)
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
  exit
end

on action_sld(me, tProps)
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
  exit
end

on action_sit(me, tProps)
  me.definePartListAction(pPartListSubSet.getAt("sit"), "sit")
  pMainAction = "sit"
  pRestingHeight = getLocalFloat(tProps.getProp(#word, 2)) - 0
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  tIsInQueue = integer(tProps.getProp(#word, 3))
  pQueuesWithObj = tIsInQueue
  exit
end

on action_lay(me, tProps)
  pMainAction = "lay"
  pCarrying = 0
  tRestingHeight = getLocalFloat(tProps.getProp(#word, 2))
  if tRestingHeight < 0 then
    pRestingHeight = abs(tRestingHeight) - 0
    tZOffset = 0
  else
    pRestingHeight = tRestingHeight - 0
    tZOffset = 2000
  end if
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  if pXFactor < 33 then
    if me = 2 then
      pScreenLoc = pScreenLoc + [-10, 18, tZOffset]
    else
      if me = 0 then
        pScreenLoc = pScreenLoc + [-17, 18, tZOffset]
      end if
    end if
  else
    if me = 2 then
      pScreenLoc = pScreenLoc + [10, 30, tZOffset]
    else
      if me = 0 then
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
  exit
end

on action_carryd(me, tProps)
  tItem = tProps.getProp(#word, 2)
  if value(tItem) > 0 then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    me.definePartListAction(pPartListSubSet.getAt("handRight"), "crr")
    call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = "001"
      me.definePartListAction(pPartListSubSet.getAt("handRight"), "crr")
      call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    end if
  end if
  exit
end

on action_cri(me, tProps)
  tItem = tProps.getProp(#word, 2)
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "075")
    else
      tCarryItm = "075"
    end if
    me.definePartListAction(pPartListSubSet.getAt("handRight"), "crr")
    call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      me.definePartListAction(pPartListSubSet.getAt("handRight"), "crr")
      call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    end if
  end if
  exit
end

on action_usei(me, tProps)
  tItem = tProps.getProp(#word, 2)
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
    me.definePartListAction(pPartListSubSet.getAt("handRight"), "drk")
    call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = "001"
      me.definePartListAction(pPartListSubSet.getAt("handRight"), "drk")
      call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    end if
  end if
  exit
end

on action_drink(me, tProps)
  tItem = tProps.getProp(#word, 2)
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
    me.definePartListAction(pPartListSubSet.getAt("handRight"), "drk")
    call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = "001"
      me.definePartListAction(pPartListSubSet.getAt("handRight"), "drk")
      call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    end if
  end if
  exit
end

on action_carryf(me, tProps)
  tItem = tProps.getProp(#word, 2)
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    me.definePartListAction(pPartListSubSet.getAt("handRight"), "crr")
    call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, tItem)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = "004"
      me.definePartListAction(pPartListSubSet.getAt("handRight"), "crr")
      call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    end if
  end if
  exit
end

on action_eat(me, tProps)
  tItem = tProps.getProp(#word, 2)
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
    me.definePartListAction(pPartListSubSet.getAt("handRight"), "drk")
    call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = "004"
      me.definePartListAction(pPartListSubSet.getAt("handRight"), "drk")
      call(#setModel, me.getDefinedPartList(pPartListSubSet.getAt("itemRight")), tCarryItm)
    end if
  end if
  exit
end

on action_talk(me, tProps)
  if pMainAction = "lay" and pXFactor < 33 then
    return(0)
  end if
  pTalking = 1
  exit
end

on action_gest(me, tProps)
  if pPeopleSize = "sh" then
    return()
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
  exit
end

on action_wave(me, tProps)
  pWaving = 1
  exit
end

on action_dance(me, tProps)
  tStyleNum = tProps.getProp(#word, 2)
  pDancing = integer(tStyleNum)
  if pDancing = void() then
    pDancing = 1
  end if
  tStyle = "dance." & pDancing
  me.startAnimation(tStyle)
  exit
end

on action_ohd(me)
  me.definePartListAction(pPartListSubSet.getAt("head"), "ohd")
  me.definePartListAction(pPartListSubSet.getAt("handRight"), "ohd")
  exit
end

on action_trd(me)
  pTrading = 1
  exit
end

on action_sleep(me)
  pSleeping = 1
  exit
end

on action_flatctrl(me, tProps)
  pCtrlType = tProps.getProp(#word, 2)
  exit
end

on action_mod(me, tProps)
  pModState = tProps.getProp(#word, 2)
  exit
end

on action_sign(me, props)
  tSignMem = "sign" & props.getProp(#word, 2)
  if getmemnum(tSignMem) = 0 then
    return(0)
  end if
  me.definePartListAction(pPartListSubSet.getAt("handLeft"), "sig")
  tSignObjID = "SIGN_EXTRA"
  if voidp(pExtraObjs.getAt(tSignObjID)) then
    pExtraObjs.addProp(tSignObjID, createObject(#temp, "HumanExtra Sign Class"))
  end if
  call(#show_sign, pExtraObjs, ["sprite":pSprite, "direction":pDirection, "signmember":tSignMem])
  exit
end