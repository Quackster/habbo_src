on construct(me)
  pName = ""
  pIDPrefix = ""
  pPartList = []
  pPartIndex = []
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
  pInfoStruct = []
  pGeometry = getThread(#room).getInterface().getGeometry()
  pXFactor = pGeometry.pXFactor
  pYFactor = pGeometry.pYFactor
  pHFactor = pGeometry.pHFactor
  pCorrectLocZ = 1
  pPartClass = value(getThread(#room).getComponent().getClassContainer().get("petpart"))
  pOffsetList = me.getOffsetList()
  return(1)
  exit
end

on deconstruct(me)
  pGeometry = void()
  pPartList = []
  pInfoStruct = []
  if pSprite.ilk = #sprite then
    releaseSprite(pSprite.spriteNum)
  end if
  if pMatteSpr.ilk = #sprite then
    releaseSprite(pMatteSpr.spriteNum)
  end if
  if pShadowSpr.ilk = #sprite then
    releaseSprite(pShadowSpr.spriteNum)
  end if
  if memberExists(pClass && pIDPrefix && pName && "Canvas") then
    removeMember(pClass && pIDPrefix && pName && "Canvas")
  end if
  pShadowSpr = void()
  pMatteSpr = void()
  pSprite = void()
  return(1)
  exit
end

on define(me, tdata)
  me.setup(tdata)
  if not memberExists(pClass && pIDPrefix && pName && "Canvas") then
    createMember(pClass && pIDPrefix && pName && "Canvas", #bitmap)
  end if
  pMember = member(getmemnum(pClass && pIDPrefix && pName && "Canvas"))
  pMember.image = image(pCanvasSize.getAt(1), pCanvasSize.getAt(2), pCanvasSize.getAt(3))
  0.regPoint = point(pMember, image.height + pCanvasSize.getAt(4))
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
  pDefShadowMem = member(getmemnum("p_std_sd_001_0_0"))
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
  return(1)
  exit
end

on setup(me, tdata)
  pName = tdata.getAt(#name)
  pClass = tdata.getAt(#class)
  pDirection = tdata.getAt(#direction).getAt(1)
  pLocX = tdata.getAt(#x)
  pLocY = tdata.getAt(#y)
  pLocH = tdata.getAt(#h)
  pCustom = getText("pet_race_" & tdata.getAt(#figure).getProp(#word, 1) & "_" & tdata.getAt(#figure).getProp(#word, 2), "")
  if pName contains numToChar(4) then
    pIDPrefix = pName.getProp(#char, 1, offset(numToChar(4), pName))
    pName = pName.getProp(#char, offset(numToChar(4), pName) + 1, length(pName))
  end if
  pCorrectLocZ = 1
  pCanvasSize = [60, 62, 32, -18]
  tPartSymbols = tdata.getAt(#parts)
  if not me.setPartLists(tdata.getAt(#figure)) then
    return(error(me, "Couldn't create part lists!", #setup))
  end if
  me.arrangeParts()
  me.refresh(pLocX, pLocY, pLocH, pDirection, pDirection)
  pSync = 0
  exit
end

on update(me)
  pSync = not pSync
  if pSync then
    me.prepare()
  else
    me.render()
  end if
  exit
end

on refresh(me, tX, tY, tH, tDirHead, tDirBody)
  pWaving = 0
  pMoving = 0
  pTalking = 0
  pSniffing = 0
  call(#reset, pPartList)
  if pCorrectLocZ then
    pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH + pRestingHeight)
  else
    pScreenLoc = pGeometry.getScreenCoordinate(tX, tY, tH)
  end if
  pMainAction = "std"
  pLocX = tX
  pLocY = tY
  pLocH = tH
  pRestingHeight = 0
  call(#defineDir, pPartList, tDirBody)
  if tDirBody <> pFlipList.getAt(tDirBody + 1) then
    if tDirBody <> tDirHead then
      if me = 4 then
        tDirHead = 2
      else
        if me = 5 then
          tDirHead = 1
        else
          if me = 6 then
            tDirHead = 4
          else
            if me = 7 then
              tDirHead = 5
            end if
          end if
        end if
      end if
    end if
  end if
  pPartList.getAt(pPartIndex.getAt("hd")).defineDir(tDirHead)
  pDirection = tDirBody
  me.arrangeParts()
  pChanges = 1
  exit
end

on select(me)
  if the doubleClick then
    if connectionExists(getVariable("connection.info.id", #info)) then
      getConnection(getVariable("connection.info.id", #info)).send("GETPETSTAT", [#string:pIDPrefix & pName])
    end if
  end if
  return(1)
  exit
end

on getClass(me)
  return("pet")
  exit
end

on getName(me)
  return(pName)
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
    return(rgb(255, 199, 199))
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
  return(me.getTileCenter())
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
    return(rgb(255, 199, 199))
  end if
  return(pPartList.getAt(pPartIndex.getAt(tPart)).getColor())
  exit
end

on getPicture(me, tImg)
  if voidp(tImg) then
    tCanvas = image(pCanvasSize.getAt(1), pCanvasSize.getAt(2), pCanvasSize.getAt(3))
  else
    tCanvas = tImg
  end if
  if voidp(pInfoStruct.getAt(#image)) then
    tPartDefinition = ["tl", "bd", "hd"]
    tTempPartList = []
    repeat while me <= undefined
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
  exit
end

on getInfo(me)
  return(pInfoStruct)
  exit
end

on getSprites(me)
  return([pSprite, pShadowSpr, pMatteSpr])
  exit
end

on closeEyes(me)
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("eyb")
  pEyesClosed = 1
  pChanges = 1
  exit
end

on openEyes(me)
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("std")
  pEyesClosed = 0
  pChanges = 1
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
  if pEyesClosed then
    me.openEyes()
  else
    if random(30) = 3 then
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
  if pMainAction = "scr" then
    pPartList.getAt(pPartIndex.getAt("bd")).defineAct("scr")
    pChanges = 1
  end if
  if pMainAction = "bnd" then
    pPartList.getAt(pPartIndex.getAt("bd")).defineAct("bnd")
    pChanges = 1
  end if
  if pMainAction = "jmp" then
    pPartList.getAt(pPartIndex.getAt("bd")).defineAct("jmp")
    pChanges = 1
  end if
  if pMainAction = "pla" then
    pPartList.getAt(pPartIndex.getAt("bd")).defineAct("pla")
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
  exit
end

on render(me)
  if not pChanges then
    return()
  end if
  pChanges = 0
  if pShadowSpr.member <> pDefShadowMem then
    pShadowSpr.member = pDefShadowMem
  end if
  if pBuffer.width <> pCanvasSize.getAt(1) or pBuffer.height <> pCanvasSize.getAt(2) then
    pMember.image = image(pCanvasSize.getAt(1), pCanvasSize.getAt(2), pCanvasSize.getAt(3))
    pMember.regPoint = point(0, pCanvasSize.getAt(2) + pCanvasSize.getAt(4))
    pSprite.width = pCanvasSize.getAt(1)
    pSprite.height = pCanvasSize.getAt(2)
    pMatteSpr.width = pCanvasSize.getAt(1)
    pMatteSpr.height = pCanvasSize.getAt(2)
    pBuffer = image(pCanvasSize.getAt(1), pCanvasSize.getAt(2), pCanvasSize.getAt(3))
  end if
  tFlip = 0
  tFlip = tFlip or pFlipList.getAt(pDirection + 1) <> pDirection
  tFlip = tFlip or pDirection = 3 and pPartList.getAt(pPartIndex.getAt("hd")).pDirection = 4
  tFlip = tFlip or pDirection = 7 and pPartList.getAt(pPartIndex.getAt("hd")).pDirection = 6
  if tFlip then
    pMember.regPoint = point(image.width, pMember.getProp(#regPoint, 2))
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
    tOffZ = pLocH + pRestingHeight * 1000 + 2
  else
    tOffZ = 2
  end if
  pSprite.locH = pScreenLoc.getAt(1)
  pSprite.locV = pScreenLoc.getAt(2)
  pSprite.locZ = pScreenLoc.getAt(3) + tOffZ
  pMatteSpr.loc = pSprite.loc
  pMatteSpr.locZ = pSprite.locZ + 1
  pShadowSpr.loc = pSprite.loc + [pShadowFix, 0]
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

on setPartLists(me, tFigure)
  tAction = pMainAction
  pPartList = []
  tPartDefinition = ["tl", "bd", "hd"]
  if tFigure.count(#word) < 3 then
    tFigure = "0 4 AA98EF"
  end if
  tRaceNum = tFigure.getProp(#word, 1)
  tPalette = tFigure.getProp(#word, 2)
  if tPalette.length < 3 then
    tPalette = "0" & tPalette
  end if
  if tPalette.length < 3 then
    tPalette = "0" & tPalette
  end if
  tPalette = "Pets Palette" && tPalette
  tColor = rgb(tFigure.getProp(#word, 3))
  i = 1
  repeat while i <= tPartDefinition.count
    tPartSymbol = tPartDefinition.getAt(i)
    tPartObj = createObject(#temp, pPartClass)
    if tPartSymbol = "bd" then
      tmodel = "000"
    else
      tmodel = "00" & tRaceNum
    end if
    tPartObj.define(tPartSymbol, tmodel, tPalette, tColor, pDirection, tAction, me)
    pPartList.add(tPartObj)
    i = 1 + i
  end repeat
  pPartIndex = []
  i = 1
  repeat while i <= pPartList.count
    pPartIndex.setAt(pPartList.getAt(i).pPart, i)
    i = 1 + i
  end repeat
  return(1)
  exit
end

on arrangeParts(me)
  tTailInd = pPartIndex.getAt("tl")
  tHeadInd = pPartIndex.getAt("hd")
  tBodyInd = pPartIndex.getAt("bd")
  tTail = pPartList.getAt(tTailInd)
  tHead = pPartList.getAt(tHeadInd)
  tBody = pPartList.getAt(tBodyInd)
  tHeadDir = tHead.getDirection()
  if tHeadDir = 7 then
    pPartList = [tHead, tBody, tTail]
    pPartIndex = ["hd":1, "bd":2, "tl":3]
  else
    if pDirection = 6 or pDirection = 7 or pDirection = 0 then
      pPartList = [tBody, tHead, tTail]
      pPartIndex = ["bd":1, "hd":2, "tl":3]
    else
      pPartList = [tTail, tBody, tHead]
      pPartIndex = ["tl":1, "bd":2, "hd":3]
    end if
  end if
  exit
end

on flipImage(me, tImg_a)
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return(tImg_b)
  exit
end

on getOffsetList(me)
  tList = []
  tList.setAt("hd_std", [[36, -21], [38, -18], [37, -18], [32, -15], [32, -20]])
  tList.setAt("hd_sit", [[36, -21], [38, -18], [37, -18], [32, -14], [32, -17]])
  tList.setAt("hd_lay", [[36, -13], [38, -11], [37, -12], [32, -8], [32, -11]])
  tList.setAt("hd_slp", [[36, -11], [38, -9], [37, -10], [32, -6], [32, -9]])
  tList.setAt("hd_wlk", tList.getAt("hd_std"))
  tList.setAt("hd_pla", tList.getAt("hd_sit"))
  tList.setAt("hd_spc", tList.getAt("hd_std"))
  tList.setAt("hd_rdy", [[35, -17], [38, -11], [37, -7], [32, -11], [32, -17]])
  tList.setAt("hd_beg", [[24, -24], [25, -27], [26, -28], [32, -26], [32, -24]])
  tList.setAt("hd_ded", [[40, -3], [38, 1], [37, 5], [32, 8], [32, -7]])
  tList.setAt("hd_jmp_0", tList.getAt("hd_rdy"))
  tList.setAt("hd_jmp_1", tList.getAt("hd_sit"))
  tList.setAt("hd_jmp_2", [[36, -33], [38, -30], [37, -30], [32, -27], [32, -32]])
  tList.setAt("hd_jmp_3", [[36, -25], [38, -22], [37, -22], [32, -19], [32, -24]])
  tList.setAt("hd_scr_0", tList.getAt("hd_sit"))
  tList.setAt("hd_scr_1", [[36, -19], [39, -16], [37, -16], [32, -12], [32, -15]])
  tList.setAt("hd_scr_2", tList.getAt("hd_sit"))
  tList.setAt("hd_scr_3", tList.getAt("hd_scr_1"))
  tList.setAt("hd_bnd_0", tList.getAt("hd_rdy"))
  tList.setAt("hd_bnd_1", [[35, -22], [36, -19], [36, -19], [32, -16], [32, -21]])
  tList.setAt("hd_bnd_2", tList.getAt("hd_bnd_1"))
  tList.setAt("hd_bnd_3", tList.getAt("hd_bnd_1"))
  tList.setAt("tl_std", [[21, -10], [20, -12], [23, -19], [32, -23], [32, -10]])
  tList.setAt("tl_sit", [[21, -2], [22, -1], [23, -6], [32, -19], [32, -3]])
  tList.setAt("tl_lay", [[21, 1], [18, -1], [23, -10], [32, -15], [32, 0]])
  tList.setAt("tl_slp", tList.getAt("tl_lay"))
  tList.setAt("tl_wlk", tList.getAt("tl_std"))
  tList.setAt("tl_pla", tList.getAt("tl_sit"))
  tList.setAt("tl_spc", tList.getAt("tl_std"))
  tList.setAt("tl_rdy", [[21, -10], [20, -12], [23, -19], [32, -23], [32, -11]])
  tList.setAt("tl_beg", [[21, -2], [22, -1], [23, -5], [32, -14], [32, 1]])
  tList.setAt("tl_ded", [[23, 2], [18, 1], [23, -19], [32, -20], [32, -10]])
  tList.setAt("tl_jmp_0", tList.getAt("tl_rdy"))
  tList.setAt("tl_jmp_1", tList.getAt("tl_sit"))
  tList.setAt("tl_jmp_2", [[21, -16], [20, -18], [23, -25], [32, -28], [32, -16]])
  tList.setAt("tl_jmp_3", [[21, -20], [20, -22], [23, -29], [32, -33], [32, -20]])
  tList.setAt("tl_scr_0", tList.getAt("tl_sit"))
  tList.setAt("tl_scr_1", [[21, -1], [22, 0], [23, -5], [32, -18], [32, -2]])
  tList.setAt("tl_scr_2", tList.getAt("tl_sit"))
  tList.setAt("tl_scr_3", tList.getAt("tl_scr_1"))
  tList.setAt("tl_bnd_0", tList.getAt("tl_rdy"))
  tList.setAt("tl_bnd_1", [[23, -13], [24, -14], [25, -21], [32, -27], [32, -12]])
  tList.setAt("tl_bnd_2", tList.getAt("tl_bnd_1"))
  tList.setAt("tl_bnd_3", tList.getAt("tl_bnd_1"))
  return(tList)
  exit
end

on action_mv(me, tProps)
  pMainAction = "wlk"
  pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = float(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH)
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  pMoveStart = the milliSeconds
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("wlk")
  exit
end

on action_sld(me, tProps)
  pMoving = 1
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  tloc = tProps.getProp(#word, 2)
  tLocX = integer(tloc.getProp(#item, 1))
  tLocY = integer(tloc.getProp(#item, 2))
  tLocH = float(tloc.getProp(#item, 3))
  the itemDelimiter = tDelim
  pStartLScreen = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  pDestLScreen = pGeometry.getScreenCoordinate(tLocX, tLocY, tLocH)
  pMoveStart = the milliSeconds
  exit
end

on action_sit(me, tProps)
  pMainAction = "sit"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("sit")
  if pCorrectLocZ then
    pRestingHeight = float(tProps.getProp(#word, 2)) - pLocH
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  else
    pRestingHeight = float(tProps.getProp(#word, 2))
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pRestingHeight)
  end if
  exit
end

on action_snf(me)
  pSniffing = 1
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("snf")
  exit
end

on action_scr(me)
  me.pMainAction = "scr"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("scr")
  exit
end

on action_bnd(me)
  me.pMainAction = "bnd"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("bnd")
  exit
end

on action_lay(me, tProps)
  pMainAction = "lay"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("lay")
  if pCorrectLocZ then
    pRestingHeight = float(tProps.getProp(#word, 2)) - pLocH
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pLocH + pRestingHeight)
  else
    pRestingHeight = float(tProps.getProp(#word, 2))
    pScreenLoc = pGeometry.getScreenCoordinate(pLocX, pLocY, pRestingHeight)
  end if
  exit
end

on action_slp(me, tProps)
  me.action_lay(tProps)
  me.closeEyes()
  pMainAction = "slp"
  exit
end

on action_jmp(me, tProps)
  pMainAction = "jmp"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("jmp")
  exit
end

on action_ded(me, tProps)
  pMainAction = "ded"
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("ded")
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("ded")
  pPartList.getAt(pPartIndex.getAt("tl")).defineAct("ded")
  exit
end

on action_eat(me, tProps)
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct("eat")
  exit
end

on action_beg(me, tProps)
  pMainAction = "beg"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("beg")
  exit
end

on action_pla(me, tProps)
  pMainAction = "pla"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("pla")
  exit
end

on action_rdy(me, tProps)
  pMainAction = "rdy"
  pPartList.getAt(pPartIndex.getAt("bd")).defineAct("rdy")
  exit
end

on action_talk(me, tProps)
  pTalking = 1
  exit
end

on action_wav(me, tProps)
  pWaving = 1
  pPartList.getAt(pPartIndex.getAt("tl")).defineAct("wav")
  exit
end

on action_gst(me, tProps)
  tGesture = tProps.getProp(#word, 2)
  pPartList.getAt(pPartIndex.getAt("hd")).defineAct(tGesture)
  if me <> "sml" then
    if me <> "agr" then
      if me <> "sad" then
        if me = "puz" then
          pPartList.getAt(pPartIndex.getAt("tl")).defineAct(tGesture)
        end if
        exit
      end if
    end if
  end if
end