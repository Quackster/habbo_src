global chessBoardLoc, gChess, gChessBoardSprite

on beginSprite me
  gChessBoardSprite = me.spriteNum
end

on exitFrame me
  exitFrame(gChess)
end
