property pSprList, pClass, pType, pName, pCustom, pWallX, pWallY, pDirection, pFormatVer, pLocX, pLocY, pLocH, pLocalX, pLocalY

on construct me 
  pClass = ""
  pName = ""
  pCustom = ""
  pType = ""
  pSprList = []
  pLocX = 0
  pLocY = 0
  pLocH = 0
  pLocZ = 0
  pWallX = 0
  pWallY = 0
  pLocalX = 0
  pLocalY = 0
  pFormatVer = 0
  pDirection = 0
  return TRUE
end

on deconstruct me 
  repeat while pSprList <= 1
    tSpr = getAt(1, count(pSprList))
    releaseSprite(tSpr.spriteNum)
  end repeat
  pSprList = []
  return TRUE
end

on define me, tProps 
  pClass = tProps.getAt(#class)
  pLocX = tProps.getAt(#x)
  pLocY = tProps.getAt(#y)
  pLocH = tProps.getAt(#h)
  pLocZ = tProps.getAt(#z)
  pLocalX = tProps.getAt(#local_x)
  pLocalY = tProps.getAt(#local_y)
  pWallX = tProps.getAt(#wall_x)
  pWallY = tProps.getAt(#wall_y)
  pFormatVer = tProps.getAt(#formatVersion)
  pDirection = tProps.getAt(#direction)
  pType = tProps.getAt(#type)
  if (pClass = "poster") then
    pName = getText("poster_" & pType & "_name", "poster_" & pType & "_name")
    pCustom = getText("poster_" & pType & "_desc", "poster_" & pType & "_desc")
  else
    if pClass <> "post.it.vd" then
      if (pClass = "post.it") then
        pName = getText("wallitem_" & pClass & "_name", "wallitem_" & pClass & "_name")
        pCustom = getText("wallitem_" & pClass & "_desc", "wallitem_" & pClass & "_desc")
      else
        if (pClass = "photo") then
          pName = getText("wallitem_" & pClass & "_name", "wallitem_" & pClass & "_name")
          pCustom = getText("wallitem_" & pClass & "_desc", "wallitem_" & pClass & "_desc")
        end if
      end if
      me.solveMembers()
      me.updateLocation()
      return TRUE
    end if
  end if
end

on getClass me 
  return(pClass)
end

on setDirection me, tDirection 
  me.pDirection = tDirection
end

on getInfo me 
  tInfo = [:]
  tInfo.setAt(#name, pName)
  tInfo.setAt(#class, pClass)
  tInfo.setAt(#custom, pCustom)
  tInfo.setAt(#smallmember, pClass & "_small")
  if memberExists(pClass & "_small") then
    tInfo.setAt(#image, member(getmemnum(pClass & "_small")).image)
  else
    tInfo.setAt(#image, pSprList.getAt(1).member.image)
  end if
  return(tInfo)
end

on getLocation me 
  return([pWallX, pWallY])
end

on getCustom me 
  return(pCustom)
end

on getSprites me 
  return(pSprList)
end

on select me 
  return TRUE
end

on solveMembers me 
  if pClass <> "post.it" then
    if (pClass = "post.it.vd") then
      tMemName = pDirection && pClass
    else
      if (pClass = "poster") then
        tMemName = pDirection && pClass && pType
      else
        if (pClass = "photo") then
          tMemName = pDirection && pClass
        else
          return(error(me, "Unknown item class:" && pClass, #solveMembers))
        end if
      end if
    end if
    if memberExists(tMemName) then
      if (pSprList.count = 0) then
        tSpr = sprite(reserveSprite(me.getID()))
        tTargetID = getThread(#room).getInterface().getID()
        setEventBroker(tSpr.spriteNum, me.getID())
        tSpr.setMember(member(tMemName))
        tSpr.registerProcedure(#eventProcItemObj, tTargetID, #mouseDown)
        tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseEnter)
        tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseLeave)
        pSprList.add(tSpr)
      else
        tSpr = pSprList.getAt(1)
      end if
      me.updateColor(pType)
      return TRUE
    end if
    return FALSE
  end if
end

on updateColor me, tHexstr 
  tSpr = pSprList.getAt(1)
  tSpr.ink = 8
  if (pClass = "post.it") then
    if (tHexstr = "") then
      tHexstr = "#FFFF33"
    end if
    tSpr.bgColor = rgb(tHexstr)
    tSpr.color = paletteIndex(255)
  else
    if (pClass = "post.it.vd") then
      tHexstr = "FFFFFF"
      tSpr.bgColor = rgb(tHexstr)
      tSpr.color = rgb(0, 0, 0)
    end if
  end if
end

on updateLocation me 
  if (pFormatVer = #old) then
    tGeometry = getThread(#room).getInterface().getGeometry()
    tScreenLocs = tGeometry.getScreenCoordinate(pLocX, pLocY, ((pLocH * 18) / 32))
    repeat while pFormatVer <= count(pFormatVer)
      tSpr = getAt(count(pFormatVer), pSprList)
      tSpr.locH = tScreenLocs.getAt(1)
      tSpr.locV = tScreenLocs.getAt(2)
    end repeat
  else
    if (pFormatVer = #new) then
      tWallObjs = getThread(#room).getComponent().getPassiveObject(#list)
      repeat while pFormatVer <= count(pFormatVer)
        tWallObj = getAt(count(pFormatVer), tWallObjs)
        if (tWallObj.getLocation().getAt(1) = pWallX) and (tWallObj.getLocation().getAt(2) = pWallY) then
          tWallSprites = tWallObj.getSprites()
          repeat while pFormatVer <= count(pFormatVer)
            tSpr = getAt(count(pFormatVer), tWallObjs)
            tSpr.locH = ((tWallSprites.getAt(1).locH - tWallSprites.getAt(1).member.getProp(#regPoint, 1)) + pLocalX)
            tSpr.locV = ((tWallSprites.getAt(1).locV - tWallSprites.getAt(1).member.getProp(#regPoint, 2)) + pLocalY)
          end repeat
        else
        end if
      end repeat
    end if
  end if
  tObjMover = getThread(#room).getInterface().getObjectMover()
  repeat while pSprList <= 1
    tSpr = getAt(1, count(pSprList))
    tItemRp = tSpr.member.regPoint
    tItemR = (rect(tSpr.locH, tSpr.locV, tSpr.locH, tSpr.locV) + rect(-tItemRp.getAt(1), -tItemRp.getAt(2), (tSpr.member.width - tItemRp.getAt(1)), (tSpr.member.height - tItemRp.getAt(2))))
    tPieceUnderSpr = tObjMover.getPassiveObjectIntersectingRect(tItemR).getAt(1)
    if objectp(tPieceUnderSpr) then
      tlocz = tPieceUnderSpr.getSprites().getAt(1).locZ
      if tPieceUnderSpr.getSprites().count > 1 then
        if tPieceUnderSpr.getSprites().getAt(2).locZ > tPieceUnderSpr.getSprites().getAt(1).locZ then
          tlocz = tPieceUnderSpr.getSprites().getAt(2).locZ
        end if
      end if
      tSpr.locZ = (tlocz + 2)
    else
      tSpr.locZ = (getIntVariable("window.default.locz") - 10000)
    end if
  end repeat
end
