property pCanvasName, pValid

on deconstruct me
  callAncestor(#deconstruct, [me])
  pValid = 0
  if memberExists(pCanvasName) and (pCanvasName <> VOID) then
    removeMember(pCanvasName)
  end if
  return 1
end

on define me, tdata
  pValid = 1
  me.pName = "template"
  me.pClass = tdata[#class]
  me.pDirection = tdata[#direction][1]
  me.pHeadDir = me.pDirection
  me.pLastDir = me.pDirection
  me.pPeopleSize = getVariable("human.size." & tdata[#type])
  if not me.pPeopleSize then
    error(me, "People size not found, using default!", #define, #minor)
    me.pPeopleSize = "h"
  end if
  me.pCanvasSize = value(getVariable("human.canvas." & me.pPeopleSize))
  if not me.pCanvasSize then
    error(me, "Canvas size not found, using default!", #define, #minor)
    me.pCanvasSize = [#std: [64, 102, 32, -10], #lay: [89, 102, 32, -8]]
  end if
  pCanvasName = me.pClass && me.pName && me.getID() && "Canvas"
  if not memberExists(pCanvasName) then
    createMember(pCanvasName, #bitmap)
  end if
  tSize = me.pCanvasSize[#std]
  me.pMember = member(getmemnum(pCanvasName))
  me.pMember.image = image(tSize[1], tSize[2], tSize[3])
  me.pMember.regPoint = point(0, me.pMember.image.height + tSize[4])
  me.pBuffer = me.pMember.image
  tPartSymbols = tdata[#parts]
  if not me.setPartLists(tdata[#figure]) then
    return error(me, "Couldn't create part lists!", #define, #major)
  end if
  me.arrangeParts()
  me.simulateUpdate()
  return me.pMember
end

on getMember me
  return me.pMember
end

on resetTemplateHuman me
  me.pMoving = 0
  me.pDancing = 0
  me.pTalking = 0
  me.pCarrying = 0
  me.pWaving = 0
  me.pTrading = 0
  me.pAnimating = 0
  call(#reset, me.pPartList)
  me.resetAction()
  me.arrangeParts()
  me.pChanges = 1
end

on simulateUpdate me
  if pValid then
    me.pSync = not me.pSync
    if me.pSync then
      me.prepare()
    else
      me.render()
    end if
    me.delay(1000 / the frameTempo, #simulateUpdate)
  end if
end

on Refresh me, tX, tY, tH, tDirHead, tDirBody
  me.pMoving = 0
  me.pDancing = 0
  me.pTalking = 0
  me.pCarrying = 0
  me.pWaving = 0
  me.pTrading = 0
  me.pCtrlType = 0
  me.pModState = 0
  me.pLocFix = point(-1, 2)
  call(#reset, me.pPartList)
  me.pMainAction = "std"
  me.pLocX = tX
  me.pLocY = tY
  me.pLocH = tH
  me.pRestingHeight = 0.0
  call(#defineDir, me.pPartList, tDirBody)
  if me.pMainAction <> "lay" then
    call(#defineDirMultiple, me.pPartList, tDirHead, me.pPartListSubSet["head"])
  end if
  me.pDirection = tDirBody
  me.arrangeParts()
  me.pChanges = 1
end

on render me
  if not me.pChanges then
    return 
  end if
  me.pChanges = 0
  me.pUpdateRect = rect(0, 0, 0, 0)
  me.pBuffer.fill(me.pBuffer.rect, me.pAlphaColor)
  call(#update, me.pPartList)
end
