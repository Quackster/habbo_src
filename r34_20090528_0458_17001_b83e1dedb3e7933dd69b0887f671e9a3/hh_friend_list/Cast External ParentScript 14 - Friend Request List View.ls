property pListImg, pWriterIdPlain, pContentList, pItemHeight, pItemWidth, pEmptyListText

on construct me
  pSelectedFriendID = VOID
  pContentList = [:]
  pContentList.sort()
  pWriterIdPlain = getUniqueID()
  tPlain = getStructVariable("struct.font.plain")
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#111111")]
  createWriter(pWriterIdPlain, tMetrics)
  pItemHeight = integer(getVariable("fr.requests.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  pListImg = image(pItemWidth, 0, 32)
  pEmptyListText = getText("friend_list_no_requests")
end

on deconstruct me
  pListImg = VOID
  removeWriter(pWriterIdPlain)
end

on setListData me, tdata
  pContentList = [:]
  pContentList.sort()
  repeat with tNo = 1 to tdata.count
    tRequest = tdata[tNo]
    tRequestId = string(tRequest[#id])
    pContentList[tRequestId] = tRequest
  end repeat
end

on cleanUp me
  tNewList = [:]
  tNewList.sort()
  repeat with tIndex = 1 to pContentList.count
    tRequest = pContentList[tIndex]
    if tRequest[#state] = #pending then
      tNewList[tRequest[#id]] = tRequest
    end if
  end repeat
  me.setListData(tNewList.duplicate())
  pListImg = image(pItemWidth, 0, 32)
  repeat with tIndex = 1 to tNewList.count
    tRequest = tNewList[tIndex]
    tRequestId = string(tRequest[#id])
    tPosV = (tIndex - 1) * me.pItemHeight
    tRequestImg = me.renderRequestItem(tRequest)
    pListImg = me.insertImageTo(tRequestImg, pListImg.duplicate(), tPosV)
  end repeat
end

on addRequest me, tRequest
  if ilk(tRequest) <> #propList then
    return 0
  end if
  tRequestId = string(tRequest[#id])
  pContentList[tRequestId] = tRequest
  tIndex = pContentList.findPos(tRequestId)
  tPosV = (tIndex - 1) * me.pItemHeight
  tRequestImg = me.renderRequestItem(tRequest)
  pListImg = me.insertImageTo(tRequestImg, pListImg.duplicate(), tPosV)
end

on handleRequestState me, tRequestId, tstate
  if pContentList.findPos(string(tRequestId)) = VOID then
    return 0
  end if
  tRequest = pContentList[string(tRequestId)]
  tRequest[#state] = tstate
  pContentList[tRequestId] = tRequest
  tIndex = pContentList.findPos(tRequestId)
  tPosV = (tIndex - 1) * me.pItemHeight
  tRequestImg = me.renderRequestItem(tRequest)
  pListImg = me.updateImagePart(tRequestImg, pListImg.duplicate(), tPosV)
end

on handleAll me, tstate
  repeat with tIndex = 1 to pContentList.count
    tRequest = pContentList[tIndex]
    if tRequest[#state] = #pending then
      tRequest[#state] = tstate
      pContentList[string(tRequest[#id])] = tRequest
      tPosV = (tIndex - 1) * me.pItemHeight
      tRequestImg = me.renderRequestItem(tRequest)
      pListImg = me.updateImagePart(tRequestImg, pListImg.duplicate(), tPosV)
    end if
  end repeat
end

on renderRequestItem me, tRequestData
  tNameWriter = getWriter(pWriterIdPlain)
  tItemImg = image(pItemWidth, pItemHeight, 32)
  tName = tRequestData[#name]
  tNameImg = tNameWriter.render(tName)
  tSourceRect = tNameImg.rect
  tNamePosH = integer(getVariable("fr.requests.name.offset.h"))
  tNamePosV = (pItemHeight - tNameImg.height) / 2
  tdestrect = tSourceRect + rect(tNamePosH, tNamePosV, tNamePosH, tNamePosV)
  tItemImg.copyPixels(tNameImg, tdestrect, tSourceRect)
  case tRequestData[#state] of
    #pending:
      tAcceptIconImg = getMember(getVariable("fr.requests.accept.icon")).image
      tAcceptIconRect = tAcceptIconImg.rect
      tAcceptIconPosH = integer(getVariable("fr.requests.accept.offset.h"))
      tAcceptIconPosV = (pItemHeight - tAcceptIconImg.height) / 2
      tdestrect = tAcceptIconRect + rect(tAcceptIconPosH, tAcceptIconPosV, tAcceptIconPosH, tAcceptIconPosV)
      tItemImg.copyPixels(tAcceptIconImg, tdestrect, tAcceptIconRect, [#ink: 36])
      tRejectIconImg = getMember(getVariable("fr.requests.reject.icon")).image
      tRejectIconRect = tAcceptIconImg.rect
      tRejectIconPosH = integer(getVariable("fr.requests.reject.offset.h"))
      tRejectIconPosV = (pItemHeight - tRejectIconImg.height) / 2
      tdestrect = tRejectIconRect + rect(tRejectIconPosH, tRejectIconPosV, tRejectIconPosH, tRejectIconPosV)
      tItemImg.copyPixels(tRejectIconImg, tdestrect, tRejectIconRect, [#ink: 36])
    #accepted:
      tImg = tNameWriter.render(getText("friend_request_accepted"))
      tSourceRect = tImg.rect
      tMargin = integer(getVariable("fr.requests.status.margin.h"))
      tPosH = pItemWidth - (tImg.width + tMargin)
      tPosV = (pItemHeight - tImg.height) / 2
      tdestrect = tSourceRect + rect(tPosH, tPosV, tPosH, tPosV)
      tItemImg.copyPixels(tImg, tdestrect, tImg.rect)
    #rejected:
      tImg = tNameWriter.render(getText("friend_request_declined"))
      tSourceRect = tImg.rect
      tMargin = integer(getVariable("fr.requests.status.margin.h"))
      tPosH = pItemWidth - (tImg.width + tMargin)
      tPosV = (pItemHeight - tImg.height) / 2
      tdestrect = tSourceRect + rect(tPosH, tPosV, tPosH, tPosV)
      tItemImg.copyPixels(tImg, tdestrect, tImg.rect)
    #error:
      tImg = tNameWriter.render(getText("friend_request_failed"))
      tSourceRect = tImg.rect
      tMargin = integer(getVariable("fr.requests.status.margin.h"))
      tPosH = pItemWidth - (tImg.width + tMargin)
      tPosV = (pItemHeight - tImg.height) / 2
      tdestrect = tSourceRect + rect(tPosH, tPosV, tPosH, tPosV)
      tItemImg.copyPixels(tImg, tdestrect, tImg.rect)
  end case
  return tItemImg.duplicate()
end

on renderBackgroundImage me
  if ilk(pContentList) <> #propList then
    return image(1, 1, 32)
  end if
  if pContentList.count = 0 then
    return image(1, 1, 32)
  end if
  tDarkBg = rgb(string(getVariable("fr.requests.bg.dark")))
  pItemHeight = integer(getVariable("fr.requests.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  tImage = image(pItemWidth, pContentList.count * pItemHeight, 32)
  tCurrentPosV = 0
  repeat with tIndex = 1 to (pContentList.count / 2) + 1
    tImage.fill(0, tCurrentPosV, pItemWidth, tCurrentPosV + pItemHeight, tDarkBg)
    tCurrentPosV = tCurrentPosV + (pItemHeight * 2)
  end repeat
  return tImage
end

on relayEvent me, tEvent, tLocX, tLocY
  tListIndex = (tLocY / me.pItemHeight) + 1
  tEventResult = [:]
  tEventResult[#Event] = tEvent
  if tEvent = #mouseWithin then
    return tEventResult
  end if
  if (tListIndex > me.pContentList.count) or (tListIndex < 1) then
    tEventResult[#cursor] = "cursor.arrow"
  else
    tRequest = me.pContentList[tListIndex]
    tEventResult[#request] = tRequest
    if (tLocX > integer(getVariable("fr.requests.reject.offset.h"))) and (tRequest[#state] = #pending) then
      tEventResult[#element] = #request_reject
      tEventResult[#update] = 1
      tEventResult[#cursor] = "cursor.finger"
      me.handleRequestState(tRequest[#id], #rejected)
    else
      if (tLocX > integer(getVariable("fr.requests.accept.offset.h"))) and (tRequest[#state] = #pending) then
        if threadExists(#friend_list) then
          tComponent = getThread(#friend_list).getComponent()
          if tComponent.isFriendListFull() then
            executeMessage(#alert, "console_fr_limit_exceeded_error")
            return 0
          end if
          tEventResult[#element] = #request_accept
          tEventResult[#update] = 1
          me.handleRequestState(tRequest[#id], #accepted)
        end if
      else
        tEventResult[#element] = #name
      end if
    end if
  end if
  return tEventResult
end
