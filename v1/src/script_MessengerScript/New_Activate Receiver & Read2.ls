property selected, mname, num
global gBuddyList, gMessageManager, gpUiButtons, gChosenBuddyId, gChosenbuddyName, gpBuddyIndicators, gpBuddyExistsIndicators

on beginSprite me
  put EMPTY into field "receivers"
  mname = sprite(me.spriteNum).member.name
  num = integer(char 7 of mname)
  mname = (("buddy" & num) & ".field")
  disable(me)
  if ((gpBuddyExistsIndicators = [:]) or voidp(gpBuddyExistsIndicators)) then
    return 
  end if
  l = getaProp(gpBuddyExistsIndicators, num)
  repeat with spr in l
    if ((length(member(mname).text) < 10) or (line 2 of the text of member(mname) starts "last time")) then
      sendSprite(spr, #disable)
      next repeat
    end if
    sendSprite(spr, #enable)
  end repeat
end

on mouseUp me
  global buddySelectHiSpr
  if ((the mouseV > (sprite(me.spriteNum).top + 15)) or (getBuddyMsgCount(gMessageManager, getBuddyIdFromFieldNum(gBuddyList, num)) = 0)) then
    bname = getBuddyIdFromFieldNum(gBuddyList, num)
    if (bname = VOID) then
      return 
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
      return 
    end if
    goContext("readmsg")
    msg = getNextBuddyMsg(gMessageManager, gChosenBuddyId)
    if (msg = VOID) then
      goContext("buddies")
      return 
    end if
    display(msg)
  end if
end

on enable me
  bname = getBuddyIdFromFieldNum(gBuddyList, num)
  if not (field("receivers") contains (bname & " ")) then
    put (bname & " ") after field "receivers"
  end if
  gChosenbuddyName = getBuddyNameFromFieldNum(gBuddyList, num)
  receiverNames = EMPTY
  repeat with i = 1 to the number of words in field "receivers"
    id = integer(word i of field "receivers")
    receiverNames = (receiverNames && getBuddyName(gBuddyList, id))
  end repeat
  member("receivers.show").text = ((AddTextToField("receivers2") & RETURN) & receiverNames)
  member("messenger.message.new").text = EMPTY
  member("messenger.message.new").scrollTop = 0
  member("message.charCount").text = "0/255"
  if ((gpBuddyIndicators <> VOID) and (gpBuddyIndicators <> [:])) then
    l = getaProp(gpBuddyIndicators, num)
    repeat with spr in l
      sendSprite(spr, #enable)
    end repeat
  end if
  selected = 1
  sendSprite(getaProp(gpUiButtons, "writemsg"), #enable)
  sendSprite(getaProp(gpUiButtons, "removebuddy"), #enable)
end

on disable me
  if voidp(gBuddyList) then
    return 
  end if
  bname = getBuddyIdFromFieldNum(gBuddyList, num)
  newrc = EMPTY
  rc = field("receivers")
  repeat with i = 1 to the number of words in rc
    if (word i of rc = bname) then
      next repeat
    end if
    put (word i of rc & " ") after bname
  end repeat
  put newrc into field "receivers"
  receiverNames = EMPTY
  repeat with i = 1 to the number of words in field "receivers"
    id = integer(word i of field "receivers")
    receiverNames = (receiverNames && getBuddyName(gBuddyList, id))
  end repeat
  member("receivers.show").text = ((AddTextToField("receivers2") & RETURN) & receiverNames)
  member("messenger.message.new").text = EMPTY
  member("messenger.message.new").scrollTop = 0
  member("message.charCount").text = "0/255"
  if voidp(gpBuddyIndicators) then
    gpBuddyIndicators = [:]
  end if
  if (gpBuddyIndicators = [:]) then
    return 
  end if
  l = getaProp(gpBuddyIndicators, num)
  repeat with spr in l
    sendSprite(spr, #disable)
  end repeat
  if (field("receivers").length < 2) then
    sendSprite(getaProp(gpUiButtons, "writemsg"), #disable)
    sendSprite(getaProp(gpUiButtons, "removebuddy"), #disable)
  end if
  selected = 0
end

on checkBuddyList me
  bname = getBuddyIdFromFieldNum(gBuddyList, num)
  rc = field("receivers")
  repeat with i = 1 to the number of words in rc
    if (word i of rc = bname) then
      enable(me)
      return 
    end if
  end repeat
  disable(me)
end
