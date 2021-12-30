on beginSprite me 
  sprite(me.spriteNum).blend = 0
  iSpr = me.spriteNum
  sprite(sprite(0).number).cursor = ["cursor_cross_mask", sprite(0).number]
end

on endSprite me 
  iSpr = me.spriteNum
  sprite(iSpr).cursor = 0
end

on mouseLeave me 
end

on mouseWithin me 
end

on mouseUp me 
end

on mouseDown me 
  tFlag = 0
  i = 614
  repeat while i <= 662
    tid = void()
    tList = sprite(i).scriptInstanceList
    if tList.count > 0 then
      if tList.getAt(1).handlers().getOne(#checkPos) > 0 then
        tid = call(#checkPos, sprite(i).scriptInstanceList, #mouseDown)
      end if
    end if
    if not voidp(tid) then
      call(#mouseUp, sprite(i).scriptInstanceList)
      put("click" && tid)
      tFlag = 1
    else
      i = (i + 1)
      i = (1 + i)
    end if
  end repeat
  if tFlag then
    return()
  end if
  if the mouseLoc.inside(sprite(637).rect) then
    call(#mouseDown, sprite(637).scriptInstanceList)
    tFlag = 1
  end if
  if tFlag then
    return()
  end if
  if the mouseLoc.inside(sprite(612).rect) then
    if not objectp(gTraderWindow) then
      return()
    end if
    if not objectp(gTraderWindow.pItemMoverObj) then
      return()
    end if
    tDraggedItemID = gTraderWindow.pItemMoverObj.kill()
    tDraggedItemSpr = sendAllSprites(#returnSprByID, tDraggedItemID)
    if not voidp(tDraggedItemSpr) then
      sprite(tDraggedItemSpr).visible = 1
      sprite(tDraggedItemSpr).blend = 100
    end if
    gTraderWindow.pItemMoverObj = void()
  end if
end
