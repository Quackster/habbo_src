property pTextList2

on mouseDown me
  if me.pSprite.blend < 100 then
    return 0
  end if
  if not listp(me.pTextlist) then
    return executeMessage(#openFxWindow)
  end if
  if me.pTextlist.count < 2 then
    return executeMessage(#openFxWindow)
  end if
  me.ancestor.mouseDown()
  if me.pState <> #open then
    return 1
  end if
  if pTextList2 <> VOID then
    me.updateDropImgFX(pTextList2, 1, #up, me.pimage)
  end if
  me.render()
end

on updateData me, tTextList, tTextKeys, tChosenIndex, tChosenValue, tTextList2
  me.pDropDownType = #default
  pTextList2 = tTextList2
  return me.ancestor.updateData(tTextList, tTextKeys, tChosenIndex, tChosenValue)
end

on updateDropImgFX me, tItemsList, tListOfAllItemsOrNot, tstate, tNewImg
  tStr = EMPTY
  if tItemsList.count > 0 then
    if not tListOfAllItemsOrNot then
      tStr = tStr & tItemsList[1] & RETURN
    else
      repeat with f = 1 to me.pShowOrder.count
        tStr = tStr & tItemsList[me.pShowOrder[f]] & RETURN
      end repeat
    end if
  end if
  tMemNum = getmemnum("dropdown.button.text")
  if tMemNum = 0 then
    tMemNum = createMember("dropdown.button.text", #text)
  end if
  tTextMember = member(tMemNum)
  tFontDesc = me.pProp[tstate][#text]
  pMarginTop = tFontDesc[#marginV]
  pMarginLeft = tFontDesc[#marginH]
  pMarginBottom = tFontDesc[#marginbottom]
  tTextMember.wordWrap = 0
  tTextMember.font = string(tFontDesc[#font])
  tTextMember.fontStyle = list(symbol(tFontDesc[#fontStyle]))
  tTextMember.fontSize = tFontDesc[#fontSize]
  tTextMember.color = rgb(tFontDesc[#color])
  tTextMember.text = tStr.line[1..tStr.line.count - 1]
  tTextMember.fixedLineSpace = me.pLineHeight
  tTextMember.alignment = #right
  tTextImg = tTextMember.image
  tdestrect = tTextImg.rect + rect(0, me.pMarginTop, 0, me.pMarginTop)
  tdestrect = tdestrect + rect(tNewImg.width, 0, tNewImg.width, 0) - rect(me.pTextWidth + me.pDropDownImg.getProp("top_right").width, 0, me.pTextWidth + me.pDropDownImg.getProp("top_right").width, 0)
  if variableExists("dropdown.top.offset") then
    tdestrect = rect(0, getVariable("dropdown.top.offset"), 0, getVariable("dropdown.top.offset"))
  end if
  tNewImg.copyPixels(tTextImg, tdestrect, tTextImg.rect)
  return tNewImg
end
