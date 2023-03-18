on createImgFromTxt me
  me.pTextMem.rect = rect(0, 0, me.pOwnW, me.pOwnH)
  if not listp(me.pFontData[#fontStyle]) then
    tList = []
    tDelim = the itemDelimiter
    the itemDelimiter = ","
    repeat with i = 1 to me.pFontData[#fontStyle].item.count
      tList.add(symbol(me.pFontData[#fontStyle].item[i]))
    end repeat
    the itemDelimiter = tDelim
    me.pFontData[#fontStyle] = tList
  end if
  if not voidp(me.pFontData[#text]) then
    me.pTextMem.text = me.pFontData[#text]
    me.pFontData[#text] = VOID
  else
    if me.pFontData[#key] = EMPTY then
      me.pTextMem.text = EMPTY
    else
      if me.pFontData[#key].char[1] = "%" then
        tKey = symbol(me.pFontData[#key].char[2..length(me.pFontData[#key])])
        me.pTextMem.text = string(getObject(me.pMotherId).getProperty(tKey))
      else
        if textExists(me.pFontData[#key]) then
          me.pTextMem.text = getTextManager().GET(me.pFontData[#key])
        else
          error(me, "Text not found:" && me.pFontData[#key], #createImgFromTxt)
          me.pTextMem.text = me.pFontData[#key]
        end if
      end if
    end if
  end if
  me.pFontData[#text] = me.pTextMem.text
  if me.pTextMem.fontStyle <> me.pFontData[#fontStyle] then
    me.pTextMem.fontStyle = me.pFontData[#fontStyle]
  end if
  if me.pTextMem.wordWrap <> me.pFontData[#wordWrap] then
    me.pTextMem.wordWrap = me.pFontData[#wordWrap]
  end if
  if me.pTextMem.alignment <> me.pFontData[#alignment] then
    me.pTextMem.alignment = me.pFontData[#alignment]
  end if
  if me.pTextMem.bgColor <> me.pFontData[#bgColor] then
    me.pTextMem.bgColor = me.pFontData[#bgColor]
  end if
  if me.pTextMem.font <> me.pFontData[#font] then
    me.pTextMem.font = me.pFontData[#font]
  end if
  if me.pTextMem.fontSize <> me.pFontData[#fontSize] then
    me.pTextMem.fontSize = me.pFontData[#fontSize]
  end if
  if me.pTextMem.color <> me.pFontData[#color] then
    me.pTextMem.color = me.pFontData[#color]
  end if
  if me.pTextMem.fixedLineSpace <> me.pFontData[#fixedLineSpace] then
    me.pTextMem.fixedLineSpace = me.pFontData[#fixedLineSpace]
  end if
  if me.pTextMem.topSpacing < 10 then
    me.pTextMem.topSpacing = 1
  end if
  if me.pScaleH = #center then
    tWidth = me.pTextMem.charPosToLoc(me.pTextMem.char.count).locH + 16
    if me.pProps[#style] = #unique then
      me.pLocX = me.pLocX + ((me.pwidth - tWidth) / 2)
      me.pwidth = tWidth
      me.pOwnW = tWidth
    else
      me.pOwnX = me.pOwnX + ((me.pOwnW - tWidth) / 2)
      me.pOwnW = tWidth
    end if
    me.pTextMem.rect = rect(0, 0, tWidth, me.pTextMem.height)
  else
    if me.pProps[#style] = #unique then
      me.pwidth = me.pTextMem.image.width
      me.pOwnW = me.pwidth
    else
      me.pOwnW = me.pTextMem.image.width
    end if
  end if
  if me.pScrolls.count > 0 then
    tHeight = me.pTextMem.rect.height
  else
    tHeight = me.pOwnH
  end if
  me.pimage = image(me.pOwnW, tHeight, me.pDepth, me.pPalette)
  if me.pimage = VOID then
    return 0
  end if
  if me.pTextMem = VOID then
    return 0
  end if
  if me.pNeedFill then
    me.pimage.fill(me.pimage.rect, me.pFontData[#bgColor])
  end if
  me.pimage.copyPixels(me.pTextMem.image, me.pimage.rect, me.pimage.rect, [#ink: 8])
  return 1
end
