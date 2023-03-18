property pClass, pName, pCustom, pType, pSprList, pLocX, pLocY, pLocH, pLocZ, pXFactor, pWallX, pWallY, pLocalX, pLocalY, pFormatVer, pDirection, pParentWallLocZ, pPersistentFurniData, pExpireTimeStamp

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
  pParentWallLocZ = VOID
  pPersistentFurniData = VOID
  pExpireTimeStamp = -1
  return 1
end

on deconstruct me
  repeat with tSpr in pSprList
    releaseSprite(tSpr.spriteNum)
  end repeat
  pParentWallLocZ = VOID
  pSprList = []
  return 1
end

on define me, tProps
  if voidp(pPersistentFurniData) then
    pPersistentFurniData = getThread("dynamicdownloader").getComponent().getPersistentFurniDataObject()
  end if
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
  pXFactor = getThread(#room).getInterface().getGeometry().pXFactor
  pExpireTimeStamp = tProps[#expire]
  case pClass of
    "poster":
      pName = getText("poster_" & pType & "_name", "poster_" & pType & "_name")
      pCustom = getText("poster_" & pType & "_desc", "poster_" & pType & "_desc")
    "post.it.vd", "post.it":
      tFurniData = pPersistentFurniData.getPropsByClass("i", pClass)
      if not voidp(tFurniData) then
        pName = tFurniData[#localizedName]
        pCustom = tFurniData[#localizedDesc]
      else
        pName = EMPTY
        pCustom = EMPTY
      end if
    "photo":
      tFurniData = pPersistentFurniData.getPropsByClass("i", pClass)
      if not voidp(tFurniData) then
        pName = pPersistentFurniData.getPropsByClass("i", pClass)[#localizedName]
        pCustom = pPersistentFurniData.getPropsByClass("i", pClass)[#localizedDesc]
      else
        pName = getText("wallitem_photo_name")
        pCustom = getText("wallitem_photo_desc")
      end if
  end case
  if me.solveMembers() = 0 then
    return 0
  end if
  if me.prepare(tProps) = 0 then
    return 0
  end if
  me.updateLocation()
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
  tInfo[#custom] = pCustom
  tInfo[#smallmember] = pClass & "_small"
  tInfo[#expire] = pExpireTimeStamp
  tMemName = pClass && pType & "_small"
  if (pClass = "poster") and memberExists(tMemName) then
    tInfo[#image] = member(getmemnum(tMemName)).image
    return tInfo
  end if
  if memberExists(pClass & "_small") then
    tInfo[#image] = member(getmemnum(pClass & "_small")).image
  else
    if pSprList.count > 0 then
      tTestMem2 = pSprList[1].member.name.char[1..length(pSprList[1].member.name) - 11] & "small"
      if memberExists(tTestMem2) then
        tInfo[#image] = getMember(tTestMem2).image
      else
        tInfo[#image] = pSprList[1].member.image
      end if
    else
      tInfo[#image] = getMember("no_icon_small").image
    end if
  end if
  return tInfo
end

on getLocation me
  return [pWallX, pWallY]
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

on hasURL me
  return textExists("item_ad_url_" & pType)
end

on GetUrl me
  return getText("item_ad_url_" & pType)
end

on prepare me, tdata
  return 1
end

on solveColors me, tpartColors
  if voidp(tpartColors) then
    tpartColors = "0,0,0"
  end if
  pPartColors = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  repeat with i = 1 to tpartColors.item.count
    pPartColors.add(string(tpartColors.item[i]))
  end repeat
  repeat with j = pPartColors.count to 4
    pPartColors.add("*ffffff")
  end repeat
  the itemDelimiter = tDelim
end

on solveInk me, tPart, tClass
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return 8
  end if
  tPropList = value(field(getmemnum(tClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveInk, #minor)
    return 8
  else
    if voidp(tPropList[tPart]) then
      return 8
    end if
    if not voidp(tPropList[tPart][#ink]) then
      return tPropList[tPart][#ink]
    end if
  end if
  return 8
end

on solveBlend me, tPart, tClass
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return 100
  end if
  tPropList = value(field(getmemnum(tClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveBlend, #minor)
    return 100
  else
    if voidp(tPropList[tPart]) then
      return 100
    end if
    if not voidp(tPropList[tPart][#blend]) then
      return tPropList[tPart][#blend]
    end if
  end if
  return 100
end

on solveLocZ me, tPart, tdir, tClass
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return 0
  end if
  tPropList = value(field(getmemnum(tClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveLocZ, #minor)
    return 0
  else
    if voidp(tPropList[tPart]) then
      return 0
    end if
    if voidp(tPropList[tPart][#zshift]) then
      return 0
    end if
    if tPropList[tPart][#zshift].count <= tdir then
      tdir = 0
    end if
  end if
  return tPropList[tPart][#zshift][tdir + 1]
end

on solveLocShift me, tPart, tdir, tClass
  if voidp(tClass) then
    tClass = pClass
  end if
  if not memberExists(tClass & ".props") then
    return 0
  end if
  tPropList = value(field(getmemnum(tClass & ".props")))
  if ilk(tPropList) <> #propList then
    error(me, tClass & ".props is not valid!", #solveLocShift, #minor)
    return 0
  else
    if voidp(tPropList[tPart]) then
      return 0
    end if
    if voidp(tPropList[tPart][#locshift]) then
      return 0
    end if
    if tPropList[tPart][#locshift].count <= tdir then
      return 0
    end if
    tShift = value(tPropList[tPart][#locshift][tdir + 1])
    if ilk(tShift) = #point then
      return tShift
    end if
  end if
  return 0
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
      return error(me, "Unknown item class:" && pClass, #solveMembers, #minor)
  end case
  if pXFactor = 32 then
    tMemName = "s_" & tMemName
  end if
  tMemNum = getmemnum(tMemName)
  if tMemNum <> 0 then
    if pSprList.count = 0 then
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
      tSpr = pSprList[1]
    end if
    me.updateColor(pType)
    return 1
  end if
  return 0
end

on setState me, tValue
  me.updateColor(tValue)
end

on updateColor me, tHexstr
  if not listp(pSprList) then
    return 0
  end if
  if pSprList.count < 1 then
    return 0
  end if
  tSpr = pSprList[1]
  tSpr.ink = 8
  if pClass = "post.it" then
    if tHexstr = EMPTY then
      tHexstr = "#FFFF33"
    end if
    tSpr.bgColor = rgb(tHexstr)
    tSpr.color = paletteIndex(255)
  else
    if pClass = "post.it.vd" then
      tHexstr = "FFFFFF"
      tSpr.bgColor = rgb(tHexstr)
      tSpr.color = rgb(0, 0, 0)
    end if
  end if
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
      tWallObjFound = 0
      if tWallObjs.count > 0 then
        repeat with tWallObj in tWallObjs
          if (tWallObj.getLocation()[1] = pWallX) and (tWallObj.getLocation()[2] = pWallY) then
            tWallSprites = tWallObj.getSprites()
            repeat with tSpr in pSprList
              tSpr.locH = tWallSprites[1].locH - tWallSprites[1].member.regPoint[1] + pLocalX
              tSpr.locV = tWallSprites[1].locV - tWallSprites[1].member.regPoint[2] + pLocalY
            end repeat
            tWallObjFound = 1
            exit repeat
          end if
        end repeat
      end if
      if not tWallObjFound then
        tVisualizer = getThread(#room).getInterface().getRoomVisualizer()
        if not voidp(tVisualizer) then
          case pDirection of
            "leftwall":
              tPartTypes = [#wallleft]
            "rightwall":
              tPartTypes = [#wallright]
          end case
          tLounge = tVisualizer.getProperty(#layout)
          if (tLounge = "model_a.room") and (pWallY = 1) and (pClass contains "post.it") and (pWallX > 0) and (pDirection = "rightwall") then
            pWallY = 0
          end if
          tPartProps = tVisualizer.getPartAtLocation(pWallX, pWallY, tPartTypes)
          if ilk(tPartProps) = #propList then
            tWallObjFound = 1
            repeat with tSpr in pSprList
              tMem = member(getmemnum(tPartProps.member))
              tFixNegativeLoc = 0
              if tLounge = "model_b.room" then
                if (pWallX = 4) and (pWallY = 4) and (pLocalX < 0) then
                  tFixNegativeLoc = 1
                end if
              else
                if tLounge = "model_f.room" then
                  if (pWallX = 2) and (pWallY = 6) and (pLocalX < 0) then
                    tFixNegativeLoc = 1
                  end if
                  if (pWallX = 6) and (pWallY = 2) and (pLocalX < 0) then
                    tFixNegativeLoc = 1
                  end if
                else
                  if tLounge = "model_g.room" then
                    if (pWallX = 6) and (pWallY = 4) and (pLocalX < 0) then
                      tFixNegativeLoc = 1
                    end if
                  else
                    if tLounge = "model_h.room" then
                      if (pWallX = 4) and (pWallY = 8) and (pLocalX < 0) then
                        tFixNegativeLoc = 1
                      end if
                    end if
                  end if
                end if
              end if
              if tFixNegativeLoc then
                pLocalX = 32 + pLocalX
              end if
              tSpr.locH = tPartProps.locH - tMem.regPoint[1] + pLocalX
              tSpr.locV = tPartProps.locV - tMem.regPoint[2] + pLocalY
            end repeat
            pParentWallLocZ = tPartProps[#locZ]
          end if
        end if
      end if
      if not (pClass contains "post.it") then
        if not tWallObjFound and getObject(#session).GET(#room_owner) then
          tComponent = getThread(#room).getComponent()
          if not (tComponent = 0) then
            tComponent.getRoomConnection().send("ADDSTRIPITEM", [#integer: 1, #integer: integer(me.getID())])
          end if
        end if
      end if
  end case
  tObjMover = getThread(#room).getInterface().getObjectMover()
  if not voidp(pParentWallLocZ) then
    repeat with i = 1 to pSprList.count
      pSprList[i].locZ = pParentWallLocZ + 20000 + i
    end repeat
  else
    repeat with tSpr in pSprList
      if tSpr.member = member(0, 0) then
        return error(me, "Spritelist contains empty sprite!", #updateLocation, #minor)
      end if
      tItemRp = tSpr.member.regPoint
      tItemR = rect(tSpr.locH, tSpr.locV, tSpr.locH, tSpr.locV) + rect(-tItemRp[1], -tItemRp[2], tSpr.member.width - tItemRp[1], tSpr.member.height - tItemRp[2])
      tPieceUnderSpr = tObjMover.getPassiveObjectIntersectingRect(tItemR)[1]
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
  end if
end
