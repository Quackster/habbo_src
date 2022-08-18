property pPieces, isOpen, myColor

on new me, towner, tlocation, tid, tdata 
  ancestor = new(script("InteractiveItem Abstract"), towner, tlocation, tid, tdata)
  if the movieName contains "private" then
    Initialize(me)
  end if
  isOpen = 0
  setaProp(gpInteractiveItems, me.id, me)
  me.itemType = "Backgammon"
  gBackgammon = me
  return(me)
end

on Initialize me 
end

on open me, content 
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

on close me 
  isOpen = 0
  sendItemMessage(me, "CLOSE")
  close(gGameContext)
end

on itemDie me, itemId 
  if (itemId = me.id) then
    close(me)
  end if
end

on register me, piece 
  add(getaProp(pPieces, piece.color), piece)
end

on handleBoardData me, s 
  dices = s.line[3]
  sendSprite(gBgDices.getAt(1), #setUsed, (dices.word[1] = "true"))
  sendSprite(gBgDices.getAt(2), #setUsed, (dices.word[2] = "true"))
  if (s.getPropRef(#line, 1).getProp(#word, 2) = gMyName) then
    myColor = 0
  else
    myColor(1)
  end if
  boardMem = member(getmemnum("backgammon_board"))
  pieceMems = [member(getmemnum("bgpiece.0")), member(getmemnum("bgpiece.1"))]
  piecer = pieceMems.getAt(1).width
  slotw = ((boardMem.width * 1) / 12)
  counter = [0, 0]
  slot = 1
  repeat while slot <= 24
    ln = s.line[(3 + slot)]
    the itemDelimiter = "/"
    pieces = ln.item[2]
    j = 1
    repeat while j <= the number of char in pieces
      p = (integer(pieces.char[j]) + 1)
      counter.setAt(p, (counter.getAt(p) + 1))
      pieceObj = pPieces.getAt(p).getAt(counter.getAt(p))
      if slot <= 12 then
        x = ((sprite(gBGBoardSprite).locH - boardMem.getProp(#regPoint, 1)) + ((slot - 1) * slotw))
        y = (((sprite(gBGBoardSprite).locV - boardMem.getProp(#regPoint, 2)) + boardMem.height) - (j * piecer))
      else
        x = ((sprite(gBGBoardSprite).locH - boardMem.getProp(#regPoint, 1)) + ((24 - slot) * slotw))
        y = ((sprite(gBGBoardSprite).locV - boardMem.getProp(#regPoint, 2)) + ((j - 1) * piecer))
      end if
      put(pieceObj.spriteNum, point(integer(x), y), sprite(gBGBoardSprite).locH, slot, slotw)
      pieceObj.slot = slot
      sprite(pieceObj.spriteNum).loc = point(integer(x), integer(y))
      j = (1 + j)
    end repeat
    slot = (1 + slot)
  end repeat
  pieces = s.getProp(#line, the number of line in s)
  j = 1
  repeat while j <= the number of char in pieces
    p = (integer(pieces.char[j]) + 1)
    counter.setAt(p, (counter.getAt(p) + 1))
    pieceObj = pPieces.getAt(p).getAt(counter.getAt(p))
    x = ((sprite(gBGBoardSprite).locH - boardMem.getProp(#regPoint, 1)) + (boardMem.width / 2))
    y = (((sprite(gBGBoardSprite).locV - boardMem.getProp(#regPoint, 2)) + boardMem.height) - (j * piecer))
    pieceObj.slot = -1
    sprite(pieceObj.spriteNum).loc = point(integer(x), integer(y))
    j = (1 + j)
  end repeat
  the itemDelimiter = ","
end

on processItemMessage me, data 
  ln1 = data.line[2]
  content = data.line[3..the number of line in data]
  put(data)
  if ln1 contains "BOARDDATA" then
    if (isOpen = 0) then
      pPieces = [0:[], 1:[]]
      displayFrame(gGameContext, "bg.board")
      isOpen = 1
    end if
    handleBoardData(me, content)
  end if
  if ln1 contains "TURN" then
    ln2 = data.line[3]
    num = integer(ln2.word[1])
    dice1 = integer(ln2.word[2])
    dice2 = integer(ln2.word[3])
    if (num = myColor) then
    else
    end if
    sendSprite(gBgDices.getAt(1), #set, dice1)
    sendSprite(gBgDices.getAt(2), #set, dice2)
  end if
end
