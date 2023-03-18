property itemType, spr
global gpopUpAdder, gpPostItNos, gPostitCounter

on new me, ttype, stripItemId, tPostItCount
  put "gPostitCounter:" && gPostitCounter
  if gPostitCounter < 40 then
    spr = sprMan_getPuppetSprite()
    sprite(spr).castNum = getmemnum("leftwall post.it")
    o = new(script("PostItAdder Class"), spr, stripItemId)
    add(sprite(spr).scriptInstanceList, o)
    setProp(o, #spriteNum, spr)
    beginSprite(o)
    put o
    return o
  else
    helpText_setText(AddTextToField("NoMorePostits"))
  end if
end
