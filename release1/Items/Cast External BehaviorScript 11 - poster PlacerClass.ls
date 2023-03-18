property itemType, spr

on new me, titemType, stripItemId, ttype
  if voidp(ttype) then
    ttype = 1
    put "Poster type not defined!!!"
  end if
  pType = ttype
  spr = sprMan_getPuppetSprite()
  sprite(spr).castNum = getmemnum("leftwall poster" && pType)
  o = new(script("PosterAdder Class"), spr, stripItemId, pType)
  add(sprite(spr).scriptInstanceList, o)
  setProp(o, #spriteNum, spr)
  beginSprite(o)
  return o
end
