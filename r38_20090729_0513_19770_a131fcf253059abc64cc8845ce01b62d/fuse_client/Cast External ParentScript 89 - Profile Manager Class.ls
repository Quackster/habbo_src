property pItemList, pTotalTimeStart

on construct me
  pLastExecutedMessage = EMPTY
  pItemList = [:]
  pItemList.sort()
  pTotalTimeStart = the milliSeconds
  return 1
end

on deconstruct me
  pItemList = [:]
  return 1
end

on create me, tTask
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return 
    end if
  end if
  if not symbolp(tTask) and not stringp(tTask) then
    return error(me, "Symbol or string expected:" && tTask, #create, #major)
  end if
  if not voidp(me.pItemList[tTask]) then
    return error(me, "Profile task already exists:" && tTask, #create, #major)
  end if
  tTaskInstance = new script("Profile Task")
  tTaskInstance.setID(tTask)
  me.pItemList[tTask] = tTaskInstance
  return 1
end

on Remove me, tTask
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return 
    end if
  end if
  if not symbolp(tTask) and not stringp(tTask) then
    return error(me, "Symbol or string expected:" && tTask, #Remove, #minor)
  end if
  if voidp(me.pItemList[tTask]) then
    return error(me, "Profile task not found:" && tTask, #Remove, #minor)
  end if
  return me.pItemList.deleteProp(tTask)
end

on GET me, tTask
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return 
    end if
  end if
  if not symbolp(tTask) and not stringp(tTask) then
    return error(me, "Symbol or string expected:" && tTask, #GET, #minor)
  end if
  if voidp(me.pItemList[tTask]) then
    return error(me, "Profile task not found:" && tTask, #GET, #minor)
  end if
  return me.pItemList[tTask]
end

on exists me, tTask
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return 
    end if
  end if
  return not voidp(me.pItemList[tTask])
end

on start me, tTask
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return 
    end if
  end if
  if not symbolp(tTask) and not stringp(tTask) then
    return error(me, "Symbol or string expected:" && tTask, #start, #minor)
  end if
  if voidp(me.pItemList[tTask]) then
    if not me.create(tTask) then
      return error(me, "Could not create task:" && tTask, #start, #minor)
    end if
  end if
  me.pItemList[tTask].start()
end

on finish me, tTask
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return 
    end if
  end if
  if not symbolp(tTask) and not stringp(tTask) then
    return error(me, "Symbol or string expected:" && tTask, #finish, #minor)
  end if
  if voidp(me.pItemList[tTask]) then
    return error(me, "Profile task not found:" && tTask, #finish, #minor)
  end if
  me.pItemList[tTask].finish()
end

on reset me
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return 
    end if
  end if
  pItemList = [:]
  pTotalTimeStart = the milliSeconds
end

on print me
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return 
    end if
  end if
  tString = EMPTY
  put me.printToText(tString)
end

on printToText me, tText
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return 
    end if
  end if
  tTime = the milliSeconds
  tSortedList = [:]
  tSortedList.sort()
  repeat with i = 1 to me.pItemList.count
    tSortedList.setaProp(me.pItemList[i].getTime(), me.pItemList[i])
  end repeat
  put "---- Profile tasks ---------------------------" & RETURN after tText
  repeat with i = 1 to tSortedList.count
    tText = tSortedList[i].print(tText)
  end repeat
  put "****" & RETURN after tText
  put "Total time since last reset : " & tTime - pTotalTimeStart & " ms" & RETURN after tText
  put "----------------------------------------------" & RETURN after tText
  return tText
end

on printToDialog me
  tText = me.printToText(EMPTY)
  if createWindow("Profile Dialog") then
    tWndObj = getWindow("Profile Dialog")
    tWndObj.setProperty(#title, "Profile")
    tWndObj.merge("habbo_basic.window")
    tWndObj.merge("profiler.window")
    tWndObj.center()
    tWriterId = getUniqueID()
    createWriter(tWriterId, getStructVariable("struct.font.plain"))
    tWndObj.getElement("alert_text").feedImage(getWriter(tWriterId).render(tText))
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcProfileDialog, me.getID(), #mouseUp)
    removeWriter(tWriterId)
  end if
end

on printToUrl me
  tText = replaceChunks(me.printToText(EMPTY), RETURN, "%0D%0A")
  gotoNetPage("http://localhost/?profile=" & tText, "_new")
end

on printToClipBoard me
  tText = me.printToText(EMPTY)
  tMemberName = getUniqueID()
  tmember = member(createMember(tMemberName, #field))
  tmember.text = tText
  tmember.copyToClipboard()
  removeMember(tMemberName)
end

on eventProcProfileDialog me, tEvent, tElemID
  if tEvent = #mouseUp then
    case tElemID of
      "close", "alert_ok":
        removeWindow("Profile Dialog")
      "reset":
        me.reset()
      "refresh":
        tText = me.printToText(EMPTY)
        tWriterId = getUniqueID()
        createWriter(tWriterId, getStructVariable("struct.font.plain"))
        tWndObj = getWindow("Profile Dialog")
        tWndObj.getElement("alert_text").feedImage(getWriter(tWriterId).render(tText))
        removeWriter(tWriterId)
      "printtourl":
        me.printToUrl()
      "copytoclipboard":
        me.printToClipBoard()
    end case
  end if
end

on handlers
  return []
end
