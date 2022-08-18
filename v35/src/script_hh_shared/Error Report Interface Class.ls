property pWindowID, pCurrentErrorIndex, pErrorLock

on construct me
  pWindowID = getText("error_report")
  pCurrentErrorIndex = 1
  pErrorLock = 0
  return 1
end

on deconstruct me
  return 1
end

on showErrors me
  if pErrorLock then
    return 1
  end if
  pErrorLock = 1
  tReportLists = me.getComponent().getErrorLists()
  if (tReportLists.count = 0) then
    pErrorLock = 0
    return 0
  end if
  if not windowExists(pWindowID) then
    createWindow(pWindowID, "habbo_full.window")
    tWndObj = getWindow(pWindowID)
    tWndObj.merge("error_report_details.window")
    tWndObj.center()
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcErrorReport, me.getID(), #mouseUp)
    tWndObj.getElement("error_report_prev").setText("<<<")
    tWndObj.getElement("error_report_next").setText(">>>")
  end if
  me.updateErrorView()
  pErrorLock = 0
end

on showPreviousError me
  tTriedErrorIndex = (pCurrentErrorIndex - 1)
  tReportList = me.getComponent().getErrorLists()
  if ((tTriedErrorIndex < 1) or (tReportList.count = 0)) then
    return 0
  end if
  pCurrentErrorIndex = tTriedErrorIndex
  me.updateErrorView()
end

on showNextError me
  tTriedErrorIndex = (pCurrentErrorIndex + 1)
  tReportList = me.getComponent().getErrorLists()
  if (tTriedErrorIndex > tReportList.count) then
    return 0
  end if
  pCurrentErrorIndex = tTriedErrorIndex
  me.updateErrorView()
end

on updateErrorView me
  tWndObj = getWindow(pWindowID)
  tIndexOfCurrentReport = pCurrentErrorIndex
  tReportList = me.getComponent().getErrorLists()
  tErrorReport = tReportList[tIndexOfCurrentReport]
  tCounts = ((pCurrentErrorIndex & "/") & tReportList.count)
  tElement = tWndObj.getElement("error_report_count")
  if (tElement <> 0) then
    tElement.setText(tCounts)
  end if
  tTexts = [:]
  tTexts["error_report_errorid"] = ("ID:" && tErrorReport[#errorId])
  tExplainText = EMPTY
  if not voidp(tErrorReport[#time]) then
    tExplainText = (tErrorReport[#time] & RETURN)
  end if
  if not voidp(tErrorReport[#errorMsgId]) then
    tExplainText = (((tExplainText & getText("error_report_trigger_message")) & ":") && tErrorReport[#errorMsgId])
  else
    if not voidp(tErrorReport[#errorMsg]) then
      tExplainText = (tExplainText & tErrorReport[#errorMsg])
    end if
  end if
  tTexts["error_report_details"] = tExplainText
  repeat with tIndex = 1 to tTexts.count
    tElementName = tTexts.getPropAt(tIndex)
    tText = tTexts[tIndex]
    if tWndObj.elementExists(tElementName) then
      tElement = tWndObj.getElement(tElementName)
      tElement.setText(tText)
    end if
  end repeat
end

on hideErrorReportWindow me
  if not windowExists(pWindowID) then
    return 0
  end if
  me.getComponent().clearErrorLists(pCurrentErrorIndex)
  pCurrentErrorIndex = 1
  tWndObj = getWindow(pWindowID)
  tWndObj.close()
end

on eventProcErrorReport me, tEvent, tElemID, tParams
  if (tEvent = #mouseUp) then
    case tElemID of
      "error_report_ok", "close":
        me.hideErrorReportWindow()
      "error_report_prev":
        me.showPreviousError()
      "error_report_next":
        me.showNextError()
    end case
  end if
end
