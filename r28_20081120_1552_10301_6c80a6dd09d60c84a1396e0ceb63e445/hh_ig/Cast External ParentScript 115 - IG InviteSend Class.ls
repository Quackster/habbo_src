property pUserList, pUserListFilter, pExcludeList, pTicketsLeft

on construct me
  pUserList = VOID
  pExcludeList = []
  pUserListFilter = 1
  pTicketsLeft = 0
  return 1
end

on deconstruct me
  return me.ancestor.deconstruct()
end

on getUserList me
  if pUserList = VOID then
    return me.getHandler().send_LIST_POSSIBLE_INVITEES(pUserListFilter)
  end if
  return pUserList
end

on changeUserListFilter me, tFilter
  if tFilter = VOID then
    return 0
  end if
  if tFilter = pUserListFilter then
    return 1
  end if
  pUserListFilter = tFilter
  return me.getHandler().send_LIST_POSSIBLE_INVITEES(pUserListFilter)
end

on getUserListFilter me
  return pUserListFilter
end

on sendInviteToListIndex me, tIndex, tMessage
  put "* sendInviteToListIndex" && tIndex && tMessage
  if tIndex = VOID then
    return 0
  end if
  if pUserList = VOID then
    return 0
  end if
  if pUserList.count < tIndex then
    return 0
  end if
  tUserName = pUserList[tIndex]
  me.getHandler().send_INVITE_USER(tUserName, tMessage)
  me.pExcludeList.append(tUserName)
  put "* TODO: how to exclude people.."
  return 1
end

on sendInviteToName me, tUserName, tMessage
  put "* sendInviteToName" && tUserName && tMessage
  if tUserName = EMPTY then
    return 0
  end if
  me.getHandler().send_INVITE_USER(tUserName, tMessage)
  me.pExcludeList.append(tUserName)
  put "* TODO: how to exclude people.."
  return 1
end

on excludeListIndex me, tIndex
  put "* TODO: excludeListIndex" && tIndex
  if tIndex = VOID then
    return 0
  end if
  if pUserList = VOID then
    return 0
  end if
  if pUserList.count < tIndex then
    return 0
  end if
  tUserName = pUserList[tIndex]
  me.pExcludeList.append(tUserName)
  put "* TODO: how to exclude people.." && tUserName
  return 1
end

on saveInviteTicketCount me, tNum
  pTicketsLeft = tNum
  return 1
end

on getInviteTicketCount me
  return pTicketsLeft
end

on showInviteResponse me, tdata
  put me.getID() && "* showInviteResponse" && tdata
  return 1
end

on saveInviteData me, tdata
  pUserListFilter = tdata.getaProp(#list_type)
  pUserList = tdata.getaProp(#invitee_list)
  return 1
end

on update me
end

on render me
end
