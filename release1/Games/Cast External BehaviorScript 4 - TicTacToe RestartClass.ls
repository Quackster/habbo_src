global gTicTacToe

on new me
  return me
end

on mouseDown me
  sendItemMessage(gTicTacToe, "RESTART")
end
