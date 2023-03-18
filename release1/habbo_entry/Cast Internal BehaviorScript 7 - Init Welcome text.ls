on beginSprite me
  global gLoginName
  if the movieName contains "cr_entry" then
    put "Welcome to Crossroads," into line 1 of field the name of the member of sprite(the spriteNum of me)
  else
    put "Welcome to Habbo Hotel," into line 1 of field the name of the member of sprite(the spriteNum of me)
  end if
  put gLoginName into line 2 of field the name of the member of sprite(the spriteNum of me)
end
