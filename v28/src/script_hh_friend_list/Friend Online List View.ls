property pContentList, pWriterIdPlain, pItemWidth, pItemHeight, pListImg

on construct me 
  pListImg = image(1, 1, 32)
  pListImg = member("friends_requests").image
  pContentList = [:]
  pContentList.sort()
  pWriterIdPlain = getUniqueID()
  createWriter(pWriterIdPlain, getStructVariable("struct.font.plain"))
  pItemHeight = integer(getVariable("fr.online.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  pEmptyListText = getText("friend_list_no_friends_online_category")
end

on deconstruct me 
  pListImg = void()
  removeWriter(pWriterIdPlain)
end

on setListData me, tdata 
  if ilk(tdata) = #propList then
    pContentList = tdata.duplicate()
    me.renderListImage()
  end if
end

on renderFriendItem me, tFriendData, tSelected 
  tNameWriter = getWriter(pWriterIdPlain)
  tFigureParser = getObject("Figure_System")
  tPreviewObj = getObject("Figure_Preview")
  tItemImg = image(pItemWidth, pItemHeight, 32)
  tName = tFriendData.getAt(#name)
  if tSelected then
    tSelectedBg = rgb(string(getVariable("fr.offline.bg.selected")))
    tItemImg.fill(0, 0, pItemWidth, pItemHeight, tSelectedBg)
  end if
  tFacePosH = integer(getVariable("fr.online.face.offset.h"))
  tParsedFigure = tFigureParser.parseFigure(tFriendData.getAt(#figure), tFriendData.getAt(#sex), "user")
  tHeadImage = tPreviewObj.getHumanPartImg(#head, tParsedFigure, 2, "sh")
  tSourceRect = tHeadImage.rect
  tFacePosV = pItemHeight - tHeadImage.height / 2
  tdestrect = tSourceRect + rect(tFacePosH, tFacePosV, tFacePosH, tFacePosV)
  tItemImg.copyPixels(tHeadImage, tdestrect, tSourceRect, [#ink:36])
  tNamePosH = integer(getVariable("fr.online.name.offset.h"))
  tNameImage = tNameWriter.render(tFriendData.getAt(#name))
  tSourceRect = tNameImage.rect
  tNamePosV = pItemHeight - tNameImage.height / 2
  tdestrect = tSourceRect + rect(tNamePosH, tNamePosV, tNamePosH, tNamePosV)
  tItemImg.copyPixels(tNameImage, tdestrect, tSourceRect, [#ink:36])
  tImIconImg = getMember(getVariable("fr.online.im.icon")).image
  tImIconRect = tImIconImg.rect
  tImIconPosH = integer(getVariable("fr.online.im.offset.h"))
  tImIconPosV = pItemHeight - tImIconImg.height / 2
  tdestrect = tImIconRect + rect(tImIconPosH, tImIconPosV, tImIconPosH, tImIconPosV)
  tItemImg.copyPixels(tImIconImg, tdestrect, tImIconRect, [#ink:36])
  if tFriendData.getAt(#canfollow) then
    tFollowIconImg = getMember(getVariable("fr.online.follow.icon")).image
    tFollowIconRect = tFollowIconImg.rect
    tFollowIconPosH = integer(getVariable("fr.online.follow.offset.h"))
    tFollowIconPosV = pItemHeight - tFollowIconImg.height / 2
    tdestrect = tFollowIconRect + rect(tFollowIconPosH, tFollowIconPosV, tFollowIconPosH, tFollowIconPosV)
    tItemImg.copyPixels(tFollowIconImg, tdestrect, tFollowIconRect, [#ink:36])
  end if
  return(tItemImg.duplicate())
end

on renderListImage me 
  if pContentList.count = 0 then
    me.pListImg = image(1, 1, 32)
  end if
  me.pFriendRenderQueue = []
  tItemHeight = integer(getVariable("fr.online.item.height"))
  tCurrentPosV = 0
  tNo = 1
  repeat while tNo <= pContentList.count
    tFriend = pContentList.getAt(tNo)
    tFriend.setaProp(#posV, tCurrentPosV)
    me.append(tFriend)
    tCurrentPosV = tCurrentPosV + tItemHeight
    tNo = 1 + tNo
  end repeat
  pListImg = me.renderBackgroundImage()
end

on renderFromQueue me, tContentElement 
  if tContentElement = 0 then
    me.pFriendRenderQueue = []
    return(1)
  end if
  tItemHeight = integer(getVariable("fr.online.item.height"))
  tWidth = integer(getVariable("fr.list.panel.width"))
  tFacePosH = integer(getVariable("fr.online.face.offset.h"))
  tNamePosH = integer(getVariable("fr.online.name.offset.h"))
  tImage = image(tWidth, tItemHeight * pContentList.count, 32)
  tCurrentPosV = 0
  tNameWriter = getWriter(pWriterIdPlain)
  tFigureParser = getObject("Figure_System")
  tPartList = #head
  tPreviewObj = getObject("Figure_Preview")
  tImIconImg = getMember("friends_im_icon").image
  tImIconRect = tImIconImg.rect
  tImIconPosH = integer(getVariable("fr.online.im.offset.h"))
  tImIconPosV = tItemHeight - tImIconImg.height / 2
  tFollowIconImg = getMember("friends_follow_icon").image
  tFollowIconRect = tFollowIconImg.rect
  tFollowIconPosH = integer(getVariable("fr.online.follow.offset.h"))
  tFollowIconPosV = tItemHeight - tFollowIconImg.height / 2
  i = 1
  repeat while i <= me.pTasksPerUpdate
    if me.count(#pFriendRenderQueue) > 0 then
      tFriend = me.getProp(#pFriendRenderQueue, 1)
      me.deleteAt(1)
      tCurrentPosV = tFriend.getAt(#posV)
      if me.isFriendselected(tFriend.getAt(#name)) then
        tSelectedBg = rgb(string(getVariable("fr.online.bg.selected")))
        pListImg.fill(0, tCurrentPosV, tWidth, tCurrentPosV + tItemHeight, tSelectedBg)
      end if
      tParsedFigure = tFigureParser.parseFigure(tFriend.getAt(#figure), tFriend.getAt(#sex), "user")
      tHeadImage = tPreviewObj.getHumanPartImg(tPartList, tParsedFigure, 2, "sh")
      tSourceRect = tHeadImage.rect
      tFacePosV = tCurrentPosV + tItemHeight - tHeadImage.height / 2
      tdestrect = tSourceRect + rect(tFacePosH, tFacePosV, tFacePosH, tFacePosV)
      pListImg.copyPixels(tHeadImage, tdestrect, tSourceRect, [#ink:36])
      tNameImage = tNameWriter.render(tFriend.getAt(#name))
      tSourceRect = tNameImage.rect
      tNamePosV = tCurrentPosV + tItemHeight - tNameImage.height / 2
      tdestrect = tSourceRect + rect(tNamePosH, tNamePosV, tNamePosH, tNamePosV)
      pListImg.copyPixels(tNameImage, tdestrect, tSourceRect, [#ink:36])
      tdestrect = tImIconRect + rect(tImIconPosH, tCurrentPosV + tImIconPosV, tImIconPosH, tCurrentPosV + tImIconPosV)
      pListImg.copyPixels(tImIconImg, tdestrect, tImIconRect, [#ink:36])
      if tFriend.getAt(#canfollow) then
        tdestrect = tFollowIconRect + rect(tFollowIconPosH, tCurrentPosV + tFollowIconPosV, tFollowIconPosH, tCurrentPosV + tFollowIconPosV)
        pListImg.copyPixels(tFollowIconImg, tdestrect, tFollowIconRect, [#ink:36])
      end if
    end if
    i = 1 + i
  end repeat
  tContentElement.feedImage(pListImg)
end

on renderBackgroundImage me 
  if ilk(pContentList) <> #propList then
    return(image(1, 1, 32))
  end if
  if pContentList.count = 0 then
    return(image(1, 1, 32))
  end if
  tDarkBg = rgb(string(getVariable("fr.online.bg.dark")))
  pItemHeight = integer(getVariable("fr.online.item.height"))
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
end

on relayEvent me, tEvent, tLocX, tLocY 
  tItemHeight = integer(getVariable("fr.online.item.height"))
  tListIndex = tLocY / tItemHeight + 1
  tEventResult = [:]
  tEventResult.setAt(#Event, tEvent)
  tEventResult.setAt(#cursor, "cursor.arrow")
  if tListIndex > pContentList.count then
    return(tEventResult)
  end if
  tFriend = pContentList.getAt(tListIndex)
  tEventResult.setAt(#friend, tFriend)
  if tEvent = #mouseWithin then
    if tLocX > integer(getVariable("fr.online.im.offset.h")) then
      tEventResult.setAt(#element, #im)
      tEventResult.setAt(#cursor, "cursor.finger")
    else
      if tLocX > integer(getVariable("fr.online.follow.offset.h")) and tFriend.getAt(#canfollow) then
        tEventResult.setAt(#element, #follow)
        tEventResult.setAt(#cursor, "cursor.finger")
      end if
    end if
    tEventResult.setAt(#item_y, tListIndex - 1 * me.pItemHeight)
    tEventResult.setAt(#item_height, me.pItemHeight)
    return(tEventResult)
  end if
  if tEvent <> #mouseUp then
    return(1)
  end if
  tListWidth = integer(getVariable("fr.list.panel.width"))
  if tLocX > integer(getVariable("fr.online.im.offset.h")) then
    tEventResult.setAt(#element, #im)
  else
    if tLocX > integer(getVariable("fr.online.follow.offset.h")) and tFriend.getAt(#canfollow) then
      tEventResult.setAt(#element, #follow)
    else
      if the doubleClick then
        tEventResult.setAt(#element, #im)
        me.userSelectionEvent(tFriend.getAt(#name))
        tEventResult.setAt(#update, 1)
      else
        tEventResult.setAt(#element, #name)
        me.userSelectionEvent(tFriend.getAt(#name))
        tEventResult.setAt(#update, 1)
      end if
    end if
  end if
  return(tEventResult)
end
