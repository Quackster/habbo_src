property pBuddyMsgs
global gBuddyList

on new me
  pBuddyMsgs = [:]
  return me
end

on handleFusePMessage me, data
  put data
  msg = new(script("Message Class"), data)
  l = getaProp(pBuddyMsgs, msg.senderID)
  if l = VOID then
    l = []
    addProp(pBuddyMsgs, msg.senderID, l)
  end if
  puppetSound(3, "newmessage.sound")
  add(l, msg)
  if objectp(gBuddyList) then
    update(gBuddyList)
  end if
end

on getMessageCount me
  c = 0
  repeat with b in pBuddyMsgs
    c = c + count(b)
  end repeat
  return c
end

on getBuddyMsgCount me, buddyId
  l = getaProp(pBuddyMsgs, buddyId)
  if l = VOID then
    return 0
  else
    return count(l)
  end if
end

on getNextBuddyMsg me, buddyId
  global gBuddyFigures
  l = getaProp(pBuddyMsgs, buddyId)
  if l = VOID then
    return VOID
  else
    if count(l) > 0 then
      msg = l[1]
      deleteAt(l, 1)
      update(gBuddyList)
      if count(l) = 0 then
        deleteProp(pBuddyMsgs, buddyId)
      end if
      markAsRead(msg)
      MyWireFace(FigureDataParser(gBuddyFigures.getaProp(buddyId)), "face_icon")
      return msg
    else
      return getNextMessage(me)
    end if
  end if
end

on getNextMessage me
  if count(pBuddyMsgs) > 0 then
    bid = getPropAt(pBuddyMsgs, 1)
    return getNextBuddyMsg(me, bid)
  end if
  return VOID
end
