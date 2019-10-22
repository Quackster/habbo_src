property pCurrentPageIndex, pWindowID, pRequestsPerPage, pPageCount, pRequestList

on construct me 
  pRequestList = []
  pWindowID = ""
  pCurrentPageIndex = 1
  pRequestsPerPage = 5
  pPageCount = 0
  return TRUE
end

on deconstruct me 
  return TRUE
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
  tOwnLimit = tListLimits.getAt(#own)
  tBuddyData = getThread(#messenger).getComponent().getBuddyData()
  tBuddyCount = tBuddyData.getAt(#buddies).count
  if (tOwnLimit = -1) or tBuddyCount < tOwnLimit then
    return FALSE
  end if
  return TRUE
end

on updateView me 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  if pCurrentPageIndex < 1 then
    return FALSE
  end if
  tWindowObj = getWindow(pWindowID)
  tComponent = getThread(#messenger).getComponent()
  tRequestCount = tComponent.getRequestCount()
  pPageCount = (tRequestCount / pRequestsPerPage)
  if (tRequestCount mod pRequestsPerPage) > 0 then
    pPageCount = (pPageCount + 1)
  end if
  pRequestList = tComponent.getRequestSet(pCurrentPageIndex, pRequestsPerPage)
  tScreenIndex = 1
  repeat while tScreenIndex <= pRequestsPerPage
    me.updateListItemView(tScreenIndex)
    tScreenIndex = (1 + tScreenIndex)
  end repeat
  tNextElem = tWindowObj.getElement("console_fr_next")
  tPrevElem = tWindowObj.getElement("console_fr_previous")
  if pPageCount > pCurrentPageIndex then
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
  if tPendingRequestCount > pRequestsPerPage then
    tOptionsElem.setProperty(#visible, 1)
  else
    tOptionsElem.setProperty(#visible, 0)
  end if
  return TRUE
end

on updateListItemView me, tItemNumber 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tWindowObj = getWindow(pWindowID)
  tNameElem = tWindowObj.getElement("request_name" & tItemNumber)
  tDecisionElem = tWindowObj.getElement("request_decision" & tItemNumber)
  tAcceptElem = tWindowObj.getElement("request_accept" & tItemNumber)
  tDeclineElem = tWindowObj.getElement("request_decline" & tItemNumber)
  if tItemNumber <= pRequestList.count then
    tRequest = pRequestList.getAt(tItemNumber)
    tNameElem.setProperty(#visible, 1)
    tNameElem.setText(tRequest.getAt(#name))
    tstate = pRequestList.getAt(tItemNumber).getaProp(#state)
    if (tstate = #pending) then
      tAcceptElem.setProperty(#visible, 1)
      tDeclineElem.setProperty(#visible, 1)
      tDecisionElem.setProperty(#visible, 0)
    else
      tAcceptElem.setProperty(#visible, 0)
      tDeclineElem.setProperty(#visible, 0)
      tDecisionElem.setProperty(#visible, 1)
      if (tstate = #accepted) then
        tDecisionElem.setText(getText("friend_request_accepted"))
      else
        if (tstate = #declined) then
          tDecisionElem.setText(getText("friend_request_declined"))
        else
          if (tstate = #failed) then
            tDecisionElem.setText(getText("friend_request_failed"))
          else
            if (tstate = #sent) then
              tDecisionElem.setProperty(#visible, 0)
            else
              error(me, "Unknown request state", #updateListItemView, #minor)
            end if
          end if
        end if
      end if
    end if
  else
    tNameElem.setProperty(#visible, 0)
    tDecisionElem.setProperty(#visible, 0)
    tAcceptElem.setProperty(#visible, 0)
    tDeclineElem.setProperty(#visible, 0)
  end if
end

on confirmRequest me, tItemNo, tAccept 
  tstate = pRequestList.getAt(tItemNo).getaProp(#state)
  if tstate <> #pending then
    return(error(me, "Friend request already confirmed.", #confirm, #major))
  end if
  tComponent = getThread(#messenger).getComponent()
  tRequestId = pRequestList.getAt(tItemNo).getaProp(#id)
  if tAccept then
    if me.isBuddyListFull() then
      executeMessage(#alert, "console_fr_limit_exceeded_error")
      return FALSE
    end if
    tComponent.acceptRequest(tRequestId)
  else
    tComponent.declineRequest(tRequestId)
  end if
  me.updateView()
  return TRUE
end

on getUserId me, tItemNo 
  if tItemNo < 1 or tItemNo > pRequestList.count then
    return FALSE
  end if
  tUserID = pRequestList.getAt(tItemNo).getaProp(#webID)
  return(tUserID)
end
