property pSprite, pMemberName, pUserId, pGameId, pGameType, pAnimCounter, pSelfCheckCounter, pAnimFrame, pLastLoc, pLastDir, pSize, pOwnGame

on construct me 
  pLastLoc = void()
  pLastDir = void()
  pUserId = ""
  pOwnGame = 0
  return(1)
end

on deconstruct me 
  if pSprite.ilk = #sprite then
    releaseSprite(pSprite.spriteNum)
  end if
  return(1)
end

on show_ig_icon me, tParams 
  tXFactor = getThread(#room).getInterface().getGeometry().pXFactor
  if integer(tXFactor) > 32 then
    pSize = "h"
  else
    pSize = "sh"
  end if
  pGameType = tParams.getaProp("gametype")
  pGameId = tParams.getaProp("gameid")
  pUserId = tParams.getaProp("userid")
  me.checkMemberName()
  if not pSprite.ilk = #sprite then
    tMemNum = getmemnum(pMemberName & "0")
    if tMemNum <= 0 then
      return(0)
    end if
    tSpriteNum = reserveSprite("IGBubble_" & pUserId)
    if tSpriteNum < 1 then
      return(0)
    end if
    pSprite = sprite(tSpriteNum)
    pSprite.member = member(tMemNum)
    pSprite.blend = 80
    pSprite.ink = 8
    pSprite.locZ = tParams.getaProp("locz")
    tTargetID = "ig_interface"
    setEventBroker(pSprite.spriteNum, pGameId & "_" & pGameType)
    pSprite.registerProcedure(#eventProcMouseDownIcon, tTargetID, #mouseDown)
    pSprite.registerProcedure(#eventProcRollOverIcon, tTargetID, #mouseEnter)
    pSprite.registerProcedure(#eventProcRollOverIcon, tTargetID, #mouseLeave)
    pSprite.visible = 1
    pAnimCounter = 0
    pLastLoc = void()
    pLastDir = void()
    pAnimFrame = 0
  end if
  me.update()
  return(1)
end

on hide me 
  pSprite.loc = point(-1000, -1000)
  return(1)
end

on Refresh me 
  return(1)
end

on update me 
  pAnimCounter = pAnimCounter + 1
  if pAnimCounter > 2 then
    pAnimCounter = 0
    if pSelfCheckCounter < 10 then
      pSelfCheckCounter = pSelfCheckCounter + 1
    else
      pSelfCheckCounter = 0
      me.checkMemberName()
    end if
    pAnimFrame = pAnimFrame + 1
    if pAnimFrame > 3 then
      pAnimFrame = 0
    end if
    tMemNum = getmemnum(pMemberName & pAnimFrame)
    if tMemNum <= 0 then
      return(0)
    end if
    pSprite.member = member(tMemNum)
  end if
  tHumanObj = getThread(#room).getComponent().getUserObject(pUserId)
  if tHumanObj = 0 then
    return(me.hide())
  end if
  tHumanLoc = tHumanObj.getPartLocation("hd")
  tHumanDir = tHumanObj.getDirection()
  if voidp(pLastLoc) then
    pLastLoc = point(0, 0)
  end if
  if tHumanDir <> pLastDir then
    tChanges = 1
  else
    if tHumanLoc <> pLastLoc then
      if tHumanLoc.getAt(1) <> pLastLoc.getAt(1) then
        tChanges = 1
      else
        if abs(tHumanLoc.getAt(2) - pLastLoc.getAt(2)) > 1 then
          tChanges = 1
        end if
      end if
    end if
  end if
  if not tChanges then
    return(1)
  end if
  pSprite.locZ = tHumanObj.getProperty(#locZ) + 3200
  pLastLoc = tHumanLoc
  pLastDir = tHumanDir
  if pSize = "h" then
    tLocV = tHumanLoc.getAt(2) - 65
    if tHumanDir = 7 then
      pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 2, tLocV)
    else
      if tHumanDir = 6 then
        pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) + 1, tLocV)
      else
        if tHumanDir = 5 then
          pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) + 2, tLocV)
        else
          if tHumanDir = 4 then
            pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 1, tLocV)
          else
            if tHumanDir = 3 then
              pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 2, tLocV)
            else
              if tHumanDir = 2 then
                pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 2, tLocV)
              else
                if tHumanDir = 1 then
                  pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2), tLocV)
                else
                  if tHumanDir = 0 then
                    pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 1, tLocV)
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  else
    tLocV = tHumanLoc.getAt(2) - 44
    if tHumanDir = 7 then
      pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 2, tLocV)
    else
      if tHumanDir = 6 then
        pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 1, tLocV)
      else
        if tHumanDir = 5 then
          pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 1, tLocV)
        else
          if tHumanDir = 4 then
            pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) + 1, tLocV)
          else
            if tHumanDir = 3 then
              pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 2, tLocV)
            else
              if tHumanDir = 2 then
                pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 2, tLocV)
              else
                if tHumanDir = 1 then
                  pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 1, tLocV)
                else
                  if tHumanDir = 0 then
                    pSprite.loc = point(tHumanLoc.getAt(1) - (pSprite.width / 2) - 2, tLocV)
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

on checkMemberName me 
  tThread = getThread(#ig)
  if tThread = 0 then
    return(0)
  end if
  tComponent = tThread.getComponent()
  tService = tComponent.getIGComponent("GameList")
  if tService = 0 then
    return(0)
  end if
  if tService.getJoinedGameId() = pGameId then
    pOwnGame = 1
  else
    pOwnGame = 0
  end if
  pMemberName = "ig_iconbubble_" & pGameType & "_" & pOwnGame & "_"
  if pSize = "sh" then
    pMemberName = "s_" & pMemberName
  end if
  return(1)
end
