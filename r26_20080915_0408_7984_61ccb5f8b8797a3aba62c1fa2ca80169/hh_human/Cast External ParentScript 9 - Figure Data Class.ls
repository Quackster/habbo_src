property pPaletteList, pColorList, pSetList, pSetTypeList

on construct me
  me.reset()
  return 1
end

on deconstruct me
  me.reset()
  return 1
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
    repeat with i = 1 to tParserObject.child.count
      tName = tParserObject.child[i].name
      if tName = "figuredata" then
        tElementFigureData = tParserObject.child[i]
        repeat with j = 1 to tElementFigureData.child.count
          tElement = tElementFigureData.child[j]
          if tElement.name = "colors" then
            if me.parseColors(tElement) = 0 then
              me.reset()
              return 0
            end if
            next repeat
          end if
          if tElement.name = "sets" then
            if me.parseSets(tElement) = 0 then
              me.reset()
              return 0
            end if
          end if
        end repeat
      end if
    end repeat
  else
    return 0
  end if
  return 1
end

on getColor me, tColorId
  tColor = pColorList[string(tColorId)]
  if voidp(tColor) then
    return 0
  end if
  return tColor
end

on getPaletteColor me, tPaletteID, tColorIndex
  tPalette = pPaletteList[string(tPaletteID)]
  if voidp(tPalette) then
    return 0
  end if
  tColorIndex = value(tColorIndex)
  if (tColorIndex < 1) or (tColorIndex > tPalette.count) then
    return 0
  end if
  tColor = tPalette[tColorIndex]
  if voidp(tColor) then
    return 0
  end if
  return tColor
end

on getPaletteColorID me, tPaletteID, tColorIndex
  tPalette = pPaletteList[string(tPaletteID)]
  if voidp(tPalette) then
    return 0
  end if
  tColorIndex = value(tColorIndex)
  if (tColorIndex < 1) or (tColorIndex > tPalette.count) then
    return 0
  end if
  return tPalette.getPropAt(tColorIndex)
end

on getSetColor me, tSetID, tColorIndex
  tSetType = me.getSetType(tSetID)
  if tSetType = 0 then
    return 0
  end if
  tPaletteID = me.getSetTypePaletteID(tSetType)
  if tPaletteID = 0 then
    return 0
  end if
  tColor = me.getPaletteColor(tPaletteID, tColorIndex)
  return tColor
end

on getSetColorID me, tSetID, tColorIndex
  tSetType = me.getSetType(tSetID)
  if tSetType = 0 then
    return 0
  end if
  tPaletteID = me.getSetTypePaletteID(tSetType)
  if tPaletteID = 0 then
    return 0
  end if
  return me.getPaletteColorID(tPaletteID, tColorIndex)
end

on getSetType me, tSetID
  tSet = me.getSet(tSetID)
  if tSet = 0 then
    return 0
  end if
  if voidp(tSet["settype"]) then
    return 0
  end if
  return tSet["settype"]
end

on getSetPartCount me, tSetID
  tParts = me.getSetParts(tSetID)
  if tParts = 0 then
    return 0
  end if
  return tParts.count
end

on getSetPartData me, tSetID, tPartIndex
  tParts = me.getSetParts(tSetID)
  if tParts = 0 then
    return 0
  end if
  if (tPartIndex < 1) or (tPartIndex > tParts.count) then
    return 0
  end if
  tPartData = tParts[tPartIndex]
  tdata = [:]
  tdata["id"] = tPartData["id"]
  tdata["type"] = tPartData["type"]
  tdata["colorable"] = tPartData["colorable"]
  return tdata
end

on getSetHiddenLayers me, tSetID
  tSet = me.getSet(tSetID)
  if tSet = 0 then
    return 0
  end if
  if ilk(tSet["hiddenlayers"]) <> #list then
    return 0
  end if
  return tSet["hiddenlayers"].duplicate()
end

on getSet me, tSetID
  tSet = pSetList[string(tSetID)]
  if ilk(tSet) <> #propList then
    return 0
  end if
  return tSet
end

