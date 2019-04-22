on construct(me)
  pListImg = image(1, 1, 32)
  pContentList = []
  pContentList.sort()
  pWriterIdPlain = getUniqueID()
  tPlain = getStructVariable("struct.font.plain")
  tMetrics = [#font:tPlain.getaProp(#font), #fontStyle:tPlain.getaProp(#fontStyle), #color:rgb("#888888")]
  createWriter(pWriterIdPlain, tMetrics)
  pItemHeight = integer(getVariable("fr.offline.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  pEmptyListText = getText("friend_list_no_friends_online_category")
  exit
end

on deconstruct(me)
  pListImg = void()
  removeWriter(pWriterIdPlain)
  exit
end

on setListData(me, tdata)
  if ilk(tdata) = #propList then
    pContentList = tdata.duplicate()
    me.renderListImage()
  end if
  exit
end

on renderFriendItem(me, tFriendData, tSelected)
  pItemHeight = integer(getVariable("fr.offline.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  tNameWriter = getWriter(pWriterIdPlain)
  tItemImg = image(pItemWidth, pItemHeight, 32)
  tName = tFriendData.getAt(#name)
  if tSelected then
    tSelectedBg = rgb(string(getVariable("fr.offline.bg.selected")))
    tItemImg.fill(0, 0, pItemWidth, pItemHeight, tSelectedBg)
  end if
  tNameImg = tNameWriter.render(tName)
  tSourceRect = tNameImg.rect
  tNamePosH = integer(getVariable("fr.offline.name.offset.h"))
  tNamePosV = pItemHeight - tNameImg.height / 2
  tdestrect = tSourceRect + rect(tNamePosH, tNamePosV, tNamePosH, tNamePosV)
  tItemImg.copyPixels(tNameImg, tdestrect, tNameImg.rect)
  return(tItemImg.duplicate())
  exit
end

on renderListImage(me)
  if pContentList.count = 0 then
    return(image(1, 1, 32))
  end if
  pItemHeight = integer(getVariable("fr.offline.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  tNamePosH = integer(getVariable("fr.offline.name.offset.h"))
  tSelectedBg = rgb(string(getVariable("fr.offline.bg.selected")))
  tImage = image(pItemWidth, pItemHeight * pContentList.count, 32)
  tCurrentPosV = 0
  tNameWriter = getWriter(pWriterIdPlain)
  repeat while me <= undefined
    tFriend = getAt(undefined, undefined)
    tName = tFriend.getAt(#name)
    if me.isFriendselected(tName) then
      tImage.fill(0, tCurrentPosV, pItemWidth, tCurrentPosV + pItemHeight, tSelectedBg)
    end if
    tNameImage = tNameWriter.render(tName)
    tSourceRect = tNameImage.rect
    tNamePosV = tCurrentPosV + pItemHeight - tNameImage.height / 2
    tdestrect = tSourceRect + rect(tNamePosH, tNamePosV, tNamePosH, tNamePosV)
    tImage.copyPixels(tNameImage, tdestrect, tNameImage.rect)
    tCurrentPosV = tCurrentPosV + pItemHeight
  end repeat
  pListImg = tImage.duplicate()
  exit
end

on renderBackgroundImage(me)
  if ilk(pContentList) <> #propList then
    return(image(1, 1, 32))
  end if
  if pContentList.count = 0 then
    return(image(1, 1, 32))
  end if
  tDarkBg = rgb(string(getVariable("fr.offline.bg.dark")))
  pItemHeight = integer(getVariable("fr.offline.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  tImage = image(pItemWidth, pContentList.count * pItemHeight, 32)
  tCurrentPosV = 0
  tIndex = 1
  repeat while tIndex <= pContentList.count / 2 + 1
    tImage.fill(0, tCurrentPosV, pItemWidth, tCurrentPosV + pItemHeight, tDarkBg)
    tCurrentPosV = tCurrentPosV + pItemHeight * 2
    tIndex = 1 + tIndex
  end repeat
  return(tImage)
  exit
end

on relayEvent(me, tEvent, tLocX, tLocY)
  tListIndex = tLocY / me.pItemHeight + 1
  tEventResult = []
  tEventResult.setAt(#Event, tEvent)
  if tEvent = #mouseWithin then
    return(tEventResult)
  end if
  if tListIndex > me.count(#pContentList) then
    nothing()
  else
    tFriend = me.getProp(#pContentList, tListIndex)
    tEventResult.setAt(#friend, tFriend)
    tEventResult.setAt(#element, #name)
    me.userSelectionEvent(tFriend.getAt(#name))
    tEventResult.setAt(#update, 1)
  end if
  return(tEventResult)
  exit
end