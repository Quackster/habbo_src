global gBackgammon

on new me
  return me
end

on mouseDown
  global gBackgammon
  sendItemMessage(gBackgammon, "CHANGETURN")
end
