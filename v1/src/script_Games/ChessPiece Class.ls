property pieceName, pieceCoordinate, pieceSprite, chessBoardObj, dragging, animateStart, newLoc, oldLoc
global gChess, chessBoardLoc, gChessBoardSprite

on new me, tPieceName, spr
  pieceSprite = spr
  pieceName = tPieceName
  dragging = 0
  pieceCoordinate = VOID
  return me
end

on locatePiece me, coordinate
  chessBoardLoc = sprite(gChessBoardSprite).loc
  x = (charToNum(char 1 of coordinate) - 97)
  y = (9 - integer(char 2 of coordinate))
  if (pieceCoordinate <> VOID) then
    oldLoc = sprite(pieceSprite).loc
    animateStart = the milliSeconds
  end if
  newLoc = ((chessBoardLoc + (point(x, (y - 1)) * gChess.chessSquareSize)) + (point(gChess.chessSquareSize, gChess.chessSquareSize) * 0.5))
  if (pieceCoordinate = VOID) then
    sprite(pieceSprite).loc = newLoc
  end if
  pieceCoordinate = coordinate
end

on mouseDown me
  dragged = stopdrag(gChess)
  put pieceName
  if ((dragged <> me) and (char 1 of pieceName = gChess.chosenType)) then
    drag(gChess, me)
  end if
end

on exitFrame me
  if ((the milliSeconds - animateStart) <= 2000) then
    f = (((the milliSeconds - animateStart) * 1.0) / 2000.0)
    sprite(pieceSprite).locH = integer((oldLoc[1] + (f * (newLoc[1] - oldLoc[1]))))
    sprite(pieceSprite).locV = integer((oldLoc[2] + (f * (newLoc[2] - oldLoc[2]))))
  else
    if (newLoc <> VOID) then
      sprite(pieceSprite).loc = newLoc
      newLoc = VOID
    end if
  end if
end
