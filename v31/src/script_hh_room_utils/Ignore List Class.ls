property pIgnoreList, pUserNamesPending

on construct me 
  pUserNamesPending = []
  registerMessage(#userlogin, me.getID(), #initIgnoreList)
  registerMessage(#ignore_user_result, me.getID(), #saveIgnoreResult)
  registerMessage(#save_ignore_list, me.getID(), #saveIgnoreList)
end

on deconstruct me 
  unregisterMessage(#userlogin, me.getID())
  unregisterMessage(#ignore_user_result, me.getID())
  unregisterMessage(#save_ignore_list, me.getID())
end

on initIgnoreList me 
  tConnection = getConnection(#info)
  if (tConnection = 0) then
    return(error(me, "Info connection not available.", #construct))
  end if
  tConnection.send("GET_IGNORE_LIST")
  unregisterMessage(#userlogin, me.getID())
  return TRUE
end

on getIgnoreStatus me, tUserName 
  if voidp(pIgnoreList) then
    me.reset()
  end if
  if (pIgnoreList = []) then
    return FALSE
  end if
  return(pIgnoreList.findPos(tUserName))
end

on setIgnoreStatus me, tUserName, tStatus 
  if voidp(pIgnoreList) then
    me.reset()
  end if
  tConnection = getConnection(#info)
  if (tConnection = 0) then
    return(error(me, "Info connection not available.", #construct))
  end if
  if (tUserName = void()) then
    return FALSE
  end if
  pUserNamesPending.append(tUserName)
  if tStatus then
    tConnection.send("IGNOREUSER", [#string:tUserName])
  else
    tConnection.send("UNIGNORE_USER", [#string:tUserName])
  end if
  return TRUE
end

on saveIgnoreList me, tList 
  pIgnoreList = tList
  return TRUE
end

on saveIgnoreResult me, tResult 
  if (pUserNamesPending.count = 0) then
    return FALSE
  end if
  tUserName = pUserNamesPending.getAt(1)
  pUserNamesPending.deleteAt(1)
  if (tResult = 0) then
    return(error(me, "Ignore user failed.", #saveIgnoreResult))
  else
    if (tResult = 1) then
      me.addUserToIgnoreList(tUserName)
    else
      if (tResult = 2) then
        me.addUserToIgnoreList(tUserName)
        me.removeOldestIgnore()
      else
        if (tResult = 3) then
          me.removeUserFromIgnoreList(tUserName)
        else
          return(error(me, "Unsupported result for ignore user:" && tResult, #saveIgnoreResult))
        end if
      end if
    end if
  end if
  return TRUE
end

on addUserToIgnoreList me, tUserName 
  if not pIgnoreList.findPos(tUserName) then
    pIgnoreList.add(tUserName)
  end if
end

on removeUserFromIgnoreList me, tUserName 
  pIgnoreList.deleteOne(tUserName)
end

on removeOldestIgnore me 
  if voidp(pIgnoreList) then
    return FALSE
  end if
  pIgnoreList.deleteAt(1)
  return TRUE
end

on reset me 
  pIgnoreList = []
  return TRUE
end
