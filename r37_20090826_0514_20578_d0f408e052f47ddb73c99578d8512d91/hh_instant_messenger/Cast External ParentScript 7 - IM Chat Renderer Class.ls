property pChatImage, pListLine, pWriter, pChatWidth, pHighlightUserID, pMaxHeight, pMargin

on construct me
  pChatData = []
  pChatWidth = 185
  pMargin = 3
  pMaxHeight = getIntVariable("im.chat.length.max")
  me.clearImage()
  tFont = getStructVariable("struct.font.plain")
  tFont.setaProp(#wordWrap, 1)
  tFont.setaProp(#rect, rect(0, 0, pChatWidth - (2 * pMargin), 0))
  tID = getUniqueID()
  createWriter(tID, tFont)
  pWriter = getWriter(tID)
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
  ttype = tEntry.getaProp(#type)
  tUserID = tEntry.getaProp(#userID)
  tText = tEntry.getaProp(#Msg)
  tUseTime = (ttype = #message) or (ttype = #invitation)
  if tUseTime then
    tText = tEntry.getaProp(#time) && tText
  end if
  case ttype of
    #invitation:
      tColor = getVariable("im.color.invitation", "FFFFFF")
    #notification:
      tColor = getVariable("im.color.notification", "FFFFFF")
    #error:
      tColor = getVariable("im.color.error", "FFFFFF")
    #message:
      if tUserID = pHighlightUserID then
        tColor = getVariable("im.color.sender", "FFFFFF")
      else
        tColor = getVariable("im.color.receiver", "FFFFFF")
      end if
    #otherwise:
      tColor = "FFFFFF"
  end case
  tTextImage = pWriter.render(tText).duplicate()
  tEntryImage = image(pChatWidth, tTextImage.height + (2 * pMargin), 8)
  tEntryImage.fill(tEntryImage.rect, rgb(tColor))
  tTargetRect = tTextImage.rect + rect(pMargin, pMargin, pMargin, pMargin)
  tEntryImage.copyPixels(tTextImage, tTargetRect, tTextImage.rect)
  tNewHeight = pChatImage.height + tEntryImage.height
  if tNewHeight > pMaxHeight then
    tNewHeight = pMaxHeight
  end if
  tNewChatImage = image(pChatWidth, tNewHeight, 8)
  if tPos = #start then
    if tNewHeight = pMaxHeight then
      return 0
    end if
    tNewChatImage.copyPixels(tEntryImage, tEntryImage.rect, tEntryImage.rect)
    tTargetRect = rect(0, tEntryImage.height, pChatWidth, tEntryImage.height + pChatImage.height)
    tNewChatImage.copyPixels(pChatImage, tTargetRect, pChatImage.rect)
  else
    tTop = tNewChatImage.height - tEntryImage.height - pChatImage.height
    tBottom = tTop + pChatImage.height
    tTargetRect = rect(0, tTop, pChatImage.width, tBottom)
    tNewChatImage.copyPixels(pChatImage, tTargetRect, pChatImage.rect)
    tTop = tNewChatImage.height - tEntryImage.height
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
