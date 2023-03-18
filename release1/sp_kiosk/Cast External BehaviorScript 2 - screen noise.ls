on exitFrame me
  if random(50) = 1 then
    set the blend of sprite the spriteNum of me to 18
  else
    set the blend of sprite the spriteNum of me to 5
  end if
  set the locV of sprite the spriteNum of me to random(298) + 90
end
