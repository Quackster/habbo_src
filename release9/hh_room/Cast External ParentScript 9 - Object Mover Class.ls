property pActive, pPause, pClientID, pStripID, pMoveProc, pSprList, pLoczList, pLocShiftList, pGeometry, pLastLoc, pSmallSpr, pSavedDim, pSavedDir, pClientObj, pItemLocStr, pOrigCoord

on construct me
  pActive = 0
  pPause = 0
  pClientID = EMPTY
  pStripID = EMPTY
  pMoveProc = #moveActive
  pSprList = []
  pLoczList = []
  pLocShiftList = []
  pGeometry = VOID
  pLastLoc = point(0, 0)
  pSavedDim = 1
  pSavedDir = 2
  pItemLocStr = 0
  pOrigCoord = [0, 0, 0]
  return 1
end

on deconstruct me
  if pClientID <> EMPTY then
    me.clear()
  end if
  removeUpdate(me.getID())
  pActive = 0
  pPause = 0
  pMoveProc = #moveActive
  pClientID = EMPTY
  pSprList = []
  pLoczList = []
  pLocShiftList = []
  pGeometry = VOID
  pSavedDim = 1
  pSavedDir = 2
  pOrigCoord = [0, 0, 0]
  return 1
end

on define me, tClientID, tStripID, tObjType
  if pClientID <> EMPTY then
    return error(me, "Already moving active object:" && pClientID, #define)
  end if
  pClientID = tClientID
  if stringp(tStripID) then
    pStripID = tStripID
  end if
  if pSprList.count > 0 then
    error(me, "Sprites hanging in object mover! Clearing them out...", #define)
    repeat with i = 1 to pSprList.count
      if ilk(pSprList[i], #sprite) then
        releaseSprite(pSprList[i].spriteNum)
      end if
    end repeat
    pSprList = []
  end if
  if ilk(pSmallSpr, #sprite) then
    releaseSprite(pSmallSpr.spriteNum)
  end if
  pSmallSpr = VOID
  case tObjType of
    "active":
      pMoveProc = #moveActive
      tClientObj = getThread(#room).getComponent().getActiveObject(tClientID)
      pLoczList = tClientObj.pLoczList
      pLocShiftList = tClientObj.pLocShiftList
      if objectp(tClientObj) then
        call(#prepareForMove, [tClientObj])
      end if
    "item":
      pMoveProc = #moveItem
      tClientObj = getThread(#room).getComponent().getItemObject(tClientID)
      pLoczList = []
    otherwise:
      error(me, "Invalid object type:" && tObjType, #define)
      tClientObj = 0
  end case
  pClientObj = tClientObj
  if not tClientObj then
    pClientID = EMPTY
    return error(me, "Couldn't find object to move:" && tClientID, #define)
  end if
  tOrigSprList = tClientObj.getSprites()
  if not listp(tOrigSprList) then
    error(me, "List with sprites expected:" && tOrigSprList, #define)
    tOrigSprList = []
  end if
  pOrigCoord = [tClientObj.pLocX, tClientObj.pLocY, tClientObj.pLocH]
  if tOrigSprList.count < 1 then
    pClientID = EMPTY
    pClientObj = EMPTY
    tConnection = getThread(#room).getComponent().getRoomConnection()
    if tConnection <> 0 then
      tConnection.send("GETSTRIP", "new")
    end if
    return error(me, "No sprites found for drawing object for moving.", #define)
  end if
  if getSpriteManager().getProperty(#freeSprCount) < (tOrigSprList.count + 1) then
    return 0
  end if
  repeat with i = 1 to tOrigSprList.count
    tSpr = sprite(reserveSprite(me.getID()))
    setEventBroker(tSpr.spriteNum, "ObjMoverSpr" & i)
    tSpr.setMember(tOrigSprList[i].member)
    tSpr.ink = tOrigSprList[i].ink
    tSpr.rotation = tOrigSprList[i].rotation
    tSpr.skew = tOrigSprList[i].skew
    tSpr.flipH = tOrigSprList[i].flipH
    tSpr.flipV = tOrigSprList[i].flipV
    tSpr.blend = tOrigSprList[i].blend
    tSpr.bgColor = tOrigSprList[i].bgColor
    tTargetID = getThread(#room).getInterface().getID()
    tSpr.registerProcedure(#eventProcRoom, tTargetID, #mouseDown)
    tOrigSprList[i].loc = point(-4000, -4000)
    pSprList.add(tSpr)
  end repeat
  tInfo = tClientObj.getInfo()
  tMemNum = getObject("Preview_renderer").getPreviewMember(tInfo[#image])
  tSmallMem = member(tMemNum)
  pSmallSpr = sprite(reserveSprite(me.getID()))
  pSmallSpr.member = tSmallMem
  pSmallSpr.width = tSmallMem.width
  pSmallSpr.height = tSmallMem.height
  pSmallSpr.ink = 36
  pSmallSpr.blend = 60
  pSmallSpr.loc = point(-1000, -1000)
  pSmallSpr.locZ = 20000000
  if tObjType = "active" then
    pSavedDim = tClientObj.pDimensions
    pSavedDir = tClientObj.pDirection[1]
    tOrigLocX = tClientObj.pLocX
    tOrigLocY = tClientObj.pLocY
    tOrigLocH = tClientObj.pLocH
    if listp(pSavedDim[2]) then
      dy = pSavedDim[2]
    else
      dy = 1
    end if
    if listp(pSavedDim[1]) then
      dx = pSavedDim[1]
    else
      dx = 1
    end if
    repeat with yy = tClientObj.pLocY to tClientObj.pLocY + dy
      repeat with xx = tClientObj.pLocX to tClientObj.pLocX + dx
        if ((yy + 1) > 0) and ((yy + 1) <= pGeometry.getObjectPlaceMap().count) then
          if ((xx + 1) > 0) and ((xx + 1) <= pGeometry.getObjectPlaceMap()[yy + 1].count) then
            pGeometry.getObjectPlaceMap()[yy + 1][xx + 1] = 0
          end if
        end if
      end repeat
    end repeat
  end if
  pActive = 1
  pPause = 0
  registerMessage(#activeObjectRemoved, me.getID(), #checkObjectExists)
  receiveUpdate(me.getID())
  return 1
end

on close me
  return me.clear()
end

on clear me
  removeUpdate(me.getID())
  unregisterMessage(#activeObjectRemoved, me.getID())
  pActive = 0
  pPause = 0
  pClientID = EMPTY
  pStripID = EMPTY
  pSavedDim = 1
  pSavedDir = 2
  pOrigCoord = [0, 0, 0]
  repeat with i = 1 to pSprList.count
    releaseSprite(pSprList[i].spriteNum)
  end repeat
  pSprList = []
  if ilk(pSmallSpr, #sprite) then
    releaseSprite(pSmallSpr.spriteNum)
  end if
  pSmallSpr = VOID
end

on pause me
  pPause = 1
  return 1
end

on resume me
  pPause = 0
  return 1
end

on getProperty me, tProp
  case tProp of
    #Active:
      return pActive
    #pause:
      return pPause
    #clientID:
      return pClientID
    #stripId:
      return pStripID
    #itemLocStr:
      if pItemLocStr = 0 then
        return 0
      end if
      return deobfuscate(pItemLocStr)
    #loc:
      if pPause then
        return pGeometry.getWorldCoordinate(pLastLoc[1], pLastLoc[2])
      else
        return pGeometry.getWorldCoordinate(the mouseH, the mouseV)
      end if
    otherwise:
      return 0
  end case
end

on setProperty me, tProp, tValue
  case tProp of
    #geometry:
      pGeometry = tValue
    otherwise:
      return 0
  end case
end

on update me
  if not pPause then
    call(pMoveProc, me)
  end if
end

on moveActive me
  if (the mouseLoc = pLastLoc) or not pActive then
    return 
  end if
  pLastLoc = the mouseLoc
  pClientObj.ghostObject()
  pClientObj.updateLocation()
  call(#prepareForMove, [pClientObj])
  tloc = pGeometry.getWorldCoordinate(the mouseH, the mouseV)
  if listp(tloc) then
    if listp(pSavedDim[1]) then
      tDX = pSavedDim[1]
    else
      tDX = 1
    end if
    if listp(pSavedDim[2]) then
      tDY = pSavedDim[2]
    else
      tDY = 1
    end if
    tPlaceMap = pGeometry.getObjectPlaceMap()
    repeat with tY = tloc[2] to tloc[2] + tDY - 1
      repeat with tX = tloc[1] to tloc[1] + tDX - 1
        if ((tY + 1) > 0) and ((tY + 1) <= tPlaceMap.count()) then
          if ((tX + 1) > 0) and ((tX + 1) <= tPlaceMap[tY + 1].count()) then
            if tPlaceMap[tY + 1][tX + 1] > 1000 then
              tOccupied = 1
              return 
            end if
          end if
        end if
      end repeat
    end repeat
  end if
  if not tloc or tOccupied then
    me.showSmallPic()
  else
    me.showActualPic(tloc)
  end if
end

on moveItem me
  if (the mouseLoc = pLastLoc) or not pActive then
    return 
  end if
  pLastLoc = the mouseLoc
  pItemLocStr = 0
  if pSprList.count < 1 then
    return 0
  end if
  repeat with i = 1 to pSprList.count
    pSprList[i].locH = (the mouseLoc)[1]
    pSprList[i].locV = (the mouseLoc)[2]
  end repeat
  tClass = pClientObj.getClass()
  if (tClass = "poster") or (tClass contains "post.it") or (tClass = "photo") then
    tProps = [#insideWall: 0]
    tRoomInterface = getThread(#room).getInterface()
    if not voidp(tRoomInterface) then
      tVisual = tRoomInterface.getRoomVisualizer()
      if not voidp(tVisual) then
        tSp = pSprList[1]
        tRp = sprite(tSp).member.regPoint
        tRect = rect(sprite(tSp).locH, sprite(tSp).locV, sprite(tSp).locH, sprite(tSp).locV) + rect(-tRp[1], -tRp[2], sprite(tSp).member.width - tRp[1], sprite(tSp).member.height - tRp[2])
        tProps = tVisual.getWallPartUnderRect(tRect, 0.5)
        if tProps[#insideWall] then
          tProps[#localCoordinate][1] = tProps[#localCoordinate][1] + pSprList[1].member.regPoint[1]
          tProps[#localCoordinate][2] = tProps[#localCoordinate][2] + pSprList[1].member.regPoint[2]
        end if
      end if
    end if
    if tProps[#insideWall] = 0 then
      tProps = me.getWallSpriteItemWithin(pSprList[1])
    end if
    if tProps[#insideWall] = 0 then
      repeat with i = 1 to pSprList.count
        pSprList[i].blend = 30
      end repeat
      pItemLocStr = 0
    else
      repeat with i = 1 to pSprList.count
        pSprList[i].blend = 100
      end repeat
      if voidp(tProps[#wallObject]) then
        tWallObjLoc = tProps[#wallLocation]
      else
        tWallObjLoc = tProps[#wallObject].getLocation()
      end if
      pItemLocStr = obfuscate(":w=" & tWallObjLoc[1] & "," & tWallObjLoc[2] && "l=" & tProps[#localCoordinate][1] & "," & tProps[#localCoordinate][2] && tProps.direction.char[1])
    end if
    tName = pSprList[1].member.name
    if pGeometry.pXFactor = 32 then
      tMemNum = getmemnum("s_" & tProps[#direction] && tName.word[2..tName.word.count])
    else
      tMemNum = getmemnum(tProps[#direction] && tName.word[2..tName.word.count])
    end if
    if tMemNum = 0 then
      return 0
    end if
    if tMemNum < 1 then
      tMemNum = abs(tMemNum)
      pSprList[1].flipH = 1
    else
      pSprList[1].flipH = 0
    end if
    pSprList[1].castNum = tMemNum
    if tProps[#wallSprites] <> 0 then
      tSprites = tProps[#wallSprites]
      tlocz = tSprites[1].locZ
      if tlocz < -1000000 then
        tlocz = tlocz + 20100
      end if
      if tSprites.count > 1 then
        if tSprites[2].locZ > tlocz then
          tlocz = tSprites[2].locZ
        end if
      end if
      pSprList[1].locZ = tlocz + 2
    end if
  end if
end

on moveTrade me
  if (the mouseLoc = pLastLoc) or not pActive then
    return 
  end if
  pLastLoc = the mouseLoc
  pMoveProc = #moveTrade
  pSmallSpr.blend = 100
  me.showSmallPic()
end

on cancelMove me
  tClickAction = getThread(#room).getInterface().getProperty(#clickAction)
  case tClickAction of
    "moveActive", "moveItem":
      tLocX = pOrigCoord[1]
      tLocY = pOrigCoord[2]
      tLocH = pOrigCoord[3]
      tObj = getThread(#room).getComponent().getActiveObject(pClientID)
      if tObj = 0 then
        return 0
      end if
      tObj.moveTo(tLocX, tLocY, tLocH)
    "placeActive", "placeItem":
      getThread(#room).getComponent().getRoomConnection().send("GETSTRIP", "update")
  end case
end

on showSmallPic me
  if not voidp(pSmallSpr) then
    pSmallSpr.loc = the mouseLoc
  end if
  repeat with i = 1 to pSprList.count
    pSprList[i].loc = point(-1000, -1000)
  end repeat
end

on showActualPic me, tloc
  if not voidp(pSmallSpr) then
    pSmallSpr.loc = point(-1000, -1000)
  end if
  if voidp(tloc) then
    tloc = pGeometry.getWorldCoordinate(the mouseH, the mouseV)
  end if
  if not tloc then
    return me.showSmallPic()
  end if
  tScreenCoord = pGeometry.getScreenCoordinate(tloc[1], tloc[2], tloc[3])
  repeat with i = 1 to pSprList.count
    pSprList[i].loc = point(tScreenCoord[1], tScreenCoord[2])
    if pSprList[i].rotation = 180 then
      pSprList[i].locH = tScreenCoord[1] + pGeometry.pXFactor
    end if
    pSprList[i].loc = pSprList[i].loc + pLocShiftList[i][pSavedDir + 1]
    tZ = pLoczList[i][pSavedDir + 1]
    pSprList[i].locZ = tScreenCoord[3] + (pClientObj.pLocH * 1000) + tZ - 1
  end repeat
  pClientObj.relocate(pSprList)
end

on getWallSpriteItemWithin me, tSpr
  tRoomInterface = getThread(#room).getInterface()
  tRoomComponent = getThread(#room).getComponent()
  tItemRp = tSpr.member.regPoint
  tItemR = rect(tSpr.locH, tSpr.locV, tSpr.locH, tSpr.locV) + rect(-tItemRp[1], -tItemRp[2], tSpr.member.width - tItemRp[1], tSpr.member.height - tItemRp[2])
  tWallObjectUnder = me.getPassiveObjectIntersectingRect(tItemR)[1]
  if tWallObjectUnder = 0 then
    return [#direction: "rightwall", #wallSprite: 0, #insideWall: 0]
  end if
  tDirection = tWallObjectUnder.getDirection()
  tCorner = 0
  tWallCheckSprList = tWallObjectUnder.getSprites()
  tWallCheckSpr = tWallCheckSprList[1]
  if tWallCheckSprList.count > 1 then
    if tWallCheckSprList[1].rect = tWallCheckSprList[2].rect then
      tWallCheckSprList.deleteAt(2)
    end if
  end if
  if (tDirection[1] = 3) or (tWallCheckSprList.count > 1) then
    if tWallCheckSprList.count = 1 then
      if tSpr.locH < tWallCheckSpr.locH then
        tWallDir = 0
      else
        tWallDir = 2
      end if
    else
      if tWallObjectUnder.getSprites()[1].right < tWallObjectUnder.getSprites()[2].right then
        if tSpr.locH < tWallObjectUnder.getSprites()[1].right then
          tWallDir = 2
          tWallCheckSpr = tWallObjectUnder.getSprites()[1]
        else
          tWallDir = 0
          tWallCheckSpr = tWallObjectUnder.getSprites()[2]
        end if
      else
        if tSpr.locH < tWallObjectUnder.getSprites()[2].right then
          tWallDir = 2
          tWallCheckSpr = tWallObjectUnder.getSprites()[2]
        else
          tWallDir = 0
          tWallCheckSpr = tWallObjectUnder.getSprites()[1]
        end if
      end if
    end if
    tCorner = 1
  else
    if tDirection[1] = 1 then
      if tSpr.locH < tWallObjectUnder.getSprites()[1].locH then
        tWallDir = 2
      else
        tWallDir = 0
      end if
      tCorner = 1
    else
      tWallDir = tDirection[1]
    end if
  end if
  case tWallDir of
    0:
      tCornerA = point(tSpr.loc[1] - tSpr.member.regPoint[1] + tSpr.member.width, tSpr.loc[2] - tSpr.member.regPoint[2])
      tCornerB = point(tSpr.loc[1] - tSpr.member.regPoint[1], tSpr.loc[2] - tSpr.member.regPoint[2] + tSpr.member.height)
      tDirName = "leftwall"
    2:
      tCornerA = point(tSpr.loc[1] - tSpr.member.regPoint[1], tSpr.loc[2] - tSpr.member.regPoint[2])
      tCornerB = point(tSpr.loc[1] - tSpr.member.regPoint[1] + tSpr.member.width, tSpr.loc[2] - tSpr.member.regPoint[2] + tSpr.member.height)
      tDirName = "rightwall"
  end case
  tRects = [rect(tCornerA[1], tCornerA[2], tCornerA[1] + 1, tCornerA[2] + 1), rect(tCornerB[1], tCornerB[2], tCornerB[1] + 1, tCornerB[2] + 1)]
  tWallInfo = [me.getPassiveObjectIntersectingRect(tRects[1]), me.getPassiveObjectIntersectingRect(tRects[2])]
  tWallObjs = [tWallInfo[1][1], tWallInfo[2][1]]
  if tCorner = 1 then
    if (tWallObjs[1] = tWallObjs[2]) and (tWallInfo[1][2] <> tWallInfo[2][2]) then
      return [#direction: tDirName, #wallSprites: tWallObjectUnder.getSprites(), #insideWall: 0]
    end if
  end if
  repeat with i = 1 to 2
    tWallObj = tWallObjs[i]
    tRect = tRects[i]
    if voidp(tWallObj) then
      return [#direction: tDirName, #wallSprites: tWallObjectUnder.getSprites(), #insideWall: 0]
      next repeat
    end if
    tWallSpr = tWallObj.getSprites()[1]
    if tWallObj = tWallObjectUnder then
      tWallSpr = tWallCheckSpr
    end if
    tLocalCoordinate = point(tRect[1] - tWallSpr.left, tRect[2] - tWallSpr.top)
    if (tLocalCoordinate[1] < 0) or (tLocalCoordinate[2] < 0) then
      return [#direction: tDirName, #wallSprites: tWallObjectUnder.getSprites(), #insideWall: 0]
    end if
    tLocalPixel = tWallSpr.member.image.getPixel(tLocalCoordinate[1], tLocalCoordinate[2])
    if tLocalPixel = paletteIndex(0) then
      return [#direction: tDirName, #wallSprites: tWallObjectUnder.getSprites(), #insideWall: 0]
    end if
  end repeat
  if (tWallObjs[1].getDirection() <> tWallObjs[2].getDirection()) and ((tWallObjs[1].getDirection()[1] <> 3) and (tWallObjs[2].getDirection()[1] <> 3)) then
    return [#direction: tDirName, #wallSprites: tWallObjectUnder.getSprites(), #insideWall: 0]
  end if
  tWallSpr = tWallObjs[1].getSprites()[1]
  tLocalCoordinate = point(tSpr.loc[1] - tWallSpr.left, tSpr.loc[2] - tWallSpr.top)
  return [#direction: tDirName, #wallSprites: tWallObjectUnder.getSprites(), #insideWall: 1, #wallObject: tWallObjs[1], #localCoordinate: tLocalCoordinate]
end

on getPassiveObjectIntersectingRect me, tItemR
  tPieceList = getThread(#room).getComponent().getPassiveObject(#list)
  tPieceObjUnder = VOID
  tPieceSprUnder = 0
  tPieceUnderLocZ = -1000000000
  repeat with tPiece in tPieceList
    tSprites = tPiece.getSprites()
    repeat with tPieceSpr in tSprites
      tRp = sprite(tPieceSpr).member.regPoint
      tR = rect(sprite(tPieceSpr).locH, sprite(tPieceSpr).locV, sprite(tPieceSpr).locH, sprite(tPieceSpr).locV) + rect(-tRp[1], -tRp[2], sprite(tPieceSpr).member.width - tRp[1], sprite(tPieceSpr).member.height - tRp[2])
      if (intersect(tItemR, tR) <> rect(0, 0, 0, 0)) and (tPieceUnderLocZ < tPieceSpr.locZ) then
        tPieceObjUnder = tPiece
        tPieceSprUnder = tPieceSpr
        tPieceUnderLocZ = tPieceSpr.locZ
      end if
    end repeat
  end repeat
  return [tPieceObjUnder, tPieceSprUnder]
end

on checkObjectExists me
  tObj = getThread(#room).getComponent().getActiveObject(pClientID)
  if tObj = 0 then
    getThread(#room).getInterface().stopObjectMover()
  end if
end
