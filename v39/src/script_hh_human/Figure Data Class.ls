property pColorList, pPaletteList, pSetList, pSetTypeList

on construct me 
  me.reset()
  return(1)
end

on deconstruct me 
  me.reset()
  return(1)
end

on reset me 
  pPaletteList = [:]
  pColorList = [:]
  pSetList = [:]
  pSetTypeList = [:]
end

on parseData me, tXMLData 
  me.reset()
  tParserObject = new(xtra("xmlparser"))
  errCode = tParserObject.parseString(tXMLData)
  errorString = tParserObject.getError()
  if voidp(errorString) then
    i = 1
    repeat while i <= tParserObject.count(#child)
      tName = tParserObject.getPropRef(#child, i).name
      if tName = "figuredata" then
        tElementFigureData = tParserObject.getProp(#child, i)
        j = 1
        repeat while j <= tElementFigureData.count(#child)
          tElement = tElementFigureData.getProp(#child, j)
          if tElement.name = "colors" then
            if me.parseColors(tElement) = 0 then
              me.reset()
              return(0)
            end if
          else
            if tElement.name = "sets" then
              if me.parseSets(tElement) = 0 then
                me.reset()
                return(0)
              end if
            end if
          end if
          j = 1 + j
        end repeat
      end if
      i = 1 + i
    end repeat
    exit repeat
  end if
  return(0)
  return(1)
end

on getColor me, tColorId 
  tColor = pColorList.getAt(string(tColorId))
  if voidp(tColor) then
    return(0)
  end if
  return(tColor)
end

on getPaletteColor me, tPaletteID, tColorIndex 
  tPalette = pPaletteList.getAt(string(tPaletteID))
  if voidp(tPalette) then
    return(0)
  end if
  tColorIndex = value(tColorIndex)
  if tColorIndex < 1 or tColorIndex > tPalette.count then
    return(0)
  end if
  tColor = tPalette.getAt(tColorIndex)
  if voidp(tColor) then
    return(0)
  end if
  return(tColor)
end

on getPaletteColorID me, tPaletteID, tColorIndex 
  tPalette = pPaletteList.getAt(string(tPaletteID))
  if voidp(tPalette) then
    return(0)
  end if
  tColorIndex = value(tColorIndex)
  if tColorIndex < 1 or tColorIndex > tPalette.count then
    return(0)
  end if
  return(tPalette.getPropAt(tColorIndex))
end

on getSetColor me, tSetID, tColorIndex 
  tSetType = me.getSetType(tSetID)
  if tSetType = 0 then
    return(0)
  end if
  tPaletteID = me.getSetTypePaletteID(tSetType)
  if tPaletteID = 0 then
    return(0)
  end if
  tColor = me.getPaletteColor(tPaletteID, tColorIndex)
  return(tColor)
end

on getSetColorID me, tSetID, tColorIndex 
  tSetType = me.getSetType(tSetID)
  if tSetType = 0 then
    return(0)
  end if
  tPaletteID = me.getSetTypePaletteID(tSetType)
  if tPaletteID = 0 then
    return(0)
  end if
  return(me.getPaletteColorID(tPaletteID, tColorIndex))
end

on getSetType me, tSetID 
  tSet = me.getSet(tSetID)
  if tSet = 0 then
    return(0)
  end if
  if voidp(tSet.getAt("settype")) then
    return(0)
  end if
  return(tSet.getAt("settype"))
end

on getSetPartCount me, tSetID 
  tParts = me.getSetParts(tSetID)
  if tParts = 0 then
    return(0)
  end if
  return(tParts.count)
end

on getSetPartData me, tSetID, tPartIndex 
  tParts = me.getSetParts(tSetID)
  if tParts = 0 then
    return(0)
  end if
  if tPartIndex < 1 or tPartIndex > tParts.count then
    return(0)
  end if
  tPartData = tParts.getAt(tPartIndex)
  tdata = [:]
  tdata.setAt("id", tPartData.getAt("id"))
  tdata.setAt("type", tPartData.getAt("type"))
  tdata.setAt("colorable", tPartData.getAt("colorable"))
  return(tdata)
end

on getSetHiddenLayers me, tSetID 
  tSet = me.getSet(tSetID)
  if tSet = 0 then
    return(0)
  end if
  if ilk(tSet.getAt("hiddenlayers")) <> #list then
    return(0)
  end if
  return(tSet.getAt("hiddenlayers").duplicate())
end

on getSet me, tSetID 
  tSet = pSetList.getAt(string(tSetID))
  if ilk(tSet) <> #propList then
    return(0)
  end if
  return(tSet)
end

on addSet me, tSetID, tSetData 
  if pSetList.findPos(tSetID) then
    return(error(me, "multiple set elements with id" && tSetID && "in figure XML!", #addSet, #major))
  end if
  pSetList.setAt(tSetID, tSetData)
  return(1)
end

on getSetTypePaletteID me, tSetType 
  tSetType = pSetTypeList.getAt(string(tSetType))
  if ilk(tSetType) <> #propList then
    return(0)
  end if
  if voidp(tSetType.getAt("paletteid")) then
    return(0)
  end if
  return(tSetType.getAt("paletteid"))
end

on getSetParts me, tSetID 
  tSet = me.getSet(tSetID)
  if tSet = 0 then
    return(0)
  end if
  if voidp(tSet.getAt("parts")) then
    return(0)
  end if
  return(tSet.getAt("parts"))
end

on parseColors me, tElementColors 
  i = 1
  repeat while i <= tElementColors.count(#child)
    tElement = tElementColors.getProp(#child, i)
    if tElement.name = "palette" then
      tID = void()
      j = 1
      repeat while j <= tElement.count(#attributeName)
        if tElement.getProp(#attributeName, j) = "id" then
          tID = tElement.getProp(#attributeValue, j)
        end if
        j = 1 + j
      end repeat
      if voidp(tID) then
        return(error(me, "missing id attribute for palette element in figure XML!", #parseColors, #major))
      end if
      tColorList = [:]
      j = 1
      repeat while j <= tElement.count(#child)
        tElementColor = tElement.getProp(#child, j)
        if tElementColor.name = "color" then
          tColorId = void()
          k = 1
          repeat while k <= tElementColor.count(#attributeName)
            if tElementColor.getProp(#attributeName, k) = "id" then
              tColorId = tElementColor.getProp(#attributeValue, k)
            end if
            k = 1 + k
          end repeat
          if voidp(tColorId) then
            return(error(me, "missing id attribute for color element in palette element with id" && tID && "in figure XML!", #parseColors, #major))
          end if
          if tColorList.findPos(tColorId) then
            return(error(me, "multiple color elements with id" && tColorId && "in palette element with id" && tID && "in figure XML!", #parseSets, #major))
          end if
          if tElementColor.count(#child) = 1 then
            tColorValue = tElementColor.getPropRef(#child, 1).text
          end if
          if voidp(tColorValue) then
            return(error(me, "missing color data for color element with id" && tColorId && "in palette element with id" && tID && "in figure XML!", #parseColors, #major))
          end if
          tColorList.addProp(tColorId, tColorValue)
          if pColorList.findPos(tColorId) then
            return(error(me, "multiple color elements with id" && tColorId && "in figure XML!", #parseColors, #major))
          end if
          pColorList.addProp(tColorId, tColorValue)
        end if
        j = 1 + j
      end repeat
      if pPaletteList.findPos(tID) then
        return(error(me, "multiple palette elements with id" && tID && "in figure XML!", #parseColors, #major))
      end if
      pPaletteList.addProp(tID, tColorList)
    end if
    i = 1 + i
  end repeat
  return(1)
end

on parseSets me, tElementSets 
  i = 1
  repeat while i <= tElementSets.count(#child)
    tElement = tElementSets.getProp(#child, i)
    if tElement.name = "settype" then
      tAttributes = ["type":void(), "paletteid":void()]
      j = 1
      repeat while j <= tElement.count(#attributeName)
        tName = tElement.getProp(#attributeName, j)
        tValue = tElement.getProp(#attributeValue, j)
        tAttributes.setAt(tName, tValue)
        j = 1 + j
      end repeat
      if voidp(tAttributes.getAt("type")) then
        return(error(me, "missing type attribute for settype element in figure XML!", #parseSets, #major))
      end if
      if voidp(tAttributes.getAt("paletteid")) then
        return(error(me, "missing paletteid attribute for settype element in figure XML!", #parseSets, #major))
      end if
      j = 1
      repeat while j <= tElement.count(#child)
        tElementSet = tElement.getProp(#child, j)
        if tElementSet.name = "set" then
          if me.parseSet(tElementSet, tAttributes.getAt("type")) = 0 then
            return(0)
          end if
        end if
        j = 1 + j
      end repeat
      if pSetTypeList.findPos(tAttributes.getAt("type")) then
        return(error(me, "multiple settype elements with type" && tAttributes.getAt("type") && "in figure XML!", #parseSets, #major))
      end if
      tSetTypeData = ["paletteid":tAttributes.getAt("paletteid")]
      pSetTypeList.addProp(tAttributes.getAt("type"), tSetTypeData)
    end if
    i = 1 + i
  end repeat
  return(1)
end

on parseSet me, tElementSet, tSetType 
  tAttributes = ["id":void(), "colorable":void()]
  j = 1
  repeat while j <= tElementSet.count(#attributeName)
    tName = tElementSet.getProp(#attributeName, j)
    tValue = tElementSet.getProp(#attributeValue, j)
    tAttributes.setAt(tName, tValue)
    j = 1 + j
  end repeat
  if voidp(tAttributes.getAt("id")) then
    return(error(me, "missing id attribute for set element in figure XML!", #parseSet, #major))
  end if
  if voidp(tAttributes.getAt("colorable")) then
    return(error(me, "missing colorable attribute for set element in figure XML!", #parseSet, #major))
  end if
  tPartData = []
  tHiddenLayers = []
  i = 1
  repeat while i <= tElementSet.count(#child)
    tElement = tElementSet.getProp(#child, i)
    if tElement.name = "part" then
      tAttributesPart = ["id":void(), "type":void(), "colorable":void()]
      j = 1
      repeat while j <= tElement.count(#attributeName)
        tName = tElement.getProp(#attributeName, j)
        tValue = tElement.getProp(#attributeValue, j)
        tAttributesPart.setAt(tName, tValue)
        j = 1 + j
      end repeat
      if voidp(tAttributesPart.getAt("id")) then
        return(error(me, "missing id attribute for part element in figure XML!", #parseSet, #major))
      end if
      if voidp(tAttributesPart.getAt("type")) then
        return(error(me, "missing type attribute for part element in figure XML!", #parseSet, #major))
      end if
      if voidp(tAttributesPart.getAt("colorable")) then
        return(error(me, "missing colorable attribute for part element in figure XML!", #parseSet, #major))
      end if
      tColorable = value(tAttributes.getAt("colorable")) and value(tAttributesPart.getAt("colorable"))
      tdata = ["id":tAttributesPart.getAt("id"), "type":tAttributesPart.getAt("type"), "colorable":tColorable]
      tPartData.add(tdata)
    else
      if tElement.name = "hiddenlayers" then
        j = 1
        repeat while j <= tElement.count(#child)
          tElementLayer = tElement.getProp(#child, j)
          if tElementLayer.name = "layer" then
            tPartType = void()
            k = 1
            repeat while k <= tElementLayer.count(#attributeName)
              if tElementLayer.getProp(#attributeName, k) = "parttype" then
                tPartType = tElementLayer.getProp(#attributeValue, k)
              end if
              k = 1 + k
            end repeat
            if voidp(tPartType) then
              return(error(me, "missing parttype attribute for layer element in hiddenlayers element in set element with id" && tAttributes.getAt("id") && "in figure XML!", #parseColors, #major))
            end if
            tHiddenLayers.add(tPartType)
          end if
          j = 1 + j
        end repeat
      end if
    end if
    i = 1 + i
  end repeat
  tSetData = ["settype":tSetType, "parts":tPartData, "hiddenlayers":tHiddenLayers]
  return(me.addSet(tAttributes.getAt("id"), tSetData))
  return(1)
end
