property spr, chosenType, isOpen, destImage, bothTypeChosen

on new me, towner, tlocation, tid, tdata 
  ancestor = new(script("InteractiveItem Abstract"), towner, tlocation, tid, tdata)
  if the movieName contains "private" then
    Initialize(me)
  end if
  isOpen = 0
  setaProp(gpInteractiveItems, me.id, me)
  me.itemType = "TicTacToe"
  gTicTacToe = me
  return(me)
end

on itemDie me, itemId 
  if itemId = me.id then
    close(me)
    if spr > 0 then
      sprMan_releaseSprite(spr)
    end if
  end if
end

on selectTicType me, tictype 
  chosenType = tictype
  sendItemMessage(me, "CHOOSETYPE" && chosenType)
end

on Initialize me 
  oldDelim = the itemDelimiter
  the itemDelimiter = ","
  me.locX = integer(me.location.item[1])
  me.locY = integer(me.location.item[2])
  me.locHeight = integer(me.location.item[3])
  spr = sprMan_getPuppetSprite()
  sprite(spr).castNum = getmemnum("TicTacToe_small")
  sprite(spr).scriptInstanceList = [me]
  screenLoc = getScreenCoordinate(me.locX, me.locY, me.locHeight)
  sprite(spr).loc = point(screenLoc.getAt(1), screenLoc.getAt(2))
  sprite(spr).locZ = screenLoc.getAt(3)
end

on boardMouseDown me, x, y 
  sendItemMessage(me, "SETSECTOR" && chosenType && x && y)
  setSector(me, x, y, chosenType)
end

on mouseDown me 
  if the doubleClick then
    open(me)
  else
    select(me)
  end if
end

on setupBoard me, Data 
  if isOpen = 0 then
    isOpen = 1
  end if
  origImage = member("TicTacToe.board.real.plain").image
  destImage = member(getmemnum("TicTacToe.board.real")).image
  origMemImage = member("TicTacToe.board.real.plain").image
  destImage.copyPixels(origMemImage, member("TicTacToe.board.real.plain").image.rect, member("TicTacToe.board.real").rect)
  w = 25
  setOpponents(me, Data.line[1..2])
  Data = Data.line[3..the number of line in Data]
  i = 1
  repeat while i <= Data.length
    c = Data.char[i]
    if c <> " " then
      setSector(me, i mod w - 1, i / w, c)
    end if
    i = 1 + i
  end repeat
  if bothTypeChosen = 1 and gGameContext.frame <> "game" then
    displayFrame(gGameContext, "game")
  end if
end

on setOpponents me, Data 
  member("opponent.x").text = Data.word[2]
  member("opponent.o").text = Data.word[2]
  member("tictactoe.game_players").text = Data
  if Data.line[1].length > 3 and Data.line[2].length > 3 then
    bothTypeChosen = 1
  else
    bothTypeChosen = 0
  end if
end

on close me 
  if isOpen then
    isOpen = 0
    sendItemMessage(me, "CLOSE")
    close(gGameContext)
  end if
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

on setSector me, x, y, c 
  sectorWidth = 10
  memberImage = member("TicTacToe." & c).image
  destRect = rect(6 + x * sectorWidth - 1, 6 + y * sectorWidth - 1, 6 + x + 1 * sectorWidth - 1, 6 + y + 1 * sectorWidth - 1)
  destImage.copyPixels(memberImage, destRect, member("TicTacToe." & c).rect, [#ink:36])
end

on processItemMessage me, content 
  ln1 = content.line[2]
  if ln1 contains "BOARDDATA" then
    setupBoard(me, content.line[3..the number of line in content])
    if gGameContext.frame = void() then
      displayFrame(gGameContext, "chooseparty")
      if bothTypeChosen then
        displayFrame(gGameContext, "game")
      end if
    end if
  else
    if ln1 contains "SELECTTYPE" then
      chosenType = content.word[2]
      put("CHOSENTYPE", chosenType)
      displayFrame(gGameContext, "game")
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
