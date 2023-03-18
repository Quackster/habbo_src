property pBuddies, scrollStart, numOfFields, lBuddyRequests, emailOk, smsOk
global gMessageManager, gChosenBuddyRequest, gpBuddyExistsIndicators, gBuddyFigures

on new me
  pBuddies = []
  lBuddyRequests = []
  numOfFields = 4
  scrollStart = 0
  return me
end

on handleFuseBuddyListMsg me, msg
  pBuddies = []
  i = 1
  namesOnline = []
  namesOffline = []
  pNames = [:]
  repeat while i <= the number of lines in msg
    ln = line i of msg
    if ln.length > 4 then
      p = [:]
      oldDelim = the itemDelimiter
      the itemDelimiter = "/"
      suppinfo = the last item in ln
      ln = item 1 to the number of items in ln - 1 of ln
      the itemDelimiter = oldDelim
      if suppinfo contains "email_ok" then
        addProp(p, #emailOk, 1)
      else
        addProp(p, #emailOk, 0)
      end if
      if suppinfo contains "sms_ok" then
        addProp(p, #smsOk, 1)
      else
        addProp(p, #smsOk, 0)
      end if
      addProp(p, #id, integer(word 1 of ln))
      addProp(p, #name, word 2 of ln)
      addProp(p, #msg, word 3 to the number of words in ln of ln)
      od = the itemDelimiter
      the itemDelimiter = TAB
      unit = item 1 of line i + 1 of msg
      if unit = "ENTERPRISESERVER" then
        unit = "messenger"
      end if
      addProp(p, #unit, unit)
      addProp(p, #last_access_time, item 2 of line i + 1 of msg)
      the itemDelimiter = od
      if unit.length > 2 then
        add(namesOnline, word 2 of ln)
      else
        add(namesOffline, word 2 of ln)
      end if
      addProp(pNames, word 2 of ln, p)
    end if
    i = i + 2
  end repeat
  sort(namesOnline)
  sort(namesOffline)
  repeat with nm in namesOnline
    p = getaProp(pNames, nm)
    add(pBuddies, p)
  end repeat
  repeat with nm in namesOffline
    p = getaProp(pNames, nm)
    add(pBuddies, p)
  end repeat
  update(me)
end

on update me
  global gBLScrollBlockSpr, gPopUpContext
  if objectp(gPopUpContext) then
    if gPopUpContext.frame = "buddies" then
      if (count(pBuddies) - numOfFields) > 0 then
        sendSprite(gBLScrollBlockSpr, #update, scrollStart * 1.0 / (count(pBuddies) - numOfFields))
      else
        sendSprite(gBLScrollBlockSpr, #update, 0)
      end if
    end if
  end if
  msgCount = 0
  repeat with i = scrollStart to scrollStart + numOfFields - 1
    if i >= count(pBuddies) then
      emptyField(me, i - scrollStart + 1)
      next repeat
    end if
    fillField(me, i - scrollStart + 1, pBuddies[i + 1])
    msgCount = msgCount + getBuddyMsgCount(gMessageManager, getaProp(pBuddies[i + 1], #id))
  end repeat
  if count(pBuddies) = 0 then
    member("buddy1.field").text = AddTextToField("YouCanAskBuddys")
  end if
  if count(lBuddyRequests) = 1 then
    member("messenger.new_buddy_requests").text = AddTextToField("OnebuddyRequest")
    member("messenger.new_buddy_requests").font = "Volter-Bold (goldfish)"
    member("messenger.new_buddy_requests").fontStyle = [#underline]
  else
    member("messenger.new_buddy_requests").text = count(lBuddyRequests) && AddTextToField("BuddyRequesta")
  end if
  member("messenger.new_buddy_requests").font = "Volter-Bold (goldfish)"
  member("messenger.new_buddy_requests").fontStyle = [#underline]
  if objectp(gMessageManager) then
    member("messenger.no_of_new_messages").text = getMessageCount(gMessageManager) && AddTextToField("NewBuddyMessages")
    if getMessageCount(gMessageManager) > 0 then
      member("messenger.no_of_new_messages").font = "Volter-Bold (goldfish)"
      member("messenger.no_of_new_messages").fontStyle = [#underline]
    else
      member("messenger.no_of_new_messages").font = "Volter (goldfish)"
      member("messenger.no_of_new_messages").fontStyle = [#plain]
    end if
  end if
  if count(lBuddyRequests) > 0 then
    member("messenger.new_buddy_requests").font = "Volter-Bold (goldfish)"
    member("messenger.new_buddy_requests").fontStyle = [#underline]
    member("messenger.new_buddy_requests2").text = member("messenger.new_buddy_requests").text
    member("messenger.new_buddy_requests2").font = "Volter-Bold (goldfish)"
    member("messenger.new_buddy_requests2").fontStyle = [#underline]
  else
    member("messenger.new_buddy_requests").font = "Volter (goldfish)"
    member("messenger.new_buddy_requests").fontStyle = [#plain]
    member("messenger.new_buddy_requests2").text = member("messenger.new_buddy_requests").text
    member("messenger.new_buddy_requests2").font = "Volter (goldfish)"
    member("messenger.new_buddy_requests2").fontStyle = [#plain]
  end if
end

on emptyField me, num
  member("buddy" & num & ".field").text = EMPTY
  member("buddy_" & num).picture = member("buddy" & num & ".field").picture
end

on fillField me, num, p
  if not voidp(gMessageManager) then
    msgCount = getBuddyMsgCount(gMessageManager, getaProp(p, #id))
  else
    msgCount = 0
  end if
  member("buddy" & num & ".messages").text = msgCount && AddTextToField("UnreadMessages")
  if getaProp(p, #unit).length > 2 then
    location = "(" & getaProp(p, #unit) & ")"
  else
    location = "Last visit" && getaProp(p, #last_access_time).char[1..length(getaProp(p, #last_access_time)) - 1]
  end if
  if location contains "(Floor1" then
    location = AddTextToField("InPrivateRoom")
  end if
  if location = "(Messenger)" then
    location = AddTextToField("InFrontPage")
  end if
  if msgCount = 1 then
    msgS = AddTextToField("msg")
  else
    msgS = AddTextToField("msgs")
  end if
  mFieldText = getaProp(p, #name)
  if getaProp(p, #smsOk) = 1 then
    phoneChar = numToChar(177)
    mFieldText = mFieldText && phoneChar
  end if
  mFieldText = mFieldText && "-" && msgCount & "_" & msgS
  mFieldText = mFieldText & RETURN & location & RETURN & QUOTE & getaProp(p, #msg) & QUOTE
  mFieldText = charReplace(mFieldText, "ä", "Š")
  mFieldText = charReplace(mFieldText, "ö", "š")
  member("buddy" & num & ".field").text = mFieldText
  bField = "buddy" & num & ".field"
  set the textFont of field bField to "Volter (goldfish)"
  set the textStyle of field bField to "plain"
  set the textFont of word 1 of field bField to "Volter-Bold (goldfish)"
  set the textStyle of word 3 to the number of words in line 1 of field bField of line 1 of field bField to "underline"
  set the textStyle of line 3 of field bField to "plain"
  member("buddy_" & num).picture = member("buddy" & num & ".field").picture
  if listp(gpBuddyExistsIndicators) then
    l = getaProp(gpBuddyExistsIndicators, num)
    if getaProp(p, #unit).length > 2 then
      repeat with spr in l
        sendSprite(spr, #enable)
      end repeat
    else
      repeat with spr in l
        sendSprite(spr, #disable)
      end repeat
    end if
  end if
end

on getBuddyIdFromFieldNum me, num
  listNum = num + scrollStart
  if listNum > count(pBuddies) then
    return VOID
  else
    return getaProp(pBuddies[listNum], #id)
  end if
end

on getBuddyNameFromFieldNum me, num
  listNum = num + scrollStart
  if listNum > count(pBuddies) then
    return VOID
  else
    return getaProp(pBuddies[listNum], #name)
  end if
end

on getBuddyName me, buddyId
  repeat with l in pBuddies
    if getaProp(l, #id) = buddyId then
      return getaProp(l, #name)
    end if
  end repeat
  return VOID
end

on addBuddyRequest me, name
  if getPos(lBuddyRequests, name) < 1 then
    add(lBuddyRequests, name)
    update(me)
  end if
end

on acceptBuddy me, buddyName
  if getPos(lBuddyRequests, buddyName) > 0 then
    deleteAt(lBuddyRequests, getPos(lBuddyRequests, buddyName))
    sendEPFuseMsg("MESSENGER_ACCEPTBUDDY" && buddyName)
  end if
  nextBuddyRequest(me)
  update(me)
end

on declineBuddy me, buddyName
  if getPos(lBuddyRequests, buddyName) > 0 then
    deleteAt(lBuddyRequests, getPos(lBuddyRequests, buddyName))
    sendEPFuseMsg("MESSENGER_DECLINEBUDDY" && buddyName)
  end if
  nextBuddyRequest(me)
  update(me)
end

on nextBuddyRequest me
  if count(lBuddyRequests) > 0 then
    gChosenBuddyRequest = lBuddyRequests[1]
    s = member("messenger.buddy_request").text
    put gChosenBuddyRequest into line 1 of s
    member("messenger.buddy_request").text = s
    goContext("buddy_requests")
  else
    goContext("main")
  end if
end

on getPropsById me, id
  if voidp(pBuddies) then
    return 
  end if
  repeat with p in pBuddies
    if p.id = id then
      return p
    end if
  end repeat
end

on scrollDown me
  global buddySelectHiSpr
  sendAllSprites(#BuddySelectSwap, "HIDE")
  if scrollStart < (count(pBuddies) - numOfFields) then
    scrollStart = scrollStart + 1
  end if
  update(me)
  sendAllSprites(#checkBuddyList)
end

on scrollUp me
  global buddySelectHiSpr
  sendAllSprites(#BuddySelectSwap, "HIDE")
  if scrollStart > 0 then
    scrollStart = scrollStart - 1
  end if
  update(me)
  sendAllSprites(#checkBuddyList)
end

on scroll me, f
  global buddySelectHiSpr
  sendAllSprites(#BuddySelectSwap, "HIDE")
  oldss = scrollStart
  put f
  scrollStart = integer((count(pBuddies) - numOfFields) * f)
  if scrollStart < 1 then
    scrollStart = 0
  end if
  if oldss <> scrollStart then
    update(me)
    sendAllSprites(#checkBuddyList)
  end if
end
