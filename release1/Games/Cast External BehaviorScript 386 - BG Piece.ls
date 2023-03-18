property color, slot
global gBackgammon, gBGChosenPiece

on beginSprite me
  register(gBackgammon, me)
end

on getPropertyDescriptionList me
  return [#color: [#comment: "Color", #default: 0, #format: #integer]]
end

on mouseDown me
  n = random(6)
  put "n", n
  call(#reset, gBackgammon.pPieces[1])
  call(#reset, gBackgammon.pPieces[2])
  gBGChosenPiece = me
  hilite(me)
end

on reset me
  sprite(me.spriteNum).castNum = getmemnum("bgpiece." & color)
end

on hilite me
  sprite(me.spriteNum).castNum = getmemnum("bgpiece." & color && "hi")
end
