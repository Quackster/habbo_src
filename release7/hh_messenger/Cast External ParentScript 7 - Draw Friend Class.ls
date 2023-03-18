property pData, pID, pName, pSex, pMsg, pEmailOK, pOnline, pUnit, pLastTime, pMsgCount, pTopMarg, pLeftMarg, pwidth, pheight, pLineHeight, pMsgLinkRect, pSelected, pNeedUpdate, pCacheImage, pDotLineImg, pCacheOnlineImg, pCacheNameImg, pCacheMsgsImg, pCacheUnitImg, pCacheLastTimeImg, pCacheMissionImg, pNameNeedUpdate, pMsgsNeedUpdate, pUnitNeedUpdate, pLastNeedUpdate, pMissNeedUpdate, pWriterName, pWriterMsgs, pWriterLast, pWriterText

on construct me
  pData = [:]
  pID = EMPTY
  pMsg = EMPTY
  pEmailOK = 0
  pOnline = 0
  pUnit = EMPTY
  pLastTime = EMPTY
  pMsgCount = "0"
  pTopMarg = 3
  pLeftMarg = 29
  pLineHeight = 10
  pMsgLinkRect = rect(0, 0, 0, 0)
  pSelected = 0
  pDotLineImg = member(getmemnum("meswhitedottedline")).image
  pCacheOnlineImg = member(getmemnum("mes_smallbuddy_head")).image
  pNameNeedUpdate = 1
  pMsgsNeedUpdate = 1
  pUnitNeedUpdate = 1
  pLastNeedUpdate = 1
  pMissNeedUpdate = 1
  return 1
end

on define me, tdata, tProps
  pData = tdata
  pEmailOK = tdata.emailOk
  pID = tdata.id
  pName = tdata.name
  pSex = tdata.sex
  pwidth = tProps.width
  pheight = tProps.height
  pCacheImage = image(pwidth, pheight, 8)
  pWriterName = getWriter(tProps.writer_name)
  pWriterMsgs = getWriter(tProps.writer_msgs)
  pWriterLast = getWriter(tProps.writer_last)
  pWriterText = getWriter(tProps.writer_text)
  pNeedUpdate = 1
  me.update()
end

on update me
  pOnline = pData.online
  if pData.msg <> pMsg then
    pMsg = pData.msg
    pMissNeedUpdate = 1
    pNeedUpdate = 1
  end if
  if pData.unit <> pUnit then
    pUnit = pData.unit
    pUnitNeedUpdate = 1
    pNeedUpdate = 1
  end if
  if pData.last_access_time <> pLastTime then
    pLastTime = pData.last_access_time
    pLastNeedUpdate = 1
    pNeedUpdate = 1
  end if
  if pData.msgs <> pMsgCount then
    pMsgCount = string(pData.msgs)
    pMsgsNeedUpdate = 1
    pNeedUpdate = 1
  end if
end

