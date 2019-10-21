property pRequestList, pUnfinishedSelectionExists, pCurrentPageIndex, pRequestsPerPage, pWindowID, pUncheckedMember, pCheckedMember

on construct me 
  pRequestList = []
  pRequestPerPage = 10
  pCheckedMember = "button.checkbox.white.on"
  pUncheckedMember = "button.checkbox.white.off"
  pWindowID = ""
  pCurrentPageIndex = 1
  pRequestsPerPage = 10
  pUnfinishedSelectionExists = 0
  return TRUE
end

on deconstruct me 
  return TRUE
end

on define me, tWindowName, tRequestList 
  pWindowID = tWindowName
  pCurrentPageIndex = 1
  pRequestList = []
  tRequestNo = 1
  repeat while tRequestNo <= tRequestList.count
    tRequest = tRequestList.getAt(tRequestNo)
    pRequestList.add([#name:tRequest.getAt(#name), #id:tRequest.getAt(#id), #selected:0])
    tRequestNo = (1 + tRequestNo)
  end repeat
  me.updateView()
end

on unfinishedSelectionExists me 
  return(pUnfinishedSelectionExists)
end

on showNextPage me 
  pCurrentPageIndex = (pCurrentPageIndex + 1)
  tPagesAvailable = (pRequestList.count / pRequestsPerPage)
  if (pRequestList.count mod pRequestsPerPage) > 0 then
    tPagesAvailable = (tPagesAvailable + 1)
  end if
  if pCurrentPageIndex > tPagesAvailable then
    pCurrentPageIndex = tPagesAvailable
  end if
  me.updateView(pCurrentPageIndex)
end

on showPreviousPage me 
  pCurrentPageIndex = (pCurrentPageIndex - 1)
  if pCurrentPageIndex < 1 then
    pCurrentPageIndex = 1
  end if
  me.updateView(pCurrentPageIndex)
end

on getSelectedRequests me 
  return(me.getMaskedRequests(1))
end

on getRefusedRequests me 
  return(me.getMaskedRequests(0))
end

on clearRequests me 
  pRequestList = []
  pCurrentPageIndex = 1
  pUnfinishedSelectionExists = 0
end

on itemEvent me, tItemNumber 
  me.toggleItemSelection(tItemNumber)
end

on invertSelections me 
  tRequestNo = 1
  repeat while tRequestNo <= pRequestList.count
    pRequestList.getAt(tRequestNo).setAt(#selected, not pRequestList.getAt(tRequestNo).getAt(#selected))
    tRequestNo = (1 + tRequestNo)
  end repeat
  me.updateView()
  pUnfinishedSelectionExists = 1
end

on getAcceptedList me 
  tList = []
  repeat while pRequestList <= undefined
    tItem = getAt(undefined, undefined)
    if tItem.getAt(#selected) then
      tList.add(tItem)
    end if
  end repeat
  return(tList)
end

on getDeclinedList me 
  tList = []
  repeat while pRequestList <= undefined
    tItem = getAt(undefined, undefined)
    if not tItem.getAt(#selected) then
      tList.add(tItem)
    end if
  end repeat
  return(tList)
end

on toggleItemSelection me, tItemNumber 
  tRequestIndex = (((pCurrentPageIndex - 1) * pRequestsPerPage) + tItemNumber)
  if tRequestIndex > pRequestList.count then
    return FALSE
  end if
  tCurrentlySelected = pRequestList.getAt(tRequestIndex).getAt(#selected)
  if tCurrentlySelected then
    pRequestList.getAt(tRequestIndex).setAt(#selected, 0)
  else
    pRequestList.getAt(tRequestIndex).setAt(#selected, 1)
    if not me.isSelectedAmountValid() then
      executeMessage(#alert, "console_fr_limit_exceeded_error")
      pRequestList.getAt(tRequestIndex).setAt(#selected, 0)
    end if
  end if
  me.updateListItemView(tItemNumber)
  pUnfinishedSelectionExists = 1
end

on isSelectedAmountValid me 
  tListLimits = getThread(#messenger).getInterface().getBuddyListLimits()
  tLimit = tListLimits.getAt(#own)
  tBuddyData = getThread(#messenger).getComponent().getBuddyData()
  tFriendsAmount = tBuddyData.getAt(#buddies).count
  tSelectedAmount = me.getAcceptedList().count
  tTotalCount = (tFriendsAmount + tSelectedAmount)
  if tTotalCount > tLimit then
    return FALSE
  else
    return TRUE
  end if
end

on getMaskedRequests me, tMask 
  tList = []
  repeat while pRequestList <= undefined
    tRequest = getAt(undefined, tMask)
    if (tRequest.getAt(#selected) = tMask) then
      tList.add(tRequest.getAt(#name))
    end if
  end repeat
  return(tList)
end

on updateView me, tRequestPageIndex 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tWindowObj = getWindow(pWindowID)
  if voidp(tRequestPageIndex) then
    tRequestPageIndex = pCurrentPageIndex
  end if
  tPagesAvailable = (pRequestList.count / pRequestsPerPage)
  if (pRequestList.count mod pRequestsPerPage) > 0 then
    tPagesAvailable = (tPagesAvailable + 1)
  end if
  if tRequestPageIndex < 1 then
    tRequestPageOffset = 1
  else
    if tRequestPageIndex > tPagesAvailable then
      tRequestPageIndex = tPagesAvailable
    end if
  end if
  tScreenIndex = 1
  repeat while tScreenIndex <= pRequestsPerPage
    me.updateListItemView(tScreenIndex)
    tScreenIndex = (1 + tScreenIndex)
  end repeat
  tNextElem = tWindowObj.getElement("console_fr_next")
  tPrevElem = tWindowObj.getElement("console_fr_previous")
  if (tRequestPageIndex = tPagesAvailable) then
    tNextElem.setProperty(#visible, 0)
  else
    tNextElem.setProperty(#visible, 1)
  end if
  if (tRequestPageIndex = 1) then
    tPrevElem.setProperty(#visible, 0)
  else
    tPrevElem.setProperty(#visible, 1)
  end if
  tIndexElem = tWindowObj.getElement("fr_pages")
  tIndexElem.setText(tRequestPageIndex & "/" & tPagesAvailable)
  pCurrentPageIndex = tRequestPageIndex
end

on updateListItemView me, tItemNumber 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tWindowObj = getWindow(pWindowID)
  tFirstIndexOnPage = (((pCurrentPageIndex - 1) * pRequestsPerPage) + 1)
  tRequestIndex = ((tItemNumber + tFirstIndexOnPage) - 1)
  tCheckElemID = "fr_check_" & tItemNumber
  tCheckElem = tWindowObj.getElement(tCheckElemID)
  tNameElemID = "fr_name_" & tItemNumber
  tNameElem = tWindowObj.getElement(tNameElemID)
  if tRequestIndex <= pRequestList.count then
    tRequest = pRequestList.getAt(tRequestIndex)
    tCheckMember = pUncheckedMember
    if tRequest.getAt(#selected) then
      tCheckMember = pCheckedMember
    end if
    tCheckElem.setProperty(#visible, 1)
    tNameElem.setProperty(#visible, 1)
    tCheckElem.setProperty(#member, tCheckMember)
    tNameElem.setText(tRequest.getAt(#name))
  else
    tCheckElem.setProperty(#visible, 0)
    tNameElem.setProperty(#visible, 0)
  end if
end
