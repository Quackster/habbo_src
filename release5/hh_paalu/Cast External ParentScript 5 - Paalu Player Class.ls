property pName, pBalance, pLocation, pAction, pDirection, pZeroLoc, pLocZFix, pMoveDir, pPartList, pSprite, pMember, pBuffer, pLastTime, pAnimTime, pUpdate, pIsDropping, pDropCounter, pDropMaxCnt, pDropOffset, pDropPoint, pSplashPoint

on construct me
  pName = EMPTY
  pBalance = 0
  pLocation = 0
  pAction = "std"
  pDirection = 0
  pZeroLoc = point(0, 0)
  pMoveDir = [8, -4]
  pLocZFix = 0
  pPartList = [:]
  pSprite = sprite(reserveSprite(me.getID()))
  pMember = member(createMember(me.getID() && "CanvasX", #bitmap))
  pBuffer = image(40, 58, 32)
  pMember.image = pBuffer.duplicate()
  pMember.regPoint = point(-2, pMember.height - 10)
  pSprite.member = pMember
  pSprite.visible = 0
  pSprite.ink = 36
  tObj = createObject(#temp, "Paalu Player - Hit")
  pPartList["fx"] = tObj
  tObj = createObject(#temp, "Paalu Player - Hand")
  pPartList["lh"] = tObj
  tObj = createObject(#temp, "Paalu Player - Torso")
  pPartList["bd"] = tObj
  tObj = createObject(#temp, "Paalu Player - Hand")
  pPartList["rh"] = tObj
  tObj = createObject(#temp, "Paalu Player - Head")
  pPartList["hd"] = tObj
  tObj = createObject(#temp, "Paalu Player - Splash")
  pPartList["sp"] = tObj
  pLastTime = the milliSeconds
  pAnimTime = 500
  pUpdate = 1
  pIsDropping = 0
  pDropCounter = 0
  pDropPoint = point(0, 0)
  pDropMaxCnt = 16
  pDropOffset = 0
  pSplashPoint = point(0, 0)
  setEventBroker(pSprite.spriteNum, me.getID())
  pSprite.registerProcedure(#peeloProc, me.getID(), #mouseUp)
  return 1
end

on deconstruct me
  removePrepare(me.getID())
  call(#reset, pPartList)
  call(#deconstruct, pPartList)
  pBuffer = VOID
  pPartList = [:]
  releaseSprite(pSprite.spriteNum)
  removeMember(pMember.name)
  return 1
end

on define me, tProps
  pName = tProps[#name]
  pDirection = tProps[#dir]
  tUserObj = getThread(#room).getComponent().getUserObject(pName)
  if not tUserObj then
    return error(me, "User object not found:" && pName & "!", #define)
  end if
  tloc = tUserObj.getLocation()
  tScrLoc = getThread(#room).getInterface().getGeometry().getScreenCoordinate(tloc[1], tloc[2], tloc[3])
  tZeroLoc = getVariableValue("paalu.zero.loc", [354, 382])
  pZeroLoc = point(tZeroLoc[1], tZeroLoc[2])
  pSprite.loc = tScrLoc
  pSprite.locZ = tScrLoc[3] + 1000
  pSprite.visible = 1
  tFigureData = tUserObj.getPelleFigure()
  tProps = [#dir: pDirection, #figure: tFigureData, #buffer: pBuffer]
  pPartList["fx"].define("fx", tProps)
  pPartList["lh"].define("lh", tProps)
  pPartList["bd"].define("bd", tProps)
  pPartList["rh"].define("rh", tProps)
  pPartList["hd"].define("hd", tProps)
  pPartList["sp"].define("sp", tProps)
  if pDirection = 4 then
    pLocZFix = 5010
  else
    pLocZFix = 5020
    tPartList = [:]
    tPartList["fx"] = pPartList["fx"]
    tPartList["rh"] = pPartList["rh"]
    tPartList["bd"] = pPartList["bd"]
    tPartList["lh"] = pPartList["lh"]
    tPartList["hd"] = pPartList["hd"]
    tPartList["sp"] = pPartList["sp"]
    pPartList = tPartList
  end if
  pUpdate = 1
  pIsDropping = 0
  pDropCounter = 0
  pDropMaxCnt = 16
  pDropOffset = [0, 0]
  pDropPoint = point(0, 0)
  tUserObj.hide()
  receivePrepare(me.getID())
  return 1
end

on reset me
  removePrepare(me.getID())
  call(#reset, pPartList)
  tUserObj = getThread(#room).getComponent().getUserObject(pName)
  if objectp(tUserObj) then
    tUserObj.show()
  end if
  pName = EMPTY
  pBalance = 0
  pLocation = 0
  pDirection = 0
  pAction = "std"
  pIsDropping = 0
  pDropCounter = 0
  pDropMaxCnt = 16
  pDropOffset = [0, 0]
  pDropPoint = point(0, 0)
  pBuffer.fill(pBuffer.rect, rgb(255, 255, 255))
  pMember.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
  pSprite.visible = 0
end

on prepare me
  if pUpdate then
    call(#prepare, pPartList)
    me.render()
  end if
  if pIsDropping then
    pDropCounter = (pDropCounter + 2) mod pDropMaxCnt
    tOffset = -50 * sin(float(pDropCounter) / 10)
    pSprite.loc = pDropPoint + [0, tOffset] + pDropOffset
    pDropPoint = pDropPoint + pDropOffset
    if pDropCounter = 0 then
      pIsDropping = 0
      pSprite.visible = 0
      pPartList["sp"].splash(pSplashPoint, pSprite.locZ + 10)
    end if
  end if
  pUpdate = not pUpdate
end

on render me
  pBuffer.fill(pBuffer.rect, rgb(255, 255, 255))
  call(#render, pPartList, pBuffer)
  pMember.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
end

on status me, tStatus
  pLocation = tStatus[#loc]
  pBalance = tStatus[#bal]
  case tStatus[#act] of
    "-":
      pAction = "std"
    "X":
      pAction = "wlk"
    "S":
      pAction = "wlk"
    "W":
      pAction = "hit1"
    "E":
      pAction = "hit2"
    "A":
      pAction = "std"
    "D":
      pAction = "std"
    otherwise:
      pAction = "std"
  end case
  pSprite.loc = pZeroLoc + (pLocation * pMoveDir)
  tWorldCrd = getThread(#room).getInterface().getGeometry().getWorldCoordinate(pSprite.locH, pSprite.locV)
  if tWorldCrd <> 0 then
    pSprite.locZ = getThread(#room).getInterface().getGeometry().getScreenCoordinate(tWorldCrd[1], tWorldCrd[2], tWorldCrd[3])[3] + pLocZFix
  else
    pSprite.locZ = -100000
  end if
  tAnimBal = (pBalance / 20) + 2
  if tAnimBal < 0 then
    tAnimBal = 0
  end if
  if tAnimBal > 4 then
    tAnimBal = 4
  end if
  call(#status, pPartList, pAction, tAnimBal, pSprite.loc + [pSprite.member.width / 2, -4], pSprite.locZ, tStatus[#hit])
end

on drop me
  pIsDropping = 1
  pDropCounter = 0
  pDropPoint = pSprite.loc
  pAction = "drp"
  if pBalance < 0 then
    pDropOffset = [-1, 0]
    pDropMaxCnt = 28
    tAnimBal = 0
    pSplashPoint = pDropPoint + [-16, -8]
  else
    pDropOffset = [1, 0]
    pDropMaxCnt = 38
    tAnimBal = 4
    pSplashPoint = pDropPoint + [16, 8]
  end if
  call(#status, pPartList, pAction, tAnimBal, pSprite.loc + [pSprite.member.width / 2, -4], pSprite.locZ, 0)
end

on getBalance me
  return pBalance
end

on setDir me, tdir
  pDirection = tdir
end

on peeloProc me, tEvent, tSprID, tParam
  getThread(#room).getInterface().eventProcUserObj(tEvent, pName, tParam)
end
