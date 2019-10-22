on feedContentText me, tWndObj 
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("if_text")
  if (tElem = 0) then
    return FALSE
  end if
  tText = me.pData.getaProp(#value)
  tText = replaceChunks(tText, "\\r", "\r")
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
  tMemNum = getmemnum(getStringVariable("NUH." & me.pData.getaProp(#helpId) & ".icon"))
  if (tMemNum = 0) then
    tMemNum = getmemnum("if.icon.temp")
    if (tMemNum = 0) then
      return FALSE
    end if
  end if
  tImage = member(tMemNum).image
  tImage = me.alignIconImage(tImage, tElem.getProperty(#width), tElem.getProperty(#height))
  tElem.feedImage(tImage)
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
  if not voidp(me.pData.getaProp(#txtColor)) then
    tFont = tElem.getFont()
    tFont.setAt(#color, me.pData.getaProp(#txtColor))
    tElem.setFont(tFont)
  end if
  tElem.setText(me.pData.getaProp(#topic))
  return TRUE
end

on getShowOnCreate me 
  return(me.pData.getaProp(#autoOpen))
end
