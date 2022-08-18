global gRoomModeIndicatorSpr

on beginSprite me
  gRoomModeIndicatorSpr = me.spriteNum
  sprite(me.spriteNum).visible = 0
end

on endSprite me
  sprite(me.spriteNum).visible = 1
end

on setMode me, mode
  sprite(me.spriteNum).visible = 1
  sprite(me.spriteNum).castNum = the number of member ("door_" & mode)
end
