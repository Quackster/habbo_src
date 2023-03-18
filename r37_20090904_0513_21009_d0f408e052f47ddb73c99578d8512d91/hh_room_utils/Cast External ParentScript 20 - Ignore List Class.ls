property pUserNamesPending, pIgnoreList

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
  tConnection = getConnection(#Info)
  if tConnection = 0 then
    return error(me, "Info connection not available.", #construct)
  end if
  tConnection.send("GET_IGNORE_LIST")
  unregisterMessage(#userlogin, me.getID())
  return 1
end

on getIgnoreStatus me, tUserName
  if voidp(pIgnoreList) then
    me.reset()
  end if
  if pIgnoreList = [] then
    return 0
  end if
  return pIgnoreList.findPos(tUserName)
end

on setIgnoreStatus me, tUserName, tStatus
  if voidp(pIgnoreList) then
    me.reset()
  end if
  tConnection = getConnection(#Info)
  if tConnection = 0 then
    return error(me, "Info connection not available.", #construct)
  end if
  if tUserName = VOID then
    return 0
  end if
  pUserNamesPending.append(tUserName)
  if tStatus then
    tConnection.send("IGNOREUSER", [#string: tUserName])
  else
    tConnection.send("UNIGNORE_USER", [#string: tUserName])
  end if
  return 1
end

on saveIgnoreList me, tList
  pIgnoreList = tList
  return 1
end

on saveIgnoreResult me, tResult
  if pUserNamesPending.count = 0 then
    return 0
  end if
  tUserName = pUserNamesPending[1]
  pUserNamesPending.deleteAt(1)
  case tResult of
    0:
      return error(me, "Ignore user failed.", #saveIgnoreResult)
    1:
      me.addUserToIgnoreList(tUserName)
    2:
      me.addUserToIgnoreList(tUserName)
      me.removeOldestIgnore()
    3:
      me.removeUserFromIgnoreList(tUserName)
    otherwise:
      return error(me, "Unsupported result for ignore user:" && tResult, #saveIgnoreResult)
  end case
  return 1
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
    return 0
  end if
  pIgnoreList.deleteAt(1)
  return 1
end

on reset me
  pIgnoreList = []
  return 1
end
