property ancestor, spr, locX, locY, locHeight, isOpen, pPieces, myColor
global gpInteractiveItems, gGameContext, gBackgammon, gBGBoardSprite, gpObjects, gMyName, gBgDices

on new me, towner, tlocation, tid, tdata
  ancestor = new(script("InteractiveItem Abstract"), towner, tlocation, tid, tdata)
  if the movieName contains "private" then
    Initialize(me)
  end if
  isOpen = 0
  setaProp(gpInteractiveItems, me.id, me)
  me.itemType = "Backgammon"
  gBackgammon = me
  return me
end

on Initialize me
end

on open me, content
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

on close me
  isOpen = 0
  sendItemMessage(me, "CLOSE")
  close(gGameContext)
end

on itemDie me, itemId
  if itemId = me.id then
    close(me)
  end if
end

on register me, piece
  add(getaProp(pPieces, piece.color), piece)
end

on handleBoardData me, s
  put "Valkoinen:" && s.line[1].word[2] & RETURN & "Musta:" && s.line[2].word[2] into field "bg.opponents"
  dices = line 3 of s
  sendSprite(gBgDices[1], #setUsed, word 1 of dices = "true")
  sendSprite(gBgDices[2], #setUsed, word 2 of dices = "true")
  if s.line[1].word[2] = gMyName then
    myColor = 0
  else
    myColor(1)
  end if
  boardMem = member(getmemnum("backgammon_board"))
  pieceMems = [member(getmemnum("bgpiece.0")), member(getmemnum("bgpiece.1"))]
  piecer = pieceMems[1].width
  slotw = boardMem.width * 1.0 / 12.0
  counter = [0, 0]
  repeat with slot = 1 to 24
    ln = line 3 + slot of s
    the itemDelimiter = "/"
    pieces = item 2 of ln
    repeat with j = 1 to the number of chars in pieces
      p = integer(char j of pieces) + 1
      counter[p] = counter[p] + 1
      pieceObj = pPieces[p][counter[p]]
      if slot <= 12 then
        x = sprite(gBGBoardSprite).locH - boardMem.regPoint[1] + ((slot - 1) * slotw)
        y = sprite(gBGBoardSprite).locV - boardMem.regPoint[2] + boardMem.height - (j * piecer)
      else
        x = sprite(gBGBoardSprite).locH - boardMem.regPoint[1] + ((24 - slot) * slotw)
        y = sprite(gBGBoardSprite).locV - boardMem.regPoint[2] + ((j - 1) * piecer)
      end if
      put pieceObj.spriteNum, point(integer(x), y), sprite(gBGBoardSprite).locH, slot, slotw
      pieceObj.slot = slot
      sprite(pieceObj.spriteNum).loc = point(integer(x), integer(y))
    end repeat
  end repeat
  pieces = s.line[the number of lines in s]
  repeat with j = 1 to the number of chars in pieces
    p = integer(char j of pieces) + 1
    counter[p] = counter[p] + 1
    pieceObj = pPieces[p][counter[p]]
    x = sprite(gBGBoardSprite).locH - boardMem.regPoint[1] + (boardMem.width / 2)
    y = sprite(gBGBoardSprite).locV - boardMem.regPoint[2] + boardMem.height - (j * piecer)
    pieceObj.slot = -1
    sprite(pieceObj.spriteNum).loc = point(integer(x), integer(y))
  end repeat
  the itemDelimiter = ","
end

on processItemMessage me, data
  ln1 = line 2 of data
  content = line 3 to the number of lines in data of data
  put data
  if ln1 contains "BOARDDATA" then
    if isOpen = 0 then
      pPieces = [0: [], 1: []]
      displayFrame(gGameContext, "bg.board")
      isOpen = 1
    end if
    handleBoardData(me, content)
  end if
  if ln1 contains "TURN" then
    ln2 = line 3 of data
    num = integer(word 1 of ln2)
    dice1 = integer(word 2 of ln2)
    dice2 = integer(word 3 of ln2)
    if num = myColor then
      put "Valitse mitŠ nappulaa haluat siirtŠŠ, ja minkŠ nopan mukaan" into field "bg.status"
    else
      put "Vastapelurin vuoro" into field "bg.status"
    end if
    sendSprite(gBgDices[1], #set, dice1)
    sendSprite(gBgDices[2], #set, dice2)
  end if
end
