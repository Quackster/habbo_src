property pUserList, pUserListFilter, pTicketsLeft

on construct me 
  pUserList = void()
  pExcludeList = []
  pUserListFilter = 1
  pTicketsLeft = 0
  return TRUE
end

on deconstruct me 
  return(me.ancestor.deconstruct())
end

on getUserList me 
  if (pUserList = void()) then
    return(me.getHandler().send_LIST_POSSIBLE_INVITEES(pUserListFilter))
  end if
  return(pUserList)
end

on changeUserListFilter me, tFilter 
  if (tFilter = void()) then
    return FALSE
  end if
  if (tFilter = pUserListFilter) then
    return TRUE
  end if
  pUserListFilter = tFilter
  return(me.getHandler().send_LIST_POSSIBLE_INVITEES(pUserListFilter))
end

on getUserListFilter me 
  return(pUserListFilter)
end

on sendInviteToListIndex me, tIndex, tMessage 
  if (tIndex = void()) then
    return FALSE
  end if
  if (pUserList = void()) then
    return FALSE
  end if
  if pUserList.count < tIndex then
    return FALSE
  end if
  tUserName = pUserList.getAt(tIndex)
  me.getHandler().send_INVITE_USER(tUserName, tMessage)
  me.pExcludeList.append(tUserName)
  return TRUE
end

on sendInviteToName me, tUserName, tMessage 
  if (tUserName = "") then
    return FALSE
  end if
  me.getHandler().send_INVITE_USER(tUserName, tMessage)
  me.pExcludeList.append(tUserName)
  return TRUE
end

on excludeListIndex me, tIndex 
  if (tIndex = void()) then
    return FALSE
  end if
  if (pUserList = void()) then
    return FALSE
  end if
  if pUserList.count < tIndex then
    return FALSE
  end if
  tUserName = pUserList.getAt(tIndex)
  me.pExcludeList.append(tUserName)
  return TRUE
end

on saveInviteTicketCount me, tNum 
  pTicketsLeft = tNum
  return TRUE
end

on getInviteTicketCount me 
  return(pTicketsLeft)
end

on showInviteResponse me, tdata 
  return TRUE
end

on saveInviteData me, tdata 
  pUserListFilter = tdata.getaProp(#list_type)
  pUserList = tdata.getaProp(#invitee_list)
  return TRUE
end

on update me 
end

on render me 
end
