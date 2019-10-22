property pTextList2

on mouseDown me 
  if me.pSprite.blend < 100 then
    return FALSE
  end if
  if me.count(#pTextlist) < 2 then
    return(executeMessage(#openFxWindow))
  end if
  me.ancestor.mouseDown()
  if me.pState <> #open then
    return TRUE
  end if
  if pTextList2 <> void() then
    me.updateDropImgFX(pTextList2, 1, #up, me.pimage)
  end if
  me.render()
end

on updateData me, tTextList, tTextKeys, tChosenIndex, tChosenValue, tTextList2 
  me.pDropDownType = #default
  pTextList2 = tTextList2
  return(me.ancestor.updateData(tTextList, tTextKeys, tChosenIndex, tChosenValue))
end

on updateDropImgFX me, tItemsList, tListOfAllItemsOrNot, tstate, tNewImg 
  tStr = ""
  if tItemsList.count > 0 then
    if not tListOfAllItemsOrNot then
      tStr = tStr & tItemsList.getAt(1) & "\r"
    else
      f = 1
      repeat while f <= me.count(#pShowOrder)
        tStr = tStr & tItemsList.getAt(me.getProp(#pShowOrder, f)) & "\r"
        f = (1 + f)
      end repeat
    end if
  end if
  tMemNum = getmemnum("dropdown.button.text")
  if (tMemNum = 0) then
    tMemNum = createMember("dropdown.button.text", #text)
  end if
  tTextMember = member(tMemNum)
  tFontDesc = me.getPropRef(#pProp, tstate).getAt(#text)
  pMarginTop = tFontDesc.getAt(#marginV)
  pMarginLeft = tFontDesc.getAt(#marginH)
  pMarginBottom = tFontDesc.getAt(#marginbottom)
  tTextMember.wordWrap = 0
  tTextMember.font = string(tFontDesc.getAt(#font))
  tTextMember.fontStyle = list(symbol(tFontDesc.getAt(#fontStyle)))
  tTextMember.fontSize = tFontDesc.getAt(#fontSize)
  tTextMember.color = rgb(tFontDesc.getAt(#color))
  tTextMember.text = tStr.getProp(#line, 1, (tStr.count(#line) - 1))
  tTextMember.fixedLineSpace = me.pLineHeight
  tTextMember.alignment = #right
  tTextImg = tTextMember.image
  tdestrect = (tTextImg.rect + rect(0, me.pMarginTop, 0, me.pMarginTop))
  tdestrect = ((tdestrect + rect(tNewImg.width, 0, tNewImg.width, 0)) - rect((me.pTextWidth + me.pDropDownImg.getProp("top_right").width), 0, (me.pTextWidth + me.pDropDownImg.getProp("top_right").width), 0))
  if variableExists("dropdown.top.offset") then
    tdestrect = rect(0, getVariable("dropdown.top.offset"), 0, getVariable("dropdown.top.offset"))
  end if
  tNewImg.copyPixels(tTextImg, tdestrect, tTextImg.rect)
  return(tNewImg)
end
