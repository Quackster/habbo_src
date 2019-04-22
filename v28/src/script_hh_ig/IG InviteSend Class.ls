on construct(me)
  pUserList = void()
  pExcludeList = []
  pUserListFilter = 1
  pTicketsLeft = 0
  return(1)
  exit
end

on deconstruct(me)
  return(me.deconstruct())
  exit
end

on getUserList(me)
  if pUserList = void() then
    return(me.getHandler().send_LIST_POSSIBLE_INVITEES(pUserListFilter))
  end if
  return(pUserList)
  exit
end

on changeUserListFilter(me, tFilter)
  if tFilter = void() then
    return(0)
  end if
  if tFilter = pUserListFilter then
    return(1)
  end if
  pUserListFilter = tFilter
  return(me.getHandler().send_LIST_POSSIBLE_INVITEES(pUserListFilter))
  exit
end

on getUserListFilter(me)
  return(pUserListFilter)
  exit
end

on sendInviteToListIndex(me, tIndex, tMessage)
  put("* sendInviteToListIndex" && tIndex && tMessage)
  if tIndex = void() then
    return(0)
  end if
  if pUserList = void() then
    return(0)
  end if
  if pUserList.count < tIndex then
    return(0)
  end if
  tUserName = pUserList.getAt(tIndex)
  me.getHandler().send_INVITE_USER(tUserName, tMessage)
  me.append(tUserName)
  put("* TODO: how to exclude people..")
  return(1)
  exit
end

on sendInviteToName(me, tUserName, tMessage)
  put("* sendInviteToName" && tUserName && tMessage)
  if tUserName = "" then
    return(0)
  end if
  me.getHandler().send_INVITE_USER(tUserName, tMessage)
  me.append(tUserName)
  put("* TODO: how to exclude people..")
  return(1)
  exit
end

on excludeListIndex(me, tIndex)
  put("* TODO: excludeListIndex" && tIndex)
  if tIndex = void() then
    return(0)
  end if
  if pUserList = void() then
    return(0)
  end if
  if pUserList.count < tIndex then
    return(0)
  end if
  tUserName = pUserList.getAt(tIndex)
  me.append(tUserName)
  put("* TODO: how to exclude people.." && tUserName)
  return(1)
  exit
end

on saveInviteTicketCount(me, tNum)
  pTicketsLeft = tNum
  return(1)
  exit
end

on getInviteTicketCount(me)
  return(pTicketsLeft)
  exit
end

on showInviteResponse(me, tdata)
  put(me.getID() && "* showInviteResponse" && tdata)
  return(1)
  exit
end

on saveInviteData(me, tdata)
  pUserListFilter = tdata.getaProp(#list_type)
  pUserList = tdata.getaProp(#invitee_list)
  return(1)
  exit
end

on update(me)
  exit
end

on render(me)
  exit
end