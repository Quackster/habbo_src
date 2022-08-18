property spr, shipSpr, isOpen, lMyShips, shipToPlace, direction, myturn, waitingForTurnChange, lShoots, lOthersShoots, myTurnNum

on new me, towner, tlocation, tid, tdata 
  ancestor = new(script("InteractiveItem Abstract"), towner, tlocation, tid, tdata)
  if the movieName contains "private" then
    Initialize(me)
  end if
  isOpen = 0
  setaProp(gpInteractiveItems, me.id, me)
  me.itemType = "BattleShip"
  gBattleShip = me
  lMyShips = []
  lShoots = []
  lOthersShoots = []
  waitingForTurnChange = 0
  updateBoard(me)
  return(me)
end

on itemDie me, itemId 
  if (itemId = me.id) then
    close(me)
    if spr > 0 then
      sprMan_releaseSprite(spr)
    end if
    if shipSpr > 0 then
      sprMan_releaseSprite(spr)
    end if
  end if
end

on Initialize me 
  oldDelim = the itemDelimiter
  the itemDelimiter = ","
  me.locX = integer(me.location.item[1])
  me.locY = integer(me.location.item[2])
  me.locHeight = integer(me.location.item[3])
  spr = sprMan_getPuppetSprite()
  sprite(spr).castNum = getmemnum("BattleShip_small")
  sprite(spr).scriptInstanceList = [me]
  screenLoc = getScreenCoordinate(me.locX, me.locY, me.locHeight)
  sprite(spr).loc = point(screenLoc.getAt(1), screenLoc.getAt(2))
  sprite(spr).locZ = screenLoc.getAt(3)
end

on mouseDown me 
  if the doubleClick then
    open(me)
  else
    select(me)
  end if
end

