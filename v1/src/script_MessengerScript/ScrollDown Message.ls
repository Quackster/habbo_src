on mouseWithin me 
  if the mouseDown then
    sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "hi")
    scrollByLine(member("messenger.message"), 1)
  else
    sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1])
    scrollOn = 0
  end if
end

on mouseUp me 
  scrollOn = 0
end

on mouseDown me 
  sprite(me.spriteNum).castNum = getmemnum(sprite(me.spriteNum).member.name.word[1] && "hi")
  scrollByLine(member("messenger.message"), 1)
end
