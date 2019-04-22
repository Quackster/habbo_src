property pBackground, pSelectedBg, pTextRendererId, pimage, pwidth, pheight, pData, pIcon, pText

on construct me 
  pData = void()
  pBackground = void()
  pSelectedBg = void()
  pIcon = void()
  pTextRendererId = getUniqueID()
  pimage = void()
  pText = ""
end

on deconstruct me 
  pData = void()
end

on define me, tNodeObj, tProps 
  sendProcessTracking(800)
  if not objectp(tNodeObj) then
    return(error(me, "NodeObj was not object", #define, #major))
  end if
  if ilk(tProps) <> #propList then
    return(error(me, "Props was not propList", #define, #major))
  end if
  pData = tNodeObj
  if tNodeObj.getData(#icon) > 0 and variableExists("treeview.node.icon." & tNodeObj.getData(#icon)) then
    pIcon = getMember(getVariable("treeview.node.icon." & tNodeObj.getData(#icon)))
  else
    pIcon = void()
  end if
  tBgMemberName = getVariable("treeview.node.bg." & tNodeObj.getData(#color))
  tSelMemberName = getVariable("treeview.node.bg.selected." & tNodeObj.getData(#color))
  if not stringp(tBgMemberName) then
    tBgMemberName = getVariable("treeview.node.bg.0")
  end if
  if not stringp(tSelMemberName) then
    tSelMemberName = getVariable("treeview.node.bg.selected.0")
  end if
  pBackground = getMember(tBgMemberName)
  pSelectedBg = getMember(tSelMemberName)
  sendProcessTracking(801)
  if ilk(pBackground) <> #member then
    return(error(me, "Unable to create renderer, invalid background image.", #define, #major))
  end if
  if ilk(pSelectedBg) <> #member then
    return(error(me, "Unable to create renderer, invalid selected image.", #define, #major))
  end if
  if pBackground.type <> #bitmap then
    return(error(me, "Invalid background type.", #define, #major))
  end if
  if pSelectedBg.type <> #bitmap then
    return(error(me, "Invalid background selected type", #define, #major))
  end if
  sendProcessTracking(802)
  pwidth = tProps.getAt(#width)
  pheight = image.height
  if not writerExists(pTextRendererId) then
    createWriter(pTextRendererId, getStructVariable("struct.font.bold"))
  end if
  if not writerExists(pTextRendererId) then
    return(error(me, "Unable to create writer.", #define, #major))
  end if
  sendProcessTracking(803)
  if textExists(tNodeObj.getData(#nodename)) then
    pText = getText(tNodeObj.getData(#nodename))
  else
    pText = tNodeObj.getData(#nodename)
  end if
end

on setState me, tstate 
  sendProcessTracking(810)
  me.render()
end

on select me, tSelected 
  sendProcessTracking(820)
  me.render()
end

on getImage me 
  sendProcessTracking(830)
  if voidp(pimage) then
    me.render()
  end if
  return(pimage)
end

on render me 
  sendProcessTracking(840)
  pimage = image(pwidth, pheight, 32)
  tLevel = integer(pData.getData(#level)) - 1
  tOffsetX = getIntVariable("treeview.node.start.offset") + getIntVariable("treeview.node.item.offset") * max([tLevel, 0])
  if pData.getSelected() then
    pSelectedBg.image.copyPixels(pimage.rect, pSelectedBg, image.rect, [#useFastQuads:1])
  else
    pBackground.image.copyPixels(pimage.rect, pBackground, image.rect, [#useFastQuads:1])
  end if
  if not voidp(pIcon) then
    tOffsetY = pimage.height.getCenteredOfs(pIcon, image.height)
    tCenterX = getIntVariable("treeview.node.icon.maxwidth").getCenteredOfs(pIcon, image.height)
    pIcon.copyPixels(image.rect + rect(tOffsetX + tCenterX, tOffsetY, tOffsetX + tCenterX, tOffsetY), pIcon, image.rect, [#useFastQuads:1, #ink:36])
    tOffsetX = tOffsetX + getIntVariable("treeview.node.icon.maxwidth") + getIntVariable("treeview.node.item.offset")
  end if
  tTextImage = getWriter(pTextRendererId).render(pText)
  tTextImage.useAlpha = 1
  tOffsetY = me.getCenteredOfs(pimage.height - tTextImage.height)
  pimage.copyPixels(tTextImage, tTextImage.rect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY), tTextImage.rect, [#useFastQuads:1, #ink:36])
  if pData.getState() = #closed then
    tStateIndicator = getMember(getVariable("treeview.node.stateindicator.closed"))
  else
    tStateIndicator = getMember(getVariable("treeview.node.stateindicator.open"))
  end if
  if pData.hasChildren() then
    tOffsetX = pimage.width - getIntVariable("treeview.node.stateindicator.offset.right")
    tOffsetY = pimage.height.getCenteredOfs(tStateIndicator, image.height)
    pimage.copyPixels(tStateIndicator.image, tStateIndicator.rect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY), tStateIndicator.rect, [#useFastQuads:1, #ink:36])
  end if
end

on getCenteredOfs me, tDest, tSource 
  sendProcessTracking(850)
  return(tDest - tSource / 2)
end
