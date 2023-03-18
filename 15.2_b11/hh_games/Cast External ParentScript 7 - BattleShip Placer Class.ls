property pSpr, pGameBoardSpr, pReservedSquare, pSquareSize, pShipCount, pShipSize, pDirection

on Init me, tGameBoardSpr, tlocz
  pSpr = sprite(reserveSprite(me.getID()))
  setEventBroker(pSpr.spriteNum, me.getID())
  call(#registerClient, pSpr.scriptInstanceList, me)
  call(#registerProcedure, pSpr.scriptInstanceList, #eventProcShipPlacer, me.getID(), #mouseUp)
  pSpr.ink = 8
  pSpr.locZ = tlocz
  pGameBoardSpr = tGameBoardSpr
  pSquareSize = 19
  pShipCount = 0
  pShipSize = 0
  pDirection = "horizontal"
  pReservedSquare = []
  me.getNextShip()
  receiveUpdate(me.getID())
end

on deconstruct me
  removeUpdate(me.getID())
  releaseSprite(pSpr.spriteNum)
  pSpr = VOID
end

on eventProcShipPlacer me, tEvent, tSprID, tParam
  pSpr.visible = 0
  tSprite = rollover()
  pSpr.visible = 1
  tid = call(#getID, sprite(tSprite).scriptInstanceList)
  if (tid = "close") or (tid contains "turn") then
    getThread(#games).getInterface().eventProcBattleShip(tEvent, tid)
  end if
end

on getNextShip me
  case pShipCount of
    0:
      pShipSize = 5
      tShip = getText("game_bs_ship1", "An Aircraft Carrier")
    1, 2:
      pShipSize = 4
      tShip = string(3 - pShipCount) && getText("game_bs_ship2", "BattleShip(s)")
    3, 4, 5:
      pShipSize = 3
      tShip = string(6 - pShipCount) && getText("game_bs_ship3", "Cruiser(s)")
    6, 7, 8, 9:
      pShipSize = 2
      tShip = string(10 - pShipCount) && getText("game_bs_ship4", "Destroyer(s)")
    otherwise:
      removeObject(me.getID())
      getThread(#games).getInterface().battleShipWaitOtherPlayer()
  end case
  if not voidp(tShip) then
    getThread(#games).getInterface().showShipInfo(tShip)
    me.setShipMember()
  end if
end

on setShipMember me
  tMemName = "game_bs_ship_" & pShipSize & "_" & pDirection.char[1]
  pSpr.member = member(getmemnum(tMemName))
end

on getBoardSector me, tpoint
  return string(tpoint[1] / pSquareSize && tpoint[2] / pSquareSize)
end

on ShipPlace me, tPoint1, tPoint2
  tP1 = me.getBoardSector(tPoint1)
  tP2 = me.getBoardSector(tPoint2)
  tX1 = value(tP1.word[1])
  tX2 = value(tP2.word[1])
  tY1 = value(tP1.word[2])
  tY2 = value(tP2.word[2])
  tSetSquares = [:]
  tCanSet = 1
  if pDirection = "horizontal" then
    repeat with xxx = tX1 to tX2
      if pReservedSquare.getOne(xxx & tY1) <> 0 then
        tCanSet = 0
        exit repeat
        next repeat
      end if
      tSetSquares[xxx & tY1] = 1
    end repeat
  else
    if pDirection = "vertical" then
      repeat with yyy = tY1 to tY2
        if pReservedSquare.getOne(tX1 & yyy) <> 0 then
          tCanSet = 0
          exit repeat
          next repeat
        end if
        tSetSquares[tX1 & yyy] = 1
      end repeat
    end if
  end if
  if tCanSet = 1 then
    repeat with f = 1 to tSetSquares.count
      tProp = tSetSquares.getPropAt(f)
      pReservedSquare.add(tProp)
    end repeat
    tRect = rect(tPoint1, tPoint2) + rect(1, 1, 1, 1)
    if pDirection = "horizontal" then
      tRect = tRect + rect(0, 1, 0, 1)
    else
      tRect = tRect + rect(1, 0, 1, 0)
    end if
    getThread(#games).getInterface().placeShip(pSpr.member, tRect)
    tPlace = pShipSize && tX1 && tY1 && tX2 && tY2
    getThread(#games).getComponent().sendBattleShipPlaceShip(tPlace)
    pShipCount = pShipCount + 1
    me.getNextShip()
  end if
end

on turnShip me
  if not threadExists(#games) then
    return removeObject(me.getID())
  end if
  if pDirection = "horizontal" then
    pDirection = "vertical"
  else
    pDirection = "horizontal"
  end if
  me.setShipMember()
end

on update me
  pSpr.loc = the mouseLoc
  tUpPoint = point(pSpr.left, pSpr.top)
  tDownPoint = point(pSpr.right, pSpr.bottom)
  if tUpPoint.inside(pGameBoardSpr.rect) and tDownPoint.inside(pGameBoardSpr.rect) then
    pSpr.blend = 100
    if the mouseDown then
      tloc = point(pSpr.left - pGameBoardSpr.left, pSpr.top - pGameBoardSpr.top)
      tTempLoc = me.getBoardSector(tloc)
      tNewLoc = point(value(tTempLoc.word[1]) * pSquareSize, value(tTempLoc.word[2]) * pSquareSize)
      tloc = tNewLoc
      tLoc2 = tNewLoc + point(pSpr.width, pSpr.height)
      me.ShipPlace(tloc, tLoc2)
    end if
  else
    pSpr.blend = 50
  end if
end
