property spr, bothTypeChosen, pieceData, chosenType, lPieceSprites, chessBoardLocZ, dragPieceObj, chessSquareSize

on new me, towner, tlocation, tid, tdata 
  ancestor = new(script("InteractiveItem Abstract"), towner, tlocation, tid, tdata)
  lPieceSprites = []
  chessBoardLocZ = 2010000000
  chessSquareSize = 27
  dragPieceObj = void()
  setaProp(gpInteractiveItems, me.id, me)
  me.itemType = "Chess"
  chosenType = void()
  if the movieName contains "private" then
    Initialize(me)
  end if
  return(me)
end

on Initialize me 
  oldDelim = the itemDelimiter
  the itemDelimiter = ","
  me.locX = integer(me.location.item[1])
  me.locY = integer(me.location.item[2])
  me.locHeight = integer(me.location.item[3])
  spr = sprMan_getPuppetSprite()
  sprite(spr).castNum = getmemnum("Chess_small")
  sprite(spr).scriptInstanceList = [me]
  screenLoc = getScreenCoordinate(me.locX, me.locY, me.locHeight)
  sprite(spr).loc = point(screenLoc.getAt(1), screenLoc.getAt(2))
  sprite(spr).locZ = screenLoc.getAt(3)
  put("Chess has sprite=", spr)
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
  put(content)
  ln1 = content.line[2]
  if ln1 contains "PIECEDATA" then
    Data = content.line[3..the number of line in content]
    setOpponents(me, Data.line[1..2])
    Data = Data.line[3..the number of line in Data]
    pieceData = Data
    if gGameContext.frame = void() then
      if bothTypeChosen = 0 then
        displayFrame(gGameContext, "chesschoosepart")
      else
        displayFrame(gGameContext, "chessgame")
        setupPieces(me, pieceData)
      end if
    else
      if chosenType <> void() and gGameContext.frame = "chessgame" then
        setupPieces(me, pieceData)
      end if
    end if
  else
    if ln1 contains "SELECTTYPE" then
      chosenType = content.word[2]
      displayFrame(gGameContext, "chessgame")
    else
      if ln1 contains "OPPONENTS" then
        setOpponents(me, content.line[3..4])
      else
        if ln1 contains "TYPERESERVED" then
          beep(1)
        end if
      end if
    end if
  end if
end

on setupPieces me, Data 
  if voidp(Data) then
    return()
  end if
  wc = the number of word in Data
  if voidp(lPieceSprites) or count(lPieceSprites) = 0 then
    lPieceSprites = []
    i = 1
    repeat while i <= wc
      s = Data.word[i]
      if s.length = 5 then
        add(lPieceSprites, sprMan_getPuppetSprite())
      end if
      i = 1 + i
    end repeat
  end if
  j = 0
  i = 1
  repeat while i <= wc
    s = Data.word[i]
    if s.length = 5 then
      j = j + 1
      pieceMember = getmemnum(s.char[1..3])
      pieceCoordinate = s.char[4..5]
      sprite(lPieceSprites.getAt(j)).castNum = pieceMember
      o = new(script("ChessPiece Class"), s.char[1..3], lPieceSprites.getAt(j), me)
      sprite(lPieceSprites.getAt(j)).scriptInstanceList = [o]
      sprite(lPieceSprites.getAt(j)).locZ = chessBoardLocZ + 2
      locatePiece(o, pieceCoordinate)
    end if
    i = 1 + i
  end repeat
end

on drag me, pieceObj 
  dragPieceObj = pieceObj
end

on stopdrag me 
  if dragPieceObj = void() then
    return()
  end if
  relativePlace = sprite(dragPieceObj.pieceSprite).loc - chessBoardLoc
  xcoord = relativePlace.getAt(1) / chessSquareSize
  ycoord = 9 - relativePlace.getAt(2) / chessSquareSize + 1
  if xcoord >= 0 and xcoord < 8 and ycoord > 0 and ycoord <= 8 then
    locatePiece(dragPieceObj, dragPieceObj.pieceCoordinate)
    sendItemMessage(me, "MOVEPIECE" && dragPieceObj.pieceCoordinate && numToChar(97 + xcoord) & ycoord)
  else
    locatePiece(dragPieceObj, dragPieceObj.pieceCoordinate)
  end if
  oldDragPieceObj = dragPieceObj
  dragPieceObj = void()
  return(oldDragPieceObj)
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

on setOpponents me, Data 
  member("opponent.W").text = "White:" & "\r" & Data.word[2]
  member("opponent.B").text = "Black:" & "\r" & Data.word[2]
  member("chess.game_status").text = "White:" && Data.word[2] & "\r" & "Black:" && Data.word[2]
  if Data.line[1].length > 3 and Data.line[2].length > 3 then
    bothTypeChosen = 1
  else
    bothTypeChosen = 0
  end if
end

on mouseDown me 
  if the doubleClick then
    if count(lPieceSprites) = 0 then
      gGameContext = void()
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
  if myUserLoc.getAt(1) > 400 then
    p = point(40, 70)
  else
    p = point(400, 70)
  end if
  gGameContext = new(script("PopUp Context Class"), 2000000000, 30, 99, p)
end

on releasePieces me 
  if count(lPieceSprites) > 0 then
    repeat while lPieceSprites <= undefined
      spri = getAt(undefined, undefined)
      sprMan_releaseSprite(spri)
    end repeat
  end if
  lPieceSprites = [:]
end

on close me 
  sendItemMessage(me, "CLOSE")
  releasePieces(me)
  close(gGameContext)
  gChess = void()
end
