property ancestor, spr, locX, locY, locHeight, isOpen, lMyShips, shipToPlace, shipSpr, lastX, lastY, bothTypeChosen, direction, myTurnNum, lShoots, lOthersShoots, myturn, waitingForTurnChange
global gpInteractiveItems, gGameContext, gBattleShip, gpObjects, gMyName, gBSBoardSprite

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
  return me
end

on itemDie me, itemId
  if itemId = me.id then
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
  me.locX = integer(item 1 of the location of me)
  me.locY = integer(item 2 of the location of me)
  me.locHeight = integer(item 3 of the location of me)
  spr = sprMan_getPuppetSprite()
  sprite(spr).castNum = getmemnum("BattleShip_small")
  sprite(spr).scriptInstanceList = [me]
  screenLoc = getScreenCoordinate(me.locX, me.locY, me.locHeight)
  sprite(spr).loc = point(screenLoc[1], screenLoc[2])
  sprite(spr).locZ = screenLoc[3]
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
  if myUserLoc[1] > 400 then
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
    member("bs_game_news").text = EMPTY
    displayFrame(gGameContext, "bs.wait")
    lShoots = []
    lOthersShoots = []
    return 
  end if
  if voidp(shipSpr) then
    shipSpr = sprite(sprMan_getPuppetSprite())
  end if
  shipSpr.locZ = 2000000100
  direction = #horizontal
  shipSpr.castNum = getmemnum("bs_ship_" & shipToPlace.size & "_" & char 1 of string(direction))
  shipSpr.visible = 0
end

on rotateShip me
  if direction = #horizontal then
    direction = #vertical
  else
    direction = #horizontal
  end if
  shipSpr.castNum = getmemnum("bs_ship_" & shipToPlace.size & "_" & char 1 of string(direction))
end

on getNextShipToPlace me
  c = count(lMyShips)
  case c of
    0:
      member("bs_currentship").text = "An Aircraft Carrier"
      return new(script("BSShip"), "5")
    1, 2:
      member("bs_currentship").text = 3 - c && "BattleShip(s)"
      return new(script("BSShip"), "4")
    3, 4, 5:
      member("bs_currentship").text = 6 - c && "Cruiser(s)"
      return new(script("BSShip"), "3")
    6, 7, 8, 9:
      member("bs_currentship").text = 10 - c && "Destroyer(s)"
      return new(script("BSShip"), "2")
  end case
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
    case direction of
      #horizontal:
        ya = y
        repeat with xa = x to x + shipToPlace.size - 1
          repeat with o in lMyShips
            if isMySector(o, xa, ya) then
              beep(1)
              return 
            end if
          end repeat
        end repeat
      #vertical:
        xa = x
        repeat with ya = y to y + shipToPlace.size - 1
          repeat with o in lMyShips
            if isMySector(o, xa, ya) then
              beep(1)
              return 
            end if
          end repeat
        end repeat
    end case
    place(shipToPlace, direction, x, y)
    cursor(-1)
  else
    if myturn then
      shoot(me, x, y)
    end if
  end if
end

on shoot me, x, y
  global gBSSounsON
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
    repeat with ship in lMyShips
      shipImage = sprite(ship.spr).member.image
      destRect = rect(7 + (ship.x1 * 19), 5 + (ship.y1 * 19), 7 + ((ship.x2 + 1) * 19), 5 + ((ship.y2 + 1) * 19))
      destImage.copyPixels(shipImage, destRect, shipImage.rect, [#ink: 36])
    end repeat
  end if
  repeat with shoot in l
    x = shoot[1]
    y = shoot[2]
    type = shoot[3]
    hitImage = member(getmemnum("bs_" & string(type))).image
    srcrect = hitImage.rect
    destRect = rect(8 + (x * 19), 6 + (y * 19), 8 + (x * 19) + srcrect.right - srcrect.left, 6 + srcrect.bottom - srcrect.top + (y * 19))
    destImage.copyPixels(hitImage, destRect, srcrect, [#ink: 36])
  end repeat
end

on processItemMessage me, content
  ln1 = line 2 of content
  put content
  if ln1 contains "BOTHCHOSEN" then
    close(me)
  else
    if ln1 contains "OPPONENTS" then
      repeat with i = 3 to the number of lines in content
        ln = line i of content
        if word 2 of ln = gMyName then
          myTurnNum = integer(word 1 of ln)
        end if
      end repeat
    else
      if ln1 contains "GAMEEND" then
        member("bs_game_new_fi").text = line 3 of content & " WON!"
      else
        if ln1 contains "MISS" then
          x = integer(word 1 of line 3 of content)
          y = integer(word 2 of line 3 of content)
          member("bs_game_news").text = "Miss:" && x & "," & y
        else
          if ln1 contains "HITTWICE" then
            beep(1)
          else
            if (ln1 contains "HIT") or (ln1 contains "SINK") then
              x = integer(word 1 of line 3 of content)
              y = integer(word 2 of line 3 of content)
              if ln1 contains "SINK" then
                member("bs_game_news").text = "Toast!!!"
              else
                member("bs_game_news").text = "A Hit!!!:" && x & "," & y
              end if
              updateBoard(me)
            else
              if ln1 contains "SITUATION" then
                opponent1Data = line 4 of content
                opponent2Data = line 6 of content
                lShoots = []
                lOthersShoots = []
                t = the milliSeconds
                repeat with j = 1 to 2
                  if j = 1 then
                    s = opponent1Data
                  end if
                  if j = 2 then
                    s = opponent2Data
                  end if
                  repeat with i = 1 to s.length
                    ay = (i - 1) / 13
                    ax = (i - 1) mod 13
                    if j <> (myTurnNum + 1) then
                      case char i of s of
                        "O":
                          add(lShoots, [ax, ay, #miss])
                        "X":
                          add(lShoots, [ax, ay, #hit])
                        "S":
                          add(lShoots, [ax, ay, #sink])
                      end case
                      next repeat
                    end if
                    case char i of s of
                      "O":
                        add(lOthersShoots, [ax, ay, #miss])
                      "X":
                        add(lOthersShoots, [ax, ay, #hit])
                      "S":
                        add(lOthersShoots, [ax, ay, #sink])
                    end case
                  end repeat
                end repeat
                updateBoard(me)
              else
                if ln1 contains "TURN" then
                  if integer(line 3 of content) = myTurnNum then
                    member("bs_game_new_fi").text = "Click on a square"
                    member("battleships.game_players").text = "Your turn"
                    myturn = 1
                  else
                    member("bs_game_new_fi").text = " "
                    member("battleships.game_players").text = "The enemy's turn"
                    myturn = 0
                  end if
                  updateBoard(me)
                  if gGameContext.frame = "bs.board" then
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
  end if
end
