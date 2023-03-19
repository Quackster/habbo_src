property pListImg, pWriterIdPlain, pWriterIdBold, pContentList, pItemHeight, pItemWidth, pEmptyListText

on construct me
  pSelectedFriendID = VOID
  pContentList = [#friends: [], #habbos: []]
  pContentList.sort()
  pWriterIdPlain = getUniqueID()
  tPlain = getStructVariable("struct.font.plain")
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#111111")]
  createWriter(pWriterIdPlain, tMetrics)
  pWriterIdBold = getUniqueID()
  tBold = getStructVariable("struct.font.bold")
  tMetrics = [#font: tBold.getaProp(#font), #fontStyle: tBold.getaProp(#fontStyle), #color: rgb("#111111")]
  createWriter(pWriterIdBold, tMetrics)
  pItemHeight = integer(getVariable("fr.requests.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  me.renderListImage()
  pEmptyListText = EMPTY
end

on deconstruct me
  pListImg = VOID
  removeWriter(pWriterIdPlain)
end

on setListData me, tdata
  if ilk(tdata) = #propList then
    pContentList = tdata.duplicate()
    me.renderListImage()
  end if
end

on renderFriendItem me, tFriendData
  pItemHeight = integer(getVariable("fr.search.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  tNameWriter = getWriter(pWriterIdBold)
  tItemImg = image(pItemWidth, pItemHeight, 32)
  tName = tFriendData[#name]
  tNameImg = tNameWriter.render(tName)
  tSourceRect = tNameImg.rect
  tNamePosH = integer(getVariable("fr.offline.name.offset.h"))
  tNamePosV = (pItemHeight - tNameImg.height) / 2
  tdestrect = tSourceRect + rect(tNamePosH, tNamePosV, tNamePosH, tNamePosV)
  tItemImg.copyPixels(tNameImg, tdestrect, tNameImg.rect)
  return tItemImg.duplicate()
end

on renderListImageFriends me, tContentList
  if not listp(tContentList) then
    return image(1, 1, 32)
  end if
  if tContentList.count = 0 then
    return image(1, 1, 32)
  end if
  pItemHeight = integer(getVariable("fr.search.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  tNamePosH = integer(getVariable("fr.search.name.offset.h"))
  tFacePosH = integer(getVariable("fr.search.face.offset.h"))
  tFigureParser = getObject("Figure_System")
  tPartList = #head
  tPreviewObj = getObject("Figure_Preview")
  tImIconImg = getMember("friends_im_icon").image
  tImIconRect = tImIconImg.rect
  tImIconPosH = integer(getVariable("fr.search.im.offset.h"))
  tImIconPosV = (pItemHeight - tImIconImg.height) / 2
  tMailIconImg = getMember("friends_mail_list_icon").image
  tMailIconRect = tMailIconImg.rect
  tMailIconPosH = integer(getVariable("fr.search.mail.offset.h"))
  tMailIconPosV = (pItemHeight - tMailIconImg.height) / 2
  tFollowIconImg = getMember("friends_follow_icon").image
  tFollowIconRect = tFollowIconImg.rect
  tFollowIconPosH = integer(getVariable("fr.search.follow.offset.h"))
  tFollowIconPosV = (pItemHeight - tFollowIconImg.height) / 2
  tImage = image(pItemWidth, pItemHeight * tContentList.count, 32)
  tCurrentPosV = 0
  tNameWriter = getWriter(pWriterIdPlain)
  repeat with tFriend in tContentList
    tName = tFriend[#name]
    tParsedFigure = tFigureParser.parseFigure(tFriend[#figure], tFriend[#sex], "user")
    tHeadImage = tPreviewObj.getHumanPartImg(tPartList, tParsedFigure, 2, "sh")
    tSourceRect = tHeadImage.rect
    tFacePosV = tCurrentPosV + ((pItemHeight - tHeadImage.height) / 2)
    tdestrect = tSourceRect + rect(tFacePosH, tFacePosV, tFacePosH, tFacePosV)
    tImage.copyPixels(tHeadImage, tdestrect, tSourceRect, [#ink: 36])
    tNameImage = tNameWriter.render(tName)
    tSourceRect = tNameImage.rect
    tNamePosV = tCurrentPosV + ((pItemHeight - tNameImage.height) / 2)
    tdestrect = tSourceRect + rect(tNamePosH, tNamePosV, tNamePosH, tNamePosV)
    tImage.copyPixels(tNameImage, tdestrect, tNameImage.rect)
    if tFriend[#online] then
      tdestrect = tImIconRect + rect(tImIconPosH, tCurrentPosV + tImIconPosV, tImIconPosH, tCurrentPosV + tImIconPosV)
      tImage.copyPixels(tImIconImg, tdestrect, tImIconRect, [#ink: 36])
      if tFriend[#canfollow] then
        tdestrect = tFollowIconRect + rect(tFollowIconPosH, tCurrentPosV + tFollowIconPosV, tFollowIconPosH, tCurrentPosV + tFollowIconPosV)
        tImage.copyPixels(tFollowIconImg, tdestrect, tFollowIconRect, [#ink: 36])
      end if
    else
      tdestrect = tMailIconRect + rect(tMailIconPosH, tCurrentPosV + tMailIconPosV, tMailIconPosH, tCurrentPosV + tMailIconPosV)
      tImage.copyPixels(tMailIconImg, tdestrect, tMailIconRect, [#ink: 36])
    end if
    tCurrentPosV = tCurrentPosV + pItemHeight
  end repeat
  return tImage
end

on renderListImageUsers me, tContentList
  if not listp(tContentList) then
    return image(1, 1, 32)
  end if
  if tContentList.count = 0 then
    return image(1, 1, 32)
  end if
  pItemHeight = integer(getVariable("fr.search.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  tNamePosH = integer(getVariable("fr.search.name.offset.h"))
  tFigureParser = getObject("Figure_System")
  tPartList = #head
  tPreviewObj = getObject("Figure_Preview")
  tAddFriendIconImg = getMember("friends_addfriend_icon").image
  tAddFriendIconRect = tAddFriendIconImg.rect
  tAddFriendIconPosH = integer(getVariable("fr.search.addfriend.offset.h"))
  tAddFriendIconPosV = (pItemHeight - tAddFriendIconImg.height) / 2
  tImage = image(pItemWidth, pItemHeight * tContentList.count, 32)
  tCurrentPosV = 0
  tNameWriter = getWriter(pWriterIdPlain)
  tOwnName = getObject(#session).GET(#userName)
  repeat with tFriend in tContentList
    tName = tFriend[#name]
    tNameImage = tNameWriter.render(tName)
    tSourceRect = tNameImage.rect
    tNamePosV = tCurrentPosV + ((pItemHeight - tNameImage.height) / 2)
    tdestrect = tSourceRect + rect(tNamePosH, tNamePosV, tNamePosH, tNamePosV)
    tImage.copyPixels(tNameImage, tdestrect, tNameImage.rect)
    if not tFriend.getaProp(#fr_pending) then
      if tName <> tOwnName then
        tdestrect = tAddFriendIconRect + rect(tAddFriendIconPosH, tCurrentPosV + tAddFriendIconPosV, tAddFriendIconPosH, tCurrentPosV + tAddFriendIconPosV)
        tImage.copyPixels(tAddFriendIconImg, tdestrect, tAddFriendIconRect, [#ink: 36])
      end if
    end if
    tCurrentPosV = tCurrentPosV + pItemHeight
  end repeat
  return tImage
end

on renderListImage me
  tImage1 = me.renderListImageFriends(pContentList[#friends])
  tImage2 = me.renderListImageUsers(pContentList[#habbos])
  if pContentList[#friends].count = 0 then
    tText = getText("friend_result_nofriendsfound")
  else
    tText = replaceChunks(getText("friend_result_friends"), "%cnt%", pContentList[#friends].count)
  end if
  tFriendsResultLine = me.renderFriendItem([#name: tText])
  if pContentList[#habbos].count = 0 then
    tText = getText("friend_result_noothersfound")
  else
    tText = replaceChunks(getText("friend_result_other"), "%cnt%", pContentList[#habbos].count)
  end if
  tHabbosResultLine = me.renderFriendItem([#name: tText])
  tImage = me.concatenateImages([tFriendsResultLine, tImage1, tHabbosResultLine, tImage2])
  pListImg = tImage.duplicate()
end

on renderBackgroundImage me
  if ilk(pContentList) <> #propList then
    return image(1, 1, 32)
  end if
  if pContentList.count = 0 then
    return image(1, 1, 32)
  end if
  tCount = pContentList[#friends].count + pContentList[#habbos].count + 2
  tDarkBg = rgb(string(getVariable("fr.offline.bg.dark")))
  pItemHeight = integer(getVariable("fr.offline.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  tImage = image(pItemWidth, tCount * pItemHeight, 32)
  tCurrentPosV = 0
  repeat with tIndex = 1 to (tCount / 2) + 1
    tImage.fill(0, tCurrentPosV, pItemWidth, tCurrentPosV + pItemHeight, tDarkBg)
    tCurrentPosV = tCurrentPosV + (pItemHeight * 2)
  end repeat
  return tImage
end

on hideAddFriendLink me, tIndex, tCurrentPosV
  tAddFriendIconImg = getMember("friends_addfriend_icon").image
  tAddFriendIconRect = tAddFriendIconImg.rect
  tAddFriendIconPosH = integer(getVariable("fr.search.addfriend.offset.h"))
  tAddFriendIconPosV = (pItemHeight - tAddFriendIconImg.height) / 2
  tdestrect = tAddFriendIconRect + rect(tAddFriendIconPosH, tCurrentPosV + tAddFriendIconPosV, tAddFriendIconPosH, tCurrentPosV + tAddFriendIconPosV)
  me.pListImg.fill(tdestrect, rgb(255, 255, 255))
end

on relayEvent me, tEvent, tLocX, tLocY
  tListIndex = (tLocY / me.pItemHeight) + 1
  tEventResult = [:]
  tEventResult[#Event] = tEvent
  if pContentList.count = 0 then
    tEventResult[#cursor] = "cursor.arrow"
    return tEventResult
  end if
  if (tListIndex > 1) and (tListIndex <= (pContentList[#friends].count + 1)) then
    tFriend = pContentList[#friends][tListIndex - 1]
    tEventResult[#friend] = tFriend
    if tEvent = #mouseWithin then
      if tFriend.getaProp(#online) then
        if (tLocX > integer(getVariable("fr.search.im.offset.h"))) and tFriend[#online] then
          tEventResult[#element] = #im
          tEventResult[#cursor] = "cursor.finger"
        else
          if (tLocX > integer(getVariable("fr.search.follow.offset.h"))) and tFriend[#canfollow] then
            tEventResult[#element] = #follow
            tEventResult[#cursor] = "cursor.finger"
          end if
        end if
      else
        if tLocX > integer(getVariable("fr.search.mail.offset.h")) then
          tEventResult[#element] = #mail
          tEventResult[#cursor] = "cursor.finger"
        end if
      end if
      tEventResult[#item_y] = (tListIndex - 1) * me.pItemHeight
      tEventResult[#item_height] = me.pItemHeight
      return tEventResult
    end if
    if tFriend.getaProp(#online) then
      if (tLocX > integer(getVariable("fr.search.im.offset.h"))) and tFriend[#online] then
        tEventResult[#element] = #im
        tEventResult[#cursor] = "cursor.finger"
      else
        if (tLocX > integer(getVariable("fr.search.follow.offset.h"))) and tFriend[#canfollow] then
          tEventResult[#element] = #follow
          tEventResult[#cursor] = "cursor.finger"
        end if
      end if
    else
      if tLocX > integer(getVariable("fr.search.mail.offset.h")) then
        tEventResult[#element] = #mail
        tEventResult[#cursor] = "cursor.finger"
      end if
    end if
  else
    if ((tListIndex - 2) > pContentList[#friends].count) and ((tListIndex - 2 - pContentList[#friends].count) <= pContentList[#habbos].count) then
      tFriend = pContentList[#habbos][tListIndex - 2 - pContentList[#friends].count]
      tEventResult[#friend] = tFriend
      if tFriend.getaProp(#name) = getObject(#session).GET(#userName) then
        tDisableFR = 1
      end if
      if tFriend.getaProp(#fr_pending) then
        tDisableFR = 1
      end if
      if tEvent = #mouseWithin then
        if tLocX > integer(getVariable("fr.search.addfriend.offset.h")) then
          if tDisableFR then
            return 1
          end if
          tEventResult[#element] = #addFriend
          tEventResult[#cursor] = "cursor.finger"
          tEventResult[#item_y] = (tListIndex - 1) * me.pItemHeight
          tEventResult[#item_height] = me.pItemHeight
        end if
        tEventResult[#item_y] = (tListIndex - 1) * me.pItemHeight
        tEventResult[#item_height] = me.pItemHeight
        return tEventResult
      end if
      if tDisableFR then
        return 1
      end if
      if tLocX > integer(getVariable("fr.search.addfriend.offset.h")) then
        tEventResult[#element] = #addFriend
        tEventResult[#cursor] = "cursor.finger"
        me.hideAddFriendLink(tListIndex, (tListIndex - 1) * me.pItemHeight)
        tEventResult[#update] = 1
      end if
    end if
  end if
  return tEventResult
end

on concatenateImages me, tImageList
  tHeight = 0
  repeat with tImage in tImageList
    tHeight = tHeight + tImage.height
  end repeat
  tImageOut = image(pItemWidth, tHeight, 32)
  tOffRect = rect(0, 0, 0, 0)
  repeat with tImage in tImageList
    tImageOut.copyPixels(tImage, tImage.rect + tOffRect, tImage.rect)
    tOffRect = tOffRect + rect(0, tImage.height, 0, tImage.height)
  end repeat
  return tImageOut
end