on close me 
  if isOpen then
    cursor(-1)
    isOpen = 0
    sendItemMessage(me, "CLOSE")
    close(gGameContext)
    call(#endSprite, lMyShips)
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
  displayFrame(gGameContext, "bs.placeintro")
  isOpen = 1
  nextShip(me)
end

on nextShip me 
  if not voidp(shipToPlace) then
    add(lMyShips, shipToPlace)
  end if
  shipToPlace = getNextShipToPlace(me)
  if voidp(shipToPlace) then
    cursor(-1)
    call(#hide, lMyShips)
    sprMan_releaseSprite(shipSpr.spriteNum)
    member("bs_game_news").text = ""
    displayFrame(gGameContext, "bs.wait")
    lShoots = []
    lOthersShoots = []
    return()
  end if
  if voidp(shipSpr) then
    shipSpr = sprite(sprMan_getPuppetSprite())
  end if
  shipSpr.locZ = 2000000100
  direction = #horizontal
  shipSpr.castNum = getmemnum("bs_ship_" & shipToPlace.size & "_" & string(direction).char[1])
  shipSpr.visible = 0
end

on rotateShip me 
  if (direction = #horizontal) then
    direction = #vertical
  else
    direction = #horizontal
  end if
  shipSpr.castNum = getmemnum("bs_ship_" & shipToPlace.size & "_" & string(direction).char[1])
end

on getNextShipToPlace me 
  c = count(lMyShips)
  if (c = 0) then
    member("bs_currentship").text = "An Aircraft Carrier"
    return(new(script("BSShip"), "5"))
  else
    if c <> 1 then
      if (c = 2) then
        member("bs_currentship").text = (3 - c) && "BattleShip(s)"
        return(new(script("BSShip"), "4"))
      else
        if c <> 3 then
          if c <> 4 then
            if (c = 5) then
              member("bs_currentship").text = (6 - c) && "Cruiser(s)"
              return(new(script("BSShip"), "3"))
            else
              if c <> 6 then
                if c <> 7 then
                  if c <> 8 then
                    if (c = 9) then
                      member("bs_currentship").text = (10 - c) && "Destroyer(s)"
                      return(new(script("BSShip"), "2"))
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on boardRollover me, x, y, boardX, boardY 
  if not voidp(shipToPlace) then
    shipSpr.visible = 1
    shipSpr.loc = point(x, y)
    lastX = boardX
    lastY = boardY
    cursor(200)
  else
    if myturn then
      cursor([member("shoot cursor"), member("shoot cursor mask")])
    else
      cursor(-1)
    end if
  end if
end

on boardEndRollover me 
  if not voidp(shipToPlace) then
    shipSpr.visible = 0
  end if
  cursor(-1)
end

on boardMouseDown me, x, y 
  if waitingForTurnChange then
    waitingForTurnChange = 0
  end if
  if not voidp(shipToPlace) then
    if (direction = #horizontal) then
      ya = y
      xa = x
      repeat while xa <= ((x + shipToPlace.size) - 1)
        repeat while direction <= count(direction)
          o = getAt(count(direction), lMyShips)
          if isMySector(o, xa, ya) then
            beep(1)
            return()
          end if
        end repeat
        xa = (1 + xa)
      end repeat
      exit repeat
    end if
    if (direction = #vertical) then
      xa = x
      ya = y
      repeat while ya <= ((y + shipToPlace.size) - 1)
        repeat while direction <= count(direction)
          o = getAt(count(direction), lMyShips)
          if isMySector(o, xa, ya) then
            beep(1)
            return()
          end if
        end repeat
        ya = (1 + ya)
      end repeat
    end if
    place(shipToPlace, direction, x, y)
    cursor(-1)
  else
    if myturn then
      shoot(me, x, y)
    end if
  end if
end

on shoot me, x, y 
  sendItemMessage(me, "SHOOT" && x && y)
  if gBSSounsON then
    puppetSound(1, "torpedo")
  end if
  cursor([member("shoot2 cursor"), member("shoot2 cursor mask")])
end

on updateBoard me 
  if myturn then
    l = lShoots
  else
    l = lOthersShoots
  end if
  destImage = member("battleships.board.real").image
  origImage = member("battleships.board.real.plain").image
  destImage.copyPixels(origImage, destImage.rect, origImage.rect)
  if not myturn then
    repeat while lMyShips <= 1
      ship = getAt(1, count(lMyShips))
      shipImage = sprite(ship.spr).member.image
      destRect = rect((7 + (ship.x1 * 19)), (5 + (ship.y1 * 19)), (7 + ((ship.x2 + 1) * 19)), (5 + ((ship.y2 + 1) * 19)))
      destImage.copyPixels(shipImage, destRect, shipImage.rect, [#ink:36])
    end repeat
  end if
  repeat while l <= 1
    shoot = getAt(1, count(l))
    x = shoot.getAt(1)
    y = shoot.getAt(2)
    type = shoot.getAt(3)
    hitImage = member(getmemnum("bs_" & string(type))).image
    srcrect = hitImage.rect
    destRect = rect((8 + (x * 19)), (6 + (y * 19)), (((8 + (x * 19)) + srcrect.right) - srcrect.left), (((6 + srcrect.bottom) - srcrect.top) + (y * 19)))
    destImage.copyPixels(hitImage, destRect, srcrect, [#ink:36])
  end repeat
end

on processItemMessage me, content 
  ln1 = content.line[2]
  put(content)
  if ln1 contains "BOTHCHOSEN" then
    close(me)
  else
    if ln1 contains "OPPONENTS" then
      i = 3
      repeat while i <= the number of line in content
        ln = content.line[i]
        if (ln.word[2] = gMyName) then
          myTurnNum = integer(ln.word[1])
        end if
        i = (1 + i)
      end repeat
      exit repeat
    end if
    if ln1 contains "GAMEEND" then
      member("bs_game_new_fi").text = content.line[3] & " WON!"
    else
      if ln1 contains "MISS" then
        x = integer(content.word[1])
        y = integer(content.word[2])
        member("bs_game_news").text = "Miss:" && x & "," & y
      else
        if ln1 contains "HITTWICE" then
          beep(1)
        else
          if ln1 contains "HIT" or ln1 contains "SINK" then
            x = integer(content.word[1])
            y = integer(content.word[2])
            if ln1 contains "SINK" then
              member("bs_game_news").text = "Toast!!!"
            else
              member("bs_game_news").text = "A Hit!!!:" && x & "," & y
            end if
            updateBoard(me)
          else
            if ln1 contains "SITUATION" then
              opponent1Data = content.line[4]
              opponent2Data = content.line[6]
              lShoots = []
              lOthersShoots = []
              t = the milliSeconds
              j = 1
              repeat while j <= 2
                if (j = 1) then
                  s = opponent1Data
                end if
                if (j = 2) then
                  s = opponent2Data
                end if
                i = 1
                repeat while i <= s.length
                  ay = ((i - 1) / 13)
                  ax = ((i - 1) mod 13)
                  if j <> (myTurnNum + 1) then
                    if (s.char[i] = "O") then
                      add(lShoots, [ax, ay, #miss])
                    else
                      if (s.char[i] = "X") then
                        add(lShoots, [ax, ay, #hit])
                      else
                        if (s.char[i] = "S") then
                          add(lShoots, [ax, ay, #sink])
                        end if
                      end if
                    end if
                  else
                    if (s.char[i] = "O") then
                      add(lOthersShoots, [ax, ay, #miss])
                    else
                      if (s.char[i] = "X") then
                        add(lOthersShoots, [ax, ay, #hit])
                      else
                        if (s.char[i] = "S") then
                          add(lOthersShoots, [ax, ay, #sink])
                        end if
                      end if
                    end if
                  end if
                  i = (1 + i)
                end repeat
                j = (1 + j)
              end repeat
              updateBoard(me)
            else
              if ln1 contains "TURN" then
                if (integer(content.line[3]) = myTurnNum) then
                  member("bs_game_new_fi").text = "Click on a square"
                  member("battleships.game_players").text = "Your turn"
                  myturn = 1
                else
                  member("bs_game_new_fi").text = " "
                  member("battleships.game_players").text = "The enemy's turn"
                  myturn = 0
                end if
                updateBoard(me)
                if (gGameContext.frame = "bs.board") then
                  nothing()
                else
                  displayFrame(gGameContext, "bs.board")
                end if
                if myturn then
                  call(#hide, lMyShips)
                  member("bs_game_new_fi").text = "Choose a target"
                else
                  member("bs_game_new_fi").text = " "
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end
