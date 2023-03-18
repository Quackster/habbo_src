property context
global gChess

on new me
  return me
end

on mouseDown me
  goContext("chessgame", me.context)
  sendItemMessage(gChess, "RESTART")
end
