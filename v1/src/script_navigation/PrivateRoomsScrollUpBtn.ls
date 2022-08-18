property Active

on beginSprite me 
  Active = 1
end

on mouseDown me 
  if (Active = 1) then
    sprite(me.spriteNum).member = "scroll_Up_active_hi"
  end if
end

on mouseUp me 
  if (member(gPrivateDropMem).name = "0.item.DropList") then
    if (Active = 1) then
      sprite(me.spriteNum).member = "scroll_Up_active"
      FirstPlaceNow = (FirstPlaceNow - 11)
      if FirstPlaceNow < 0 then
        FirstPlaceNow = 0
      end if
      sendEPFuseMsg("SEARCHBUSYFLATS /" & FirstPlaceNow & ",11")
    else
      sprite(me.spriteNum).member = "scroll_Up_inactive"
    end if
    put("Scrolling popular rooms list")
  else
    if (member(gPrivateDropMem).name = "1.item.DropList") then
      if (Active = 1) then
        sprite(me.spriteNum).member = "scroll_Up_active"
      else
        sprite(me.spriteNum).member = "scroll_Up_inactive"
      end if
      put("Scrolling search list")
    else
      if (member(gPrivateDropMem).name = "2.item.DropList") then
        if (Active = 1) then
          sprite(me.spriteNum).member = "scroll_Up_active"
        else
          sprite(me.spriteNum).member = "scroll_Up_inactive"
        end if
        put("Scrolling own rooms list")
      else
        if (member(gPrivateDropMem).name = "3.item.DropList") then
          if (Active = 1) then
            sprite(me.spriteNum).member = "scroll_Up_active"
          else
            sprite(me.spriteNum).member = "scroll_Up_inactive"
          end if
          put("Scrolling favorites list")
        end if
      end if
    end if
  end if
end
