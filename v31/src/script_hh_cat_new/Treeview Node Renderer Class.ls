on construct(me)
  pData = void()
  pBackground = void()
  pSelectedBg = void()
  pIcon = void()
  pTextRendererId = getUniqueID()
  pimage = void()
  pText = ""
  exit
end

on deconstruct(me)
  pData = void()
  exit
end

on define(me, tNodeObj, tProps)
  if not objectp(tNodeObj) then
    return(0)
  end if
  if ilk(tProps) <> #propList then
    return(0)
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
  if ilk(pBackground) <> #member then
    return(error(me, "Unable to create renderer, invalid background image.", #define, #major))
  end if
  if ilk(pSelectedBg) <> #member then
    return(error(me, "Unable to create renderer, invalid selected image.", #define, #major))
  end if
  pwidth = tProps.getAt(#width)
  pheight = image.height
  if not writerExists(pTextRendererId) then
    createWriter(pTextRendererId, getStructVariable("struct.font.bold"))
  end if
  if textExists(tNodeObj.getData(#nodename)) then
    pText = getText(tNodeObj.getData(#nodename))
  else
    pText = tNodeObj.getData(#nodename)
  end if
  exit
end

on setState(me, tstate)
  me.render()
  exit
end

on select(me, tSelected)
  me.render()
  exit
end

on getImage(me)
  if voidp(pimage) then
    me.render()
  end if
  return(pimage)
  exit
end

on render(me)
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
  exit
end

on getCenteredOfs(me, tDest, tSource)
  return(tDest - tSource / 2)
  exit
end