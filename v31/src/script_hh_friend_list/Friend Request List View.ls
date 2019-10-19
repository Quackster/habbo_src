on construct(me)
  pSelectedFriendID = void()
  pContentList = []
  pContentList.sort()
  pWriterIdPlain = getUniqueID()
  tPlain = getStructVariable("struct.font.plain")
  tMetrics = [#font:tPlain.getaProp(#font), #fontStyle:tPlain.getaProp(#fontStyle), #color:rgb("#111111")]
  createWriter(pWriterIdPlain, tMetrics)
  pItemHeight = integer(getVariable("fr.requests.item.height"))
  pItemWidth = integer(getVariable("fr.list.panel.width"))
  pListImg = image(pItemWidth, 0, 32)
  pEmptyListText = getText("friend_list_no_requests")
  exit
end

on deconstruct(me)
  pListImg = void()
  removeWriter(pWriterIdPlain)
  exit
end

on setListData(me, tdata)
  pContentList = []
  pContentList.sort()
  tNo = 1
  repeat while tNo <= tdata.count
    tRequest = tdata.getAt(tNo)
    tRequestId = string(tRequest.getAt(#id))
    pContentList.setAt(tRequestId, tRequest)
    tNo = 1 + tNo
  end repeat
  exit
end

on cleanUp(me)
  tNewList = []
  tNewList.sort()
  tIndex = 1
  repeat while tIndex <= pContentList.count
    tRequest = pContentList.getAt(tIndex)
    if tRequest.getAt(#state) = #pending then
      tNewList.setAt(tRequest.getAt(#id), tRequest)
    end if
    tIndex = 1 + tIndex
  end repeat
  me.setListData(tNewList.duplicate())
  pListImg = image(pItemWidth, 0, 32)
  tIndex = 1
  repeat while tIndex <= tNewList.count
    tRequest = tNewList.getAt(tIndex)
    tRequestId = string(tRequest.getAt(#id))
    tPosV = tIndex - 1 * me.pItemHeight
    tRequestImg = me.renderRequestItem(tRequest)
    pListImg = me.insertImageTo(tRequestImg, pListImg.duplicate(), tPosV)
    tIndex = 1 + tIndex
  end repeat
  exit
end

on addRequest(me, tRequest)
  if ilk(tRequest) <> #propList then
    return(0)
  end if
  tRequestId = string(tRequest.getAt(#id))
  pContentList.setAt(tRequestId, tRequest)
  tIndex = pContentList.findPos(tRequestId)
  tPosV = tIndex - 1 * me.pItemHeight
  tRequestImg = me.renderRequestItem(tRequest)
  pListImg = me.insertImageTo(tRequestImg, pListImg.duplicate(), tPosV)
  exit
end

on handleRequestState(me, tRequestId, tstate)
  if pContentList.findPos(string(tRequestId)) = void() then
    return(0)
  end if
  tRequest = pContentList.getAt(string(tRequestId))
  tRequest.setAt(#state, tstate)
  pContentList.setAt(tRequestId, tRequest)
  tIndex = pContentList.findPos(tRequestId)
  tPosV = tIndex - 1 * me.pItemHeight
  tRequestImg = me.renderRequestItem(tRequest)
  pListImg = me.updateImagePart(tRequestImg, pListImg.duplicate(), tPosV)
  exit
end

on handleAll(me, tstate)
  tIndex = 1
  repeat while tIndex <= pContentList.count
    tRequest = pContentList.getAt(tIndex)
    if tRequest.getAt(#state) = #pending then
      tRequest.setAt(#state, tstate)
      pContentList.setAt(string(tRequest.getAt(#id)), tRequest)
      tPosV = tIndex - 1 * me.pItemHeight
      tRequestImg = me.renderRequestItem(tRequest)
      pListImg = me.updateImagePart(tRequestImg, pListImg.duplicate(), tPosV)
    end if
    tIndex = 1 + tIndex
  end repeat
  exit
end

on renderRequestItem(me, tRequestData)
  tNameWriter = getWriter(pWriterIdPlain)
  tItemImg = image(pItemWidth, pItemHeight, 32)
  tName = tRequestData.getAt(#name)
  tNameImg = tNameWriter.render(tName)
  tSourceRect = tNameImg.rect
  tNamePosH = integer(getVariable("fr.requests.name.offset.h"))
  tNamePosV = pItemHeight - tNameImg.height / 2
  tdestrect = tSourceRect + rect(tNamePosH, tNamePosV, tNamePosH, tNamePosV)
  tItemImg.copyPixels(tNameImg, tdestrect, tSourceRect)
  if me = #pending then
    tAcceptIconImg = getMember(getVariable("fr.requests.accept.icon")).image
    tAcceptIconRect = tAcceptIconImg.rect
    tAcceptIconPosH = integer(getVariable("fr.requests.accept.offset.h"))
    tAcceptIconPosV = pItemHeight - tAcceptIconImg.height / 2
    tdestrect = tAcceptIconRect + rect(tAcceptIconPosH, tAcceptIconPosV, tAcceptIconPosH, tAcceptIconPosV)
    tItemImg.copyPixels(tAcceptIconImg, tdestrect, tAcceptIconRect, [#ink:36])
    tRejectIconImg = getMember(getVariable("fr.requests.reject.icon")).image
    tRejectIconRect = tAcceptIconImg.rect
    tRejectIconPosH = integer(getVariable("fr.requests.reject.offset.h"))
    tRejectIconPosV = pItemHeight - tRejectIconImg.height / 2
    tdestrect = tRejectIconRect + rect(tRejectIconPosH, tRejectIconPosV, tRejectIconPosH, tRejectIconPosV)
    tItemImg.copyPixels(tRejectIconImg, tdestrect, tRejectIconRect, [#ink:36])
  else
    if me = #accepted then
      tImg = tNameWriter.render(getText("friend_request_accepted"))
      tSourceRect = tImg.rect
      tMargin = integer(getVariable("fr.requests.status.margin.h"))
      tPosH = pItemWidth - tImg.width + tMargin
      tPosV = pItemHeight - tImg.height / 2
      tdestrect = tSourceRect + rect(tPosH, tPosV, tPosH, tPosV)
      tItemImg.copyPixels(tImg, tdestrect, tImg.rect)
    else
      if me = #rejected then
        tImg = tNameWriter.render(getText("friend_request_declined"))
        tSourceRect = tImg.rect
        tMargin = integer(getVariable("fr.requests.status.margin.h"))
        tPosH = pItemWidth - tImg.width + tMargin
        tPosV = pItemHeight - tImg.height / 2
        tdestrect = tSourceRect + rect(tPosH, tPosV, tPosH, tPosV)
        tItemImg.copyPixels(tImg, tdestrect, tImg.rect)
      else
        if me = #error then
          tImg = tNameWriter.render(getText("friend_request_failed"))
          tSourceRect = tImg.rect
          tMargin = integer(getVariable("fr.requests.status.margin.h"))
          tPosH = pItemWidth - tImg.width + tMargin
          tPosV = pItemHeight - tImg.height / 2
          tdestrect = tSourceRect + rect(tPosH, tPosV, tPosH, tPosV)
          tItemImg.copyPixels(tImg, tdestrect, tImg.rect)
        end if
      end if
    end if
  end if
  return(tItemImg.duplicate())
  exit
end

on renderBackgroundImage(me)
  if ilk(pContentList) <> #propList then
    return(image(1, 1, 32))
  end if
  if pContentList.count = 0 then
    return(image(1, 1, 32))
  end if
  tDarkBg = rgb(string(getVariable("fr.requests.bg.dark")))
  pItemHeight = integer(getVariable("fr.requests.item.height"))
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
  exit
end

on relayEvent(me, tEvent, tLocX, tLocY)
  tListIndex = tLocY / me.pItemHeight + 1
  tEventResult = []
  tEventResult.setAt(#Event, tEvent)
  if tEvent = #mouseWithin then
    return(tEventResult)
  end if
  if tListIndex > me.count(#pContentList) or tListIndex < 1 then
    tEventResult.setAt(#cursor, "cursor.arrow")
  else
    tRequest = me.getProp(#pContentList, tListIndex)
    tEventResult.setAt(#request, tRequest)
    if tLocX > integer(getVariable("fr.requests.reject.offset.h")) and tRequest.getAt(#state) = #pending then
      tEventResult.setAt(#element, #request_reject)
      tEventResult.setAt(#update, 1)
      tEventResult.setAt(#cursor, "cursor.finger")
      me.handleRequestState(tRequest.getAt(#id), #rejected)
    else
      if tLocX > integer(getVariable("fr.requests.accept.offset.h")) and tRequest.getAt(#state) = #pending then
        if threadExists(#friend_list) then
          tComponent = getThread(#friend_list).getComponent()
          if tComponent.isFriendListFull() then
            executeMessage(#alert, "console_fr_limit_exceeded_error")
            return(0)
          end if
          tEventResult.setAt(#element, #request_accept)
          tEventResult.setAt(#update, 1)
          me.handleRequestState(tRequest.getAt(#id), #accepted)
        end if
      else
        tEventResult.setAt(#element, #name)
      end if
    end if
  end if
  return(tEventResult)
  exit
end