global gPostitCounter

on postItNew stripItemId
  if gPostitCounter < 40 then
    spr = sprMan_getPuppetSprite()
    sprite(spr).castNum = getmemnum("leftwall post.it")
    o = new(script("PostItAdder Class"), spr, stripItemId)
    add(sprite(spr).scriptInstanceList, o)
    setProp(o, #spriteNum, spr)
    beginSprite(o)
  else
    helpText_setText(AddTextToField("NoMorePostits"))
  end if
end

on posterNew stripItemId, ttype
  spr = sprMan_getPuppetSprite()
  sprite(spr).castNum = getmemnum("leftwall poster" && ttype)
  o = new(script("PosterAdder Class"), spr, stripItemId, ttype)
  add(sprite(spr).scriptInstanceList, o)
  setProp(o, #spriteNum, spr)
  beginSprite(o)
end
