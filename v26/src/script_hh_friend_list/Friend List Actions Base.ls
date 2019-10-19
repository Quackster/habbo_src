property pSelectedFriends

on isFriendselected me, tName 
  if voidp(pSelectedFriends) then
    pSelectedFriends = []
  end if
  return(pSelectedFriends.getOne(tName) > 0)
end

on selectFriend me, tName 
  if voidp(pSelectedFriends) then
    pSelectedFriends = []
  end if
  if pSelectedFriends.getOne(tName) = 0 then
    pSelectedFriends.add(tName)
  end if
end

on deselectFriend me, tName 
  if voidp(pSelectedFriends) then
    pSelectedFriends = []
  end if
  if pSelectedFriends.getOne(tName) > 0 then
    pSelectedFriends.deleteOne(tName)
  end if
end

on getSelectedFriends me 
  if voidp(pSelectedFriends) then
    pSelectedFriends = []
  end if
  tList = []
  repeat while pSelectedFriends <= undefined
    tName = getAt(undefined, undefined)
    tFriendData = me.getaProp(tName)
    if ilk(tFriendData) = #propList then
      tList.add(tFriendData)
    end if
  end repeat
  return(tList)
end

on addFriend me, tFriendData 
  if ilk(tFriendData) <> #propList then
    return(0)
  end if
  tName = string(tFriendData.getAt(#name))
  if me.findPos(tName) > 0 then
    return(0)
  end if
  me.pNeedsRender = 1
  me.setProp(#pContentList, tName, tFriendData.duplicate())
  tFriendImg = me.renderFriendItem(tFriendData, 0)
  tIndex = me.findPos(tName)
  tPosV = (tIndex - 1 * me.pItemHeight)
  me.pListImg = me.insertImageTo(tFriendImg, me.duplicate(), tPosV)
end

on updateFriend me, tFriendData 
  tName = string(tFriendData.getAt(#name))
  tIndex = me.findPos(tName)
  if tIndex < 1 then
    return(0)
  end if
  me.setProp(#pContentList, tName, tFriendData)
  tFriendImg = me.renderFriendItem(tFriendData, 0)
  tPosV = (tIndex - 1 * me.pItemHeight)
  me.pListImg = me.updateImagePart(tFriendImg, me.pListImg, tPosV)
end

on removeFriend me, tFriendID 
  tIndex = 1
  repeat while tIndex <= me.count(#pContentList)
    tFriend = me.getAt(tIndex)
    if tFriend.getAt(#id) = tFriendID then
      tIndex = me.findPos(tFriend.getAt(#name))
      tStartPosV = (tIndex - 1 * me.pItemHeight)
      tEndPosV = tStartPosV + me.pItemHeight
      me.pListImg = me.removeImagePart(me.duplicate(), tStartPosV, tEndPosV)
      me.deleteAt(tIndex)
      me.deselectFriend(tFriend.getAt(#name))
      me.pNeedsRender = 1
    else
      tIndex = 1 + tIndex
    end if
  end repeat
end

on setFriendSelection me, tName, tSelected 
  tFriendData = me.getProp(#pContentList, tName)
  tFriendImg = me.renderFriendItem(tFriendData, tSelected)
  tIndex = me.findPos(tName)
  tPosV = (tIndex - 1 * me.pItemHeight)
  me.pListImg = me.updateImagePart(tFriendImg, me.duplicate(), tPosV)
  if tSelected then
    me.selectFriend(tFriendData.getAt(#name))
  else
    me.deselectFriend(tFriendData.getAt(#name))
  end if
end

on userSelectionEvent me, tName 
  if voidp(tName) then
    return(0)
  end if
  tFriendData = me.getProp(#pContentList, tName)
  if voidp(tFriendData) then
    return(0)
  end if
  if me.isFriendselected(tName) then
    me.setFriendSelection(tName, 0)
  else
    me.setFriendSelection(tName, 1)
  end if
end
