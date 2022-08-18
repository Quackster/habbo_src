property tlocz

on beginSprite me
  sprite(me.spriteNum).locZ = tlocz
end

on endSprite me
  sprite(me.spriteNum).locZ = me.spriteNum
end

on getPropertyDescriptionList me
  return [#tlocz: [#comment: "LocZ", #format: #integer, #default: 1000000000]]
end
