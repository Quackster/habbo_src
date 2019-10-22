property pItemList, pTotalTimeStart

on construct me 
  pLastExecutedMessage = ""
  pItemList = [:]
  pItemList.sort()
  pTotalTimeStart = the milliSeconds
  return TRUE
end

on deconstruct me 
  pItemList = [:]
  return TRUE
end

on create me, tTask 
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
  return TRUE
end

on Remove me, tTask 
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
  return(me.pItemList.deleteProp(tTask))
end

on GET me, tTask 
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
end

on exists me, tTask 
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  return(not voidp(me.getProp(#pItemList, tTask)))
end

on start me, tTask 
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
end

on finish me, tTask 
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
end

on reset me 
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  pItemList = [:]
  pTotalTimeStart = the milliSeconds
end

on print me 
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  tString = ""
  put(me.printToText(tString))
end

on printToText me, tText 
  if getObjectManager().managerExists(#variable_manager) then
    if not variableExists("profiler.enabled") then
      return()
    end if
  end if
  tTime = the milliSeconds
  tSortedList = [:]
  tSortedList.sort()
  i = 1
  repeat while i <= me.count(#pItemList)
    tSortedList.setaProp(me.pItemList.getAt(i).getTime(), me.pItemList.getAt(i))
    i = (1 + i)
  end repeat
  i = 1
  repeat while i <= tSortedList.count
    tText = tSortedList.getAt(i).print(tText)
    i = (1 + i)
  end repeat
  return(tText)
end

on printToDialog me 
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
end

on printToUrl me 
  tText = replaceChunks(me.printToText(""), "\r", "%0D%0A")
  gotoNetPage("http://localhost/?profile=" & tText, "_new")
end

on printToClipBoard me 
  tText = me.printToText("")
  tMemberName = getUniqueID()
  tmember = member(createMember(tMemberName, #field))
  tmember.text = tText
  tmember.copyToClipboard()
  removeMember(tMemberName)
end

on eventProcProfileDialog me, tEvent, tElemID 
  if (tEvent = #mouseUp) then
    if tElemID <> "close" then
      if (tElemID = "alert_ok") then
        removeWindow("Profile Dialog")
      else
        if (tElemID = "reset") then
          me.reset()
        else
          if (tElemID = "refresh") then
            tText = me.printToText("")
            tWriterId = getUniqueID()
            createWriter(tWriterId, getStructVariable("struct.font.plain"))
            tWndObj = getWindow("Profile Dialog")
            tWndObj.getElement("alert_text").feedImage(getWriter(tWriterId).render(tText))
            removeWriter(tWriterId)
          else
            if (tElemID = "printtourl") then
              me.printToUrl()
            else
              if (tElemID = "copytoclipboard") then
                me.printToClipBoard()
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on handlers  
  return([])
end
