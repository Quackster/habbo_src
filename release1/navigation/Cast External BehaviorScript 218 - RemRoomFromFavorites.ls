property spriteNum

on mouseDown me
  sprite(spriteNum).member = member(getmemnum("removefromfavorites_btn_e_hi"))
end

on mouseUp me
  global gChosenFlatId
  if not voidp(gChosenFlatId) then
    sendEPFuseMsg("REM_FAVORITE_ROOM" && gChosenFlatId)
  end if
  sprite(spriteNum).member = member(getmemnum("removefromfavorites_btn_e"))
  put "Room" && gChosenFlatId && "removed from favorites...!"
end

on mouseUpOutSide me
  sprite(spriteNum).member = member(getmemnum("removefromfavorites_btn_e"))
end

on exitFrame me
  global gPrivateDropMem
  if member(gPrivateDropMem).name <> "3.item.DropList" then
    sprite(spriteNum).member = member(getmemnum("addtofavorites_btn_e"))
    sprite(spriteNum).scriptInstanceList = [script("AddRoomToFavorites")]
  end if
end
