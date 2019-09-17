property pPreviewSpriteNameIdList, pPreviewSprites, pPartName, tempSex, pPartPropList, pMultielementList, whichPartNowCounter, whichColorNowCounter

on beginSprite me 
  pPartPropList = [:]
  whichPartNowCounter = 1
  whichColorNowCounter = 1
  pPreviewSprites = [:]
  repeat while pPreviewSpriteNameIdList <= undefined
    f = getAt(undefined, undefined)
    pPreviewSprites.addProp(f, sendAllSprites(#SpriteNumOfSprite, f))
  end repeat
  put(gMySex)
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
  put(s)
  oldItemDelimiter = the itemDelimiter
  f = 1
  repeat while f <= s.count(#line)
    the itemDelimiter = "/"
    rgbLine = s.getPropRef(#line, f).getProp(#item, 2)
    if rgbLine = "" or rgbLine = "0" then
      rgbLine = "255,255,255"
    end if
    the itemDelimiter = "&"
    rgbList = []
    i = 1
    repeat while i <= rgbLine.count(#item)
      rgbList.add(rgbLine.getProp(#item, i))
      i = 1 + i
    end repeat
    the itemDelimiter = "/"
    if s.getPropRef(#line, f).getPropRef(#item, 1).length < 3 then
      tmpNbr = "" & s.getPropRef(#line, f).getProp(#item, 1)
      t = 1
      repeat while t <= 3
        if tmpNbr.length < 3 then
          tmpNbr = "0" & tmpNbr
        end if
        t = 1 + t
      end repeat
      exit repeat
    end if
    tmpNbr = "" & s.getPropRef(#line, f).getProp(#item, 1)
    pPartPropList.addProp(tmpNbr, rgbList)
    f = 1 + f
  end repeat
  the itemDelimiter = "/"
  if pPartName.count(#item) > 1 then
    pMultielementList = []
    f = 1
    repeat while f <= pPartName.count(#item)
      pMultielementList.add(pPartName.getProp(#item, f))
      f = 1 + f
    end repeat
  end if
  the itemDelimiter = oldItemDelimiter
  UpdatePreviewSpritesColor()
  UpdatePreviewSpritesPart()
end

on GetMyPartData me, whichPart 
  if whichPart = pPartName then
    the itemDelimiter = ","
    r = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter)).getAt(whichColorNowCounter).getProp(#item, 1))
    g = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter)).getAt(whichColorNowCounter).getProp(#item, 2))
    b = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter)).getAt(whichColorNowCounter).getProp(#item, 3))
    NewPart = pPartName & "=" & pPartPropList.getPropAt(whichPartNowCounter) & "/" & r & "," & g & "," & b
    put(NewPart)
    return(NewPart)
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
  put(s)
  f = 1
  repeat while f <= pPreviewSprites.count
    sendSprite(pPreviewSprites.getProp(pPreviewSprites.getPropAt(f)), #ChangePartPreviewSprite, s)
    f = 1 + f
  end repeat
end

on UpdatePreviewSpritesColor me 
  oldItemDelimiter = the itemDelimiter
  the itemDelimiter = ","
  r = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter)).getAt(whichColorNowCounter).getProp(#item, 1))
  g = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter)).getAt(whichColorNowCounter).getProp(#item, 2))
  b = integer(pPartPropList.getProp(pPartPropList.getPropAt(whichPartNowCounter)).getAt(whichColorNowCounter).getProp(#item, 3))
  f = 1
  repeat while f <= pPreviewSprites.count
    sprite(pPreviewSprites.getProp(pPreviewSprites.getPropAt(f))).bgColor = rgb(r, g, b)
    f = 1 + f
  end repeat
  the itemDelimiter = oldItemDelimiter
end

on getPropertyDescriptionList me 
  pList = [:]
  addProp(pList, #pPartName, [#comment:"Which figure part(s) (multielement example lh/ch/rh)", #format:#string, #default:"ch"])
  addProp(pList, #pPreviewSpriteNameIdList, [#comment:"Identification name List of Preview Sprite", #format:#list, #default:["ch_SmallPreview", "ch_ColorPreview", "ch_Preview"]])
  return(pList)
end
