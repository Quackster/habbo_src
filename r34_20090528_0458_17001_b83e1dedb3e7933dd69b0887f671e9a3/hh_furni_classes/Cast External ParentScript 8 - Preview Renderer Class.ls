property pPossibleParts

on construct me
  createMember("preview_rendered", #bitmap)
  pPossibleParts = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l"]
  return 1
end

on deconstruct me
  removeMember("preview_rendered")
  return 1
end

on getPreviewMember me, tImage
  if tImage = VOID then
    return 0
  end if
  tMemNum = getmemnum("preview_rendered")
  member(tMemNum).image = tImage
  return tMemNum
end

on solveClass me, tClass, tMemStr
  tName = tClass
  if tName contains "*" then
    tSmallMem = tName & "_small"
    tName = tName.char[1..offset("*", tName) - 1]
    if not memberExists(tSmallMem) then
      tSmallMem = tName & "_small"
    end if
  else
    tSmallMem = tClass & "_small"
  end if
  if tMemStr = VOID then
    tMemStr = EMPTY
  end if
  if memberExists(tSmallMem) then
    return tSmallMem
  else
    if memberExists(tMemStr) then
      return tMemStr
    else
      return "no_icon_small"
    end if
  end if
end

on solveColorList me, tpartColors
  if (tpartColors = EMPTY) or voidp(tpartColors) then
    tpartColors = "0,0,0"
  end if
  tPartList = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  repeat with i = 1 to tpartColors.item.count
    tPartList.add(string(tpartColors.item[i]))
  end repeat
  repeat with j = tPartList.count to 4
    tPartList.add("*ffffff")
  end repeat
  the itemDelimiter = tDelim
  return tPartList
end

on renderPreviewImage me, tMemStr, tColorList, tColorListToSolve, tClass
  if tMemStr = VOID then
    tMemStr = me.solveClass(tClass, tMemStr)
  end if
  if getmemnum(tMemStr) = 0 then
    tMemStr = me.solveClass(tClass, tMemStr)
  end if
  if tColorListToSolve <> VOID then
    tColorList = me.solveColorList(tColorListToSolve)
  end if
  if not me.doLayersExist(tMemStr) then
    if getmemnum(tMemStr) = 0 then
      return member(getmemnum("no_icon_small")).image
    end if
    tColor = me.getSmallsColor(tMemStr, tColorList)
    if ilk(member(getmemnum(tMemStr))) <> #member then
      return 0
    end if
    if member(getmemnum(tMemStr)).type <> #bitmap then
      return 0
    end if
    if (tColor = 0) or (tColor = EMPTY) then
      return member(getmemnum(tMemStr)).image
    end if
    return me.applyDarkenColor(member(getmemnum(tMemStr)).image, tColor)
  end if
  if getmemnum(tMemStr) = 0 then
    return 0
  end if
  tMem = member(getmemnum(tMemStr))
  tOffset = point(50, 50)
  tRect = rect(tOffset.locH, tOffset.locV, tMem.rect.width + tOffset.locH, tMem.rect.height + tOffset.locV)
  tRendered = image(tMem.rect.width + (tOffset.locH * 2), tMem.rect.height + (tOffset.locV * 2), 32)
  tRendered.copyPixels(tMem.image, tRect, tMem.rect)
  repeat with i = 1 to pPossibleParts.count
    if memberExists(tMemStr & "_" & pPossibleParts[i]) then
      tRendered = me.addLayerToImage(tRendered, i, tMemStr, tColorList, tOffset)
    end if
  end repeat
  if tRendered = 0 then
    return 0
  end if
  tRendered = tRendered.trimWhiteSpace()
  return tRendered
end

on getSmallsColor me, tMemStr, tColorList
  tColor = me.getLastColor(tColorList)
  if (tColor = "ffffff") or (tMemStr contains "*") then
    return 0
  end if
  return tColor
end

on doLayersExist me, tMemStr
  repeat with i = 1 to pPossibleParts.count
    if memberExists(tMemStr & "_" & pPossibleParts[i]) then
      return 1
    end if
  end repeat
  return 0
end

on getLastColor me, tColorList
  tColor = "ffffff"
  if tColorList.ilk = #list then
    repeat with i = 1 to tColorList.count
      if (tColorList[i] contains "ffffff") or (tColorList[i] = "0") or (tColorList[i] = "null") then
        nothing()
        next repeat
      end if
      tColor = tColorList[i]
    end repeat
  end if
  return tColor
end

on addLayerToImage me, tImg, tNum, tMemStr, tColorList, tOffset
  tAbc = pPossibleParts[tNum]
  if tColorList = VOID then
    tColorList = []
  end if
  if tColorList.count < tNum then
    tColor = "ffffff"
  else
    tColor = tColorList[tNum]
  end if
  tmember = member(getmemnum(tMemStr & "_" & tAbc))
  if ilk(tmember) <> #member then
    error(me, "Member was not found" && tMemStr & "_" & tAbc, #addLayerToImage, #minor)
    return image(1, 1, 32)
  end if
  tImg2 = tmember.image
  tRegp = tmember.regPoint - member(getmemnum(tMemStr)).regPoint
  tRegp = tRegp - tOffset
  tRect = tImg2.rect - rect(tRegp[1], tRegp[2], tRegp[1], tRegp[2])
  tMatte = tImg2.createMatte()
  tColorObj = rgb(tColor)
  tImg.copyPixels(tImg2, tRect, tImg2.rect, [#ink: 41, #bgColor: tColorObj, #maskImage: tMatte])
  return tImg
end

on applyDarkenColor me, tOrgImg, tColor
  tColorObj = rgb(tColor)
  tImg = image(tOrgImg.width, tOrgImg.height, 32)
  tMatte = tOrgImg.createMatte()
  tImg.copyPixels(tOrgImg, tImg.rect, tImg.rect, [#ink: 41, #bgColor: tColorObj, #maskImage: tMatte])
  return tImg
end
