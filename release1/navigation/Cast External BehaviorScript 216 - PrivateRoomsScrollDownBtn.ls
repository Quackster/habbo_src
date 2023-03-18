property Active
global gPrivateDropMem, FirstPlaceNow, SrollDirection

on beginSprite me
  Active = 1
end

on mouseDown me
  if Active = 1 then
    sprite(me.spriteNum).member = "scroll_Down_active_hi"
  end if
end

on mouseUp me
  case member(gPrivateDropMem).name of
    "0.item.DropList":
      if Active = 1 then
        sprite(me.spriteNum).member = "scroll_Down_active"
        FirstPlaceNow = FirstPlaceNow + 11
        sendEPFuseMsg("SEARCHBUSYFLATS /" & FirstPlaceNow & ",11")
      else
        sprite(me.spriteNum).member = "scroll_Down_inactive"
      end if
      put "Scrolling popular rooms list"
    "1.item.DropList":
      if Active = 1 then
        sprite(me.spriteNum).member = "scroll_Down_active"
      else
        sprite(me.spriteNum).member = "scroll_Down_inactive"
      end if
      put "Scrolling search list"
    "2.item.DropList":
      if Active = 1 then
        sprite(me.spriteNum).member = "scroll_Down_active"
      else
        sprite(me.spriteNum).member = "scroll_Down_inactive"
      end if
      put "Scrolling own rooms list"
    "3.item.DropList":
      if Active = 1 then
        sprite(me.spriteNum).member = "scroll_Down_active"
      else
        sprite(me.spriteNum).member = "scroll_Down_inactive"
      end if
      put "Scrolling favorites list"
  end case
end
