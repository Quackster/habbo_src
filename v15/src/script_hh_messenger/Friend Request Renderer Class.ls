property pRequestList, pRequestsPerPage, pCheckedMember, pUncheckedMember, pWindowID, pCurrentPageIndex, pUnfinishedSelectionExists

on construct me
  pRequestList = []
  pRequestPerPage = 10
  pCheckedMember = "button.checkbox.white.on"
  pUncheckedMember = "button.checkbox.white.off"
  pWindowID = EMPTY
  pCurrentPageIndex = 1
  pRequestsPerPage = 10
  pUnfinishedSelectionExists = 0
  return 1
end

on deconstruct me
  return 1
end

on define me, tWindowName, tRequestList
  pWindowID = tWindowName
  pCurrentPageIndex = 1
  pRequestList = []
  repeat with tRequestNo = 1 to tRequestList.count
    tRequest = tRequestList[tRequestNo]
    pRequestList.add([#name: tRequest[#name], #id: tRequest[#id], #webID: tRequest[#webID], #selected: 0])
  end repeat
  me.updateView()
end

on unfinishedSelectionExists me
  return pUnfinishedSelectionExists
end

on showNextPage me
  pCurrentPageIndex = (pCurrentPageIndex + 1)
  tPagesAvailable = (pRequestList.count / pRequestsPerPage)
  if ((pRequestList.count mod pRequestsPerPage) > 0) then
    tPagesAvailable = (tPagesAvailable + 1)
  end if
  if (pCurrentPageIndex > tPagesAvailable) then
    pCurrentPageIndex = tPagesAvailable
  end if
  me.updateView(pCurrentPageIndex)
end

on showPreviousPage me
  pCurrentPageIndex = (pCurrentPageIndex - 1)
  if (pCurrentPageIndex < 1) then
    pCurrentPageIndex = 1
  end if
  me.updateView(pCurrentPageIndex)
end

on getSelectedRequests me
  return me.getMaskedRequests(1)
end

on clearRequests me
  pRequestList = []
  pCurrentPageIndex = 1
  pUnfinishedSelectionExists = 0
end

on itemEvent me, tItemNumber
  me.toggleItemSelection(tItemNumber)
end

on getSelectedList me
  tList = []
  repeat with tItem in pRequestList
    if tItem[#selected] then
      tList.add(tItem)
    end if
  end repeat
  return tList
end

on getDeselectedList me
  tList = []
  repeat with tItem in pRequestList
    if not tItem[#selected] then
      tList.add(tItem)
    end if
  end repeat
  return tList
end

on getUserIdForSelectionNo me, tSelectionNo
  tRequestIndex = integer((((pCurrentPageIndex - 1) * pRequestsPerPage) + tSelectionNo))
  tUserID = pRequestList[tRequestIndex][#webID]
  return tUserID
end

on toggleItemSelection me, tItemNumber
  tRequestIndex = integer((((pCurrentPageIndex - 1) * pRequestsPerPage) + tItemNumber))
  if (tRequestIndex > pRequestList.count) then
    return 0
  end if
  tCurrentlySelected = pRequestList[tRequestIndex][#selected]
  if tCurrentlySelected then
    pRequestList[tRequestIndex][#selected] = 0
  else
    pRequestList[tRequestIndex][#selected] = 1
    if not me.isSelectedAmountValid() then
      executeMessage(#alert, "console_fr_limit_exceeded_error")
      pRequestList[tRequestIndex][#selected] = 0
    end if
  end if
  me.updateListItemView(tItemNumber)
  pUnfinishedSelectionExists = 1
end

on setAllRequestSelectionsTo me, tValue
  if voidp(tValue) then
    tValue = 0
  end if
  repeat with tItemNo = 1 to pRequestList.count
    pRequestList[tItemNo][#selected] = tValue
  end repeat
end

on isSelectedAmountValid me, tInverted
  if voidp(tInverted) then
    tInverted = 0
  end if
  tListLimits = getThread(#messenger).getInterface().getBuddyListLimits()
  tLimit = tListLimits[#own]
  tBuddyData = getThread(#messenger).getComponent().getBuddyData()
  tFriendsAmount = tBuddyData[#buddies].count
  if tInverted then
    tSelectedAmount = me.getDeselectedList().count
  else
    tSelectedAmount = me.getSelectedList().count
  end if
  tTotalCount = (tFriendsAmount + tSelectedAmount)
  if (tTotalCount > tLimit) then
    return 0
  else
    return 1
  end if
end

on getMaskedRequests me, tMask
  tList = []
  repeat with tRequest in pRequestList
    if (tRequest[#selected] = tMask) then
      tList.add(tRequest[#name])
    end if
  end repeat
  return tList
end

on updateView me, tRequestPageIndex
  if not windowExists(pWindowID) then
    return 0
  end if
  tWindowObj = getWindow(pWindowID)
  if voidp(tRequestPageIndex) then
    tRequestPageIndex = pCurrentPageIndex
  end if
  tPagesAvailable = (pRequestList.count / pRequestsPerPage)
  if ((pRequestList.count mod pRequestsPerPage) > 0) then
    tPagesAvailable = (tPagesAvailable + 1)
  end if
  if (tRequestPageIndex < 1) then
    tRequestPageOffset = 1
  else
    if (tRequestPageIndex > tPagesAvailable) then
      tRequestPageIndex = tPagesAvailable
    end if
  end if
  repeat with tScreenIndex = 1 to pRequestsPerPage
    me.updateListItemView(tScreenIndex)
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
  tIndexElem.setText(((tRequestPageIndex & "/") & tPagesAvailable))
  pCurrentPageIndex = tRequestPageIndex
end

on updateListItemView me, tItemNumber
  if not windowExists(pWindowID) then
    return 0
  end if
  tWindowObj = getWindow(pWindowID)
  tFirstIndexOnPage = (((pCurrentPageIndex - 1) * pRequestsPerPage) + 1)
  tRequestIndex = ((tItemNumber + tFirstIndexOnPage) - 1)
  tCheckElemID = ("fr_check_" & tItemNumber)
  tCheckElem = tWindowObj.getElement(tCheckElemID)
  tNameElemID = ("fr_name_" & tItemNumber)
  tNameElem = tWindowObj.getElement(tNameElemID)
  if (tRequestIndex <= pRequestList.count) then
    tRequest = pRequestList[tRequestIndex]
    tCheckMember = pUncheckedMember
    if tRequest[#selected] then
      tCheckMember = pCheckedMember
    end if
    tCheckElem.setProperty(#visible, 1)
    tNameElem.setProperty(#visible, 1)
    tCheckElem.setProperty(#member, tCheckMember)
    tNameElem.setText(tRequest[#name])
  else
    tCheckElem.setProperty(#visible, 0)
    tNameElem.setProperty(#visible, 0)
  end if
end
