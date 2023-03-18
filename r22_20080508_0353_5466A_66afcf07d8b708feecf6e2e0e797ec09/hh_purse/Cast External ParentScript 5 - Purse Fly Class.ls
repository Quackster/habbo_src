property pElement, pWinTop, pWinBottom, pWinLeft, pWinRight, pFlyMember, pWayCounter, pMyDir, pMyNum

on define me, tsprite, tCount
  tWndObj = getWindow(getText("win_purse", "Habbo Purse"))
  pElement = tWndObj.getElement("fly_" & tCount)
  pElement.setProperty(#visible, 1)
  pFlyMember = 1
  pMyDir = 1
  pMyDir = [1, 3, 1, 4][tCount]
  pWinTop = 120
  pWinBottom = 185
  pWinLeft = 45
  pWinRight = 285
  pMyNum = tCount
  pWayCounter = 1
  return 1
end

on animateFly me
  tList = getWindow(getText("win_purse", "Habbo Purse")).getProperty(#spriteList)
  tSpr = tList["fly_" & pMyNum]
  tFly = member(getmemnum("purse_fly" & pFlyMember))
  pElement.setProperty(#member, tFly)
  pElement.setProperty(#width, tFly.width)
  pElement.setProperty(#height, tFly.height)
  tLocX = pElement.getProperty(#locX)
  tLocY = pElement.getProperty(#locY)
  case 1 of
    (tLocX < pWinLeft):
      if pMyDir = 2 then
        tSpr.flipH = 0
        pMyDir = 1
      else
        pWayCounter = 6
      end if
    (tLocX > pWinRight):
      if pMyDir = 1 then
        tSpr.flipH = 1
        pMyDir = 2
      else
        pWayCounter = 1
      end if
    (tLocY > pWinBottom):
      if pMyDir = 4 then
        tSpr.flipV = 0
        pMyDir = 3
      else
        pWayCounter = 11
      end if
    (tLocY < pWinTop):
      if pMyDir = 3 then
        tSpr.flipV = 1
        pMyDir = 4
      else
        pWayCounter = 0
      end if
  end case
  if pMyDir < 3 then
    case 1 of
      (pWayCounter <= 10):
        tY = 2
      ((pWayCounter > 10) and (pWayCounter <= 20)):
        tY = -2
      (pWayCounter > 20):
        pWayCounter = 0
    end case
    pFlyMember = 3 + (pFlyMember = 3)
  else
    case 1 of
      (pWayCounter <= 5):
        tX = -5
      ((pWayCounter > 5) and (pWayCounter <= 10)):
        tX = 5
      (pWayCounter > 10):
        pWayCounter = 0
    end case
    pFlyMember = 1 + (pFlyMember = 1)
  end if
  case pMyDir of
    1:
      pElement.moveTo(tLocX + 7, tLocY + tY)
    2:
      pElement.moveTo(tLocX - 7, tLocY + tY)
    3:
      pElement.moveTo(tLocX + tX, tLocY - 3)
    4:
      pElement.moveTo(tLocX + tX, tLocY + 3)
  end case
  pWayCounter = pWayCounter + 1
end

on hideFlies me
  tWndObj = getWindow(getText("win_purse", "Habbo Purse"))
  pElement = tWndObj.getElement("fly_" & pMyNum)
  pElement.setProperty(#visible, 0)
end
