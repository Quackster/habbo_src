property pSprList, pClass, pType, pName, pCustom, pWallX, pWallY, pDirection, pXFactor, pFormatVer, pLocX, pLocY, pLocH, pLocalX, pLocalY, pParentWallLocZ

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
  pParentWallLocZ = void()
  return TRUE
end

on deconstruct me 
  repeat while pSprList <= undefined
    tSpr = getAt(undefined, undefined)
    releaseSprite(tSpr.spriteNum)
  end repeat
  pParentWallLocZ = void()
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
  pXFactor = getThread(#room).getInterface().getGeometry().pXFactor
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
      if (me.solveMembers() = 0) then
        return FALSE
      end if
      if (me.prepare(tProps) = 0) then
        return FALSE
      end if
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
    if pSprList.count > 0 then
      tTestMem2 = pSprList.getAt(1).member.name.getProp(#char, 1, (length(pSprList.getAt(1).member.name) - 11)) & "small"
      if memberExists(tTestMem2) then
        tInfo.setAt(#image, getMember(tTestMem2).image)
      else
        tInfo.setAt(#image, pSprList.getAt(1).member.image)
      end if
    else
      tInfo.setAt(#image, getMember("no_icon_small").image)
    end if
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

on prepare me, tdata 
  return TRUE
end

on solveColors me, tpartColors 
  if voidp(tpartColors) then
    tpartColors = "0,0,0"
  end if
  pPartColors = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  i = 1
  repeat while i <= tpartColors.count(#item)
    pPartColors.add(string(tpartColors.getProp(#item, i)))
    i = (1 + i)
  end repeat
  j = pPartColors.count
  repeat while j <= 4
    pPartColors.add("*ffffff")
    j = (1 + j)
  end repeat
  the itemDelimiter = tDelim
end

on solveInk me, tPart, tClass 
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return(8)
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveInk, #minor)
    return(8)
  else
    if voidp(tPropList.getAt(tPart)) then
      return(8)
    end if
    if not voidp(tPropList.getAt(tPart).getAt(#ink)) then
      return(tPropList.getAt(tPart).getAt(#ink))
    end if
  end if
  return(8)
end

on solveBlend me, tPart, tClass 
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return(100)
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveBlend, #minor)
    return(100)
  else
    if voidp(tPropList.getAt(tPart)) then
      return(100)
    end if
    if not voidp(tPropList.getAt(tPart).getAt(#blend)) then
      return(tPropList.getAt(tPart).getAt(#blend))
    end if
  end if
  return(100)
end

on solveLocZ me, tPart, tdir, tClass 
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return FALSE
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveLocZ, #minor)
    return FALSE
  else
    if voidp(tPropList.getAt(tPart)) then
      return FALSE
    end if
    if voidp(tPropList.getAt(tPart).getAt(#zshift)) then
      return FALSE
    end if
    if tPropList.getAt(tPart).getAt(#zshift).count <= tdir then
      tdir = 0
    end if
  end if
  return(tPropList.getAt(tPart).getAt(#zshift).getAt((tdir + 1)))
end

on solveLocShift me, tPart, tdir, tClass 
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return FALSE
  end if
  tPropList = value(field(0))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveLocShift, #minor)
    return FALSE
  else
    if voidp(tPropList.getAt(tPart)) then
      return FALSE
    end if
    if voidp(tPropList.getAt(tPart).getAt(#locshift)) then
      return FALSE
    end if
    if tPropList.getAt(tPart).getAt(#locshift).count <= tdir then
      return FALSE
    end if
    tShift = value(tPropList.getAt(tPart).getAt(#locshift).getAt((tdir + 1)))
    if (ilk(tShift) = #point) then
      return(tShift)
    end if
  end if
  return FALSE
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
          return(error(me, "Unknown item class:" && pClass, #solveMembers, #minor))
        end if
      end if
    end if
    if (pXFactor = 32) then
      tMemName = "s_" & tMemName
    end if
    tMemNum = getmemnum(tMemName)
    if tMemNum <> 0 then
      if (pSprList.count = 0) then
        tSpr = sprite(reserveSprite(me.getID()))
        tTargetID = getThread(#room).getInterface().getID()
        setEventBroker(tSpr.spriteNum, me.getID())
        if tMemNum < 1 then
          tMemNum = abs(tMemNum)
          tSpr.flipH = 1
        end if
        tSpr.castNum = tMemNum
        tSpr.width = member(tMemNum).width
        tSpr.height = member(tMemNum).height
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

on setState me, tValue 
  me.updateColor(tValue)
end

on updateColor me, tHexstr 
  if not listp(pSprList) then
    return FALSE
  end if
  if pSprList.count < 1 then
    return FALSE
  end if
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
    repeat while pFormatVer <= undefined
      tSpr = getAt(undefined, undefined)
      tSpr.locH = tScreenLocs.getAt(1)
      tSpr.locV = tScreenLocs.getAt(2)
    end repeat
  else
    if (pFormatVer = #new) then
      tWallObjs = getThread(#room).getComponent().getPassiveObject(#list)
      tWallObjFound = 0
      if tWallObjs.count > 0 then
        repeat while pFormatVer <= undefined
          tWallObj = getAt(undefined, undefined)
          if (tWallObj.getLocation().getAt(1) = pWallX) and (tWallObj.getLocation().getAt(2) = pWallY) then
            tWallSprites = tWallObj.getSprites()
            repeat while pFormatVer <= undefined
              tSpr = getAt(undefined, undefined)
              tSpr.locH = ((tWallSprites.getAt(1).locH - tWallSprites.getAt(1).member.getProp(#regPoint, 1)) + pLocalX)
              tSpr.locV = ((tWallSprites.getAt(1).locV - tWallSprites.getAt(1).member.getProp(#regPoint, 2)) + pLocalY)
            end repeat
            tWallObjFound = 1
          else
          end if
        end repeat
      end if
      if not tWallObjFound then
        tVisualizer = getThread(#room).getInterface().getRoomVisualizer()
        if not voidp(tVisualizer) then
          if (pFormatVer = "leftwall") then
            tPartTypes = [#wallleft]
          else
            if (pFormatVer = "rightwall") then
              tPartTypes = [#wallright]
            end if
          end if
          tLounge = tVisualizer.getProperty(#layout)
          if (tLounge = "model_a.room") and (pWallY = 1) and pClass contains "post.it" and pWallX > 0 and (pDirection = "rightwall") then
            pWallY = 0
          end if
          tPartProps = tVisualizer.getPartAtLocation(pWallX, pWallY, tPartTypes)
          if (ilk(tPartProps) = #propList) then
            tWallObjFound = 1
            repeat while pFormatVer <= undefined
              tSpr = getAt(undefined, undefined)
              tMem = member(getmemnum(tPartProps.member))
              tFixNegativeLoc = 0
              if (tLounge = "model_b.room") then
                if (pWallX = 4) and (pWallY = 4) and pLocalX < 0 then
                  tFixNegativeLoc = 1
                end if
              else
                if (tLounge = "model_f.room") then
                  if (pWallX = 2) and (pWallY = 6) and pLocalX < 0 then
                    tFixNegativeLoc = 1
                  end if
                  if (pWallX = 6) and (pWallY = 2) and pLocalX < 0 then
                    tFixNegativeLoc = 1
                  end if
                else
                  if (tLounge = "model_g.room") then
                    if (pWallX = 6) and (pWallY = 4) and pLocalX < 0 then
                      tFixNegativeLoc = 1
                    end if
                  else
                    if (tLounge = "model_h.room") then
                      if (pWallX = 4) and (pWallY = 8) and pLocalX < 0 then
                        tFixNegativeLoc = 1
                      end if
                    end if
                  end if
                end if
              end if
              if tFixNegativeLoc then
                pLocalX = (32 + pLocalX)
              end if
              tSpr.locH = ((tPartProps.locH - tMem.getProp(#regPoint, 1)) + pLocalX)
              tSpr.locV = ((tPartProps.locV - tMem.getProp(#regPoint, 2)) + pLocalY)
            end repeat
            pParentWallLocZ = tPartProps.getAt(#locZ)
          end if
        end if
      end if
      if not pClass contains "post.it" then
        if not tWallObjFound and getObject(#session).GET(#room_owner) then
          tComponent = getThread(#room).getComponent()
          if not (tComponent = 0) then
            tComponent.getRoomConnection().send("ADDSTRIPITEM", "new item" && me.getID())
          end if
        end if
      end if
    end if
  end if
  tObjMover = getThread(#room).getInterface().getObjectMover()
  if not voidp(pParentWallLocZ) then
    i = 1
    repeat while i <= pSprList.count
      pSprList.getAt(i).locZ = ((pParentWallLocZ + 20000) + i)
      i = (1 + i)
    end repeat
    exit repeat
  end if
  repeat while pFormatVer <= undefined
    tSpr = getAt(undefined, undefined)
    if (tSpr.member = member(0, 0)) then
      return(error(me, "Spritelist contains empty sprite!", #updateLocation, #minor))
    end if
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
