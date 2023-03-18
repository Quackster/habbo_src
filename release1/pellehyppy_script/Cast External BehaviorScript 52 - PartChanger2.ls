property pPartName, pPreviewSpriteNameIdList, pPreviewSprites, pPartPropList, whichPartNowCounter, whichColorNowCounter, pMultielementList, tempSex
global gMySex

on beginSprite me
  pPartPropList = [:]
  whichPartNowCounter = 1
  whichColorNowCounter = 1
  pPreviewSprites = [:]
  repeat with f in pPreviewSpriteNameIdList
    pPreviewSprites.addProp(f, sendAllSprites(#SpriteNumOfSprite, f))
  end repeat
  put gMySex
  tempSex = "Male"
  if gMySex = "M" then
    gMySex = "Male"
  end if
  if gMySex = "F" then
    gMySex = "Female"
  end if
  if gMySex = "Male" then
    tempSex = "Male"
  end if
  if gMySex = "Female" then
    tempSex = "Female"
  end if
  s = member(pPartName & "/specs_" & tempSex).text
  put s
  oldItemDelimiter = the itemDelimiter
  repeat with f = 1 to s.line.count
    the itemDelimiter = "/"
    rgbLine = s.line[f].item[2]
    if (rgbLine = EMPTY) or (rgbLine = "0") then
      rgbLine = "255,255,255"
    end if
    the itemDelimiter = "&"
    rgbList = []
    repeat with i = 1 to rgbLine.item.count
      rgbList.add(rgbLine.item[i])
    end repeat
    the itemDelimiter = "/"
    if s.line[f].item[1].length < 3 then
      tmpNbr = EMPTY & s.line[f].item[1]
      repeat with t = 1 to 3
        if tmpNbr.length < 3 then
          tmpNbr = "0" & tmpNbr
        end if
      end repeat
    else
      tmpNbr = EMPTY & s.line[f].item[1]
    end if
    pPartPropList.addProp(tmpNbr, rgbList)
  end repeat
  the itemDelimiter = "/"
  if pPartName.item.count > 1 then
    pMultielementList = []
    repeat with f = 1 to pPartName.item.count
      pMultielementList.add(pPartName.item[f])
    end repeat
  end if
  the itemDelimiter = oldItemDelimiter
  UpdatePreviewSpritesColor()
  UpdatePreviewSpritesPart()
end

on GetMyPartData me, whichPart
  if whichPart = pPartName then
    the itemDelimiter = ","
    r = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter))[whichColorNowCounter].item[1])
    g = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter))[whichColorNowCounter].item[2])
    b = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter))[whichColorNowCounter].item[3])
    NewPart = pPartName & "=" & pPartPropList.getPropAt(whichPartNowCounter) & "/" & r & "," & g & "," & b
    put NewPart
    return NewPart
  end if
end

on changePart me, whichPart, dir
  if whichPart = pPartName then
    whichColorNowCounter = 1
    if dir > 0 then
      whichPartNowCounter = whichPartNowCounter + 1
      if whichPartNowCounter > pPartPropList.count then
        whichPartNowCounter = 1
      end if
    else
      whichPartNowCounter = whichPartNowCounter - 1
      if whichPartNowCounter < 1 then
        whichPartNowCounter = pPartPropList.count
      end if
    end if
  end if
  UpdatePreviewSpritesColor()
  UpdatePreviewSpritesPart()
end

on changePartColor me, whichPart, dir
  if whichPart = pPartName then
    if dir > 0 then
      whichColorNowCounter = whichColorNowCounter + 1
      if whichColorNowCounter > pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter)).count then
        whichColorNowCounter = 1
      end if
    else
      whichColorNowCounter = whichColorNowCounter - 1
      if whichColorNowCounter < 1 then
        whichColorNowCounter = pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter)).count
      end if
    end if
  end if
  UpdatePreviewSpritesColor()
end

on UpdatePreviewSpritesPart me
  s = "sh_std_" & pPartName & "_" & pPartPropList.getPropAt(whichPartNowCounter) & "_2_0"
  put s
  repeat with f = 1 to pPreviewSprites.count
    sendSprite(pPreviewSprites.getProp(pPreviewSprites.getPropAt(f)), #ChangePartPreviewSprite, s)
  end repeat
end

on UpdatePreviewSpritesColor me
  oldItemDelimiter = the itemDelimiter
  the itemDelimiter = ","
  r = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter))[whichColorNowCounter].item[1])
  g = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter))[whichColorNowCounter].item[2])
  b = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter))[whichColorNowCounter].item[3])
  repeat with f = 1 to pPreviewSprites.count
    sprite(pPreviewSprites.getProp(pPreviewSprites.getPropAt(f))).bgColor = rgb(r, g, b)
  end repeat
  the itemDelimiter = oldItemDelimiter
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #pPartName, [#comment: "Which figure part(s) (multielement example lh/ch/rh)", #format: #string, #default: "ch"])
  addProp(pList, #pPreviewSpriteNameIdList, [#comment: "Identification name List of Preview Sprite", #format: #list, #default: ["ch_SmallPreview", "ch_ColorPreview", "ch_Preview"]])
  return pList
end
