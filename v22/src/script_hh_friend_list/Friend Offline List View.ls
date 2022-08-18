property pListImg, pWriterIdPlain, pContentList, pItemHeight, pItemWidth, pEmptyListText

on construct me
  pListImg = image(1, 1, 32)
  pContentList = [:]
  pContentList.sort()
  pWriterIdPlain = getUniqueID()
  tPlain = getStructVariable("struct.font.plain")
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#888888")]
  createWriter(pWriterIdPlain, tMetrics)
  pItemHeight = integer(getVariable("fr.offline.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  pEmptyListText = getText("friend_list_no_friends_online_category")
end

on deconstruct me
  pListImg = VOID
  removeWriter(pWriterIdPlain)
end

on setListData me, tdata
  if (ilk(tdata) = #propList) then
    pContentList = tdata.duplicate()
    me.renderListImage()
  end if
end

on renderFriendItem me, tFriendData, tSelected
  pItemHeight = integer(getVariable("fr.offline.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  tNameWriter = getWriter(pWriterIdPlain)
  tItemImg = image(pItemWidth, pItemHeight, 32)
  tName = tFriendData[#name]
  if tSelected then
    tSelectedBg = rgb(string(getVariable("fr.offline.bg.selected")))
    tItemImg.fill(0, 0, pItemWidth, pItemHeight, tSelectedBg)
  end if
  tNameImg = tNameWriter.render(tName)
  tSourceRect = tNameImg.rect
  tNamePosH = integer(getVariable("fr.offline.name.offset.h"))
  tNamePosV = ((pItemHeight - tNameImg.height) / 2)
  tdestrect = (tSourceRect + rect(tNamePosH, tNamePosV, tNamePosH, tNamePosV))
  tItemImg.copyPixels(tNameImg, tdestrect, tNameImg.rect)
  return tItemImg.duplicate()
end

on renderListImage me
  if (pContentList.count = 0) then
    return image(1, 1, 32)
  end if
  pItemHeight = integer(getVariable("fr.offline.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  tNamePosH = integer(getVariable("fr.offline.name.offset.h"))
  tSelectedBg = rgb(string(getVariable("fr.offline.bg.selected")))
  tImage = image(pItemWidth, (pItemHeight * pContentList.count), 32)
  tCurrentPosV = 0
  tNameWriter = getWriter(pWriterIdPlain)
  repeat with tFriend in pContentList
    tName = tFriend[#name]
    if me.isFriendselected(tName) then
      tImage.fill(0, tCurrentPosV, pItemWidth, (tCurrentPosV + pItemHeight), tSelectedBg)
    end if
    tNameImage = tNameWriter.render(tName)
    tSourceRect = tNameImage.rect
    tNamePosV = (tCurrentPosV + ((pItemHeight - tNameImage.height) / 2))
    tdestrect = (tSourceRect + rect(tNamePosH, tNamePosV, tNamePosH, tNamePosV))
    tImage.copyPixels(tNameImage, tdestrect, tNameImage.rect)
    tCurrentPosV = (tCurrentPosV + pItemHeight)
  end repeat
  pListImg = tImage.duplicate()
end

on renderBackgroundImage me
  if (ilk(pContentList) <> #propList) then
    return image(1, 1, 32)
  end if
  if (pContentList.count = 0) then
    return image(1, 1, 32)
  end if
  tDarkBg = rgb(string(getVariable("fr.offline.bg.dark")))
  pItemHeight = integer(getVariable("fr.offline.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  tImage = image(pItemWidth, (pContentList.count * pItemHeight), 32)
  tCurrentPosV = 0
  repeat with tIndex = 1 to ((pContentList.count / 2) + 1)
    tImage.fill(0, tCurrentPosV, pItemWidth, (tCurrentPosV + pItemHeight), tDarkBg)
    tCurrentPosV = (tCurrentPosV + (pItemHeight * 2))
  end repeat
  return tImage
end

on relayEvent me, tEvent, tLocX, tLocY
  tListIndex = ((tLocY / me.pItemHeight) + 1)
  tEventResult = [:]
  if (tListIndex > me.pContentList.count) then
    nothing()
  else
    tFriend = me.pContentList[tListIndex]
    tEventResult[#friend] = tFriend
    tEventResult[#element] = #name
    me.userSelectionEvent(tFriend[#name])
    tEventResult[#update] = 1
  end if
  return tEventResult
end
