property pClass, pName, pCustom, pType, pSprList, pLocX, pLocY, pLocH, pLocZ, pWallX, pWallY, pLocalX, pLocalY, pFormatVer, pDirection

on construct me
  pClass = EMPTY
  pName = EMPTY
  pCustom = EMPTY
  pType = EMPTY
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
  return 1
end

on deconstruct me
  repeat with tSpr in pSprList
    releaseSprite(tSpr.spriteNum)
  end repeat
  pSprList = []
  return 1
end

on define me, tProps
  pClass = tProps[#class]
  pLocX = tProps[#x]
  pLocY = tProps[#y]
  pLocH = tProps[#h]
  pLocZ = tProps[#z]
  pLocalX = tProps[#local_x]
  pLocalY = tProps[#local_y]
  pWallX = tProps[#wall_x]
  pWallY = tProps[#wall_y]
  pFormatVer = tProps[#formatVersion]
  pDirection = tProps[#direction]
  pType = tProps[#type]
  pName = pClass
  me.solveMembers()
  me.updateLocation()
  me.solveDescription()
  return 1
end

on getClass me
  return pClass
end

on setDirection me, tDirection
  me.pDirection = tDirection
end

on getInfo me
  tInfo = [:]
  tInfo[#name] = pName
  tInfo[#class] = pClass
  tInfo[#Custom] = pCustom
  if memberExists(pClass & "_small") then
    tInfo[#image] = member(getmemnum(pClass & "_small")).image
  else
    tInfo[#image] = pSprList[1].member.image
  end if
  return tInfo
end

on getCustom me
  return pCustom
end

on getSprites me
  return pSprList
end

on select me
  return 1
end

on solveMembers me
  case pClass of
    "post.it", "post.it.vd":
      tMemName = pDirection && pClass
    "poster":
      tMemName = pDirection && pClass && pType
    "photo":
      tMemName = pDirection && pClass
    otherwise:
      return error(me, "Unknown item class:" && pClass, #solveMembers)
  end case
  if memberExists(tMemName) then
    tSpr = sprite(reserveSprite(me.getID()))
    tSpr.ink = 8
    if pClass = "post.it" then
      if pType = EMPTY then
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
    return 1
  end if
  return 0
end

on updateLocation me
  case pFormatVer of
    #old:
      tGeometry = getThread(#room).getInterface().getGeometry()
      tScreenLocs = tGeometry.getScreenCoordinate(pLocX, pLocY, pLocH * 18.0 / 32.0)
      repeat with tSpr in pSprList
        tSpr.locH = tScreenLocs[1]
        tSpr.locV = tScreenLocs[2]
      end repeat
    #new:
      tWallObjs = getThread(#room).getComponent().getPassiveObject(#list)
      repeat with tWallObj in tWallObjs
        if (tWallObj.getLocation()[1] = pWallX) and (tWallObj.getLocation()[2] = pWallY) then
          tWallSprites = tWallObj.getSprites()
          repeat with tSpr in pSprList
            tSpr.locH = tWallSprites[1].locH - tWallSprites[1].member.regPoint[1] + pLocalX
            tSpr.locV = tWallSprites[1].locV - tWallSprites[1].member.regPoint[2] + pLocalY
          end repeat
          exit repeat
        end if
      end repeat
  end case
  repeat with tSpr in pSprList
    tItemRp = tSpr.member.regPoint
    tItemR = rect(tSpr.locH, tSpr.locV, tSpr.locH, tSpr.locV) + rect(-tItemRp[1], -tItemRp[2], tSpr.member.width - tItemRp[1], tSpr.member.height - tItemRp[2])
    tPieceUnderSpr = getThread(#room).getInterface().getPassiveObjectIntersectingRect(tItemR)[1]
    if objectp(tPieceUnderSpr) then
      tlocz = tPieceUnderSpr.getSprites()[1].locZ
      if tPieceUnderSpr.getSprites().count > 1 then
        if tPieceUnderSpr.getSprites()[2].locZ > tPieceUnderSpr.getSprites()[1].locZ then
          tlocz = tPieceUnderSpr.getSprites()[2].locZ
        end if
      end if
      tSpr.locZ = tlocz + 2
      next repeat
    end if
    tSpr.locZ = getIntVariable("window.default.locz") - 10000
  end repeat
end

on solveDescription me
  if pClass = "poster" then
    if threadExists(#item_data_db) then
      tdata = getThread(#item_data_db).getComponent().getPosterData(pType)
      if not tdata then
        return 0
      end if
      pName = tdata[#name]
      pCustom = tdata[#text]
    end if
  end if
  return 1
end
