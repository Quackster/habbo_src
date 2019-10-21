on construct(me)
  pUserNamesPending = []
  registerMessage(#userlogin, me.getID(), #initIgnoreList)
  registerMessage(#ignore_user_result, me.getID(), #saveIgnoreResult)
  registerMessage(#save_ignore_list, me.getID(), #saveIgnoreList)
  exit
end

on deconstruct(me)
  unregisterMessage(#userlogin, me.getID())
  unregisterMessage(#ignore_user_result, me.getID())
  unregisterMessage(#save_ignore_list, me.getID())
  exit
end

on initIgnoreList(me)
  tConnection = getConnection(#info)
  if tConnection = 0 then
    return(error(me, "Info connection not available.", #construct))
  end if
  tConnection.send("GET_IGNORE_LIST")
  unregisterMessage(#userlogin, me.getID())
  return(1)
  exit
end

on getIgnoreStatus(me, tUserName)
  if voidp(pIgnoreList) then
    me.reset()
  end if
  if pIgnoreList = [] then
    return(0)
  end if
  return(pIgnoreList.findPos(tUserName))
  exit
end

on setIgnoreStatus(me, tUserName, tStatus)
  if voidp(pIgnoreList) then
    me.reset()
  end if
  tConnection = getConnection(#info)
  if tConnection = 0 then
    return(error(me, "Info connection not available.", #construct))
  end if
  if tUserName = void() then
    return(0)
  end if
  pUserNamesPending.append(tUserName)
  if tStatus then
    tConnection.send("IGNOREUSER", [#string:tUserName])
  else
    tConnection.send("UNIGNORE_USER", [#string:tUserName])
  end if
  return(1)
  exit
end

on saveIgnoreList(me, tList)
  pIgnoreList = tList
  return(1)
  exit
end

on saveIgnoreResult(me, tResult)
  if pUserNamesPending.count = 0 then
    return(0)
  end if
  tUserName = pUserNamesPending.getAt(1)
  pUserNamesPending.deleteAt(1)
  if me = 0 then
    return(error(me, "Ignore user failed.", #saveIgnoreResult))
  else
    if me = 1 then
      me.addUserToIgnoreList(tUserName)
    else
      if me = 2 then
        me.addUserToIgnoreList(tUserName)
        me.removeOldestIgnore()
      else
        if me = 3 then
          me.removeUserFromIgnoreList(tUserName)
        else
          return(error(me, "Unsupported result for ignore user:" && tResult, #saveIgnoreResult))
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on addUserToIgnoreList(me, tUserName)
  if not pIgnoreList.findPos(tUserName) then
    pIgnoreList.add(tUserName)
  end if
  exit
end

on removeUserFromIgnoreList(me, tUserName)
  pIgnoreList.deleteOne(tUserName)
  exit
end

on removeOldestIgnore(me)
  if voidp(pIgnoreList) then
    return(0)
  end if
  pIgnoreList.deleteAt(1)
  return(1)
  exit
end

on reset(me)
  pIgnoreList = []
  return(1)
  exit
end