property pGeometry, pSprite, pMatteSpr, pShadowSpr, pClass, pName, pExtraObjs, pCanvasSize, pMember, pPeopleSize, pInfoStruct, pCustom, pDirection, pXFactor, pLocX, pLocY, pLocH, pHeadDir, pQueuesWithObj, pSync, pPreviousLoc, pDancing, pPartList, pFlipList, pPartIndex, pScreenLoc, pMainAction, pCtrlType, pTrading, pCarrying, pCurrentAnim, pAnimCounter, pEyesClosed, pSleeping, pTalking, pMoving, pMoveStart, pMoveTime, pDestLScreen, pStartLScreen, pWaving, pChanges, pDefShadowMem, pBuffer, pCorrectLocZ, pRestingHeight, pShadowFix, pAlphaColor, pUpdateRect, pPartClass, pColors, pLastDir

on construct me 
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
  pBadge = space()
  pCurrentAnim = ""
  pAlphaColor = rgb(255, 255, 255)
  pSync = 1
  pColors = [:]
  pModState = 0
  pExtraObjs = [:]
  pDefShadowMem = member(0)
  pInfoStruct = [:]
  pQueuesWithObj = 0
  pGeometry = getThread(#room).getInterface().getGeometry()
  pXFactor = pGeometry.pXFactor
  pYFactor = pGeometry.pYFactor
  pHFactor = pGeometry.pHFactor
  pCorrectLocZ = 0
  pPartClass = value(getThread(#room).getComponent().getClassContainer().get("bodypart"))
  return TRUE
end

on deconstruct me 
  pGeometry = void()
  pPartList = []
  pInfoStruct = [:]
  releaseSprite(pSprite.spriteNum)
  releaseSprite(pMatteSpr.spriteNum)
  releaseSprite(pShadowSpr.spriteNum)
  if memberExists(pClass && pName && "Canvas") then
    removeMember(pClass && pName && "Canvas")
  end if
  call(#deconstruct, pExtraObjs)
  pExtraObjs = void()
  pShadowSpr = void()
  pMatteSpr = void()
  pSprite = void()
  return TRUE
end

on define me, tdata 
  me.setup(tdata)
  if not memberExists(pClass && pName && "Canvas") then
    createMember(pClass && pName && "Canvas", #bitmap)
  end if
  tSize = pCanvasSize.getAt(#std)
  pMember = member(getmemnum(pClass && pName && "Canvas"))
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
  return TRUE
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
  pPeopleSize = getVariable("human.size." & integer(pXFactor))
  if not pPeopleSize then
    error(me, "People size not found, using default!", #setup)
    pPeopleSize = "h"
  end if
  pCorrectLocZ = (pPeopleSize = "h")
  pCanvasSize = value(getVariable("human.canvas." & pPeopleSize))
  if not pCanvasSize then
    error(me, "Canvas size not found, using default!", #setup)
    pCanvasSize = [#std:[64, 102, 32, -10], #lay:[89, 102, 32, -8]]
  end if
  tPartSymbols = tdata.getAt(#parts)
  if not me.setPartLists(tdata.getAt(#figure)) then
    return(error(me, "Couldn't create part lists!", #setup))
  end if
  me.arrangeParts()
  me.refresh(pLocX, pLocY, pLocH, pDirection, pHeadDir)
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

on refresh me, tX, tY, tH, tDirHead, tDirBody 
  if pQueuesWithObj and (pPreviousLoc = [tX, tY, tH]) then
    return TRUE
  end if
  if pDancing then
    tDirHead = tDirBody
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
  pLocFix = point(-1, 2)
  call(#reset, pPartList)
  pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH)
  pMainAction = "std"
  pLocX = tX
  pLocY = tY
  pLocH = tH
  pRestingHeight = 0
  if tDirBody <> pFlipList.getAt((tDirBody + 1)) then
    if tDirBody <> tDirHead then
      if (tDirHead = 4) then
        tDirHead = 2
      else
        if (tDirHead = 5) then
          tDirHead = 1
        else
          if (tDirHead = 6) then
            tDirHead = 4
          else
            if (tDirHead = 7) then
              tDirHead = 5
            end if
          end if
        end if
      end if
    end if
  end if
  call(#defineDir, pPartList, tDirBody)
  call(#defineDirMultiple, pPartList, tDirHead, ["hd", "hr", "ey", "fc"])
  pDirection = tDirBody
  pHeadDir = tDirHead
  me.arrangeParts()
  if pExtraObjs.count > 0 then
    call(#refresh, pExtraObjs)
  end if
  pQueuesWithObj = 0
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

on setPartModel me, tPart, tmodel 
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  pPartList.getAt(pPartIndex.getAt(tPart)).setModel(tmodel)
end

on setPartColor me, tPart, tColor 
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  pPartList.getAt(pPartIndex.getAt(tPart)).setColor(tColor)
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

on getPartMember me, tPart 
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  return(pPartList.getAt(pPartIndex.getAt(tPart)).getCurrentMember())
end

on getPartColor me, tPart 
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  return(pPartList.getAt(pPartIndex.getAt(tPart)).getColor())
end

on getPicture me, tImg 
  if voidp(tImg) then
    tCanvas = image(64, 102, 32)
  else
    tCanvas = tImg
  end if
  tPartDefinition = getVariableValue("human.parts." & pPeopleSize)
  tTempPartList = []
  repeat while tPartDefinition <= undefined
    tPartSymbol = getAt(undefined, tImg)
    if not voidp(pPartIndex.getAt(tPartSymbol)) then
      tTempPartList.append(pPartList.getAt(pPartIndex.getAt(tPartSymbol)))
    end if
  end repeat
  call(#copyPicture, tTempPartList, tCanvas)
  return(me.flipImage(tCanvas))
end

on getInfo me 
  if (pCtrlType = "") then
    pInfoStruct.setAt(#ctrl, "furniture")
  else
    pInfoStruct.setAt(#ctrl, pCtrlType)
  end if
  pInfoStruct.setAt(#badge, me.pBadge)
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
end

on getSprites me 
  return([pSprite, pShadowSpr, pMatteSpr])
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
        return FALSE
      end if
    end if
  end if
end

on setProperty me, tPropID, tValue 
  return FALSE
end

on closeEyes me 
  if (pMainAction = "lay") then
    call(#defineActMultiple, pPartList, "ley", ["ey"])
  else
    call(#defineActMultiple, pPartList, "eyb", ["ey"])
  end if
  pEyesClosed = 1
  pChanges = 1
end

on openEyes me 
  if (pMainAction = "lay") then
    call(#defineActMultiple, pPartList, "lay", ["ey"])
  else
    call(#defineActMultiple, pPartList, "std", ["ey"])
  end if
  pEyesClosed = 0
  pChanges = 1
end

on startAnimation me, tMemName 
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

on show me 
  pSprite.visible = 1
  pMatteSpr.visible = 1
  pShadowSpr.visible = 1
end

on hide me 
  pSprite.visible = 0
  pMatteSpr.visible = 0
  pShadowSpr.visible = 0
end

on draw me, tRGB 
  if not ilk(tRGB, #color) then
    tRGB = rgb(255, 0, 0)
  end if
  pMember.image.draw(pMember.image.rect, [#shapeType:#rect, #color:tRGB])
end

on prepare me 
  pAnimCounter = ((pAnimCounter + 1) mod 4)
  if pEyesClosed and not pSleeping then
    me.openEyes()
  else
    if (random(30) = 3) then
      me.closeEyes()
    end if
  end if
  if pTalking and random(3) > 1 then
    if (pMainAction = "lay") then
      call(#defineActMultiple, pPartList, "lsp", ["hd", "hr", "fc"])
    else
      call(#defineActMultiple, pPartList, "spk", ["hd", "hr", "fc"])
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
    call(#doHandWorkLeft, pPartList, "wav")
    pChanges = 1
  end if
  if pDancing then
    pAnimating = 1
    pChanges = 1
  end if
end

on render me 
  if not pChanges then
    return()
  end if
  pChanges = 0
  if (pMainAction = "sit") then
    tSize = pCanvasSize.getAt(#std)
    pShadowSpr.castNum = getmemnum(pPeopleSize & "_sit_sd_001_" & pFlipList.getAt((pDirection + 1)) & "_0")
  else
    if (pMainAction = "lay") then
      tSize = pCanvasSize.getAt(#lay)
      pShadowSpr.castNum = 0
      pShadowFix = 0
    else
      tSize = pCanvasSize.getAt(#std)
      if pShadowSpr.member <> pDefShadowMem then
        pShadowSpr.member = pDefShadowMem
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
  if pFlipList.getAt((pDirection + 1)) <> pDirection or (pDirection = 3) and (pHeadDir = 4) or (pDirection = 7) and (pHeadDir = 6) then
    pMember.regPoint = point(pMember.image.width, pMember.getProp(#regPoint, 2))
    pShadowFix = pXFactor
    if not pSprite.flipH then
      pSprite.flipH = 1
      pMatteSpr.flipH = 1
      pShadowSpr.flipH = 1
    end if
  else
    pMember.regPoint = point(0, pMember.getProp(#regPoint, 2))
    pShadowFix = 0
    if pSprite.flipH then
      pSprite.flipH = 0
      pMatteSpr.flipH = 0
      pShadowSpr.flipH = 0
    end if
  end if
  if pCorrectLocZ then
    tOffZ = (((pLocH + pRestingHeight) * 1000) + 2)
  else
    tOffZ = 2
  end if
  pSprite.locH = pScreenLoc.getAt(1)
  pSprite.locV = pScreenLoc.getAt(2)
  pMatteSpr.loc = pSprite.loc
  pShadowSpr.loc = (pSprite.loc + [pShadowFix, 0])
  pSprite.locZ = (pScreenLoc.getAt(3) + tOffZ)
  pMatteSpr.locZ = (pSprite.locZ + 1)
  pShadowSpr.locZ = (pSprite.locZ - 3)
  pUpdateRect = rect(0, 0, 0, 0)
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#update, pPartList)
  pMember.image.copyPixels(pBuffer, pUpdateRect, pUpdateRect)
end

on reDraw me 
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#render, pPartList)
  pMember.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
end

on setPartLists me, tmodels 
  tAction = pMainAction
  pPartList = []
  tPartDefinition = getVariableValue("human.parts." & pPeopleSize)
  i = 1
  repeat while i <= tPartDefinition.count
    tPartSymbol = tPartDefinition.getAt(i)
    if voidp(tmodels.getAt(tPartSymbol)) then
      tmodels.setAt(tPartSymbol, [:])
    end if
    if voidp(tmodels.getAt(tPartSymbol).getAt("model")) then
      tmodels.getAt(tPartSymbol).setAt("model", "001")
    end if
    if voidp(tmodels.getAt(tPartSymbol).getAt("color")) then
      tmodels.getAt(tPartSymbol).setAt("color", rgb("EEEEEE"))
    end if
    if (tPartSymbol = "fc") and tmodels.getAt(tPartSymbol).getAt("model") <> "001" and pXFactor < 33 then
      tmodels.getAt(tPartSymbol).setAt("model", "001")
    end if
    tPartObj = createObject(#temp, pPartClass)
    if stringp(tmodels.getAt(tPartSymbol).getAt("color")) then
      tColor = value("rgb(" & tmodels.getAt(tPartSymbol).getAt("color") & ")")
    end if
    if tmodels.getAt(tPartSymbol).getAt("color").ilk <> #color then
      tColor = rgb(tmodels.getAt(tPartSymbol).getAt("color"))
    else
      tColor = tmodels.getAt(tPartSymbol).getAt("color")
    end if
    if ((tColor.red + tColor.green) + tColor.blue) > (238 * 3) then
      tColor = rgb("EEEEEE")
    end if
    tPartObj.define(tPartSymbol, tmodels.getAt(tPartSymbol).getAt("model"), tColor, pDirection, tAction, me)
    pPartList.add(tPartObj)
    pColors.setaProp(tPartSymbol, tColor)
    i = (1 + i)
  end repeat
  pPartIndex = [:]
  i = 1
  repeat while i <= pPartList.count
    pPartIndex.setAt(pPartList.getAt(i).pPart, i)
    i = (1 + i)
  end repeat
  return TRUE
end

on arrangeParts me 
  if pPartIndex.getAt("lg") < pPartIndex.getAt("sh") then
    tIndex1 = pPartIndex.getAt("lg")
    tIndex2 = pPartIndex.getAt("sh")
  else
    tIndex1 = pPartIndex.getAt("sh")
    tIndex2 = pPartIndex.getAt("lg")
  end if
  tLG = pPartList.getAt(pPartIndex.getAt("lg"))
  tSH = pPartList.getAt(pPartIndex.getAt("sh"))
  if pMainAction <> "sit" then
    if (pMainAction = "lay") then
      if (pFlipList.getAt((pDirection + 1)) = 0) then
        pPartList.setAt(tIndex1, tSH)
        pPartList.setAt(tIndex2, tLG)
      else
        pPartList.setAt(tIndex1, tLG)
        pPartList.setAt(tIndex2, tSH)
      end if
    else
      pPartList.setAt(tIndex1, tSH)
      pPartList.setAt(tIndex2, tLG)
    end if
    tRS = pPartList.getAt(pPartIndex.getAt("rs"))
    tRH = pPartList.getAt(pPartIndex.getAt("rh"))
    tRI = pPartList.getAt(pPartIndex.getAt("ri"))
    pPartList.deleteAt(pPartIndex.getAt("rs"))
    pPartList.deleteAt(pPartIndex.getAt("rh"))
    pPartList.deleteAt(pPartIndex.getAt("ri"))
    if (tRH.pActionRh = "drk") and [0, 6].getPos(pDirection) <> 0 then
      pPartList.addAt(1, tRI)
      pPartList.append(tRH)
      pPartList.append(tRS)
    else
      if (pDirection = 7) then
        pPartList.addAt(1, tRI)
        pPartList.addAt(2, tRH)
        pPartList.addAt(3, tRS)
      else
        pPartList.append(tRI)
        pPartList.append(tRH)
        pPartList.append(tRS)
      end if
    end if
    i = 1
    repeat while i <= pPartList.count
      pPartIndex.setAt(pPartList.getAt(i).pPart, i)
      i = (1 + i)
    end repeat
    if (pLastDir = pDirection) then
      return()
    end if
    pLastDir = pDirection
    tLS = pPartList.getAt(pPartIndex.getAt("ls"))
    tLH = pPartList.getAt(pPartIndex.getAt("lh"))
    tLI = pPartList.getAt(pPartIndex.getAt("li"))
    pPartList.deleteAt(pPartIndex.getAt("ls"))
    pPartList.deleteAt(pPartIndex.getAt("lh"))
    pPartList.deleteAt(pPartIndex.getAt("li"))
    if (pMainAction = 3) then
      pPartList.addAt(8, tLI)
      pPartList.addAt(9, tLH)
      pPartList.addAt(10, tLS)
    else
      pPartList.addAt(1, tLI)
      pPartList.addAt(2, tLH)
      pPartList.addAt(3, tLS)
    end if
    i = 1
    repeat while i <= pPartList.count
      pPartIndex.setAt(pPartList.getAt(i).pPart, i)
      i = (1 + i)
    end repeat
  end if
end

on flipImage me, tImg_a 
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return(tImg_b)
end

on action_mv me, tProps 
  pMainAction = "wlk"
  pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = float(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  pMoveStart = the milliSeconds
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH)
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  call(#defineActMultiple, pPartList, "wlk", ["bd", "lg", "lh", "rh", "ls", "rs", "sh"])
end

on action_sld me, tProps 
  pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = float(tloc.getProp(#item, 3))
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
  call(#defineActMultiple, pPartList, "sit", ["bd", "lg", "sh"])
  pMainAction = "sit"
  pRestingHeight = (float(tProps.getProp(#word, 2)) - 1)
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, (pLocH + pRestingHeight))
  tIsInQueue = integer(tProps.getProp(#word, 3))
  pQueuesWithObj = tIsInQueue
  me.arrangeParts()
end

on action_lay me, tProps 
  pMainAction = "lay"
  pCarrying = 0
  pRestingHeight = (float(tProps.getProp(#word, 2)) - 1)
  pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, (pLocH + pRestingHeight))
  if (pFlipList.getAt((pDirection + 1)) = 2) then
    pScreenLoc = (pScreenLoc + [10, 30, 2000])
  else
    if (pFlipList.getAt((pDirection + 1)) = 0) then
      pScreenLoc = (pScreenLoc + [-47, 32, 2000])
    end if
  end if
  pLocFix = point(30, -10)
  call(#layDown, pPartList)
  if (pDirection = 0) then
    pDirection = 4
  end if
  call(#defineDir, pPartList, pDirection)
  me.arrangeParts()
end

on action_carryd me, tProps 
  tItem = tProps.getProp(#word, 2)
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    call(#doHandWorkRight, pPartList, "crr")
    pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = "001"
      call(#doHandWorkRight, pPartList, "crr")
      pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
    end if
  end if
end

on action_cri me, tProps 
  tItem = tProps.getProp(#word, 2)
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "075")
    else
      tCarryItm = "075"
    end if
    call(#doHandWorkRight, pPartList, "crr")
    pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, "handitem" & tCarrying)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = "001"
      call(#doHandWorkRight, pPartList, "crr")
      pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
    end if
  end if
end

on action_usei me, tProps 
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
    call(#doHandWorkRight, pPartList, "drk")
    pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
    me.arrangeParts()
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = "001"
      call(#doHandWorkRight, pPartList, "drk")
      pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
    end if
  end if
end

on action_drink me, tProps 
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
    call(#doHandWorkRight, pPartList, "drk")
    pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
    me.arrangeParts()
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = "001"
      call(#doHandWorkRight, pPartList, "drk")
      pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
    end if
    me.arrangeParts()
  end if
end

on action_carryf me, tProps 
  tItem = tProps.getProp(#word, 2)
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    call(#doHandWorkRight, pPartList, "crr")
    pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
    if textExists("handitem" & tCarrying) then
      pCarrying = getText("handitem" & tCarrying, tItem)
    end if
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = "004"
      call(#doHandWorkRight, pPartList, "crr")
      pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
    end if
  end if
end

on action_eat me, tProps 
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
    call(#doHandWorkRight, pPartList, "drk")
    pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
  else
    if getObject(#room_component).getRoomID() <> "private" then
      pCarrying = tProps.getProp(#word, 2, tProps.count(#word))
      tCarryItm = "004"
      call(#doHandWorkRight, pPartList, "drk")
      pPartList.getAt(pPartIndex.getAt("ri")).setModel(tCarryItm)
    end if
  end if
end

on action_talk me, tProps 
  pTalking = 1
end

on action_gest me, tProps 
  if (pPeopleSize = "sh") then
    return()
  end if
  tList = ["ey", "fc"]
  tGesture = tProps.getProp(#word, 2)
  if (tGesture = "spr") then
    tGesture = "srp"
  end if
  if (pMainAction = "lay") then
    tGesture = "l" & tGesture.getProp(#char, 1, 2)
    call(#defineActMultiple, pPartList, tGesture, tList)
  else
    call(#defineActMultiple, pPartList, tGesture, tList)
    if (tGesture = "ohd") then
      pPartList.getAt(pPartIndex.getAt("hd")).defineAct(tGesture)
      pPartList.getAt(pPartIndex.getAt("hr")).defineAct(tGesture)
    end if
  end if
end

on action_wave me, tProps 
  pWaving = 1
end

on action_dance me, tProps 
  pDancing = 1
  tStyle = tProps.getProp(#word, 2)
  if (tStyle = "") then
    tStyle = "dance.aero"
  end if
  me.startAnimation(tStyle)
end

on action_ohd me 
  call(#defineActMultiple, pPartList, "ohd", ["hd", "fc", "ey", "hr"])
  call(#doHandWorkRight, pPartList, "ohd")
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
  call(#doHandWorkLeft, me.pPartList, "sig")
  tSignObjID = "SIGN_EXTRA"
  if voidp(pExtraObjs.getAt(tSignObjID)) then
    pExtraObjs.addProp(tSignObjID, createObject(#temp, "HumanExtra Sign Class"))
  end if
  call(#show_sign, pExtraObjs, ["sprite":pSprite, "direction":pDirection, "signmember":tSignMem])
end
