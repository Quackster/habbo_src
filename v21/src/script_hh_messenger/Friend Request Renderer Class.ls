property pRequestList, pRequestsPerPage, pWindowID, pCurrentPageIndex, pPageCount

on construct me
  pRequestList = []
  pWindowID = EMPTY
  pCurrentPageIndex = 1
  pRequestsPerPage = 5
  pPageCount = 0
  return 1
end

on deconstruct me
  return 1
end

on Init me, tWindowName
  pWindowID = tWindowName
  pCurrentPageIndex = 1
  me.updateView()
end

on showNextPage me
  pCurrentPageIndex = (pCurrentPageIndex + 1)
  me.updateView()
end

on showPreviousPage me
  pCurrentPageIndex = (pCurrentPageIndex - 1)
  me.updateView()
end

on clearRequests me
  pRequestList = []
  pCurrentPageIndex = 1
end

on isBuddyListFull me
  tListLimits = getThread(#messenger).getInterface().getBuddyListLimits()
  tLimit = tListLimits[#own]
  tBuddyData = getThread(#messenger).getComponent().getBuddyData()
  tFriendsAmount = tBuddyData[#buddies].count
  return not (tFriendsAmount < tLimit)
end

on updateView me
  if not windowExists(pWindowID) then
    return 0
  end if
  if (pCurrentPageIndex < 1) then
    return 0
  end if
  tWindowObj = getWindow(pWindowID)
  tComponent = getThread(#messenger).getComponent()
  tRequestCount = tComponent.getRequestCount()
  pPageCount = (tRequestCount / pRequestsPerPage)
  if ((tRequestCount mod pRequestsPerPage) > 0) then
    pPageCount = (pPageCount + 1)
  end if
  pRequestList = tComponent.getRequestSet(pCurrentPageIndex, pRequestsPerPage)
  repeat with tScreenIndex = 1 to pRequestsPerPage
    me.updateListItemView(tScreenIndex)
  end repeat
  tNextElem = tWindowObj.getElement("console_fr_next")
  tPrevElem = tWindowObj.getElement("console_fr_previous")
  if (pPageCount > pCurrentPageIndex) then
    tNextElem.setProperty(#visible, 1)
  else
    tNextElem.setProperty(#visible, 0)
  end if
  if (pCurrentPageIndex = 1) then
    tPrevElem.setProperty(#visible, 0)
  else
    tPrevElem.setProperty(#visible, 1)
  end if
  tPendingRequestCount = tComponent.getPendingRequestCount()
  tOptionsElem = tWindowObj.getElement("friend_request_options_button")
  if (tPendingRequestCount > pRequestsPerPage) then
    tOptionsElem.setProperty(#visible, 1)
  else
    tOptionsElem.setProperty(#visible, 0)
  end if
  return 1
end

on updateListItemView me, tItemNumber
  if not windowExists(pWindowID) then
    return 0
  end if
  tWindowObj = getWindow(pWindowID)
  tNameElem = tWindowObj.getElement(("request_name" & tItemNumber))
  tDecisionElem = tWindowObj.getElement(("request_decision" & tItemNumber))
  tAcceptElem = tWindowObj.getElement(("request_accept" & tItemNumber))
  tDeclineElem = tWindowObj.getElement(("request_decline" & tItemNumber))
  if (tItemNumber <= pRequestList.count) then
    tRequest = pRequestList[tItemNumber]
    tNameElem.setProperty(#visible, 1)
    tNameElem.setText(tRequest[#name])
    tstate = pRequestList[tItemNumber].getaProp(#state)
    if (tstate = #pending) then
      tAcceptElem.setProperty(#visible, 1)
      tDeclineElem.setProperty(#visible, 1)
      tDecisionElem.setProperty(#visible, 0)
    else
      tAcceptElem.setProperty(#visible, 0)
      tDeclineElem.setProperty(#visible, 0)
      tDecisionElem.setProperty(#visible, 1)
      case tstate of
        #accepted:
          tDecisionElem.setText(getText("friend_request_accepted"))
        #declined:
          tDecisionElem.setText(getText("friend_request_declined"))
        #failed:
          tDecisionElem.setText(getText("friend_request_failed"))
        #sent:
          tDecisionElem.setProperty(#visible, 0)
        otherwise:
          error(me, "Unknown request state", #updateListItemView, #minor)
      end case
    end if
  else
    tNameElem.setProperty(#visible, 0)
    tDecisionElem.setProperty(#visible, 0)
    tAcceptElem.setProperty(#visible, 0)
    tDeclineElem.setProperty(#visible, 0)
  end if
end

on confirmRequest me, tItemNo, tAccept
  tstate = pRequestList[tItemNo].getaProp(#state)
  if (tstate <> #pending) then
    return error(me, "Friend request already confirmed.", #confirm, #major)
  end if
  tComponent = getThread(#messenger).getComponent()
  tRequestId = pRequestList[tItemNo].getaProp(#id)
  if tAccept then
    if me.isBuddyListFull() then
      executeMessage(#alert, "console_fr_limit_exceeded_error")
      return 0
    end if
    tComponent.acceptRequest(tRequestId)
  else
    tComponent.declineRequest(tRequestId)
  end if
  me.updateView()
  return 1
end

on getUserId me, tItemNo
  if ((tItemNo < 1) or (tItemNo > pRequestList.count)) then
    return 0
  end if
  tUserID = pRequestList[tItemNo].getaProp(#webID)
  return tUserID
end
