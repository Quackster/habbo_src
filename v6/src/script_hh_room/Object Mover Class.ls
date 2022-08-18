property pClientID, pSprList, pSmallSpr, pSavedDim, pGeometry, pActive, pPause, pStripID, pItemLocStr, pLastLoc, pMoveProc, pClientObj, pOrigCoord, pLoczList, pSavedDir

on construct me 
  pActive = 0
  pPause = 0
  pClientID = ""
  pStripID = ""
  pMoveProc = #moveActive
  pSprList = []
  pLocList = []
  pLoczList = []
  pGeometry = void()
  pLastLoc = point(0, 0)
  pSavedDim = 1
  pSavedDir = 2
  pItemLocStr = 0
  pOrigCoord = [0, 0, 0]
  return TRUE
end

on deconstruct me 
  if pClientID <> "" then
    me.clear()
  end if
  removeUpdate(me.getID())
  pActive = 0
  pPause = 0
  pMoveProc = #moveActive
  pClientID = ""
  pSprList = []
  pLocList = []
  pLoczList = []
  pGeometry = void()
  pSavedDim = 1
  pSavedDir = 2
  pOrigCoord = [0, 0, 0]
  return TRUE
end

on define me, tClientID, tStripID, tObjType 
  if pClientID <> "" then
    return(error(me, "Already moving active object:" && pClientID, #define))
  end if
  pClientID = tClientID
  if stringp(tStripID) then
    pStripID = tStripID
  end if
  if pSprList.count > 0 then
    error(me, "Sprites hanging in object mover! Clearing them out...", #define)
    i = 1
    repeat while i <= pSprList.count
      if ilk(pSprList.getAt(i), #sprite) then
        releaseSprite(pSprList.getAt(i).spriteNum)
      end if
      i = (1 + i)
    end repeat
    pSprList = []
  end if
  if ilk(pSmallSpr, #sprite) then
    releaseSprite(pSmallSpr.spriteNum)
  end if
  pSmallSpr = void()
  if (tObjType = "active") then
    pMoveProc = #moveActive
    tClientObj = getThread(#room).getComponent().getActiveObject(tClientID)
    pLoczList = tClientObj.pLoczList
  else
    if (tObjType = "item") then
      pMoveProc = #moveItem
      tClientObj = getThread(#room).getComponent().getItemObject(tClientID)
      pLoczList = []
    else
      error(me, "Invalid object type:" && tObjType, #define)
      tClientObj = 0
    end if
  end if
  pClientObj = tClientObj
  if not tClientObj then
    pClientID = ""
    return(error(me, "Couldn't find object to move:" && tClientID, #define))
  end if
  tOrigSprList = tClientObj.getSprites()
  if not listp(tOrigSprList) then
    error(me, "List with sprites expected:" && tOrigSprList, #define)
    tOrigSprList = []
  end if
  pOrigCoord = [tClientObj.pLocX, tClientObj.pLocY, tClientObj.pLocH]
  i = 1
  repeat while i <= tOrigSprList.count
    tSpr = sprite(reserveSprite(me.getID()))
    setEventBroker(tSpr.spriteNum, "ObjMoverSpr" & i)
    tSpr.setMember(tOrigSprList.getAt(i).member)
    tSpr.ink = tOrigSprList.getAt(i).ink
    tSpr.rotation = tOrigSprList.getAt(i).rotation
    tSpr.skew = tOrigSprList.getAt(i).skew
    tSpr.flipH = tOrigSprList.getAt(i).flipH
    tSpr.flipV = tOrigSprList.getAt(i).flipV
    tSpr.blend = tOrigSprList.getAt(i).blend
    tSpr.bgColor = tOrigSprList.getAt(i).bgColor
    tTargetID = getThread(#room).getInterface().getID()
    tSpr.registerProcedure(#eventProcRoom, tTargetID, #mouseDown)
    tOrigSprList.getAt(i).loc = point(-4000, -4000)
    pSprList.add(tSpr)
    i = (1 + i)
  end repeat
  if tOrigSprList.count > 0 then
    tInfo = tClientObj.getInfo()
    tSmallName = tInfo.getAt(#smallmember)
    if not memberExists(tSmallName) then
      tSmallName = tOrigSprList.getAt(1).member.name.getProp(#char, 1, (length(tOrigSprList.getAt(1).member.name) - 11)) & "small"
    end if
    if not memberExists(tSmallName) then
      tSmallName = tOrigSprList.getAt(1).member.name
    end if
    tSmallMem = member(getmemnum(tSmallName))
    pSmallSpr = sprite(reserveSprite(me.getID()))
    pSmallSpr.member = tSmallMem
    pSmallSpr.width = tSmallMem.width
    pSmallSpr.height = tSmallMem.height
    pSmallSpr.ink = 36
    pSmallSpr.blend = 60
    pSmallSpr.loc = point(-1000, -1000)
    pSmallSpr.locZ = 20000000
  end if
  if (tObjType = "active") then
    pSavedDim = tClientObj.pDimensions
    pSavedDir = tClientObj.getProp(#pDirection, 1)
    tOrigLocX = tClientObj.pLocX
    tOrigLocY = tClientObj.pLocY
    tOrigLocH = tClientObj.pLocH
    if listp(pSavedDim.getAt(2)) then
      dy = pSavedDim.getAt(2)
    else
      dy = 1
    end if
    if listp(pSavedDim.getAt(1)) then
      dx = pSavedDim.getAt(1)
    else
      dx = 1
    end if
    yy = tClientObj.pLocY
    repeat while yy <= (tClientObj.pLocY + dy)
      xx = tClientObj.pLocX
      repeat while xx <= (tClientObj.pLocX + dx)
        if (yy + 1) > 0 and (yy + 1) <= pGeometry.getObjectPlaceMap().count then
          if (xx + 1) > 0 and (xx + 1) <= pGeometry.getObjectPlaceMap().getAt((yy + 1)).count then
            pGeometry.getObjectPlaceMap().getAt((yy + 1)).setAt((xx + 1), 0)
          end if
        end if
        xx = (1 + xx)
      end repeat
      yy = (1 + yy)
    end repeat
  end if
  pActive = 1
  pPause = 0
  registerMessage(#activeObjectRemoved, me.getID(), #checkObjectExists)
  receiveUpdate(me.getID())
  return TRUE
end

on close me 
  return(me.clear())
end

on clear me 
  removeUpdate(me.getID())
  unregisterMessage(#activeObjectRemoved)
  pActive = 0
  pPause = 0
  pClientID = ""
  pStripID = ""
  pSavedDim = 1
  pSavedDir = 2
  pOrigCoord = [0, 0, 0]
  i = 1
  repeat while i <= pSprList.count
    releaseSprite(pSprList.getAt(i).spriteNum)
    i = (1 + i)
  end repeat
  pSprList = []
  if ilk(pSmallSpr, #sprite) then
    releaseSprite(pSmallSpr.spriteNum)
  end if
  pSmallSpr = void()
end

on pause me 
  pPause = 1
  return TRUE
end

on resume me 
  pPause = 0
  return TRUE
end

on getProperty me, tProp 
  if (tProp = #Active) then
    return(pActive)
  else
    if (tProp = #pause) then
      return(pPause)
    else
      if (tProp = #clientID) then
        return(pClientID)
      else
        if (tProp = #stripId) then
          return(pStripID)
        else
          if (tProp = #itemLocStr) then
            return(pItemLocStr)
          else
            if (tProp = #loc) then
              if pPause then
                return(pGeometry.getWorldCoordinate(pLastLoc.getAt(1), pLastLoc.getAt(2)))
              else
                return(pGeometry.getWorldCoordinate(the mouseH, the mouseV))
              end if
            else
              return FALSE
            end if
          end if
        end if
      end if
    end if
  end if
end

on setProperty me, tProp, tValue 
  if (tProp = #geometry) then
    pGeometry = tValue
  else
    return FALSE
  end if
end

on update me 
  if not pPause then
    call(pMoveProc, me)
  end if
end

on moveActive me 
  if (the mouseLoc = pLastLoc) or not pActive then
    return()
  end if
  pLastLoc = the mouseLoc
  tloc = pGeometry.getWorldCoordinate(the mouseH, the mouseV)
  if listp(tloc) then
    if listp(pSavedDim.getAt(1)) then
      tDX = pSavedDim.getAt(1)
    else
      tDX = 1
    end if
    if listp(pSavedDim.getAt(2)) then
      tDY = pSavedDim.getAt(2)
    else
      tDY = 1
    end if
    tPlaceMap = pGeometry.getObjectPlaceMap()
    tY = tloc.getAt(2)
    repeat while tY <= ((tloc.getAt(2) + tDY) - 1)
      tX = tloc.getAt(1)
      repeat while tX <= ((tloc.getAt(1) + tDX) - 1)
        if (tY + 1) > 0 and (tY + 1) <= tPlaceMap.count() then
          if (tX + 1) > 0 and (tX + 1) <= tPlaceMap.getAt((tY + 1)).count() then
            if tPlaceMap.getAt((tY + 1)).getAt((tX + 1)) > 1000 then
              tOccupied = 1
              return()
            end if
          end if
        end if
        tX = (1 + tX)
      end repeat
      tY = (1 + tY)
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
    return()
  end if
  pLastLoc = the mouseLoc
  pItemLocStr = 0
  if pSprList.count < 1 then
    return FALSE
  end if
  i = 1
  repeat while i <= pSprList.count
    pSprList.getAt(i).locH = the mouseLoc.getAt(1)
    pSprList.getAt(i).locV = the mouseLoc.getAt(2)
    i = (1 + i)
  end repeat
  tClass = pClientObj.getClass()
  if (tClass = "poster") or tClass contains "post.it" or (tClass = "photo") then
    tProps = me.getWallSpriteItemWithin(pSprList.getAt(1))
    if (tProps.getAt(#insideWall) = 0) then
      i = 1
      repeat while i <= pSprList.count
        pSprList.getAt(i).blend = 30
        i = (1 + i)
      end repeat
      pItemLocStr = 0
    else
      i = 1
      repeat while i <= pSprList.count
        pSprList.getAt(i).blend = 100
        i = (1 + i)
      end repeat
      tWallObjLoc = tProps.getAt(#wallObject).getLocation()
      pItemLocStr = ":w=" & tWallObjLoc.getAt(1) & "," & tWallObjLoc.getAt(2) && "l=" & tProps.getAt(#localCoordinate).getAt(1) & "," & tProps.getAt(#localCoordinate).getAt(2) && tProps.direction.getProp(#char, 1)
    end if
    tName = pSprList.getAt(1).member.name
    pSprList.getAt(1).castNum = getmemnum(tProps.getAt(#direction) && tName.getProp(#word, 2, tName.count(#word)))
    if tProps.getAt(#wallSprites) <> 0 then
      tSprites = tProps.getAt(#wallSprites)
      tlocz = tSprites.getAt(1).locZ
      if tSprites.count > 1 then
        if tSprites.getAt(2).locZ > tlocz then
          tlocz = tSprites.getAt(2).locZ
        end if
      end if
      pSprList.getAt(1).locZ = (tlocz + 2)
    end if
  end if
end

on moveTrade me 
  if (the mouseLoc = pLastLoc) or not pActive then
    return()
  end if
  pLastLoc = the mouseLoc
  pMoveProc = #moveTrade
  pSmallSpr.blend = 100
  me.showSmallPic()
end

on cancelMove me 
  tClickAction = getThread(#room).getInterface().getProperty(#clickAction)
  if tClickAction <> "moveActive" then
    if (tClickAction = "moveItem") then
      tLocX = pOrigCoord.getAt(1)
      tLocY = pOrigCoord.getAt(2)
      tLocH = pOrigCoord.getAt(3)
      tObj = getThread(#room).getComponent().getActiveObject(pClientID)
      if (tObj = 0) then
        return FALSE
      end if
      tObj.moveTo(tLocX, tLocY, tLocH)
    else
      if tClickAction <> "placeActive" then
        if (tClickAction = "placeItem") then
          getThread(#room).getComponent().getRoomConnection().send("GETSTRIP", "new")
        end if
      end if
    end if
  end if
end

on showSmallPic me 
  if not voidp(pSmallSpr) then
    pSmallSpr.loc = the mouseLoc
  end if
  i = 1
  repeat while i <= pSprList.count
    pSprList.getAt(i).loc = point(-1000, -1000)
    i = (1 + i)
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
    return(me.showSmallPic())
  end if
  tScreenCoord = pGeometry.getScreenCoordinate(tloc.getAt(1), tloc.getAt(2), tloc.getAt(3))
  i = 1
  repeat while i <= pSprList.count
    pSprList.getAt(i).loc = point(tScreenCoord.getAt(1), tScreenCoord.getAt(2))
    if (pSprList.getAt(i).rotation = 180) then
      pSprList.getAt(i).locH = (tScreenCoord.getAt(1) + pGeometry.pXFactor)
    end if
    tZ = pLoczList.getAt(i).getAt((pSavedDir + 1))
    pSprList.getAt(i).locZ = (((tScreenCoord.getAt(3) + (pClientObj.pLocH * 1000)) + tZ) - 1)
    i = (1 + i)
  end repeat
end

on getWallSpriteItemWithin me, tSpr 
  tRoomInterface = getThread(#room).getInterface()
  tRoomComponent = getThread(#room).getComponent()
  tItemRp = tSpr.member.regPoint
  tItemR = (rect(tSpr.locH, tSpr.locV, tSpr.locH, tSpr.locV) + rect(-tItemRp.getAt(1), -tItemRp.getAt(2), (tSpr.member.width - tItemRp.getAt(1)), (tSpr.member.height - tItemRp.getAt(2))))
  tWallObjectUnder = me.getPassiveObjectIntersectingRect(tItemR).getAt(1)
  if (tWallObjectUnder = 0) then
    return([#direction:"rightwall", #wallSprite:0, #insideWall:0])
  end if
  tDirection = tWallObjectUnder.getDirection()
  tCorner = 0
  tWallCheckSprList = tWallObjectUnder.getSprites()
  tWallCheckSpr = tWallCheckSprList.getAt(1)
  if tWallCheckSprList.count > 1 then
    if (tWallCheckSprList.getAt(1).rect = tWallCheckSprList.getAt(2).rect) then
      tWallCheckSprList.deleteAt(2)
    end if
  end if
  if (tDirection.getAt(1) = 3) or tWallCheckSprList.count > 1 then
    if (tWallCheckSprList.count = 1) then
      if tSpr.locH < tWallCheckSpr.locH then
        tWallDir = 0
      else
        tWallDir = 2
      end if
    else
      if tWallObjectUnder.getSprites().getAt(1).right < tWallObjectUnder.getSprites().getAt(2).right then
        if tSpr.locH < tWallObjectUnder.getSprites().getAt(1).right then
          tWallDir = 2
          tWallCheckSpr = tWallObjectUnder.getSprites().getAt(1)
        else
          tWallDir = 0
          tWallCheckSpr = tWallObjectUnder.getSprites().getAt(2)
        end if
      else
        if tSpr.locH < tWallObjectUnder.getSprites().getAt(2).right then
          tWallDir = 2
          tWallCheckSpr = tWallObjectUnder.getSprites().getAt(2)
        else
          tWallDir = 0
          tWallCheckSpr = tWallObjectUnder.getSprites().getAt(1)
        end if
      end if
    end if
    tCorner = 1
  else
    if (tDirection.getAt(1) = 1) then
      if tSpr.locH < tWallObjectUnder.getSprites().getAt(1).locH then
        tWallDir = 2
      else
        tWallDir = 0
      end if
      tCorner = 1
    else
      tWallDir = tDirection.getAt(1)
    end if
  end if
  if (tWallDir = 0) then
    tCornerA = point(((tSpr.getProp(#loc, 1) - tSpr.member.getProp(#regPoint, 1)) + tSpr.member.width), (tSpr.getProp(#loc, 2) - tSpr.member.getProp(#regPoint, 2)))
    tCornerB = point((tSpr.getProp(#loc, 1) - tSpr.member.getProp(#regPoint, 1)), ((tSpr.getProp(#loc, 2) - tSpr.member.getProp(#regPoint, 2)) + tSpr.member.height))
    tDirName = "leftwall"
  else
    if (tWallDir = 2) then
      tCornerA = point((tSpr.getProp(#loc, 1) - tSpr.member.getProp(#regPoint, 1)), (tSpr.getProp(#loc, 2) - tSpr.member.getProp(#regPoint, 2)))
      tCornerB = point(((tSpr.getProp(#loc, 1) - tSpr.member.getProp(#regPoint, 1)) + tSpr.member.width), ((tSpr.getProp(#loc, 2) - tSpr.member.getProp(#regPoint, 2)) + tSpr.member.height))
      tDirName = "rightwall"
    end if
  end if
  tRects = [rect(tCornerA.getAt(1), tCornerA.getAt(2), (tCornerA.getAt(1) + 1), (tCornerA.getAt(2) + 1)), rect(tCornerB.getAt(1), tCornerB.getAt(2), (tCornerB.getAt(1) + 1), (tCornerB.getAt(2) + 1))]
  tWallInfo = [me.getPassiveObjectIntersectingRect(tRects.getAt(1)), me.getPassiveObjectIntersectingRect(tRects.getAt(2))]
  tWallObjs = [tWallInfo.getAt(1).getAt(1), tWallInfo.getAt(2).getAt(1)]
  if (tCorner = 1) then
    if (tWallObjs.getAt(1) = tWallObjs.getAt(2)) and tWallInfo.getAt(1).getAt(2) <> tWallInfo.getAt(2).getAt(2) then
      return([#direction:tDirName, #wallSprites:tWallObjectUnder.getSprites(), #insideWall:0])
    end if
  end if
  i = 1
  repeat while i <= 2
    tWallObj = tWallObjs.getAt(i)
    tRect = tRects.getAt(i)
    if (tWallObj = void()) then
      return([#direction:tDirName, #wallSprites:tWallObjectUnder.getSprites(), #insideWall:0])
    else
      tWallSpr = tWallObj.getSprites().getAt(1)
      if (tWallObj = tWallObjectUnder) then
        tWallSpr = tWallCheckSpr
      end if
      tLocalCoordinate = point((tRect.getAt(1) - tWallSpr.left), (tRect.getAt(2) - tWallSpr.top))
      if tLocalCoordinate.getAt(1) < 0 or tLocalCoordinate.getAt(2) < 0 then
        return([#direction:tDirName, #wallSprites:tWallObjectUnder.getSprites(), #insideWall:0])
      end if
      tLocalPixel = tWallSpr.member.image.getPixel(tLocalCoordinate.getAt(1), tLocalCoordinate.getAt(2))
      if (tLocalPixel = paletteIndex(0)) then
        return([#direction:tDirName, #wallSprites:tWallObjectUnder.getSprites(), #insideWall:0])
      end if
    end if
    i = (1 + i)
  end repeat
  if tWallObjs.getAt(1).getDirection() <> tWallObjs.getAt(2).getDirection() and tWallObjs.getAt(1).getDirection().getAt(1) <> 3 and tWallObjs.getAt(2).getDirection().getAt(1) <> 3 then
    return([#direction:tDirName, #wallSprites:tWallObjectUnder.getSprites(), #insideWall:0])
  end if
  tWallSpr = tWallObjs.getAt(1).getSprites().getAt(1)
  tLocalCoordinate = point((tSpr.getProp(#loc, 1) - tWallSpr.left), (tSpr.getProp(#loc, 2) - tWallSpr.top))
  return([#direction:tDirName, #wallSprites:tWallObjectUnder.getSprites(), #insideWall:1, #wallObject:tWallObjs.getAt(1), #localCoordinate:tLocalCoordinate])
end

on getPassiveObjectIntersectingRect me, tItemR 
  tPieceList = getThread(#room).getComponent().getPassiveObject(#list)
  tPieceObjUnder = void()
  tPieceSprUnder = 0
  tPieceUnderLocZ = -1000000000
  repeat while tPieceList <= 1
    tPiece = getAt(1, count(tPieceList))
    tSprites = tPiece.getSprites()
    repeat while tPieceList <= 1
      tPieceSpr = getAt(1, count(tPieceList))
      tRp = sprite(tPieceSpr).member.regPoint
      tR = (rect(sprite(tPieceSpr).locH, sprite(tPieceSpr).locV, sprite(tPieceSpr).locH, sprite(tPieceSpr).locV) + rect(-tRp.getAt(1), -tRp.getAt(2), (sprite(tPieceSpr).member.width - tRp.getAt(1)), (sprite(tPieceSpr).member.height - tRp.getAt(2))))
      if intersect(tItemR, tR) <> rect(0, 0, 0, 0) and tPieceUnderLocZ < tPieceSpr.locZ then
        tPieceObjUnder = tPiece
        tPieceSprUnder = tPieceSpr
        tPieceUnderLocZ = tPieceSpr.locZ
      end if
    end repeat
  end repeat
  return([tPieceObjUnder, tPieceSprUnder])
end

on checkObjectExists me 
  tObj = getThread(#room).getComponent().getActiveObject(pClientID)
  if (tObj = 0) then
    getThread(#room).getInterface().stopObjectMover()
  end if
end
