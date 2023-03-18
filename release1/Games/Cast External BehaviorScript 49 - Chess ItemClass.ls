property ancestor, spr, locX, locY, locHeight, lPieceSprites, chessBoardSprite, chessBoardLocZ, chessSquareSize, dragPieceObj, bothTypeChosen, chosenType, pieceData
global gpInteractiveItems, gChess, gGameContext, gpObjects, gMyName, chessBoardLoc

on new me, towner, tlocation, tid, tdata
  ancestor = new(script("InteractiveItem Abstract"), towner, tlocation, tid, tdata)
  lPieceSprites = []
  chessBoardLocZ = 2010000000
  chessSquareSize = 27
  dragPieceObj = VOID
  setaProp(gpInteractiveItems, me.id, me)
  me.itemType = "Chess"
  chosenType = VOID
  if the movieName contains "private" then
    Initialize(me)
  end if
  return me
end

on Initialize me
  oldDelim = the itemDelimiter
  the itemDelimiter = ","
  me.locX = integer(item 1 of the location of me)
  me.locY = integer(item 2 of the location of me)
  me.locHeight = integer(item 3 of the location of me)
  spr = sprMan_getPuppetSprite()
  sprite(spr).castNum = getmemnum("Chess_small")
  sprite(spr).scriptInstanceList = [me]
  screenLoc = getScreenCoordinate(me.locX, me.locY, me.locHeight)
  sprite(spr).loc = point(screenLoc[1], screenLoc[2])
  sprite(spr).locZ = screenLoc[3]
  put "Chess has sprite=", spr
  the itemDelimiter = oldDelim
end

on itemDie me, itemId
  if itemId = me.id then
    close(me)
    if spr > 0 then
      sprMan_releaseSprite(spr)
    end if
  end if
end

on processItemMessage me, content
  put content
  ln1 = line 2 of content
  if ln1 contains "PIECEDATA" then
    data = line 3 to the number of lines in content of content
    setOpponents(me, line 1 to 2 of data)
    data = line 3 to the number of lines in data of data
    pieceData = data
    if gGameContext.frame = VOID then
      if bothTypeChosen = 0 then
        displayFrame(gGameContext, "chesschoosepart")
      else
        displayFrame(gGameContext, "chessgame")
        setupPieces(me, pieceData)
      end if
    else
      if (chosenType <> VOID) and (gGameContext.frame = "chessgame") then
        setupPieces(me, pieceData)
      end if
    end if
  else
    if ln1 contains "SELECTTYPE" then
      chosenType = word 2 of line 2 of content
      displayFrame(gGameContext, "chessgame")
    else
      if ln1 contains "OPPONENTS" then
        setOpponents(me, line 3 to 4 of content)
      else
        if ln1 contains "TYPERESERVED" then
          beep(1)
        end if
      end if
    end if
  end if
end

on setupPieces me, data
  if voidp(data) then
    return 
  end if
  wc = the number of words in data
  if voidp(lPieceSprites) or (count(lPieceSprites) = 0) then
    lPieceSprites = []
    repeat with i = 1 to wc
      s = word i of data
      if s.length = 5 then
        add(lPieceSprites, sprMan_getPuppetSprite())
      end if
    end repeat
  end if
  j = 0
  repeat with i = 1 to wc
    s = word i of data
    if s.length = 5 then
      j = j + 1
      pieceMember = getmemnum(char 1 to 3 of s)
      pieceCoordinate = char 4 to 5 of s
      sprite(lPieceSprites[j]).castNum = pieceMember
      o = new(script("ChessPiece Class"), char 1 to 3 of s, lPieceSprites[j], me)
      sprite(lPieceSprites[j]).scriptInstanceList = [o]
      sprite(lPieceSprites[j]).locZ = chessBoardLocZ + 2
      locatePiece(o, pieceCoordinate)
    end if
  end repeat
end

on drag me, pieceObj
  dragPieceObj = pieceObj
end

on stopdrag me
  if dragPieceObj = VOID then
    return 
  end if
  relativePlace = sprite(dragPieceObj.pieceSprite).loc - chessBoardLoc
  xcoord = relativePlace[1] / chessSquareSize
  ycoord = 9 - ((relativePlace[2] / chessSquareSize) + 1)
  if (xcoord >= 0) and (xcoord < 8) and (ycoord > 0) and (ycoord <= 8) then
    locatePiece(dragPieceObj, dragPieceObj.pieceCoordinate)
    sendItemMessage(me, "MOVEPIECE" && dragPieceObj.pieceCoordinate && numToChar(97 + xcoord) & ycoord)
  else
    locatePiece(dragPieceObj, dragPieceObj.pieceCoordinate)
  end if
  oldDragPieceObj = dragPieceObj
  dragPieceObj = VOID
  return oldDragPieceObj
end

on selectType me, tictype
  chosenType = tictype
  sendItemMessage(me, "CHOOSETYPE" && chosenType)
end

on exitFrame me
  if not voidp(dragPieceObj) then
    sprite(dragPieceObj.pieceSprite).loc = the mouseLoc
  end if
end

on setOpponents me, data
  member("opponent.W").text = "White:" & RETURN & word 2 of line 1 of data
  member("opponent.B").text = "Black:" & RETURN & word 2 of line 2 of data
  member("chess.game_status").text = "White:" && word 2 of line 1 of data & RETURN & "Black:" && word 2 of line 2 of data
  if ((line 1 of data).length > 3) and ((line 2 of data).length > 3) then
    bothTypeChosen = 1
  else
    bothTypeChosen = 0
  end if
end

on mouseDown me
  if the doubleClick then
    if count(lPieceSprites) = 0 then
      gGameContext = VOID
      open(me)
    else
      close(me)
    end if
  else
    select(me)
  end if
end

on open me, content
  gChess = me
  sendItemMessage(me, "OPEN")
  if not voidp(gGameContext) then
    close(gGameContext)
  end if
  myUserLoc = sprite(getaProp(gpObjects, gMyName)).loc
  if myUserLoc[1] > 400 then
    p = point(40, 70)
  else
    p = point(400, 70)
  end if
  gGameContext = new(script("PopUp Context Class"), 2000000000, 30, 99, p)
end

on releasePieces me
  if count(lPieceSprites) > 0 then
    repeat with spri in lPieceSprites
      sprMan_releaseSprite(spri)
    end repeat
  end if
  lPieceSprites = [:]
end

on close me
  sendItemMessage(me, "CLOSE")
  releasePieces(me)
  close(gGameContext)
  gChess = VOID
end
