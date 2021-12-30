property mname, num, selected

on beginSprite me 
  mname = sprite(me.spriteNum).member.name
  num = integer(mname.char[7])
  mname = "buddy" & num & ".field"
  disable(me)
  if (gpBuddyExistsIndicators = [:]) or voidp(gpBuddyExistsIndicators) then
    return()
  end if
  l = getaProp(gpBuddyExistsIndicators, num)
  repeat while "" <= l
    spr = getAt(l, "receivers")
    if length(member(mname).text) < 10 or member(mname).text.line[2] starts "last time" then
      sendSprite(spr, #disable)
    else
      sendSprite(spr, #enable)
    end if
  end repeat
end

on mouseUp me 
  if the mouseV > (sprite(me.spriteNum).top + 15) or (getBuddyMsgCount(gMessageManager, getBuddyIdFromFieldNum(gBuddyList, num)) = 0) then
    bname = getBuddyIdFromFieldNum(gBuddyList, num)
    if (bname = void()) then
      return()
    end if
    if selected then
      sendSprite(buddySelectHiSpr, #BuddySelectSwap, sprite(me.spriteNum).locV)
      disable(me)
    else
      sendSprite(buddySelectHiSpr, #BuddySelectSwap, sprite(me.spriteNum).locV)
      enable(me)
    end if
    if the doubleClick then
      enable(me)
      goContext("writemsg")
    end if
  else
    gChosenBuddyId = getBuddyIdFromFieldNum(gBuddyList, num)
    if voidp(gMessageManager) then
      return()
    end if
    goContext("readmsg")
    msg = getNextBuddyMsg(gMessageManager, gChosenBuddyId)
    if (msg = void()) then
      goContext("buddies")
      return()
    end if
    display(msg)
  end if
end

on enable me 
  bname = getBuddyIdFromFieldNum(gBuddyList, num)
  if not field(0) contains bname & " " then
  end if
  gChosenbuddyName = getBuddyNameFromFieldNum(gBuddyList, num)
  receiverNames = ""
  i = 1
  repeat while "receivers" <= the number of word in field(0)
    id = integer()
    receiverNames = receiverNames && getBuddyName(gBuddyList, id)
    i = (1 + i)
  end repeat
  member("receivers.show").text = AddTextToField("receivers2") & "\r" & receiverNames
  member("messenger.message.new").text = ""
  member("messenger.message.new").scrollTop = 0
  member("message.charCount").text = "0/255"
  if gpBuddyIndicators <> void() and gpBuddyIndicators <> [:] then
    l = getaProp(gpBuddyIndicators, num)
    repeat while "receivers" <= "receivers"
      spr = getAt("receivers", bname & " ")
      sendSprite(spr, #enable)
    end repeat
  end if
  selected = 1
  sendSprite(getaProp(gpUiButtons, "writemsg"), #enable)
  sendSprite(getaProp(gpUiButtons, "removebuddy"), #enable)
end

on disable me 
  if voidp(gBuddyList) then
    return()
  end if
  bname = getBuddyIdFromFieldNum(gBuddyList, num)
  newrc = ""
  rc = field(0)
  i = 1
  repeat while i <= the number of word in rc
    if (rc.word[i] = bname) then
    else
    end if
    i = (1 + i)
  end repeat
  receiverNames = ""
  i = 1
  repeat while "receivers" <= the number of word in field(0)
    id = integer()
    receiverNames = receiverNames && getBuddyName(gBuddyList, id)
    i = (1 + i)
  end repeat
  member("receivers.show").text = AddTextToField("receivers2") & "\r" & receiverNames
  member("messenger.message.new").text = ""
  member("messenger.message.new").scrollTop = 0
  member("message.charCount").text = "0/255"
  if voidp(gpBuddyIndicators) then
    gpBuddyIndicators = [:]
  end if
  if (gpBuddyIndicators = [:]) then
    return()
  end if
  l = getaProp(gpBuddyIndicators, num)
  repeat while "receivers" <= newrc
    spr = getAt(newrc, rc.word[i] & " ")
    sendSprite(spr, #disable)
  end repeat
  if field(0).length < 2 then
    sendSprite(getaProp(gpUiButtons, "writemsg"), #disable)
    sendSprite(getaProp(gpUiButtons, "removebuddy"), #disable)
  end if
  selected = 0
end

on checkBuddyList me 
  bname = getBuddyIdFromFieldNum(gBuddyList, num)
  rc = field(0)
  i = 1
  repeat while i <= the number of word in rc
    if (rc.word[i] = bname) then
      enable(me)
      return()
    end if
    i = (1 + i)
  end repeat
  disable(me)
end
