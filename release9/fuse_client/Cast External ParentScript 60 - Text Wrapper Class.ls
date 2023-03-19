property pFontData, pTextMem, pNeedFill

on prepare me
  me.pOffX = 0
  me.pOffY = 0
  me.pOwnW = me.pProps[#width]
  me.pOwnH = me.pProps[#height]
  me.pScrolls = []
  if me.pProps[#style] = #unique then
    me.pOwnX = 0
    me.pOwnY = 0
  else
    me.pOwnX = me.pProps[#locH]
    me.pOwnY = me.pProps[#locV]
  end if
  pFontData = [:]
  pFontData[#color] = me.pProps[#txtColor]
  pFontData[#bgColor] = me.pProps[#txtBgColor]
  pFontData[#key] = me.pProps[#key]
  pFontData[#wordWrap] = me.pProps[#wordWrap]
  pFontData[#alignment] = symbol(me.pProps[#alignment])
  pFontData[#font] = me.pProps[#font]
  pFontData[#fontSize] = me.pProps[#fontSize]
  pFontData[#fontStyle] = me.pProps[#fontStyle]
  if integerp(me.pProps[#fixedLineSpace]) then
    pFontData[#fixedLineSpace] = me.pProps[#fixedLineSpace]
  else
    pFontData[#fixedLineSpace] = me.pProps[#fontSize]
  end if
  if voidp(pFontData[#key]) then
    pFontData[#key] = EMPTY
  end if
  if pFontData[#bgColor] <> rgb(255, 255, 255) then
    pNeedFill = 1
  else
    pNeedFill = 0
  end if
  me.initResources(pFontData)
  return me.createImgFromTxt()
end

on setText me, tText
  tText = string(tText)
  pFontData[#text] = tText
  tRect = rect(me.pOwnX, me.pOwnY, me.pOwnX + me.pOwnW, me.pOwnY + me.pOwnH)
  me.pBuffer.image.fill(tRect, rgb(255, 255, 255))
  me.createImgFromTxt()
  me.render()
  me.registerScroll()
  return 1
end

on getText me
  return pFontData[#text]
end

on setFont me, tStruct
  pFontData.font = tStruct.getaProp(#font)
  pFontData.fontStyle = tStruct.getaProp(#fontStyle)
  pFontData.fontSize = tStruct.getaProp(#fontSize)
  pFontData.color = tStruct.getaProp(#color)
  pFontData.fixedLineSpace = tStruct.getaProp(#lineHeight)
  tRect = rect(me.pOwnX, me.pOwnY, me.pOwnX + me.pOwnW, me.pOwnY + me.pOwnH)
  me.pBuffer.image.fill(tRect, rgb(255, 255, 255))
  me.createImgFromTxt()
  me.render()
  me.registerScroll()
  return 1
end

on getFont me
  tStruct = getStructVariable("struct.font.empty")
  tStruct.setaProp(#font, pFontData.font)
  tStruct.setaProp(#fontStyle, pFontData.fontStyle)
  tStruct.setaProp(#fontSize, pFontData.fontSize)
  tStruct.setaProp(#color, pFontData.color)
  tStruct.setaProp(#lineHeight, pFontData.fixedLineSpace)
  return tStruct
end

on registerScroll me, tid
  if voidp(me.pScrolls) then
    me.prepare()
  end if
  if not voidp(tid) then
    if me.pScrolls.getPos(tid) = 0 then
      me.pScrolls.add(tid)
    end if
  else
    if me.pScrolls.count = 0 then
      return 0
    end if
  end if
  tSourceRect = rect(me.pOffX, me.pOffY, me.pOffX + me.pOwnW, me.pOffY + me.pOwnH)
  tScrollList = []
  tWndObj = getWindowManager().get(me.pMotherId)
  repeat with tScrollId in me.pScrolls
    tScrollList.add(tWndObj.getElement(tScrollId))
  end repeat
  me.createImgFromTxt()
  call(#updateData, tScrollList, tSourceRect, me.pimage.rect)
end

on initResources me, tFontProps
  tMemNum = getResourceManager().getmemnum("visual window text")
  if tMemNum = 0 then
    tMemNum = getResourceManager().createMember("visual window text", #text)
    pTextMem = member(tMemNum)
    pTextMem.boxType = #adjust
  else
    pTextMem = member(tMemNum)
  end if
  return 1
end

on createImgFromTxt me
  pTextMem.rect = rect(0, 0, me.pOwnW, me.pOwnH)
  if not listp(pFontData[#fontStyle]) then
    tList = []
    tDelim = the itemDelimiter
    the itemDelimiter = ","
    repeat with i = 1 to pFontData[#fontStyle].item.count
      tList.add(symbol(pFontData[#fontStyle].item[i]))
    end repeat
    the itemDelimiter = tDelim
    pFontData[#fontStyle] = tList
  end if
  if not voidp(pFontData[#text]) then
    pTextMem.text = pFontData[#text]
    pFontData[#text] = VOID
  else
    if pFontData[#key] = EMPTY then
      pTextMem.text = EMPTY
    else
      if pFontData[#key].char[1] = "%" then
        tKey = symbol(pFontData[#key].char[2..length(pFontData[#key])])
        pTextMem.text = string(getObject(me.pMotherId).getProperty(tKey))
      else
        if textExists(pFontData[#key]) then
          pTextMem.text = getTextManager().get(pFontData[#key])
        else
          error(me, "Text not found:" && pFontData[#key], #createImgFromTxt)
          pTextMem.text = pFontData[#key]
        end if
      end if
    end if
  end if
  pFontData[#text] = pTextMem.text
  if pTextMem.fontStyle <> pFontData[#fontStyle] then
    pTextMem.fontStyle = pFontData[#fontStyle]
  end if
  if pTextMem.wordWrap <> pFontData[#wordWrap] then
    pTextMem.wordWrap = pFontData[#wordWrap]
  end if
  if pTextMem.alignment <> pFontData[#alignment] then
    pTextMem.alignment = pFontData[#alignment]
  end if
  if pTextMem.bgColor <> pFontData[#bgColor] then
    pTextMem.bgColor = pFontData[#bgColor]
  end if
  if pTextMem.font <> pFontData[#font] then
    pTextMem.font = pFontData[#font]
  end if
  if pTextMem.fontSize <> pFontData[#fontSize] then
    pTextMem.fontSize = pFontData[#fontSize]
  end if
  if pTextMem.color <> pFontData[#color] then
    pTextMem.color = pFontData[#color]
  end if
  if pTextMem.fixedLineSpace <> pFontData[#fixedLineSpace] then
    pTextMem.fixedLineSpace = pFontData[#fixedLineSpace]
  end if
  if me.pScaleH = #center then
    tWidth = pTextMem.charPosToLoc(pTextMem.char.count).locH + 16
    if me.pProps[#style] = #unique then
      me.pLocX = me.pLocX + ((me.pwidth - tWidth) / 2)
      me.pwidth = tWidth
      me.pOwnW = tWidth
    else
      me.pOwnX = me.pOwnX + ((me.pOwnW - tWidth) / 2)
      me.pOwnW = tWidth
    end if
    pTextMem.rect = rect(0, 0, tWidth, pTextMem.height)
  else
    if me.pProps[#style] = #unique then
      me.pwidth = pTextMem.image.width
      me.pOwnW = me.pwidth
    else
      me.pOwnW = pTextMem.image.width
    end if
  end if
  if me.pScrolls.count > 0 then
    tHeight = pTextMem.rect.height
  else
    tHeight = me.pOwnH
  end if
  me.pimage = image(me.pOwnW, tHeight, me.pDepth, me.pPalette)
  if me.pimage = VOID then
    return 0
  end if
  if pTextMem = VOID then
    return 0
  end if
  if pNeedFill then
    me.pimage.fill(me.pimage.rect, me.pFontData[#bgColor])
  end if
  me.pimage.copyPixels(pTextMem.image, me.pimage.rect, me.pimage.rect, [#ink: 8])
  return 1
end
