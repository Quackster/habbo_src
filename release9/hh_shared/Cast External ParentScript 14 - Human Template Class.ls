property pName, pClass, pSex, pCanvasName, pBuffer, pMember, pShadowFix, pDefShadowMem, pPartList, pPartIndex, pFlipList, pUpdateRect, pDirection, pLastDir, pLocFix, pAnimCounter, pEyesClosed, pSync, pChanges, pAlphaColor, pCanvasSize, pColors, pPeopleSize, pMainAction, pMoving, pTalking, pCarrying, pSleeping, pDancing, pWaving, pTrading, pCurrentAnim, pValid

on construct me
  pPartList = []
  pPartIndex = [:]
  pFlipList = [0, 1, 2, 3, 2, 1, 0, 7]
  pUpdateRect = rect(0, 0, 0, 0)
  pLocFix = point(0, 0)
  pAnimCounter = 0
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
  pCurrentAnim = EMPTY
  pAlphaColor = rgb(255, 255, 255)
  pSync = 1
  pColors = [:]
  pDefShadowMem = member(0)
  return 1
end

on deconstruct me
  pValid = 0
  pPartList = []
  if memberExists(pCanvasName) and (pCanvasName <> VOID) then
    removeMember(pCanvasName)
  end if
  return 1
end

on define me, tdata
  pValid = 1
  pName = "template"
  pClass = tdata[#class]
  pDirection = tdata[#direction][1]
  pLastDir = me.pDirection
  me.pPeopleSize = getVariable("human.size." & tdata[#type])
  if not me.pPeopleSize then
    error(me, "People size not found, using default!", #define)
    me.pPeopleSize = "h"
  end if
  me.pCanvasSize = value(getVariable("human.canvas." & me.pPeopleSize))
  if not me.pCanvasSize then
    error(me, "Canvas size not found, using default!", #define)
    me.pCanvasSize = [#std: [64, 102, 32, -10], #lay: [89, 102, 32, -8]]
  end if
  pCanvasName = me.pClass && me.pName && me.getID() && "Canvas"
  if not memberExists(pCanvasName) then
    createMember(pCanvasName, #bitmap)
  end if
  tSize = pCanvasSize[#std]
  pMember = member(getmemnum(pCanvasName))
  pMember.image = image(tSize[1], tSize[2], tSize[3])
  pMember.regPoint = point(0, pMember.image.height + tSize[4])
  pBuffer = pMember.image
  tPartSymbols = tdata[#parts]
  if not me.setPartLists(tdata[#figure]) then
    return error(me, "Couldn't create part lists!", #define)
  end if
  me.arrangeParts()
  me.simulateUpdate()
  return pMember
end

on resetTemplateHuman me
  pMoving = 0
  pDancing = 0
  pTalking = 0
  pCarrying = 0
  pWaving = 0
  pTrading = 0
  pAnimating = 0
  call(#reset, pPartList)
  pMainAction = "std"
  me.arrangeParts()
  pChanges = 1
end

on simulateUpdate me
  if pValid then
    pSync = not pSync
    if pSync then
      me.prepare()
    else
      me.render()
    end if
    me.delay(1000 / the frameTempo, #simulateUpdate)
  end if
end

on Refresh me, tX, tY, tH, tDirHead, tDirBody
  pMoving = 0
  pDancing = 0
  pTalking = 0
  pCarrying = 0
  pWaving = 0
  pTrading = 0
  pCtrlType = 0
  pModState = 0
  pLocFix = point(-1, 2)
  call(#reset, pPartList)
  pMainAction = "std"
  pLocX = tX
  pLocY = tY
  pLocH = tH
  pRestingHeight = 0.0
  call(#defineDir, pPartList, tDirBody)
  if pMainAction <> "lay" then
    call(#defineDirMultiple, pPartList, tDirHead, ["hd", "hr", "ey", "fc"])
  end if
  pDirection = tDirBody
  me.arrangeParts()
  pChanges = 1
end

on setPartModel me, tPart, tmodel
  if voidp(pPartIndex[tPart]) then
    return VOID
  end if
  pPartList[pPartIndex[tPart]].setModel(tmodel)
end

on setPartColor me, tPart, tColor
  if voidp(pPartIndex[tPart]) then
    return VOID
  end if
  pPartList[pPartIndex[tPart]].setColor(tColor)
end

on getPartMember me, tPart
  if voidp(pPartIndex[tPart]) then
    return VOID
  end if
  return pPartList[pPartIndex[tPart]].getCurrentMember()
end

on getPartColor me, tPart
  if voidp(pPartIndex[tPart]) then
    return VOID
  end if
  return pPartList[pPartIndex[tPart]].getColor()
end

on getPicture me, tImg
  if voidp(tImg) then
    tCanvas = image(64, 102, 16)
  else
    tCanvas = tImg
  end if
  call(#copyPicture, pPartList, tCanvas)
  tCanvas = me.flipImage(tCanvas)
  return tCanvas
end

on closeEyes me
  if pMainAction = "lay" then
    call(#defineActMultiple, pPartList, "ley", ["ey"])
  else
    call(#defineActMultiple, pPartList, "eyb", ["ey"])
  end if
  pEyesClosed = 1
  pChanges = 1
end

on openEyes me
  if pMainAction = "lay" then
    call(#defineActMultiple, pPartList, "lay", ["ey"])
  else
    call(#defineActMultiple, pPartList, "std", ["ey"])
  end if
  pEyesClosed = 0
  pChanges = 1
end

on prepare me
  pAnimCounter = (pAnimCounter + 1) mod 4
  if pEyesClosed and not pSleeping then
    me.openEyes()
  else
    if random(30) = 3 then
      me.closeEyes()
    end if
  end if
  if pTalking and (random(3) > 1) then
    if pMainAction = "lay" then
      call(#defineActMultiple, pPartList, "lsp", ["hd", "hr", "fc"])
    else
      call(#defineActMultiple, pPartList, "spk", ["hd", "hr", "fc"])
    end if
    pChanges = 1
  end if
  if pMoving then
    pChanges = 1
  end if
  if pWaving and (pMainAction <> "lay") then
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
    return 
  end if
  pChanges = 0
  pUpdateRect = rect(0, 0, 0, 0)
  pBuffer.fill(pBuffer.rect, pAlphaColor)
  call(#update, pPartList)
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
  repeat with i = 1 to tPartDefinition.count
    tPartSymbol = tPartDefinition[i]
    if voidp(tmodels[tPartSymbol]) then
      tmodels[tPartSymbol] = [:]
    end if
    if voidp(tmodels[tPartSymbol]["model"]) then
      tmodels[tPartSymbol]["model"] = "001"
    end if
    if voidp(tmodels[tPartSymbol]["color"]) then
      tmodels[tPartSymbol]["color"] = rgb("EEEEEE")
    end if
    tPartObj = createObject(#temp, "Bodypart Template Class")
    if stringp(tmodels[tPartSymbol]["color"]) then
      tColor = value("rgb(" & tmodels[tPartSymbol]["color"] & ")")
    end if
    if tmodels[tPartSymbol]["color"].ilk <> #color then
      tColor = rgb(tmodels[tPartSymbol]["color"])
    else
      tColor = tmodels[tPartSymbol]["color"]
    end if
    if (tColor.red + tColor.green + tColor.blue) > (238 * 3) then
      tColor = rgb("EEEEEE")
    end if
    tPartObj.define(tPartSymbol, tmodels[tPartSymbol]["model"], tColor, pDirection, tAction, me)
    pPartList.add(tPartObj)
    pColors[tPartSymbol] = tColor
  end repeat
  pPartIndex = [:]
  repeat with i = 1 to pPartList.count
    pPartIndex[pPartList[i].pPart] = i
  end repeat
  return 1
end

on arrangeParts me
  if pPartIndex["lg"] < pPartIndex["sh"] then
    tIndex1 = pPartIndex["lg"]
    tIndex2 = pPartIndex["sh"]
  else
    tIndex1 = pPartIndex["sh"]
    tIndex2 = pPartIndex["lg"]
  end if
  tLG = pPartList[pPartIndex["lg"]]
  tSH = pPartList[pPartIndex["sh"]]
  case pMainAction of
    "sit", "lay":
      if pFlipList[pDirection + 1] = 0 then
        pPartList[tIndex1] = tSH
        pPartList[tIndex2] = tLG
      else
        pPartList[tIndex1] = tLG
        pPartList[tIndex2] = tSH
      end if
    otherwise:
      pPartList[tIndex1] = tSH
      pPartList[tIndex2] = tLG
  end case
  tRS = pPartList[pPartIndex["rs"]]
  tRH = pPartList[pPartIndex["rh"]]
  tRI = pPartList[pPartIndex["ri"]]
  pPartList.deleteAt(pPartIndex["rs"])
  pPartList.deleteAt(pPartIndex["rh"])
  pPartList.deleteAt(pPartIndex["ri"])
  if (tRH.pActionRh = "drk") and ([0, 6].getPos(pDirection) <> 0) then
    pPartList.addAt(8, tRI)
    pPartList.addAt(9, tRH)
    pPartList.addAt(10, tRS)
  else
    if pDirection = 7 then
      pPartList.addAt(1, tRI)
      pPartList.addAt(2, tRH)
      pPartList.addAt(3, tRS)
    else
      pPartList.append(tRI)
      pPartList.append(tRH)
      pPartList.append(tRS)
    end if
  end if
  repeat with i = 1 to pPartList.count
    pPartIndex[pPartList[i].pPart] = i
  end repeat
  if pLastDir = pDirection then
    return 
  end if
  pLastDir = pDirection
  tLS = pPartList[pPartIndex["ls"]]
  tLH = pPartList[pPartIndex["lh"]]
  tLI = pPartList[pPartIndex["li"]]
  pPartList.deleteAt(pPartIndex["ls"])
  pPartList.deleteAt(pPartIndex["lh"])
  pPartList.deleteAt(pPartIndex["li"])
  case pDirection of
    3:
      pPartList.addAt(8, tLI)
      pPartList.addAt(9, tLH)
      pPartList.addAt(10, tLS)
    otherwise:
      pPartList.addAt(1, tLI)
      pPartList.addAt(2, tLH)
      pPartList.addAt(3, tLS)
  end case
  repeat with i = 1 to pPartList.count
    pPartIndex[pPartList[i].pPart] = i
  end repeat
end

on flipImage me, tImg_a
  tImg_b = image(tImg_a.width, tImg_a.height, tImg_a.depth)
  tQuad = [point(tImg_a.width, 0), point(0, 0), point(0, tImg_a.height), point(tImg_a.width, tImg_a.height)]
  tImg_b.copyPixels(tImg_a, tQuad, tImg_a.rect)
  return tImg_b
end

on action_mv me, tProps
  pMainAction = "wlk"
  pMoving = 1
  call(#defineActMultiple, pPartList, "wlk", ["bd", "lg", "lh", "rh", "ls", "rs", "sh"])
end

on action_sit me, tProps
  call(#defineActMultiple, pPartList, "sit", ["bd", "lg", "sh"])
  pMainAction = "sit"
  me.arrangeParts()
end

on action_lay me, tProps
  pMainAction = "lay"
  pCarrying = 0
  pLocFix = point(30, -10)
  call(#layDown, pPartList)
  if pDirection = 0 then
    pDirection = 4
  end if
  call(#defineDir, pPartList, pDirection)
  me.arrangeParts()
end

on action_carryd me, tProps
  tItem = tProps.word[2]
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    call(#doHandWorkRight, pPartList, "crr")
    pPartList[pPartIndex["ri"]].setModel(tCarryItm)
  end if
end

on action_drink me, tProps
  tItem = tProps.word[2]
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    call(#doHandWorkRight, pPartList, "drk")
    pPartList[pPartIndex["ri"]].setModel(tCarryItm)
    me.arrangeParts()
  end if
end

on action_carryf me, tProps
  tItem = tProps.word[2]
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    call(#doHandWorkRight, pPartList, "crr")
    pPartList[pPartIndex["ri"]].setModel(tCarryItm)
  end if
end

on action_eat me, tProps
  tItem = tProps.word[2]
  if integerp(value(tItem)) then
    tCarrying = tItem
    if variableExists("handitem.right." & tCarrying) then
      tCarryItm = getVariable("handitem.right." & tCarrying, "001")
    else
      tCarryItm = "001"
    end if
    call(#doHandWorkRight, pPartList, "drk")
    pPartList[pPartIndex["ri"]].setModel(tCarryItm)
  end if
end

on action_talk me, tProps
  pTalking = 1
end

on action_gest me, tProps
  if pPeopleSize = "sh" then
    return 
  end if
  tList = ["ey", "fc"]
  tGesture = tProps.word[2]
  if tGesture = "spr" then
    tGesture = "srp"
  end if
  if pMainAction = "lay" then
    tGesture = "l" & tGesture.char[1..2]
    call(#defineActMultiple, pPartList, tGesture, tList)
  else
    call(#defineActMultiple, pPartList, tGesture, tList)
    if tGesture = "ohd" then
      defineAct(pPartList[pPartIndex["hd"]], tGesture)
      defineAct(pPartList[pPartIndex["hr"]], tGesture)
    end if
  end if
end

on action_wave me, tProps
  pWaving = 1
end

on action_ohd me
  call(#defineActMultiple, pPartList, "ohd", ["hd", "fc", "ey", "hr"])
  call(#doHandWorkRight, pPartList, "ohd")
end

on action_sleep me
  pSleeping = 1
end
