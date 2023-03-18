property pTipID, pTipWidth

on construct me
  pTipID = "help_tooltip"
  pTipWidth = 150
  registerMessage(#helptooltip, me.getID(), #createHelpTooltip)
  return 1
end

on deconstruct me
  unregisterMessage(#tooltip, me.getID())
  if windowExists(pTipID) then
    removeWindow(pTipID)
  end if
  return 1
end

on createHelpTooltip me, tParams
  if tParams.count < 2 then
    return error(me, "Wrong param count", #createHelpTooltip)
  end if
  tMsg = getProp(tParams, #Msg)
  if textExists(tMsg) then
    tMsg = getText(tMsg)
  end if
  tPos = getProp(tParams, #pos)
  if ilk(tPos) = #point then
    me.createTooltipToPoint(tMsg, tPos)
  else
    if ilk(tPos) = #rect then
      me.createTooltipToRect(tMsg, tPos)
    end if
  end if
end

on createTooltipToRect me, tMsg, tRect
  if voidp(tMsg) then
    return 0
  end if
  if voidp(tRect) then
    return 0
  end if
  if ilk(tRect) <> #rect then
    return error(me, "No rect", #createTooltipToRect)
  end if
  tSpacing = 7
  tStageWidth = the stageRight - the stageLeft
  if not me.createTooltipToPoint(tMsg, point(0, 0)) then
    return 0
  end if
  tWndObj = getWindow(pTipID)
  if (tRect.top - tWndObj.pheight - tSpacing) > 0 then
    tWndObj.moveTo(tRect.left + tSpacing, tRect.top - tWndObj.pheight - tSpacing)
  else
    tWndObj.moveTo(tRect.left + tSpacing, tRect.bottom + tSpacing)
  end if
  if (tWndObj.pLocX + tWndObj.pwidth) > tStageWidth then
    tWndObj.moveTo(tStageWidth - tWndObj.pwidth, tWndObj.pLocY)
  end if
end

on createTooltipToPoint me, tMsg, tloc
  if ilk(tloc) <> #point then
    return error(me, "No point", #createTooltipToPoint)
  end if
  tLayout = "help_tooltip.window"
  tLineWidth = pTipWidth
  tFontStruct = getStructVariable("struct.font.plain")
  if not memberExists("help_tooltip.txt") then
    tmember = member(createMember("help_tooltip.txt", #field))
  else
    tmember = member("help_tooltip.txt")
  end if
  tmember.wordWrap = 1
  tmember.boxType = #adjust
  tmember.font = tFontStruct.getaProp(#font)
  tmember.fontSize = tFontStruct.getaProp(#fontSize)
  tmember.margin = tLineWidth
  tmember.text = tMsg & " "
  tmember.lineHeight = tFontStruct.getaProp(#fontSize)
  tLineCount = tmember.lineCount
  tHelpHeight = (2 * 11) + (tLineCount * tFontStruct.getaProp(#fontSize))
  if tHelpHeight < 40 then
    tHelpHeight = 40
  end if
  if not createWindow(pTipID, tLayout, tloc.locH, tloc.locV) then
    return 0
  end if
  tWndObj = getWindow(pTipID)
  tWndObj.resizeTo(tLineWidth + 30, tHelpHeight)
  if tWndObj.elementExists("tt_text") then
    tWndObj.getElement("tt_text").setText(tMsg)
  end if
  repeat with tSpr in tWndObj.pSpriteList
    tSpr.locZ = tSpr.locZ + 1000
  end repeat
  tTimeOutList = [2500, tMsg.length * 100, 10000]
  tTimeOutList.sort()
  me.createTipTimeout(tTimeOutList[2])
  tWndObj.registerProcedure(#eventProcHelpTooltip, me.getID(), #mouseUp)
  return 1
end

on removeTip me, tTipID
  if objectExists(#tipTimeout) then
    removeTimeout(#tipTimeout)
  end if
  if windowExists(tTipID) then
    removeWindow(tTipID)
  end if
end

on createTipTimeout me, tTime
  if voidp(tTime) then
    tTime = 4000
  end if
  if timeoutExists(#tipTimeout) then
    removeTimeout(#tipTimeout)
  end if
  createTimeout(#tipTimeout, tTime, #removeTip, me.getID(), pTipID)
end

on eventProcHelpTooltip me
  me.removeTip(pTipID)
end
