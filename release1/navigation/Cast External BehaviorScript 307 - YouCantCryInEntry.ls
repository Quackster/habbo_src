on beginSprite me
  member("hobba_crymessage_field").text = EMPTY
  member("hobba_crymessage_field").font = "Volter (goldfish)"
  if the movieName contains "entry" then
    sprite(me.spriteNum).visible = 0
  else
    sprite(me.spriteNum).visible = 1
  end if
end
