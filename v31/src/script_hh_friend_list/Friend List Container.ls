property pCategories, pListLimit, pFriendList

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
  tCat.setAt(#id, tID)
  tCat.setAt(#name, getText("friend_list_online_category"))
  pCategories.setAt(tID, tCat)
  tNo = 1
  repeat while tNo <= tdata.count
    tCat = [:]
    tID = string(tdata.getPropAt(tNo))
    tCat.setAt(#id, tID)
    tCat.setAt(#name, tdata.getAt(tNo))
    pCategories.setAt(tID, tCat)
    tNo = (1 + tNo)
  end repeat
  tCat = [:]
  tID = "-1"
  tCat.setAt(#id, tID)
  tCat.setAt(#name, getText("friend_list_offline_category"))
  pCategories.setAt(tID, tCat)
  tCat = [:]
  tID = "-2"
  tCat.setAt(#id, tID)
  tCat.setAt(#name, getText("friend_list_friend_requests_category"))
  pCategories.setAt(tID, tCat)
  tCat = [:]
  tID = "-3"
  tCat.setAt(#id, tID)
  tCat.setAt(#name, getText("friend_list_search_category", "Search"))
  pCategories.setAt(tID, tCat)
end

on populateFriendData me, tFriends 
  repeat while tFriends <= undefined
    tFriend = getAt(undefined, tFriends)
    me.addFriend(tFriend)
  end repeat
end

on setListLimit me, tLimit 
  pListLimit = tLimit
end

on isListFull me 
  if (pListLimit = -1) then
    return FALSE
  end if
  return(pFriendList.count >= pListLimit)
end

on addFriend me, tFriend 
  tID = string(tFriend.getAt(#id))
  pFriendList.setAt(tID, tFriend.duplicate())
end

on updateFriend me, tFriendData 
  tID = string(tFriendData.getAt(#id))
  tFriendProps = pFriendList.getAt(tID)
  if not voidp(tFriendProps) then
    tNo = 1
    repeat while tNo <= tFriendData.count
      tProp = tFriendData.getPropAt(tNo)
      tValue = tFriendData.getAt(tNo)
      if not (tProp = #figure) and (tValue = "") then
        tFriendProps.setAt(tProp, tValue)
      end if
      tNo = (1 + tNo)
    end repeat
    pFriendList.setAt(tID, tFriendProps.duplicate())
  end if
end

on removeFriend me, tFriendID 
  pFriendList.deleteProp(string(tFriendID))
end

on getFriendByID me, tFriendID 
  tFriend = pFriendList.getAt(string(tFriendID))
  if voidp(tFriend) then
    return FALSE
  else
    return(tFriend)
  end if
end

on getFriendByName me, tName 
  tFriendID = string(tName)
  tNo = 1
  repeat while tNo <= pFriendList.count
    tFriend = pFriendList.getAt(tNo)
    if (tName = string(tFriend.getAt(#name))) then
      return(tFriend)
    end if
    tNo = (1 + tNo)
  end repeat
  return FALSE
end

on getFriendsInCategory me, tCategoryID 
  tList = [:]
  tList.sort()
  tNo = 1
  repeat while tNo <= pFriendList.count
    tFriend = pFriendList.getAt(tNo)
    if (tFriend.getAt(#categoryId) = tCategoryID) then
      tList.setaProp(tFriend.getaProp(#name), tFriend)
    end if
    tNo = (1 + tNo)
  end repeat
  return(tList)
end

on getCategoryList me 
  return(pCategories)
end

on getCategoryName me, tCatID 
  tCategory = pCategories.getAt(string(tCatID))
  return(tCategory.getAt(#name))
end
