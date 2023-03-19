property pBubbleObjectId, pBubbleWindowId, pPopupTimeoutId, pCurrentFriendId, pFriendInfo, pTargetRect

on construct me
  pBubbleObjectId = "fr_popup_bubble_obj"
  pBubbleWindowId = "fr_popup_bubble_win"
  pPopupTimeoutId = "fr_popup_timer"
  return 1
end

on deconstruct me
  me.removePopupTimeout()
  me.removeBubbleObject()
  pFriendInfo = VOID
  return 1
end

on showInfoPopup me, tEventData, tWndX, tWndY, tContentElem
  if not listp(tEventData) then
    return me.removePopupTimeout()
  end if
  tFriend = tEventData.getaProp(#friend)
  if not listp(tFriend) then
    return me.removePopupTimeout()
  end if
  if tContentElem = 0 then
    return me.removePopupTimeout()
  end if
  tFriendID = tFriend.getaProp(#id)
  if tFriendID = pCurrentFriendId then
    return 1
  end if
  tItemHeight = tEventData.getaProp(#item_height)
  tWidth = tContentElem.getProperty(#width)
  tElementLocX = tWndX + tContentElem.getProperty(#locX)
  tsprite = tContentElem.getProperty(#sprite)
  if tsprite.ilk <> #sprite then
    return 0
  end if
  tItemY = tsprite.locV + tEventData.getaProp(#item_y)
  pTargetRect = rect(tElementLocX, tItemY, tElementLocX + tWidth, tItemY + tItemHeight)
  pCurrentFriendId = tFriendID
  pFriendInfo = tFriend.duplicate()
  me.removeBubbleObject()
  me.createDetailsBubble(pTargetRect)
end

on removeInfoPopup me
  me.removePopupTimeout()
  me.removeBubbleObject()
  pFriendInfo = VOID
  pCurrentFriendId = VOID
end

on createDetailsBubble me, tTargetRect
  if pFriendInfo = VOID then
    return 0
  end if
  createObject(pBubbleObjectId, "Details Bubble Class")
  tDetailsBubble = getObject(pBubbleObjectId)
  if tDetailsBubble = 0 then
    return 0
  end if
  tLayout = "friendlist_userinfo.window"
  if not pFriendInfo.getaProp(#online) then
    tLayout = "friendlist_userinfo_offline.window"
  end if
  tDetailsBubble.createWithContent(tLayout, tTargetRect, #right)
  tDetailsWindow = tDetailsBubble.getWindowObj()
  if tDetailsWindow = 0 then
    return 0
  end if
  tName = pFriendInfo.getaProp(#name)
  tFigure = pFriendInfo.getaProp(#figure)
  tsex = pFriendInfo.getaProp(#sex)
  tOnline = pFriendInfo.getaProp(#online)
  tElem = tDetailsWindow.getElement("user.info.image")
  if (tElem <> 0) and stringp(tFigure) then
    tElemWidth = tElem.getProperty(#width)
    tElemHeight = tElem.getProperty(#height)
    tHeadImage = me.getHumanImage(tFigure, tsex, tElemWidth, tElemHeight)
    if tHeadImage.ilk = #image then
      tElem.feedImage(tHeadImage)
    end if
  end if
  tElem = tDetailsWindow.getElement("user.info.name")
  if tElem <> 0 then
    tElem.setText(pFriendInfo.getaProp(#name))
  end if
  tElem = tDetailsWindow.getElement("user.info.motto")
  if tElem <> 0 then
    tElem.setText(pFriendInfo.getaProp(#mission))
  end if
  tElem = tDetailsWindow.getElement("user.info.loc")
  if tElem <> 0 then
    if tOnline then
      tElem.setText(getText("friend_info_online"))
    else
      tElem.setText(getText("friend_info_lastvisit") && pFriendInfo.getaProp(#lastAccess))
    end if
  end if
end

on removePopupTimeout me
  if timeoutExists(pPopupTimeoutId) then
    removeTimeout(pPopupTimeoutId)
  end if
end

on getBubbleObject me
  if not objectExists(pBubbleObjectId) then
    createObject(pBubbleObjectId, "Details Bubble Class")
  end if
  return getObject(pBubbleObjectId)
end

on removeBubbleObject me
  if objectExists(pBubbleObjectId) then
    removeObject(pBubbleObjectId)
  end if
  if windowExists(pBubbleWindowId) then
    removeWindow(pBubbleWindowId)
  end if
end

on getHumanImage me, tFigure, tsex, tWidth, tHeight
  tParserObj = getObject("Figure_System")
  if tParserObj = 0 then
    return 0
  end if
  tPreviewObj = getObject("Figure_Preview")
  if tPreviewObj = 0 then
    return 0
  end if
  tParsedFigure = tParserObj.parseFigure(tFigure, tsex, "user")
  tImage = tPreviewObj.getHumanPartImg(#head, tParsedFigure, 2, "sh")
  tImage = me.alignIconImage(tImage, tWidth, tHeight)
  tImage = me.alignIconImage(tImage, tWidth, tHeight)
  return tImage
end

on alignIconImage me, tImage, tWidth, tHeight
  if tImage.ilk <> #image then
    return 0
  end if
  tNewImage = image(tWidth, tHeight, tImage.depth)
  tOffsetX = (tWidth - tImage.width) / 2
  tOffsetY = 0
  tNewImage.copyPixels(tImage, tImage.rect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY), tImage.rect)
  return tNewImage
end
