on construct(me)
  pLastExecutedMessage = ""
  pItemList = []
  pItemList.sort()
  pTotalTimeStart = the milliSeconds
  return(1)
  exit
end

on deconstruct(me)
  pItemList = []
  return(1)
  exit
end

on create(me, tTask)
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  if not symbolp(tTask) and not stringp(tTask) then
    return(error(me, "Symbol or string expected:" && tTask, #create, #major))
  end if
  if not voidp(me.getProp(#pItemList, tTask)) then
    return(error(me, "Profile task already exists:" && tTask, #create, #major))
  end if
  tTaskInstance = ["Profile Task"]
  tTaskInstance.setID(tTask)
  me.setProp(#pItemList, tTask, tTaskInstance)
  return(1)
  exit
end

on Remove(me, tTask)
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  if not symbolp(tTask) and not stringp(tTask) then
    return(error(me, "Symbol or string expected:" && tTask, #Remove, #minor))
  end if
  if voidp(me.getProp(#pItemList, tTask)) then
    return(error(me, "Profile task not found:" && tTask, #Remove, #minor))
  end if
  return(me.deleteProp(tTask))
  exit
end

on GET(me, tTask)
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  if not symbolp(tTask) and not stringp(tTask) then
    return(error(me, "Symbol or string expected:" && tTask, #GET, #minor))
  end if
  if voidp(me.getProp(#pItemList, tTask)) then
    return(error(me, "Profile task not found:" && tTask, #GET, #minor))
  end if
  return(me.getProp(#pItemList, tTask))
  exit
end

on exists(me, tTask)
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  return(not voidp(me.getProp(#pItemList, tTask)))
  exit
end

on start(me, tTask)
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  if not symbolp(tTask) and not stringp(tTask) then
    return(error(me, "Symbol or string expected:" && tTask, #start, #minor))
  end if
  if voidp(me.getProp(#pItemList, tTask)) then
    if not me.create(tTask) then
      return(error(me, "Could not create task:" && tTask, #start, #minor))
    end if
  end if
  me.getPropRef(#pItemList, tTask).start()
  exit
end

on finish(me, tTask)
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  if not symbolp(tTask) and not stringp(tTask) then
    return(error(me, "Symbol or string expected:" && tTask, #finish, #minor))
  end if
  if voidp(me.getProp(#pItemList, tTask)) then
    return(error(me, "Profile task not found:" && tTask, #finish, #minor))
  end if
  me.getPropRef(#pItemList, tTask).finish()
  exit
end

on reset(me)
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  pItemList = []
  pTotalTimeStart = the milliSeconds
  exit
end

on print(me)
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  tString = ""
  put(me.printToText(tString))
  exit
end

on printToText(me, tText)
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  tTime = the milliSeconds
  tSortedList = []
  tSortedList.sort()
  i = 1
  repeat while i <= me.count(#pItemList)
    tSortedList.setaProp(me.getAt(i).getTime(), me.getAt(i))
    i = 1 + i
  end repeat
  i = 1
  repeat while i <= tSortedList.count
    tText = tSortedList.getAt(i).print(tText)
    i = 1 + i
  end repeat
  return(tText)
  exit
end

on printToDialog(me)
  tText = me.printToText("")
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
  exit
end

on printToUrl(me)
  tText = replaceChunks(me.printToText(""), "\r", "%0D%0A")
  gotoNetPage("http://localhost/?profile=" & tText, "_new")
  exit
end

on eventProcProfileDialog(me, tEvent, tElemID)
  if tEvent = #mouseUp then
    if me <> "close" then
      if me = "alert_ok" then
        removeWindow("Profile Dialog")
      else
        if me = "reset" then
          me.reset()
        else
          if me = "refresh" then
            tText = me.printToText("")
            tWriterId = getUniqueID()
            createWriter(tWriterId, getStructVariable("struct.font.plain"))
            tWndObj = getWindow("Profile Dialog")
            tWndObj.getElement("alert_text").feedImage(getWriter(tWriterId).render(tText))
            removeWriter(tWriterId)
          else
            if me = "printtourl" then
              me.printToUrl()
            end if
          end if
        end if
      end if
      exit
    end if
  end if
end

on handlers()
  return([])
  exit
end