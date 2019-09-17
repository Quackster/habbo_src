property dragOn, lastm

on exitFrame me 
  if the mouseDown and dragOn then
    p = the mouseLoc - lastm
    if p <> point(0, 0) then
      context = getaProp(me, #context)
      if context <> void() then
        move(context, p.getAt(1), p.getAt(2))
      end if
      if not voidp(gChess) then
        if gGameContext.frame = "chessgame" then
          setupPieces(gChess, gChess.pieceData)
        end if
      end if
      lastm = the mouseLoc
    end if
  else
    dragOn = 0
  end if
end

on mouseDown me 
  dragOn = 1
  lastm = the mouseLoc
end
