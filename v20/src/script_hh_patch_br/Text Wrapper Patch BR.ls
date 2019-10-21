on createImgFromTxt me 
  me.pTextMem.rect = rect(0, 0, me.pOwnW, me.pOwnH)
  if not listp(me.getProp(#pFontData, #fontStyle)) then
    tList = []
    tDelim = the itemDelimiter
    the itemDelimiter = ","
    i = 1
    repeat while i <= me.getPropRef(#pFontData, #fontStyle).count(#item)
      tList.add(symbol(me.getPropRef(#pFontData, #fontStyle).getProp(#item, i)))
      i = (1 + i)
    end repeat
    the itemDelimiter = tDelim
    me.setProp(#pFontData, #fontStyle, tList)
  end if
  if not voidp(me.getProp(#pFontData, #text)) then
    me.pTextMem.text = me.getProp(#pFontData, #text)
    me.setProp(#pFontData, #text, void())
  else
    if (me.getProp(#pFontData, #key) = "") then
      me.pTextMem.text = ""
    else
      if (me.getPropRef(#pFontData, #key).getProp(#char, 1) = "%") then
        tKey = symbol(me.getPropRef(#pFontData, #key).getProp(#char, 2, length(me.getProp(#pFontData, #key))))
        me.pTextMem.text = string(getObject(me.pMotherId).getProperty(tKey))
      else
        if textExists(me.getProp(#pFontData, #key)) then
          me.pTextMem.text = getTextManager().GET(me.getProp(#pFontData, #key))
        else
          error(me, "Text not found:" && me.getProp(#pFontData, #key), #createImgFromTxt)
          me.pTextMem.text = me.getProp(#pFontData, #key)
        end if
      end if
    end if
  end if
  me.setProp(#pFontData, #text, me.pTextMem.text)
  if me.pTextMem.fontStyle <> me.getProp(#pFontData, #fontStyle) then
    me.pTextMem.fontStyle = me.getProp(#pFontData, #fontStyle)
  end if
  if me.pTextMem.wordWrap <> me.getProp(#pFontData, #wordWrap) then
    me.pTextMem.wordWrap = me.getProp(#pFontData, #wordWrap)
  end if
  if me.pTextMem.alignment <> me.getProp(#pFontData, #alignment) then
    me.pTextMem.alignment = me.getProp(#pFontData, #alignment)
  end if
  if me.pTextMem.bgColor <> me.getProp(#pFontData, #bgColor) then
    me.pTextMem.bgColor = me.getProp(#pFontData, #bgColor)
  end if
  if me.pTextMem.font <> me.getProp(#pFontData, #font) then
    me.pTextMem.font = me.getProp(#pFontData, #font)
  end if
  if me.pTextMem.fontSize <> me.getProp(#pFontData, #fontSize) then
    me.pTextMem.fontSize = me.getProp(#pFontData, #fontSize)
  end if
  if me.pTextMem.color <> me.getProp(#pFontData, #color) then
    me.pTextMem.color = me.getProp(#pFontData, #color)
  end if
  if me.pTextMem.fixedLineSpace <> me.getProp(#pFontData, #fixedLineSpace) then
    me.pTextMem.fixedLineSpace = me.getProp(#pFontData, #fixedLineSpace)
  end if
  if me.pTextMem.topSpacing < 10 then
    me.pTextMem.topSpacing = 1
  end if
  if (me.pScaleH = #center) then
    tWidth = (me.pTextMem.charPosToLoc(me.pTextMem.count(#char)).locH + 16)
    if (me.getProp(#pProps, #style) = #unique) then
      me.pLocX = (me.pLocX + ((me.pwidth - tWidth) / 2))
      me.pwidth = tWidth
      me.pOwnW = tWidth
    else
      me.pOwnX = (me.pOwnX + ((me.pOwnW - tWidth) / 2))
      me.pOwnW = tWidth
    end if
    me.pTextMem.rect = rect(0, 0, tWidth, me.pTextMem.height)
  else
    if (me.getProp(#pProps, #style) = #unique) then
      me.pwidth = me.pTextMem.image.width
      me.pOwnW = me.pwidth
    else
      me.pOwnW = me.pTextMem.image.width
    end if
  end if
  if me.count(#pScrolls) > 0 then
    tHeight = me.pTextMem.rect.height
  else
    tHeight = me.pOwnH
  end if
  me.pimage = image(me.pOwnW, tHeight, me.pDepth, me.pPalette)
  if (me.pimage = void()) then
    return FALSE
  end if
  if (me.pTextMem = void()) then
    return FALSE
  end if
  if me.pNeedFill then
    me.pimage.fill(me.pimage.rect, me.getProp(#pFontData, #bgColor))
  end if
  me.pimage.copyPixels(me.pTextMem.image, me.pimage.rect, me.pimage.rect, [#ink:8])
  return TRUE
end
