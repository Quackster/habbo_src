global gChess

on new me
  return me
end

on mouseDown me
  sendItemMessage(gChess, "SENDHISTORY")
end
