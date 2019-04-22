property pSpr, pShipCount, pShipSize, pDirection, pSquareSize, pReservedSquare, pGameBoardSpr

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
  pSpr = void()
end

on eventProcShipPlacer me, tEvent, tSprID, tParam 
  pSpr.visible = 0
  tSprite = rollover()
  pSpr.visible = 1
  tid = call(#getID, sprite(tSprite).scriptInstanceList)
  if tid = "close" or tid contains "turn" then
    getThread(#games).getInterface().eventProcBattleShip(tEvent, tid)
  end if
end

on getNextShip me 
  if pShipCount = 0 then
    pShipSize = 5
    tShip = getText("game_bs_ship1", "An Aircraft Carrier")
  else
    if pShipCount <> 1 then
      if pShipCount = 2 then
        pShipSize = 4
        tShip = string(3 - pShipCount) && getText("game_bs_ship2", "BattleShip(s)")
      else
        if pShipCount <> 3 then
          if pShipCount <> 4 then
            if pShipCount = 5 then
              pShipSize = 3
              tShip = string(6 - pShipCount) && getText("game_bs_ship3", "Cruiser(s)")
            else
              if pShipCount <> 6 then
                if pShipCount <> 7 then
                  if pShipCount <> 8 then
                    if pShipCount = 9 then
                      pShipSize = 2
                      tShip = string(10 - pShipCount) && getText("game_bs_ship4", "Destroyer(s)")
                    else
                      removeObject(me.getID())
                      getThread(#games).getInterface().battleShipWaitOtherPlayer()
                    end if
                    if not voidp(tShip) then
                      getThread(#games).getInterface().showShipInfo(tShip)
                      me.setShipMember()
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on setShipMember me 
  tMemName = "game_bs_ship_" & pShipSize & "_" & pDirection.getProp(#char, 1)
  pSpr.member = member(getmemnum(tMemName))
end

on getBoardSector me, tpoint 
  return(string(tpoint.getAt(1) / pSquareSize && tpoint.getAt(2) / pSquareSize))
end

on ShipPlace me, tPoint1, tPoint2 
  tP1 = me.getBoardSector(tPoint1)
  tP2 = me.getBoardSector(tPoint2)
  tX1 = value(tP1.getProp(#word, 1))
  tX2 = value(tP2.getProp(#word, 1))
  tY1 = value(tP1.getProp(#word, 2))
  tY2 = value(tP2.getProp(#word, 2))
  tSetSquares = [:]
  tCanSet = 1
  if pDirection = "horizontal" then
    xxx = tX1
    repeat while xxx <= tX2
      if pReservedSquare.getOne(xxx & tY1) <> 0 then
        tCanSet = 0
      else
        tSetSquares.setAt(xxx & tY1, 1)
      end if
      xxx = 1 + xxx
    end repeat
    exit repeat
  end if
  if pDirection = "vertical" then
    yyy = tY1
    repeat while yyy <= tY2
      if pReservedSquare.getOne(tX1 & yyy) <> 0 then
        tCanSet = 0
      else
        tSetSquares.setAt(tX1 & yyy, 1)
      end if
      yyy = 1 + yyy
    end repeat
  end if
  if tCanSet = 1 then
    f = 1
    repeat while f <= tSetSquares.count
      tProp = tSetSquares.getPropAt(f)
      pReservedSquare.add(tProp)
      f = 1 + f
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
    return(removeObject(me.getID()))
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
      tNewLoc = point(value(tTempLoc.getProp(#word, 1)) * pSquareSize, value(tTempLoc.getProp(#word, 2)) * pSquareSize)
      tloc = tNewLoc
      tLoc2 = tNewLoc + point(pSpr.width, pSpr.height)
      me.ShipPlace(tloc, tLoc2)
    end if
  else
    pSpr.blend = 50
  end if
end
