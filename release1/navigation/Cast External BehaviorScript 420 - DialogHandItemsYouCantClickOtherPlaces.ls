property spriteNum

on beginSprite me
  sprite(me.spriteNum).blend = 0
  iSpr = me.spriteNum
  set the cursor of sprite iSpr to [the number of member "cursor_cross", the number of member "cursor_cross_mask"]
end

on endSprite me
  iSpr = me.spriteNum
  set the cursor of sprite iSpr to 0
end

on mouseLeave me
end

on mouseWithin me
end

on mouseUp me
end

on mouseDown me
  global gTraderWindow
  tFlag = 0
  repeat with i = 614 to 662
    tid = VOID
    tList = sprite(i).scriptInstanceList
    if tList.count > 0 then
      if tList[1].handlers().getOne(#checkPos) > 0 then
        tid = call(#checkPos, sprite(i).scriptInstanceList, #mouseDown)
      end if
    end if
    if not voidp(tid) then
      call(#mouseUp, sprite(i).scriptInstanceList)
      put "click" && tid
      tFlag = 1
      exit repeat
    end if
    i = i + 1
  end repeat
  if tFlag then
    return 
  end if
  if (the mouseLoc).inside(sprite(637).rect) then
    call(#mouseDown, sprite(637).scriptInstanceList)
    tFlag = 1
  end if
  if tFlag then
    return 
  end if
  if (the mouseLoc).inside(sprite(612).rect) then
    if not objectp(gTraderWindow) then
      return 
    end if
    if not objectp(gTraderWindow.pItemMoverObj) then
      return 
    end if
    tDraggedItemID = gTraderWindow.pItemMoverObj.kill()
    tDraggedItemSpr = sendAllSprites(#returnSprByID, tDraggedItemID)
    if not voidp(tDraggedItemSpr) then
      sprite(tDraggedItemSpr).visible = 1
      sprite(tDraggedItemSpr).blend = 100
    end if
    gTraderWindow.pItemMoverObj = VOID
  end if
end
