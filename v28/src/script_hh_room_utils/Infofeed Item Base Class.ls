property pWriterIdBold, pData

on construct me 
  pData = [:]
  pWriterIdBold = "if_writer_bold"
  return TRUE
end

on deconstruct me 
  pData = [:]
  if writerExists(pWriterIdBold) then
    removeWriter(pWriterIdBold)
  end if
  return TRUE
end

on define me, tdata 
  if not listp(tdata) then
    return(error(me, "Invalid data supplied for infofeed item!", #define))
  end if
  pData = tdata.duplicate()
  return TRUE
end

on renderMinDefault me, tWndObj 
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.merge("if_min_default.window")
  me.feedTitle(tWndObj)
  return TRUE
end

on renderMin me, tWndObj 
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.merge("if_min.window")
  me.feedTopic(tWndObj)
  return TRUE
end

on renderFull me, tWndObj, tItemPos, tItemCount 
  tIsFirstItem = tItemPos <= 1
  tIsLastItem = (tItemPos = tItemCount)
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.merge("if_full.window")
  tElem = tWndObj.getElement("if_btn_prev")
  if tElem <> 0 then
    tElem.setProperty(#blend, (40 + (not tIsFirstItem * 60)))
  end if
  tElem = tWndObj.getElement("if_btn_next")
  if tElem <> 0 then
    tElem.setProperty(#blend, (40 + (not tIsLastItem * 60)))
  end if
  me.feedTopic(tWndObj)
  me.feedContentText(tWndObj)
  me.feedContentImage(tWndObj)
  return TRUE
end

on feedTitle me, tWndObj 
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("if_title")
  if (tElem = 0) then
    return FALSE
  end if
  tText = getText("if_title")
  tBoldStruct = getStructVariable("struct.font.bold")
  tBoldStruct.setaProp(#alignment, #center)
  tBoldStruct.setaProp(#color, rgb(238, 238, 238))
  createWriter(pWriterIdBold, tBoldStruct)
  tWriter = getWriter(pWriterIdBold)
  if (tWriter = 0) then
    return FALSE
  end if
  tImage = tWriter.render(tText)
  if (tImage = 0) then
    return FALSE
  end if
  tElem.feedImage(tImage)
  tWndObj.resizeTo((tImage.width + 38), tWndObj.getProperty(#height))
  removeWriter(pWriterIdBold)
  return TRUE
end

on feedTopic me, tWndObj 
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("if_title")
  if (tElem = 0) then
    return FALSE
  end if
  tElem.setText(getText("if_topic_" & pData.getaProp(#type)))
  return TRUE
end

on feedContentText me, tWndObj 
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("if_text")
  if (tElem = 0) then
    return FALSE
  end if
  tText = getText("if_content_" & pData.getaProp(#type))
  tText = replaceChunks(tText, "\\r", "\r")
  if pData.findPos(#value) > 0 then
    tText = replaceChunks(tText, "%value%", pData.getaProp(#value))
  end if
  tElem.setText(tText)
  return TRUE
end

on feedContentImage me, tWndObj 
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("if_icon")
  if (tElem = 0) then
    return FALSE
  end if
  tMemNum = getmemnum("if.icon." & pData.getaProp(#type))
  if (tMemNum = 0) then
    error(me, "Infofeed icon 'if.icon." & pData.getaProp(#type) & "' not found.", #minor)
    tMemNum = getmemnum("if.icon.temp")
    if (tMemNum = 0) then
      return FALSE
    end if
  end if
  tImage = member(tMemNum).image
  tElem.feedImage(tImage)
  return TRUE
end

on alignIconImage me, tImage, tWidth, tHeight 
  if tImage.ilk <> #image then
    return FALSE
  end if
  tNewImage = image(tWidth, tHeight, tImage.depth)
  tOffsetX = ((tWidth - tImage.width) / 2)
  tOffsetY = ((tHeight - tImage.height) / 2)
  tNewImage.copyPixels(tImage, (tImage.rect + rect(tOffsetX, tOffsetY, tOffsetX, tOffsetY)), tImage.rect)
  return(tNewImage)
end
