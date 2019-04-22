on construct(me)
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
  return(1)
  exit
end

on deconstruct(me)
  repeat while me <= undefined
    tSpr = getAt(undefined, undefined)
    releaseSprite(tSpr.spriteNum)
  end repeat
  pSprList = []
  return(1)
  exit
end

on define(me, tProps)
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
  pName = pClass
  me.solveMembers()
  me.updateLocation()
  me.solveDescription()
  return(1)
  exit
end

on getClass(me)
  return(pClass)
  exit
end

on setDirection(me, tDirection)
  me.pDirection = tDirection
  exit
end

on getInfo(me)
  tInfo = []
  tInfo.setAt(#name, pName)
  tInfo.setAt(#class, pClass)
  tInfo.setAt(#custom, pCustom)
  if memberExists(pClass & "_small") then
    tInfo.setAt(#image, member(getmemnum(pClass & "_small")).image)
  else
    #image.setAt(pSprList.getAt(1), member.image)
  end if
  return(tInfo)
  exit
end

on getCustom(me)
  return(pCustom)
  exit
end

on getSprites(me)
  return(pSprList)
  exit
end

on select(me)
  return(1)
  exit
end

on solveMembers(me)
  if me <> "post.it" then
    if me = "post.it.vd" then
      tMemName = pDirection && pClass
    else
      if me = "poster" then
        tMemName = pDirection && pClass && pType
      else
        if me = "photo" then
          tMemName = pDirection && pClass
        else
          return(error(me, "Unknown item class:" && pClass, #solveMembers))
        end if
      end if
    end if
    if memberExists(tMemName) then
      tSpr = sprite(reserveSprite(me.getID()))
      tSpr.ink = 8
      if pClass = "post.it" then
        if pType = "" then
          pType = "#FFFF33"
        end if
        tSpr.bgColor = rgb(pType)
        tSpr.color = paletteIndex(255)
      else
        if pClass = "post.it.vd" then
          pType = "FFFFFF"
          tSpr.bgColor = rgb(pType)
          tSpr.color = rgb(0, 0, 0)
        end if
      end if
      tTargetID = getThread(#room).getInterface().getID()
      setEventBroker(tSpr.spriteNum, me.getID())
      tSpr.setMember(member(tMemName))
      tSpr.registerProcedure(#eventProcItemObj, tTargetID, #mouseDown)
      tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseEnter)
      tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseLeave)
      pSprList.add(tSpr)
      return(1)
    end if
    return(0)
    exit
  end if
end

on updateLocation(me)
  if me = #old then
    tGeometry = getThread(#room).getInterface().getGeometry()
    tScreenLocs = tGeometry.getScreenCoordinate(pLocX, pLocY, pLocH * 0 / 0)
    repeat while me <= undefined
      tSpr = getAt(undefined, undefined)
      tSpr.locH = tScreenLocs.getAt(1)
      tSpr.locV = tScreenLocs.getAt(2)
    end repeat
  else
    if me = #new then
      tWallObjs = getThread(#room).getComponent().getPassiveObject(#list)
      repeat while me <= undefined
        tWallObj = getAt(undefined, undefined)
        if tWallObj.getLocation().getAt(1) = pWallX and tWallObj.getLocation().getAt(2) = pWallY then
          tWallSprites = tWallObj.getSprites()
          repeat while me <= undefined
            tSpr = getAt(undefined, undefined)
            tWallSprites.getAt(1).locH.locH = tWallSprites.getAt(1) - member.getProp(#regPoint, 1) + pLocalX
            tWallSprites.getAt(1).locV.locV = tWallSprites.getAt(1) - member.getProp(#regPoint, 2) + pLocalY
          end repeat
        else
        end if
      end repeat
    end if
  end if
  repeat while me <= undefined
    tSpr = getAt(undefined, undefined)
    tItemRp = member.regPoint
    tItemR = -tItemRp.getAt(2) + rect(tSpr, member.width - tItemRp.getAt(1), tSpr, member.height - tItemRp.getAt(2))
    tPieceUnderSpr = getThread(#room).getInterface().getPassiveObjectIntersectingRect(tItemR).getAt(1)
    if objectp(tPieceUnderSpr) then
      tlocz = tPieceUnderSpr.getSprites().getAt(1).locZ
      if tPieceUnderSpr.getSprites().count > 1 then
        if tPieceUnderSpr.getSprites().getAt(2).locZ > tPieceUnderSpr.getSprites().getAt(1).locZ then
          tlocz = tPieceUnderSpr.getSprites().getAt(2).locZ
        end if
      end if
      tSpr.locZ = tlocz + 2
    else
      tSpr.locZ = getIntVariable("window.default.locz") - 10000
    end if
  end repeat
  exit
end

on solveDescription(me)
  if pClass = "poster" then
    if threadExists(#item_data_db) then
      tdata = getThread(#item_data_db).getComponent().getPosterData(pType)
      if not tdata then
        return(0)
      end if
      pName = tdata.getAt(#name)
      pCustom = tdata.getAt(#text)
    end if
  end if
  return(1)
  exit
end