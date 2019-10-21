on construct(me)
  pCategories = []
  pFriendList = []
  pListLimit = 0
  exit
end

on deconstruct(me)
  exit
end

on populateCategoryData(me, tdata)
  pCategories = []
  tCat = []
  tID = "0"
  tCat.setAt(#id, tID)
  tCat.setAt(#name, getText("friend_list_online_category"))
  pCategories.setAt(tID, tCat)
  tNo = 1
  repeat while tNo <= tdata.count
    tCat = []
    tID = string(tdata.getPropAt(tNo))
    tCat.setAt(#id, tID)
    tCat.setAt(#name, tdata.getAt(tNo))
    pCategories.setAt(tID, tCat)
    tNo = 1 + tNo
  end repeat
  tCat = []
  tID = "-1"
  tCat.setAt(#id, tID)
  tCat.setAt(#name, getText("friend_list_offline_category"))
  pCategories.setAt(tID, tCat)
  tCat = []
  tID = "-2"
  tCat.setAt(#id, tID)
  tCat.setAt(#name, getText("friend_list_friend_requests_category"))
  pCategories.setAt(tID, tCat)
  exit
end

on populateFriendData(me, tFriends)
  repeat while me <= undefined
    tFriend = getAt(undefined, tFriends)
    me.addFriend(tFriend)
  end repeat
  exit
end

on setListLimit(me, tLimit)
  pListLimit = tLimit
  exit
end

on isListFull(me)
  if pListLimit = -1 then
    return(0)
  end if
  return(pFriendList.count >= pListLimit)
  exit
end

on addFriend(me, tFriend)
  tID = string(tFriend.getAt(#id))
  pFriendList.setAt(tID, tFriend.duplicate())
  exit
end

on updateFriend(me, tFriendData)
  tID = string(tFriendData.getAt(#id))
  tFriendProps = pFriendList.getAt(tID)
  if not voidp(tFriendProps) then
    tNo = 1
    repeat while tNo <= tFriendData.count
      tProp = tFriendData.getPropAt(tNo)
      tValue = tFriendData.getAt(tNo)
      if not tProp = #figure and tValue = "" then
        tFriendProps.setAt(tProp, tValue)
      end if
      tNo = 1 + tNo
    end repeat
    tName = tFriendProps.getAt(#name)
    pFriendList.setAt(tID, tFriendProps.duplicate())
  end if
  exit
end

on removeFriend(me, tFriendID)
  pFriendList.deleteProp(string(tFriendID))
  exit
end

on getFriendByID(me, tFriendID)
  tFriend = pFriendList.getAt(string(tFriendID))
  if voidp(tFriend) then
    return(0)
  else
    return(tFriend)
  end if
  exit
end

on getFriendByName(me, tName)
  tFriendID = string(tName)
  tNo = 1
  repeat while tNo <= pFriendList.count
    tFriend = pFriendList.getAt(tNo)
    if tName = string(tFriend.getAt(#name)) then
      return(tFriend)
    end if
    tNo = 1 + tNo
  end repeat
  return(0)
  exit
end

on getFriendsInCategory(me, tCategoryId)
  tList = []
  tList.sort()
  tNo = 1
  repeat while tNo <= pFriendList.count
    tFriend = pFriendList.getAt(tNo)
    if tFriend.getAt(#categoryId) = tCategoryId then
      tList.setAt(tFriend.getAt(#name), tFriend)
    end if
    tNo = 1 + tNo
  end repeat
  return(tList)
  exit
end

on getCategoryList(me)
  return(pCategories)
  exit
end

on getCategoryName(me, tCatID)
  tCategory = pCategories.getAt(string(tCatID))
  return(tCategory.getAt(#name))
  exit
end