property pSelectedFriends

on isFriendselected me, tName
  if voidp(pSelectedFriends) then
    pSelectedFriends = []
  end if
  return pSelectedFriends.getOne(tName) > 0
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
  repeat with tName in pSelectedFriends
    tFriendData = me.pContentList.getaProp(tName)
    if ilk(tFriendData) = #propList then
      tList.add(tFriendData)
    end if
  end repeat
  return tList
end

on addFriend me, tFriendData
  if ilk(tFriendData) <> #propList then
    return 0
  end if
  tName = string(tFriendData[#name])
  if me.pContentList.findPos(tName) > 0 then
    return 0
  end if
  me.pNeedsRender = 1
  me.pContentList[tName] = tFriendData.duplicate()
  tFriendImg = me.renderFriendItem(tFriendData, 0)
  tIndex = me.pContentList.findPos(tName)
  tPosV = (tIndex - 1) * me.pItemHeight
  me.pListImg = me.insertImageTo(tFriendImg, me.pListImg.duplicate(), tPosV)
end

on updateFriend me, tFriendData
  tName = string(tFriendData[#name])
  tIndex = me.pContentList.findPos(tName)
  if tIndex < 1 then
    return 0
  end if
  me.pContentList[tName] = tFriendData
  tFriendImg = me.renderFriendItem(tFriendData, 0)
  tPosV = (tIndex - 1) * me.pItemHeight
  me.pListImg = me.updateImagePart(tFriendImg, me.pListImg, tPosV)
end

on removeFriend me, tFriendID
  repeat with tIndex = 1 to me.pContentList.count
    tFriend = me.pContentList[tIndex]
    if tFriend[#id] = tFriendID then
      tIndex = me.pContentList.findPos(tFriend[#name])
      tStartPosV = (tIndex - 1) * me.pItemHeight
      tEndPosV = tStartPosV + me.pItemHeight
      me.pListImg = me.removeImagePart(me.pListImg.duplicate(), tStartPosV, tEndPosV)
      me.pContentList.deleteAt(tIndex)
      me.deselectFriend(tFriend[#name])
      me.pNeedsRender = 1
      exit repeat
    end if
  end repeat
end

on setFriendSelection me, tName, tSelected
  tFriendData = me.pContentList[tName]
  tFriendImg = me.renderFriendItem(tFriendData, tSelected)
  tIndex = me.pContentList.findPos(tName)
  tPosV = (tIndex - 1) * me.pItemHeight
  me.pListImg = me.updateImagePart(tFriendImg, me.pListImg.duplicate(), tPosV)
  if tSelected then
    me.selectFriend(tFriendData[#name])
  else
    me.deselectFriend(tFriendData[#name])
  end if
end

on userSelectionEvent me, tName
  if voidp(tName) then
    return 0
  end if
  tFriendData = me.pContentList[tName]
  if voidp(tFriendData) then
    return 0
  end if
  if me.isFriendselected(tName) then
    me.setFriendSelection(tName, 0)
  else
    me.setFriendSelection(tName, 1)
  end if
end
