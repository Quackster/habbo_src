global gTicTacToe

on new me
  return me
end

on beginSprite me
end

on mouseDown me
  squareSize = 10
  boardMouseDown(gTicTacToe, (the mouseH - (6 + the left of sprite me.spriteNum)) / squareSize, (the mouseV - (6 + the top of sprite me.spriteNum)) / squareSize)
end
