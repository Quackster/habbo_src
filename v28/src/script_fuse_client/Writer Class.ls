property pMember, pTxtRect, pDefRect, pTextRenderMode, pFntStru, pUnderliningDisabled

on construct me 
  pDefRect = rect(0, 0, 480, 480)
  pTxtRect = void()
  pFntStru = void()
  pMember = member(getResourceManager().createMember("writer_" & getUniqueID(), #text))
  if variableExists("text.render.compatibility.mode") then
    pTextRenderMode = getVariable("text.render.compatibility.mode")
  else
    pTextRenderMode = 1
  end if
  if variableExists("text.underlining.disabled") then
    pUnderliningDisabled = getVariable("text.underlining.disabled")
  else
    pUnderliningDisabled = 0
  end if
  if pMember.number = 0 then
    return(0)
  else
    pMember.alignment = #left
    pMember.wordWrap = 0
    return(1)
  end if
end

on deconstruct me 
  if ilk(pMember, #member) then
    getResourceManager().removeMember(pMember.name)
    pMember = void()
  end if
  return(1)
end

on define me, tMetrics 
  if not ilk(tMetrics, #propList) then
    return(0)
  end if
  if stringp(tMetrics.getAt(#font)) then
    if pMember.font <> tMetrics.font then
      pMember.font = tMetrics.font
    end if
  end if
  if listp(tMetrics.getAt(#fontStyle)) then
    if pMember.fontStyle <> tMetrics.fontStyle then
      pMember.fontStyle = tMetrics.fontStyle
    end if
  end if
  if symbolp(tMetrics.getAt(#alignment)) then
    if pMember.alignment <> tMetrics.alignment then
      pMember.alignment = tMetrics.alignment
    end if
  end if
  if ilk(tMetrics.getAt(#color), #color) then
    if pMember.color <> tMetrics.color then
      pMember.color = tMetrics.color
    end if
  end if
  if ilk(tMetrics.getAt(#bgColor), #color) then
    if pMember.bgColor <> tMetrics.bgColor then
      pMember.bgColor = tMetrics.bgColor
    end if
  end if
  if integerp(tMetrics.getAt(#wordWrap)) then
    if pMember.wordWrap <> tMetrics.wordWrap then
      pMember.wordWrap = tMetrics.wordWrap
    end if
  end if
  if integerp(tMetrics.getAt(#antialias)) then
    if pMember.antialias <> tMetrics.antialias then
      pMember.antialias = tMetrics.antialias
    end if
  end if
  if integerp(tMetrics.getAt(#fontSize)) then
    if pMember.fontSize <> tMetrics.fontSize then
      pMember.fontSize = tMetrics.fontSize
    end if
  end if
  if integerp(tMetrics.getAt(#boxType)) then
    if pMember.boxType <> tMetrics.boxType then
      pMember.boxType = tMetrics.boxType
    end if
  end if
  if ilk(tMetrics.getAt(#rect), #rect) then
    if pMember.width <> tMetrics.width then
      pMember.rect = tMetrics.rect
    end if
  end if
  if pMember.fixedLineSpace <> pMember.fontSize then
    pMember.fixedLineSpace = pMember.fontSize
  end if
  if integerp(tMetrics.getAt(#fixedLineSpace)) then
    tTopSpacing = tMetrics.fixedLineSpace - pMember.fontSize
    if pMember.topSpacing <> tTopSpacing then
      pMember.topSpacing = tTopSpacing
    end if
  end if
  executeMessage(#invalidateCrapFixRegion)
  pTxtRect = tMetrics.getAt(#rect)
  return(1)
end

on render me, tText, tRect 
  if tText = void() then
    tText = ""
  end if
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
      tTotal = length(tText.getProp(#line, 1))
      tWidth = pMember.charPosToLoc(tTotal).locH
      if tText.count(#line) > 1 then
        i = 2
        repeat while i <= tText.count(#line)
          tTotal = tTotal + length(tText.getProp(#line, i)) + 1
          tNext = pMember.charPosToLoc(tTotal).locH
          if tNext > tWidth then
            tWidth = tNext
          end if
          i = 1 + i
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
  executeMessage(#invalidateCrapFixRegion)
  if pTextRenderMode = 1 then
    return(pMember.image)
  else
    if pTextRenderMode = 2 then
      return(me.fakeAlphaRender())
    end if
  end if
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
      tTotal = length(pMember.getProp(#line, 1))
      tWidth = pMember.charPosToLoc(tTotal).locH
      if pMember.count(#line) > 1 then
        i = 2
        repeat while i <= pMember.count(#line)
          tTotal = tTotal + length(pMember.getProp(#line, i)) + 1
          tNext = pMember.charPosToLoc(tTotal).locH
          if tNext > tWidth then
            tWidth = tNext
          end if
          i = 1 + i
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
  if pTextRenderMode = 1 then
    return(pMember.image)
  else
    if pTextRenderMode = 2 then
      return(me.fakeAlphaRender())
    end if
  end if
end

on setFont me, tStruct 
  if tStruct.ilk <> #struct then
    return(error(me, "Font struct expected!", #setFont, #major))
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
  executeMessage(#invalidateCrapFixRegion)
  return(1)
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
  return(pFntStru)
end

on setProperty me, tKey, tValue 
  tProps = [:]
  tProps.setaProp(tKey, tValue)
  return(me.define(tProps))
end

on fakeAlphaRender me 
  tColorWas = pMember.color
  tBgColorWas = pMember.bgColor
  if pUnderliningDisabled then
    if listp(pMember.fontStyle) then
      if pMember.getPos(#underline) <> 0 then
        pMember.fontStyle = [#plain]
      end if
    end if
  end if
  pMember.color = rgb(0, 0, 0)
  pMember.bgColor = rgb(255, 255, 255)
  tFakeAlpha = image(pMember.width, pMember.height, 8)
  tFakeAlpha.copyPixels(pMember.image, pMember.rect, tFakeAlpha.rect, [#ink:8])
  tFakeSrc = image(pMember.width, pMember.height, 32)
  tFakeSrc.fill(tFakeSrc.rect, [#color:tColorWas, #shape:#rect])
  tOut = image(pMember.width, pMember.height, 32)
  tOut.copyPixels(tFakeSrc, tOut.rect, tOut.rect, [#maskImage:tFakeAlpha])
  tOut.useAlpha = 1
  tOut.setAlpha(tFakeAlpha)
  pMember.color = tColorWas
  pMember.bgColor = tBgColorWas
  return(tOut)
end
