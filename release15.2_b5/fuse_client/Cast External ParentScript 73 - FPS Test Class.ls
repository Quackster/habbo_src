property pWndID, pTimerA, pTimerB, pFrames, pCurrMs

on construct me
  pWndID = "PerfTest"
  pTimerA = the milliSeconds
  pTimerB = the milliSeconds
  pFrames = 0
  pCurrMs = 0
  if not createWindow(pWndID) then
    return 0
  end if
  tWndObj = getWindow(pWndID)
  tWndObj.merge("performance.window")
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
  tWndObj.getElement("perf_per_frm").setEdit(0)
  tWndObj.getElement("perf_total").setEdit(0)
  tWndObj.getElement("close").setEdit(0)
  tWndObj.getElement("close").setText("x")
  return receiveUpdate(me.getID())
end

on deconstruct me
  removeUpdate(me.getID())
  removeWindow(pWndID)
  return 1
end

on update me
  pFrames = (pFrames + 1) mod the frameTempo
  tTime = the milliSeconds - pTimerA
  tWndObj = getWindow(pWndID)
  tWndObj.getElement("perf_per_frm").setText(tTime && "ms.")
  if pFrames = 0 then
    tCurrMs = the milliSeconds - pTimerB
    if tCurrMs <> pCurrMs then
      pCurrMs = tCurrMs
      tWndObj.getElement("perf_total").setText(pCurrMs && "ms.")
    end if
    pTimerB = the milliSeconds
  end if
  pTimerA = the milliSeconds
end

on eventProc me, tEvent, tElemID, tParam
  if tElemID = "close" then
    return removeObject(me.getID())
  else
    return 0
  end if
end
