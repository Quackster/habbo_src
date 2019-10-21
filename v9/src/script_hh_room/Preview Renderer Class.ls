property pPossibleParts

on construct me 
  createMember("preview_rendered", #bitmap)
  pPossibleParts = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l"]
  return TRUE
end

on deconstruct me 
  removeMember("preview_rendered")
  return TRUE
end

on getPreviewMember me, tImage 
  tMemNum = getmemnum("preview_rendered")
  member(tMemNum).image = tImage
  return(tMemNum)
end

on solveClass me, tClass, tMemStr 
  tName = tClass
  if tName contains "*" then
    tSmallMem = tName & "_small"
    tName = tName.getProp(#char, 1, (offset("*", tName) - 1))
    if not memberExists(tSmallMem) then
      tSmallMem = tName & "_small"
    end if
  else
    tSmallMem = tClass & "_small"
  end if
  if (tMemStr = void()) then
    tMemStr = ""
  end if
  if memberExists(tSmallMem) then
    return(tSmallMem)
  else
    if memberExists(tMemStr) then
      return(tMemStr)
    else
      return("no_icon_small")
    end if
  end if
end

on solveColorList me, tpartColors 
  if (tpartColors = "") or voidp(tpartColors) then
    tpartColors = "0,0,0"
  end if
  tPartList = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  i = 1
  repeat while i <= tpartColors.count(#item)
    tPartList.add(string(tpartColors.getProp(#item, i)))
    i = (1 + i)
  end repeat
  j = tPartList.count
  repeat while j <= 4
    tPartList.add("*ffffff")
    j = (1 + j)
  end repeat
  the itemDelimiter = tDelim
  return(tPartList)
end

on renderPreviewImage me, tMemStr, tColorList, tColorListToSolve, tClass 
  if (tMemStr = void()) then
    tMemStr = me.solveClass(tClass, tMemStr)
  end if
  if (getmemnum(tMemStr) = 0) then
    tMemStr = me.solveClass(tClass, tMemStr)
  end if
  if tColorListToSolve <> void() then
    tColorList = me.solveColorList(tColorListToSolve)
  end if
  if not me.doLayersExist(tMemStr) then
    tColor = me.getSmallsColor(tMemStr, tColorList)
    if (tColor = 0) then
      return(member(getmemnum(tMemStr)).image)
    end if
    return(me.applyDarkenColor(member(getmemnum(tMemStr)).image, tColor))
  end if
  tMem = member(getmemnum(tMemStr))
  tRendered = image(tMem.width, tMem.height, 32)
  tRendered.copyPixels(tMem.image, tMem.rect, tMem.rect)
  i = 1
  repeat while i <= pPossibleParts.count
    if memberExists(tMemStr & "_" & pPossibleParts.getAt(i)) then
      tRendered = me.addLayerToImage(tRendered, i, tMemStr, tColorList)
    end if
    i = (1 + i)
  end repeat
  return(tRendered)
end

on getSmallsColor me, tMemStr, tColorList 
  tColor = me.getLastColor(tColorList)
  if (tColor = "ffffff") or tMemStr contains "*" then
    return FALSE
  end if
  return(tColor)
end

on doLayersExist me, tMemStr 
  i = 1
  repeat while i <= pPossibleParts.count
    if memberExists(tMemStr & "_" & pPossibleParts.getAt(i)) then
      return TRUE
    end if
    i = (1 + i)
  end repeat
  return FALSE
end

on getLastColor me, tColorList 
  tColor = "ffffff"
  if (tColorList.ilk = #list) then
    i = 1
    repeat while i <= tColorList.count
      if tColorList.getAt(i) contains "ffffff" or (tColorList.getAt(i) = "0") or (tColorList.getAt(i) = "null") then
        nothing()
      else
        tColor = tColorList.getAt(i)
      end if
      i = (1 + i)
    end repeat
  end if
  return(tColor)
end

on addLayerToImage me, tImg, tNum, tMemStr, tColorList 
  tAbc = pPossibleParts.getAt(tNum)
  if (tColorList = void()) then
    tColorList = []
  end if
  if tColorList.count < tNum then
    tColor = "ffffff"
  else
    tColor = tColorList.getAt(tNum)
  end if
  tImg2 = member(getmemnum(tMemStr & "_" & tAbc)).image
  tRegp = (member(getmemnum(tMemStr & "_" & tAbc)).regPoint - member(getmemnum(tMemStr)).regPoint)
  tRect = (tImg2.rect - rect(tRegp.getAt(1), tRegp.getAt(2), tRegp.getAt(1), tRegp.getAt(2)))
  tMatte = tImg2.createMatte()
  tColorObj = rgb(tColor)
  tImg.copyPixels(tImg2, tRect, tImg2.rect, [#ink:41, #bgColor:tColorObj, #maskImage:tMatte])
  return(tImg)
end

on applyDarkenColor me, tOrgImg, tColor 
  tColorObj = rgb(tColor)
  tImg = image(tOrgImg.width, tOrgImg.height, 32)
  tMatte = tOrgImg.createMatte()
  tImg.copyPixels(tOrgImg, tImg.rect, tImg.rect, [#ink:41, #bgColor:tColorObj, #maskImage:tMatte])
  return(tImg)
end
