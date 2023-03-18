property pCategories, pFriendList, pListLimit

on construct me
  pCategories = [:]
  pFriendList = [:]
  pListLimit = 0
end

on deconstruct me
end

on populateCategoryData me, tdata
  pCategories = [:]
  tCat = [:]
  tID = "0"
  tCat[#id] = tID
  tCat[#name] = getText("friend_list_online_category")
  pCategories[tID] = tCat
  repeat with tNo = 1 to tdata.count
    tCat = [:]
    tID = string(tdata.getPropAt(tNo))
    tCat[#id] = tID
    tCat[#name] = tdata[tNo]
    pCategories[tID] = tCat
  end repeat
  tCat = [:]
  tID = "-1"
  tCat[#id] = tID
  tCat[#name] = getText("friend_list_offline_category")
  pCategories[tID] = tCat
  tCat = [:]
  tID = "-2"
  tCat[#id] = tID
  tCat[#name] = getText("friend_list_friend_requests_category")
  pCategories[tID] = tCat
  tCat = [:]
  tID = "-3"
  tCat[#id] = tID
  tCat[#name] = getText("friend_list_search_category", "Search")
  pCategories[tID] = tCat
end

on populateFriendData me, tFriends
  repeat with tFriend in tFriends
    me.addFriend(tFriend)
  end repeat
end

on setListLimit me, tLimit
  pListLimit = tLimit
end

on isListFull me
  if pListLimit = -1 then
    return 0
  end if
  return pFriendList.count >= pListLimit
end

on addFriend me, tFriend
  tID = string(tFriend[#id])
  pFriendList[tID] = tFriend.duplicate()
end

on updateFriend me, tFriendData
  tID = string(tFriendData[#id])
  tFriendProps = pFriendList[tID]
  if not voidp(tFriendProps) then
    repeat with tNo = 1 to tFriendData.count
      tProp = tFriendData.getPropAt(tNo)
      tValue = tFriendData[tNo]
      if not ((tProp = #figure) and (tValue = EMPTY)) then
        tFriendProps[tProp] = tValue
      end if
    end repeat
    pFriendList[tID] = tFriendProps.duplicate()
  end if
end

on removeFriend me, tFriendID
  pFriendList.deleteProp(string(tFriendID))
end

on getFriendByID me, tFriendID
  tFriend = pFriendList[string(tFriendID)]
  if voidp(tFriend) then
    return 0
  else
    return tFriend
  end if
end

on getFriendByName me, tName
  tFriendID = string(tName)
  repeat with tNo = 1 to pFriendList.count
    tFriend = pFriendList[tNo]
    if tName = string(tFriend[#name]) then
      return tFriend
    end if
  end repeat
  return 0
end

on getFriendsInCategory me, tCategoryId
  tList = [:]
  tList.sort()
  repeat with tNo = 1 to pFriendList.count
    tFriend = pFriendList[tNo]
    if tFriend[#categoryId] = tCategoryId then
      tList.setaProp(tFriend.getaProp(#name), tFriend)
    end if
  end repeat
  return tList
end

on getCategoryList me
  return pCategories
end

on getCategoryName me, tCatID
  tCategory = pCategories[string(tCatID)]
  return tCategory[#name]
end
