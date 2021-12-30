property scrollOn

on mouseWithin me 
  if the mouseDown and scrollOn then
    sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "hi")
    scrollByLine(member("messenger.message"), -1)
  else
    sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1])
    scrollOn = 0
  end if
end

on mouseUp me 
  scrollOn = 0
end

on mouseDown me 
  scrollOn = 1
  sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "hi")
  scrollByLine(member("messenger.message"), -1)
end
