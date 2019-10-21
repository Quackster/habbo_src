property pGeometry, pPetDefinitions, pXFactor, pSprite, pMatteSpr, pShadowSpr, pMember, pCanvasSize, pMemberNamePrefix, pInfoStruct, pName, pClass, pCustom, pRace, pLocX, pLocY, pLocH, pDirection, pSync, pPartList, pCorrectLocZ, pRestingHeight, pFlipList, pPartIndex, pIDPrefix, pScreenLoc, pAnimCounter, pEyesClosed, pTalking, pWaving, pSniffing, pMainAction, pMoving, pMoveStart, pMoveTime, pDestLScreen, pStartLScreen, pChanges, pDefShadowMem, pBuffer, pShadowFix, pAlphaColor, pUpdateRect, pPartClass

on construct me 
  pName = ""
  pIDPrefix = ""
  pPartList = []
  pPartIndex = [:]
  pFlipList = [0, 1, 2, 3, 2, 1, 0, 7]
  pLocFix = point(0, -8)
  pUpdateRect = rect(0, 0, 0, 0)
  pScreenLoc = [0, 0, 0]
  pStartLScreen = [0, 0, 0]
  pDestLScreen = [0, 0, 0]
  pRestingHeight = 0
  pAnimCounter = 0
  pMoveStart = 0
  pMoveTime = 500
  pEyesClosed = 0
  pSync = 1
  pChanges = 1
  pMainAction = "std"
  pWaving = 0
  pMoving = 0
  pSniffing = 0
  pTalking = 0
  pAlphaColor = rgb(255, 255, 255)
  pSync = 1
  pDefShadowMem = member(0)
  pInfoStruct = [:]
  pGeometry = getThread(#room).getInterface().getGeometry()
  pXFactor = pGeometry.pXFactor
  pYFactor = pGeometry.pYFactor
  pHFactor = pGeometry.pHFactor
  pOffsetList = [:]
  pOffsetListSmall = [:]
  tPetDEfText = member(getmemnum("pet.definitions")).text
  tPetDEfText = replaceChunks(tPetDEfText, "\r", "")
  pPetDefinitions = value(tPetDEfText)
  if ilk(pPetDefinitions) <> #propList then
    pPetDefinitions = [:]
    error(me, "Pet definitions has invalid data!", me.getID(), #construct, #major)
  end if
  if (pXFactor = 32) then
    pMemberNamePrefix = "s_p_"
    pCorrectLocZ = 0
  else
    pMemberNamePrefix = "p_"
    pCorrectLocZ = 1
  end if
  pPartClass = value(getThread(#room).getComponent().getClassContainer().GET("petpart"))
  return TRUE
end

on deconstruct me 
  pGeometry = void()
  pPartList = []
  pInfoStruct = [:]
  if (pSprite.ilk = #sprite) then
    releaseSprite(pSprite.spriteNum)
  end if
  if (pMatteSpr.ilk = #sprite) then
    releaseSprite(pMatteSpr.spriteNum)
  end if
  if (pShadowSpr.ilk = #sprite) then
    releaseSprite(pShadowSpr.spriteNum)
  end if
  if memberExists(me.getCanvasName()) then
    removeMember(me.getCanvasName())
  end if
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
  pMember = member(getmemnum(me.getCanvasName()))
  pMember.image = image(pCanvasSize.getAt(1), pCanvasSize.getAt(2), pCanvasSize.getAt(3))
  pMember.regPoint = point(0, (pMember.image.height + pCanvasSize.getAt(4)))
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
  pDefShadowMem = member(getmemnum(pMemberNamePrefix & "std_sd_001_0_0"))
  tTargetID = getThread(#room).getInterface().getID()
  setEventBroker(pMatteSpr.spriteNum, me.getID())
  pMatteSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseEnter)
  pMatteSpr.registerProcedure(#eventProcUserRollOver, tTargetID, #mouseLeave)
  setEventBroker(pShadowSpr.spriteNum, me.getID())
  pShadowSpr.registerProcedure(#eventProcUserObj, tTargetID, #mouseDown)
  tDelim = the itemDelimiter
  the itemDelimiter = numToChar(4)
  pInfoStruct.setAt(#name, me.getID().item[2])
  the itemDelimiter = tDelim
  pInfoStruct.setAt(#name, pName)
  pInfoStruct.setAt(#class, pClass)
  pInfoStruct.setAt(#custom, pCustom)
  pInfoStruct.setAt(#image, me.getPicture())
  return TRUE
end

on setup me, tdata 
  pName = tdata.getAt(#name)
  pClass = tdata.getAt(#class)
  pDirection = tdata.getAt(#direction).getAt(1)
  pLocX = tdata.getAt(#x)
  pLocY = tdata.getAt(#y)
  pLocH = tdata.getAt(#h)
  pRace = tdata.getAt(#figure).getProp(#word, 1)
  pOffsetList = me.getOffsetList()
  pOffsetListSmall = me.getOffsetList(#small)
  pCustom = getText("pet_race_" & pRace & "_" & tdata.getAt(#figure).getProp(#word, 2), "")
  if pName contains numToChar(4) then
    pIDPrefix = pName.getProp(#char, 1, offset(numToChar(4), pName))
    pName = pName.getProp(#char, (offset(numToChar(4), pName) + 1), length(pName))
  end if
  pCanvasSize = [62, 62, 32, -18]
  if not me.setPartLists(tdata.getAt(#figure)) then
    return(error(me, "Couldn't create part lists!", #setup, #major))
  end if
  me.resetValues(pLocX, pLocY, pLocH, pDirection, pDirection)
  me.Refresh(pLocX, pLocY, pLocH)
  pSync = 0
end

on update me 
  pSync = not pSync
  if pSync then
    me.prepare()
  else
    me.render()
  end if
end

on getWebID me 
  return FALSE
end

on setUserTypingStatus me, tStatus 
  nothing()
end

on resetValues me, tX, tY, tH, tDirHead, tDirBody 
  pWaving = 0
  pMoving = 0
  pTalking = 0
  pSniffing = 0
  call(#reset, pPartList)
  if pCorrectLocZ then
    pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, (tH + pRestingHeight))
  else
    pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH)
  end if
  pMainAction = "std"
  pLocX = tX
  pLocY = tY
  pLocH = tH
  pRestingHeight = 0
  call(#defineDir, pPartList, tDirBody)
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
  pPartList.getAt(pPartIndex.getAt("hd")).defineDir(tDirHead)
  pDirection = tDirBody
end

on Refresh me, tX, tY, tH, tDirHead, tDirBody 
  me.arrangeParts()
  pChanges = 1
end

on select me 
  if the doubleClick then
    if connectionExists(getVariable("connection.info.id", #info)) then
      getConnection(getVariable("connection.info.id", #info)).send("GETPETSTAT", [#string:pIDPrefix & pName])
    end if
  end if
  return TRUE
end

on getClass me 
  return("pet")
end

on getName me 
  return(pName)
end

on setPartModel me, tPart, tmodel 
  if voidp(pPartIndex.getAt(tPart)) then
    return(void())
  end if
  pPartList.getAt(pPartIndex.getAt(tPart)).setModel(tmodel)
end

on setPartColor me, tPart, tColor 
  if voidp(pPartIndex.getAt(tPart)) then
    return(rgb(255, 199, 199))
  end if
  pPartList.getAt(pPartIndex.getAt(tPart)).setColor(tColor)
end

on getProperty me, tPropID 
  if (tPropID = #loc) then
    return([pLocX, pLocY, pLocH])
  else
    if (tPropID = #moving) then
      return(me.pMoving)
    else
      return FALSE
    end if
  end if
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
  return(me.getTileCenter())
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
    return(rgb(255, 199, 199))
  end if
  return(pPartList.getAt(pPartIndex.getAt(tPart)).getColor())
end

on getPicture me, tImg 
  if voidp(tImg) then
    tCanvas = image(pCanvasSize.getAt(1), pCanvasSize.getAt(2), pCanvasSize.getAt(3))
  else
    tCanvas = tImg
  end if
  if voidp(pInfoStruct.getAt(#image)) then
    tPartDefinition = ["tl", "bd", "hd"]
    tTempPartList = []
    repeat while tPartDefinition <= undefined
      tPartSymbol = getAt(undefined, tImg)
      if not voidp(pPartIndex.getAt(tPartSymbol)) then
        tTempPartList.append(pPartList.getAt(pPartIndex.getAt(tPartSymbol)))
      end if
    end repeat
    call(#copyPicture, tTempPartList, tCanvas)
  else
    tCanvas.copyPixels(pInfoStruct.getAt(#image), tCanvas.rect, tCanvas.rect)
  end if
  return(me.flipImage(tCanvas))
end

on getInfo me 
  return(pInfoStruct)
end

on getSprites me 
  return([pSprite, pShadowSpr, pMatteSpr])
end

on closeEyes me 
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("eyb")
  pEyesClosed = 1
  pChanges = 1
end

on openEyes me 
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("std")
  pEyesClosed = 0
  pChanges = 1
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
  if pEyesClosed then
    me.openEyes()
  else
    if (random(30) = 3) then
      me.closeEyes()
    end if
  end if
  if pTalking and random(3) > 1 then
    pPartList.getAt(pPartIndex.getAt("hd")).defineAct("spk")
    pChanges = 1
  end if
  if pWaving then
    pPartList.getAt(pPartIndex.getAt("tl")).defineAct("wav")
    pChanges = 1
  end if
  if pSniffing then
    pPartList.getAt(pPartIndex.getAt("hd")).defineAct("snf")
    pChanges = 1
  end if
  if (pMainAction = "scr") then
    pPartList.getAt(pPartIndex.getAt("bd")).defineAct("scr")
    pChanges = 1
  end if
  if (pMainAction = "bnd") then
    pPartList.getAt(pPartIndex.getAt("bd")).defineAct("bnd")
    pChanges = 1
  end if
  if (pMainAction = "jmp") then
    pPartList.getAt(pPartIndex.getAt("bd")).defineAct("jmp")
    pChanges = 1
  end if
  if (pMainAction = "pla") then
    pPartList.getAt(pPartIndex.getAt("bd")).defineAct("pla")
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
end

on render me 
  if not pChanges then
    return()
  end if
  pChanges = 0
  if pShadowSpr.member <> pDefShadowMem then
    pShadowSpr.member = pDefShadowMem
  end if
  if pBuffer.width <> pCanvasSize.getAt(1) or pBuffer.height <> pCanvasSize.getAt(2) then
    pMember.image = image(pCanvasSize.getAt(1), pCanvasSize.getAt(2), pCanvasSize.getAt(3))
    pMember.regPoint = point(0, (pCanvasSize.getAt(2) + pCanvasSize.getAt(4)))
    pSprite.width = pCanvasSize.getAt(1)
    pSprite.height = pCanvasSize.getAt(2)
    pMatteSpr.width = pCanvasSize.getAt(1)
    pMatteSpr.height = pCanvasSize.getAt(2)
    pBuffer = image(pCanvasSize.getAt(1), pCanvasSize.getAt(2), pCanvasSize.getAt(3))
  end if
  tFlip = 0
  tFlip = tFlip or pFlipList.getAt((pDirection + 1)) <> pDirection
  tFlip = tFlip or (pDirection = 3) and (pPartList.getAt(pPartIndex.getAt("hd")).pDirection = 4)
  tFlip = tFlip or (pDirection = 7) and (pPartList.getAt(pPartIndex.getAt("hd")).pDirection = 6)
  if tFlip then
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
  pSprite.locZ = (pScreenLoc.getAt(3) + tOffZ)
  pMatteSpr.loc = pSprite.loc
  pMatteSpr.locZ = (pSprite.locZ + 1)
  pShadowSpr.loc = (pSprite.loc + [pShadowFix, 0])
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

on setPartLists me, tFigure 
  tAction = pMainAction
  pPartList = []
  tPartDefinition = ["tl", "bd", "hd"]
  if tFigure.count(#word) < 3 then
    tFigure = "0 4 AA98EF"
  end if
  tRaceNum = tFigure.getProp(#word, 1)
  tPalette = tFigure.getProp(#word, 2)
  if tPalette.length < 2 then
    tPalette = "00" & tPalette
  else
    if tPalette.length < 3 then
      tPalette = "0" & tPalette
    end if
  end if
  tPaletteType = pPetDefinitions.getAt(pRace).getAt(#paletteid)
  tPalette = "Palette" && tPaletteType && tPalette
  tColor = rgb(tFigure.getProp(#word, 3))
  i = 1
  repeat while i <= tPartDefinition.count
    tPartSymbol = tPartDefinition.getAt(i)
    tPartObj = createObject(#temp, pPartClass)
    tmodel = pPetDefinitions.getAt(pRace).getAt(#parts).getAt(tPartSymbol)
    tPartObj.define(tPartSymbol, tmodel, tPalette, tColor, pDirection, tAction, me)
    pPartList.add(tPartObj)
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
  tTailInd = pPartIndex.getAt("tl")
  tHeadInd = pPartIndex.getAt("hd")
  tBodyInd = pPartIndex.getAt("bd")
  tTail = pPartList.getAt(tTailInd)
  tHead = pPartList.getAt(tHeadInd)
  tBody = pPartList.getAt(tBodyInd)
  tHeadDir = tHead.getDirection()
  if (tHeadDir = 7) then
    pPartList = [tHead, tBody, tTail]
    pPartIndex = ["hd":1, "bd":2, "tl":3]
  else
    if (pDirection = 6) or (pDirection = 7) or (pDirection = 0) then
      pPartList = [tBody, tHead, tTail]
      pPartIndex = ["bd":1, "hd":2, "tl":3]
    else
      pPartList = [tTail, tBody, tHead]
      pPartIndex = ["tl":1, "bd":2, "hd":3]
    end if
  end if
end

on flipImage me, tImg_a 
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return(tImg_b)
end

on getOffsetList me, tSize 
  if voidp(tSize) then
    tSize = #large
  end if
  tPetOffsetId = pPetDefinitions.getAt(pRace).getAt(#offsetid)
  if (tSize = #large) then
    tListMemName = "offset." & tPetOffsetId & ".large"
  else
    tListMemName = "offset." & tPetOffsetId & ".small"
  end if
  if not memberExists(tListMemName) then
    return([:])
  end if
  tListText = member(getmemnum(tListMemName)).text
  tList = [:]
  tAliasList = [:]
  tDelim = the itemDelimiter
  the itemDelimiter = "="
  tLineNo = 1
  repeat while tLineNo <= tListText.count(#line)
    tLineText = tListText.getProp(#line, tLineNo)
    if not (chars(tLineText, 1, 1) = "#") then
      if tLineText.count(#item) > 1 then
        tKey = tLineText.getProp(#item, 1)
        tValue = tLineText.getProp(#item, 2, tLineText.count(#item))
        tKey = value(tKey)
        tValue = value(tValue)
        if (ilk(tValue) = #list) then
          tList.setAt(tKey, tValue)
        else
          tAliasList.setAt(tKey, tValue)
        end if
      end if
    end if
    tLineNo = (1 + tLineNo)
  end repeat
  the itemDelimiter = tDelim
  tItemNo = 1
  repeat while tItemNo <= tAliasList.count
    tKey = tAliasList.getPropAt(tItemNo)
    tAliasKey = tAliasList.getAt(tItemNo)
    if tList.getaProp(tAliasKey) <> void() then
      tOffsetData = tList.getAt(tAliasKey)
      tList.setAt(tKey, tOffsetData)
    else
      error(me, "Invalid alias definition, no offset available: " & tValue, me.getID(), #getOffsetList, #minor)
    end if
    tItemNo = (1 + tItemNo)
  end repeat
  return(tList)
end

on getCanvasName me 
  return(pClass && pIDPrefix && pName & me.getID() && "Canvas")
end

on action_mv me, tProps 
  pMainAction = "wlk"
  pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = getLocalFloat(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH)
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  pMoveStart = the milliSeconds
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("wlk")
end

on action_sld me, tProps 
  pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = getLocalFloat(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, (pLocH + pRestingHeight))
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  pMoveStart = the milliSeconds
end

on action_sit me, tProps 
  pMainAction = "sit"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("sit")
  if pCorrectLocZ then
    pRestingHeight = (getLocalFloat(tProps.getProp(#word, 2)) - pLocH)
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, (pLocH + pRestingHeight))
  else
    pRestingHeight = getLocalFloat(tProps.getProp(#word, 2))
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pRestingHeight)
  end if
end

on action_snf me 
  pSniffing = 1
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("snf")
end

on action_scr me 
  me.pMainAction = "scr"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("scr")
end

on action_bnd me 
  me.pMainAction = "bnd"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("bnd")
end

on action_lay me, tProps 
  pMainAction = "lay"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("lay")
  if pCorrectLocZ then
    pRestingHeight = (getLocalFloat(tProps.getProp(#word, 2)) - pLocH)
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, (pLocH + pRestingHeight))
  else
    pRestingHeight = getLocalFloat(tProps.getProp(#word, 2))
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pRestingHeight)
  end if
end

on action_slp me, tProps 
  me.action_lay(tProps)
  pMainAction = "slp"
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("slp")
end

on action_jmp me, tProps 
  pMainAction = "jmp"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("jmp")
end

on action_ded me, tProps 
  pMainAction = "ded"
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("ded")
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("ded")
  pPartList.getAt(pPartIndex.getAt("tl")).defineAct("ded")
end

on action_eat me, tProps 
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("eat")
end

on action_beg me, tProps 
  pMainAction = "beg"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("beg")
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("beg")
end

on action_pla me, tProps 
  pMainAction = "pla"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("pla")
end

on action_rdy me, tProps 
  pMainAction = "rdy"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("rdy")
end

on action_talk me, tProps 
  pTalking = 1
end

on action_wav me, tProps 
  pWaving = 1
  pPartList.getAt(pPartIndex.getAt("tl")).defineAct("wav")
end

on action_gst me, tProps 
  tGesture = tProps.getProp(#word, 2)
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct(tGesture)
  if tGesture <> "sml" then
    if tGesture <> "agr" then
      if tGesture <> "sad" then
        if (tGesture = "puz") then
          pPartList.getAt(pPartIndex.getAt("tl")).defineAct(tGesture)
        end if
      end if
    end if
  end if
end
