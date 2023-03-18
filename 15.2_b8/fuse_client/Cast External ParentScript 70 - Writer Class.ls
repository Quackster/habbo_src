property pMember, pDefRect, pTxtRect, pFntStru

on construct me
  pDefRect = rect(0, 0, 480, 480)
  pTxtRect = VOID
  pFntStru = VOID
  pMember = member(getResourceManager().createMember("writer_" & getUniqueID(), #text))
  if pMember.number = 0 then
    return 0
  else
    pMember.alignment = #left
    pMember.wordWrap = 0
    return 1
  end if
end

on deconstruct me
  if ilk(pMember, #member) then
    getResourceManager().removeMember(pMember.name)
    pMember = VOID
  end if
  return 1
end

on define me, tMetrics
  if not ilk(tMetrics, #propList) then
    return 0
  end if
  if stringp(tMetrics[#font]) then
    if pMember.font <> tMetrics.font then
      pMember.font = tMetrics.font
    end if
  end if
  if listp(tMetrics[#fontStyle]) then
    if pMember.fontStyle <> tMetrics.fontStyle then
      pMember.fontStyle = tMetrics.fontStyle
    end if
  end if
  if symbolp(tMetrics[#alignment]) then
    if pMember.alignment <> tMetrics.alignment then
      pMember.alignment = tMetrics.alignment
    end if
  end if
  if ilk(tMetrics[#color], #color) then
    if pMember.color <> tMetrics.color then
      pMember.color = tMetrics.color
    end if
  end if
  if ilk(tMetrics[#bgColor], #color) then
    if pMember.bgColor <> tMetrics.bgColor then
      pMember.bgColor = tMetrics.bgColor
    end if
  end if
  if integerp(tMetrics[#wordWrap]) then
    if pMember.wordWrap <> tMetrics.wordWrap then
      pMember.wordWrap = tMetrics.wordWrap
    end if
  end if
  if integerp(tMetrics[#antialias]) then
    if pMember.antialias <> tMetrics.antialias then
      pMember.antialias = tMetrics.antialias
    end if
  end if
  if integerp(tMetrics[#fontSize]) then
    if pMember.fontSize <> tMetrics.fontSize then
      pMember.fontSize = tMetrics.fontSize
    end if
  end if
  if integerp(tMetrics[#boxType]) then
    if pMember.boxType <> tMetrics.boxType then
      pMember.boxType = tMetrics.boxType
    end if
  end if
  if ilk(tMetrics[#rect], #rect) then
    if pMember.width <> tMetrics.rect.width then
      pMember.rect = tMetrics.rect
    end if
  end if
  if pMember.fixedLineSpace <> pMember.fontSize then
    pMember.fixedLineSpace = pMember.fontSize
  end if
  if integerp(tMetrics[#fixedLineSpace]) then
    tTopSpacing = tMetrics.fixedLineSpace - pMember.fontSize
    if pMember.topSpacing <> tTopSpacing then
      pMember.topSpacing = tTopSpacing
    end if
  end if
  pTxtRect = tMetrics[#rect]
  return 1
end

on render me, tText, tRect
  pMember.text = tText
  if tRect.ilk = #rect then
    if pMember.width <> tRect.width then
      pMember.rect = tRect
    end if
  else
    if voidp(pTxtRect) then
      tAlignment = pMember.alignment
      pMember.alignment = #left
      pMember.rect = pDefRect
      tTotal = length(tText.line[1])
      tWidth = pMember.charPosToLoc(tTotal).locH
      if tText.line.count > 1 then
        repeat with i = 2 to tText.line.count
          tTotal = tTotal + length(tText.line[i]) + 1
          tNext = pMember.charPosToLoc(tTotal).locH
          if tNext > tWidth then
            tWidth = tNext
          end if
        end repeat
      end if
      tWidth = tWidth + pMember.fontSize
      pMember.rect = rect(0, 0, tWidth, pMember.height)
      pMember.alignment = tAlignment
    else
      if pMember.width <> pTxtRect.width then
        pMember.rect = pTxtRect
      end if
    end if
  end if
  return pMember.image
end

on renderHTML me, tHtml, tRect
  tFont = me.getFont()
  pMember.html = tHtml
  if tRect.ilk = #rect then
    if pMember.width <> tRect.width then
      pMember.rect = tRect
    end if
  else
    if voidp(pTxtRect) then
      tAlignment = pMember.alignment
      pMember.alignment = #left
      pMember.rect = pDefRect
      tTotal = length(pMember.text.line[1])
      tWidth = pMember.charPosToLoc(tTotal).locH
      if pMember.text.line.count > 1 then
        repeat with i = 2 to pMember.text.line.count
          tTotal = tTotal + length(pMember.text.line[i]) + 1
          tNext = pMember.charPosToLoc(tTotal).locH
          if tNext > tWidth then
            tWidth = tNext
          end if
        end repeat
      end if
      tWidth = tWidth + pMember.fontSize
      pMember.rect = rect(0, 0, tWidth, pMember.height)
      pMember.alignment = tAlignment
    else
      if pMember.width <> pTxtRect.width then
        pMember.rect = pTxtRect
      end if
    end if
  end if
  me.setFont(tFont)
  return pMember.image
end

on setFont me, tStruct
  if tStruct.ilk <> #struct then
    return error(me, "Font struct expected!", #setFont, #major)
  end if
  if pMember.font <> tStruct.getaProp(#font) then
    pMember.font = tStruct.getaProp(#font)
  end if
  if pMember.fontSize <> tStruct.getaProp(#fontSize) then
    pMember.fontSize = tStruct.getaProp(#fontSize)
  end if
  if pMember.fontStyle <> tStruct.getaProp(#fontStyle) then
    pMember.fontStyle = tStruct.getaProp(#fontStyle)
  end if
  if pMember.color <> tStruct.getaProp(#color) then
    pMember.color = tStruct.getaProp(#color)
  end if
  if pMember.fixedLineSpace <> pMember.fontSize then
    pMember.fixedLineSpace = pMember.fontSize
  end if
  tLineHeight = pMember.fontSize + pMember.topSpacing
  if tLineHeight <> tStruct.getaProp(#lineHeight) then
    pMember.topSpacing = tStruct.getaProp(#lineHeight) - pMember.fontSize
  end if
  return 1
end

on getFont me
  if voidp(pFntStru) then
    pFntStru = getStructVariable("struct.font.empty")
  end if
  pFntStru.setaProp(#font, pMember.font)
  pFntStru.setaProp(#fontStyle, pMember.fontStyle)
  pFntStru.setaProp(#fontSize, pMember.fontSize)
  pFntStru.setaProp(#color, pMember.color)
  tLineHeight = pMember.fontSize + pMember.topSpacing
  pFntStru.setaProp(#lineHeight, tLineHeight)
  return pFntStru
end

on setProperty me, tKey, tValue
  return me.define([#tKey: tValue])
end