on select me, tClickPoint, tBuffer, tPosition
  if (integer(pMsgCount.word[1]) > 0) and inside(tClickPoint, pMsgLinkRect) then
    tMsgStruct = getThread(#messenger).getComponent().getMessageBySenderId(pID)
    getThread(#messenger).getInterface().renderMessage(tMsgStruct)
  else
    tPos = tPosition * pheight
    tRect = pCacheImage.rect + rect(0, 1, -4, -2) + [0, tPos, 0, tPos]
    if pSelected then
      pSelected = 0
      tBuffer.draw(tRect, [#shapeType: #rect, #lineSize: 1, #color: rgb("#FFFFFF")])
    else
      pSelected = 1
      tBuffer.draw(tRect, [#shapeType: #rect, #lineSize: 1, #color: rgb("#EEEEEE")])
    end if
    getThread(#messenger).getInterface().buddySelectOrNot(pName, pID, pSelected, pEmailOK)
  end if
end

on unselect me
  pSelected = 0
end

on render me, tBuffer, tPosition
  tPosition = tPosition - 1
  if pData.update then
    pNeedUpdate = 1
  end if
  if not pNeedUpdate then
    tDstRect = pCacheImage.rect + rect(0, tPosition * pheight, 0, tPosition * pheight)
    tBuffer.copyPixels(pCacheImage, tDstRect, pCacheImage.rect)
  else
    pNeedUpdate = 0
    if pNameNeedUpdate then
      tText = pName && "-"
      pCacheNameImg = pWriterName.render(tText).duplicate()
      pNameNeedUpdate = 0
      tX1 = pLeftMarg
      tX2 = tX1 + pCacheNameImg.width
      tY1 = pTopMarg
      tY2 = tY1 + pCacheNameImg.height
      tDstRect = rect(tX1, tY1, tX2, tY2)
      pCacheImage.copyPixels(pCacheNameImg, tDstRect, pCacheNameImg.rect)
    end if
    if pMsgsNeedUpdate then
      tMsgsImg = pWriterMsgs.render(pMsgCount)
      tX1 = pLeftMarg + pCacheNameImg.width + 5
      tX2 = tX1 + tMsgsImg.width
      tY1 = pTopMarg
      tY2 = tY1 + tMsgsImg.height
      tDstRect = rect(tX1, tY1, tX2, tY2)
      pCacheImage.fill(tDstRect, rgb(255, 255, 255))
      pCacheImage.copyPixels(tMsgsImg, tDstRect, tMsgsImg.rect)
      pMsgLinkRect = tDstRect
      pMsgNeedUpdate = 0
    end if
    if pLastNeedUpdate then
      if length(pUnit) < 3 then
        tText = getText("console_lastvisit", "Last visit") && pLastTime
      else
        tlocation = pUnit
        if tlocation contains "Floor1" then
          tlocation = getText("console_inprivateroom", "In private room")
        end if
        if tlocation = "Messenger" then
          tlocation = getText("console_onfrontpage", "(On front page)")
        end if
        tText = getText("console_online", "Online:") && tlocation
      end if
      tLastTimeImg = pWriterLast.render(tText)
      tX1 = pLeftMarg
      tX2 = tX1 + tLastTimeImg.width
      tY1 = pLineHeight + pTopMarg
      tY2 = tY1 + tLastTimeImg.height
      tDstRect = rect(tX1, tY1, tX2, tY2)
      pCacheImage.fill(rect(tX1, tY1, pCacheImage.width, tY2), rgb(255, 255, 255))
      pCacheImage.copyPixels(tLastTimeImg, tDstRect, tLastTimeImg.rect)
      pLastNeedUpdate = 0
    end if
    tX1 = 6
    tX2 = tX1 + pCacheOnlineImg.width
    tY1 = 4
    tY2 = tY1 + pCacheOnlineImg.height
    tDstRect = rect(tX1, tY1, tX2, tY2)
    if pOnline then
      pCacheImage.copyPixels(pCacheOnlineImg, tDstRect, pCacheOnlineImg.rect)
    else
      pCacheImage.fill(tDstRect, rgb(255, 255, 255))
    end if
    if pMissNeedUpdate then
      tMissionImg = pWriterText.render(QUOTE & pMsg & QUOTE)
      tX1 = pLeftMarg
      tX2 = tX1 + tMissionImg.width
      tY1 = (pLineHeight * 2) + pTopMarg
      tY2 = tY1 + tMissionImg.height
      tDstRect = rect(tX1, tY1, tX2, tY2)
      pCacheImage.fill(tDstRect, rgb(255, 255, 255))
      pCacheImage.copyPixels(tMissionImg, tDstRect, tMissionImg.rect)
      pMissNeedUpdate = 0
    end if
    tX1 = 0
    tX2 = pDotLineImg.width
    tY1 = pCacheImage.height - 1
    tY2 = tY1 + 1
    tDstRect = rect(tX1, tY1, tX2, tY2)
    pCacheImage.copyPixels(pDotLineImg, tDstRect, pDotLineImg.rect)
    tDstRect = pCacheImage.rect + rect(0, tPosition * pheight, 0, tPosition * pheight)
    tBuffer.copyPixels(pCacheImage, tDstRect, pCacheImage.rect)
    pData.update = 0
  end if
end
