on beginSprite me 
  if (gPrivateDropStatus = void()) then
    gDropListSpr = me.spriteNum
    if (gPrivateDropStatus = void()) then
      gPrivateDropMem = sprite(me.spriteNum).member.name
    end if
    DropListItemA = ((me.spriteNum + value(sprite(me.spriteNum).member.name.getProp(#char, 1, 1))) + 1)
    gPrivateDropMem.member = member(sprite(0).number)
    gPrivateDropStatus = 0
    member(getmemnum("flatquery")).text = ""
    UpdPopularTime = (the ticks + (10 * 60))
  else
    sprite(me.spriteNum).member = gPrivateDropMem
  end if
end

on mouseDown me 
  gPrivateDropStatus = 1
  DropListV = (((value(sprite(me.spriteNum).member.name.getProp(#char, 1, 1)) * 17) + (sprite(me.spriteNum).height / 2)) + 1)
  nextItemV = 0
  f = (me.spriteNum + 1)
  repeat while f <= (me.spriteNum + 5)
    sendSprite(f, #ActivateDropListItem, integer(((me.spriteNum + sprite(me.spriteNum).member.name.getProp(#char, 1, 1)) + 1)))
    sendSprite(f, #SetMyLocVTo, (((sprite(me.spriteNum).locV - DropListV) + nextItemV) + value(sprite(me.spriteNum).member.name.getProp(#char, 1, 1))))
    nextItemV = (nextItemV + sprite((me.spriteNum + 1)).height)
    f = (1 + f)
  end repeat
  waitAmom = (the timer + 10)
  repeat while waitAmom > the timer
    nothing()
  end repeat
end

on enterFrame me 
  if (member(gPrivateDropMem).name = "0.item.DropList") and the ticks > UpdPopularTime then
    sendSprite((me.spriteNum + 1), #UpdateBusyFlats)
    UpdPopularTime = (the ticks + (10 * 60))
  end if
end
