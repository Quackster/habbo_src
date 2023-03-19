on feedContentText me, tWndObj
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("if_text")
  if tElem = 0 then
    return 0
  end if
  tText = me.pData.getaProp(#value)
  tText = replaceChunks(tText, "\r", RETURN)
  tElem.setText(tText)
  return 1
end

on feedContentImage me, tWndObj
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("if_icon")
  if tElem = 0 then
    return 0
  end if
  tMemNum = getmemnum(getStringVariable("NUH." & me.pData.getaProp(#helpId) & ".icon"))
  if tMemNum = 0 then
    tMemNum = getmemnum("if.icon.temp")
    if tMemNum = 0 then
      return 0
    end if
  end if
  tImage = member(tMemNum).image
  tImage = me.alignIconImage(tImage, tElem.getProperty(#width), tElem.getProperty(#height))
  tElem.feedImage(tImage)
  return 1
end

on feedTopic me, tWndObj
  if tWndObj = 0 then
    return 0
  end if
  tElem = tWndObj.getElement("if_title")
  if tElem = 0 then
    return 0
  end if
  if not voidp(me.pData.getaProp(#txtColor)) then
    tFont = tElem.getFont()
    tFont[#color] = me.pData.getaProp(#txtColor)
    tElem.setFont(tFont)
  end if
  tElem.setText(me.pData.getaProp(#topic))
  return 1
end

on getShowOnCreate me
  return me.pData.getaProp(#autoOpen)
end