on addSet me, tSetID, tSetData
  if pSetList.findPos(tSetID) then
    return error(me, "multiple set elements with id" && tSetID && "in figure XML!", #addSet, #major)
  end if
  pSetList[tSetID] = tSetData
  return 1
end

on getSetTypePaletteID me, tSetType
  tSetType = pSetTypeList[string(tSetType)]
  if ilk(tSetType) <> #propList then
    return 0
  end if
  if voidp(tSetType["paletteid"]) then
    return 0
  end if
  return tSetType["paletteid"]
end

on getSetParts me, tSetID
  tSet = me.getSet(tSetID)
  if tSet = 0 then
    return 0
  end if
  if voidp(tSet["parts"]) then
    return 0
  end if
  return tSet["parts"]
end

on parseColors me, tElementColors
  repeat with i = 1 to tElementColors.child.count
    tElement = tElementColors.child[i]
    if tElement.name = "palette" then
      tID = VOID
      repeat with j = 1 to tElement.attributeName.count
        if tElement.attributeName[j] = "id" then
          tID = tElement.attributeValue[j]
        end if
      end repeat
      if voidp(tID) then
        return error(me, "missing id attribute for palette element in figure XML!", #parseColors, #major)
      end if
      tColorList = [:]
      repeat with j = 1 to tElement.child.count
        tElementColor = tElement.child[j]
        if tElementColor.name = "color" then
          tColorId = VOID
          repeat with k = 1 to tElementColor.attributeName.count
            if tElementColor.attributeName[k] = "id" then
              tColorId = tElementColor.attributeValue[k]
            end if
          end repeat
          if voidp(tColorId) then
            return error(me, "missing id attribute for color element in palette element with id" && tID && "in figure XML!", #parseColors, #major)
          end if
          if tColorList.findPos(tColorId) then
            return error(me, "multiple color elements with id" && tColorId && "in palette element with id" && tID && "in figure XML!", #parseSets, #major)
          end if
          if tElementColor.child.count = 1 then
            tColorValue = tElementColor.child[1].text
          end if
          if voidp(tColorValue) then
            return error(me, "missing color data for color element with id" && tColorId && "in palette element with id" && tID && "in figure XML!", #parseColors, #major)
          end if
          tColorList.addProp(tColorId, tColorValue)
          if pColorList.findPos(tColorId) then
            return error(me, "multiple color elements with id" && tColorId && "in figure XML!", #parseColors, #major)
          end if
          pColorList.addProp(tColorId, tColorValue)
        end if
      end repeat
      if pPaletteList.findPos(tID) then
        return error(me, "multiple palette elements with id" && tID && "in figure XML!", #parseColors, #major)
      end if
      pPaletteList.addProp(tID, tColorList)
    end if
  end repeat
  return 1
end

on parseSets me, tElementSets
  repeat with i = 1 to tElementSets.child.count
    tElement = tElementSets.child[i]
    if tElement.name = "settype" then
      tAttributes = ["type": VOID, "paletteid": VOID]
      repeat with j = 1 to tElement.attributeName.count
        tName = tElement.attributeName[j]
        tValue = tElement.attributeValue[j]
        tAttributes[tName] = tValue
      end repeat
      if voidp(tAttributes["type"]) then
        return error(me, "missing type attribute for settype element in figure XML!", #parseSets, #major)
      end if
      if voidp(tAttributes["paletteid"]) then
        return error(me, "missing paletteid attribute for settype element in figure XML!", #parseSets, #major)
      end if
      repeat with j = 1 to tElement.child.count
        tElementSet = tElement.child[j]
        if tElementSet.name = "set" then
          if me.parseSet(tElementSet, tAttributes["type"]) = 0 then
            return 0
          end if
        end if
      end repeat
      if pSetTypeList.findPos(tAttributes["type"]) then
        return error(me, "multiple settype elements with type" && tAttributes["type"] && "in figure XML!", #parseSets, #major)
      end if
      tSetTypeData = ["paletteid": tAttributes["paletteid"]]
      pSetTypeList.addProp(tAttributes["type"], tSetTypeData)
    end if
  end repeat
  return 1
end

on parseSet me, tElementSet, tSetType
  tAttributes = ["id": VOID, "colorable": VOID]
  repeat with j = 1 to tElementSet.attributeName.count
    tName = tElementSet.attributeName[j]
    tValue = tElementSet.attributeValue[j]
    tAttributes[tName] = tValue
  end repeat
  if voidp(tAttributes["id"]) then
    return error(me, "missing id attribute for set element in figure XML!", #parseSet, #major)
  end if
  if voidp(tAttributes["colorable"]) then
    return error(me, "missing colorable attribute for set element in figure XML!", #parseSet, #major)
  end if
  tPartData = []
  tHiddenLayers = []
  repeat with i = 1 to tElementSet.child.count
    tElement = tElementSet.child[i]
    if tElement.name = "part" then
      tAttributesPart = ["id": VOID, "type": VOID, "colorable": VOID]
      repeat with j = 1 to tElement.attributeName.count
        tName = tElement.attributeName[j]
        tValue = tElement.attributeValue[j]
        tAttributesPart[tName] = tValue
      end repeat
      if voidp(tAttributesPart["id"]) then
        return error(me, "missing id attribute for part element in figure XML!", #parseSet, #major)
      end if
      if voidp(tAttributesPart["type"]) then
        return error(me, "missing type attribute for part element in figure XML!", #parseSet, #major)
      end if
      if voidp(tAttributesPart["colorable"]) then
        return error(me, "missing colorable attribute for part element in figure XML!", #parseSet, #major)
      end if
      tColorable = value(tAttributes["colorable"]) and value(tAttributesPart["colorable"])
      tdata = ["id": tAttributesPart["id"], "type": tAttributesPart["type"], "colorable": tColorable]
      tPartData.add(tdata)
      next repeat
    end if
    if tElement.name = "hiddenlayers" then
      repeat with j = 1 to tElement.child.count
        tElementLayer = tElement.child[j]
        if tElementLayer.name = "layer" then
          tPartType = VOID
          repeat with k = 1 to tElementLayer.attributeName.count
            if tElementLayer.attributeName[k] = "parttype" then
              tPartType = tElementLayer.attributeValue[k]
            end if
          end repeat
          if voidp(tPartType) then
            return error(me, "missing parttype attribute for layer element in hiddenlayers element in set element with id" && tAttributes["id"] && "in figure XML!", #parseColors, #major)
          end if
          tHiddenLayers.add(tPartType)
        end if
      end repeat
    end if
  end repeat
  tSetData = ["settype": tSetType, "parts": tPartData, "hiddenlayers": tHiddenLayers]
  return me.addSet(tAttributes["id"], tSetData)
  return 1
end
