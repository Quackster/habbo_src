on new me 
  return(me)
end

on beginSprite me 
end

on mouseDown me 
  squareSize = 10
  boardMouseDown(gTicTacToe, the mouseH - 6 + sprite(me.spriteNum).left / squareSize, the mouseV - 6 + sprite(me.spriteNum).top / squareSize)
end
