on beginSprite me
end

on mouseDown me
  ml = ((the mouseV - the top of sprite me.spriteNum) / 12) + 1
  put ml
  if ml > 0 then
    flat = line ml of the text of member "flat_results.names"
    put "Go to:", flat
    sendEPFuseMsg("GETFLATINFO /" & flat)
  end if
end
