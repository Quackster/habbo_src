property pChatImage, pListLine, pWriter, pChatWidth, pBgColors, pHighlightUserID, pMaxHeight

on construct me
  pChatData = []
  pChatWidth = 200
  pBgColors = []
  pBgColors.add(rgb(getVariable("im.color.receiver")))
  pBgColors.add(rgb(getVariable("im.color.sender")))
  pBgColors.add(rgb(getVariable("im.color.error")))
  pBgColors.add(rgb(getVariable("im.color.notification")))
  pMaxHeight = getIntVariable("im.chat.length.max")
  me.clearImage()
  tID = getUniqueID()
  createWriter(tID)
  pWriter = getWriter(tID)
  tFont = getStructVariable("struct.font.plain")
  tFont.setaProp(#wordWrap, 1)
  tFont.setaProp(#rect, rect(0, 0, 180, 0))
  pWriter.define(tFont)
  pHighlightUserID = getObject(#session).GET("user_user_id")
  return 1
end

on deconstruct me
  removeObject(pWriter.getID())
  return 1
end

on setWidth me, tWidth
  pChatWidth = tWidth
end

on renderChatEntry me, tEntry, tPos
  tUserID = tEntry.getaProp(#userID)
  case tUserID of
    #notification:
      tBgColor = pBgColors[4]
    #error:
      tBgColor = pBgColors[3]
    pHighlightUserID:
      tBgColor = pBgColors[2]
    otherwise:
      tBgColor = pBgColors[1]
  end case
  tMargin = 3
  tText = tEntry.getaProp(#Msg)
  if stringp(tUserID) then
    tText = (tEntry.getaProp(#time) && tText)
  end if
  tTextImage = pWriter.render(tText).duplicate()
  tEntryImage = image(pChatWidth, (tTextImage.height + (2 * tMargin)), 8)
  tEntryImage.fill(tEntryImage.rect, tBgColor)
  tTargetRect = (tTextImage.rect + rect(tMargin, tMargin, tMargin, tMargin))
  tEntryImage.copyPixels(tTextImage, tTargetRect, tTextImage.rect)
  tNewHeight = (pChatImage.height + tEntryImage.height)
  if (tNewHeight > pMaxHeight) then
    tNewHeight = pMaxHeight
  end if
  tNewChatImage = image(pChatWidth, tNewHeight, 8)
  if (tPos = #start) then
    if (tNewHeight = pMaxHeight) then
      return 0
    end if
    tNewChatImage.copyPixels(tEntryImage, tEntryImage.rect, tEntryImage.rect)
    tTargetRect = rect(0, tEntryImage.height, pChatWidth, (tEntryImage.height + pChatImage.height))
    tNewChatImage.copyPixels(pChatImage, tTargetRect, pChatImage.rect)
  else
    tTop = ((tNewChatImage.height - tEntryImage.height) - pChatImage.height)
    tBottom = (tTop + pChatImage.height)
    tTargetRect = rect(0, tTop, pChatImage.width, tBottom)
    tNewChatImage.copyPixels(pChatImage, tTargetRect, pChatImage.rect)
    tTop = (tNewChatImage.height - tEntryImage.height)
    tTargetRect = rect(0, tTop, pChatWidth, tNewChatImage.height)
    tNewChatImage.copyPixels(tEntryImage, tTargetRect, tEntryImage.rect)
  end if
  pChatImage = tNewChatImage
  return 1
end

on clearImage me
  pChatImage = image(pChatWidth, 0, 8)
end

on getChatImage me
  return pChatImage
end
