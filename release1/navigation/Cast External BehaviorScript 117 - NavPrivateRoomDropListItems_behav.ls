global gDropListSpr, gPopUpContext2, gPrivateDropMem

on beginSprite me
  sprite(me.spriteNum).locV = 2000
end

on SetMyLocVTo me, LocMyV
  sprite(me.spriteNum).locV = LocMyV
end

on SwapMember me
  if sprite(me.spriteNum).member.name contains "_hi" then
    sprite(me.spriteNum).member = sprite(me.spriteNum).member.name.char[1..length(sprite(me.spriteNum).member.name) - 3]
  end if
end

on ActivateDropListItem me, NowAct
  if me.spriteNum = NowAct then
    if sprite(me.spriteNum).member.name.char[length(sprite(me.spriteNum).member.name) - 2..length(sprite(me.spriteNum).member.name)] <> "_hi" then
      sprite(me.spriteNum).member = sprite(me.spriteNum).member.name & "_hi"
    end if
  else
    if sprite(me.spriteNum).member.name contains "_hi" then
      sprite(me.spriteNum).member = sprite(me.spriteNum).member.name.char[length(sprite(44).member.name.length(sprite(me.spriteNum).member.name)) - 3]
    end if
  end if
end

on mouseWithin me
  if sprite(me.spriteNum).member.name.char[length(sprite(me.spriteNum).member.name) - 2..length(sprite(me.spriteNum).member.name)] <> "_hi" then
    sendSprite(gDropListSpr + value(sprite(gDropListSpr).member).name.char[1..1] + 1, #SwapMember)
    sprite(me.spriteNum).member = sprite(me.spriteNum).member.name & "_hi"
    sprite(gDropListSpr).member = me.spriteNum - gDropListSpr - 1 & sprite(gDropListSpr).member.name.char[2..length(sprite(gDropListSpr).member.name)]
  end if
end

on mouseUp me
  global NaviPrivateSearchSpr
  if sprite(me.spriteNum).member.name.char[length(sprite(me.spriteNum).member.name) - 2..length(sprite(me.spriteNum).member.name)] = "_hi" then
    put me.spriteNum - gDropListSpr - 1 & sprite(gDropListSpr).member.name.char[2..length(sprite(gDropListSpr).member.name)]
    gPrivateDropMem = the number of member (the spriteNum of me - gDropListSpr - 1 & (the name of the member of sprite(gDropListSpr)).char[2..length(the name of the member of sprite(gDropListSpr))])
    repeat with f = gDropListSpr + 1 to gDropListSpr + 5
      sendSprite(f, #SetMyLocVTo, 2000)
      updateStage()
    end repeat
    sFrame = "private_places"
    goContext(sFrame, gPopUpContext2)
  end if
  if sprite(me.spriteNum).member.name contains "search" then
    sendSprite(NaviPrivateSearchSpr, #SwapMyStatus, 1)
  else
    sendSprite(NaviPrivateSearchSpr, #SwapMyStatus, 0)
  end if
end
