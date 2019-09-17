property pieceCoordinate, pieceSprite, newLoc, pieceName, animateStart, oldLoc

on new me, tPieceName, spr 
  pieceSprite = spr
  pieceName = tPieceName
  dragging = 0
  pieceCoordinate = void()
  return(me)
end

on locatePiece me, coordinate 
  chessBoardLoc = sprite(gChessBoardSprite).loc
  x = charToNum(coordinate.char[1]) - 97
  y = 9 - integer(coordinate.char[2])
  if pieceCoordinate <> void() then
    oldLoc = sprite(pieceSprite).loc
    animateStart = the milliSeconds
  end if
  newLoc = chessBoardLoc + point(x, y - 1) * gChess.chessSquareSize + point(gChess.chessSquareSize, gChess.chessSquareSize) * 0.5
  if pieceCoordinate = void() then
    sprite(pieceSprite).loc = newLoc
  end if
  pieceCoordinate = coordinate
end

on mouseDown me 
  dragged = stopdrag(gChess)
  put(pieceName)
  if dragged <> me and pieceName.char[1] = gChess.chosenType then
    drag(gChess, me)
  end if
end

on exitFrame me 
  if the milliSeconds - animateStart <= 2000 then
    f = the milliSeconds - animateStart * 1 / 2000
    sprite(pieceSprite).locH = integer(oldLoc.getAt(1) + f * newLoc.getAt(1) - oldLoc.getAt(1))
    sprite(pieceSprite).locV = integer(oldLoc.getAt(2) + f * newLoc.getAt(2) - oldLoc.getAt(2))
  else
    if newLoc <> void() then
      sprite(pieceSprite).loc = newLoc
      newLoc = void()
    end if
  end if
end
