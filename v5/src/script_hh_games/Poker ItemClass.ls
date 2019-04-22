property spr, isOpen, pCards, cardNum, lCardTypes, pOtherCards, pPlayersCards, changed

on new me, towner, tlocation, tid, tdata 
  ancestor = new(script("InteractiveItem Abstract"), towner, tlocation, tid, tdata)
  if the movieName contains "private" then
    Initialize(me)
  end if
  isOpen = 0
  setaProp(gpInteractiveItems, me.id, me)
  me.itemType = "Poker"
  gPoker = me
  changed = 0
  return(me)
end

on Initialize me 
  oldDelim = the itemDelimiter
  the itemDelimiter = ","
  me.locX = integer(me.location.item[1])
  me.locY = integer(me.location.item[2])
  me.locHeight = integer(me.location.item[3])
  spr = sprMan_getPuppetSprite()
  sprite(spr).castNum = getmemnum("Poker_small")
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
    isOpen = 0
    me.sendItemMessage("CLOSE")
    close(gGameContext)
  end if
end

on open me, content 
  if not voidp(gGameContext) then
    close(gGameContext)
  end if
  myUserLoc = sprite(getaProp(gpObjects, gMyName)).loc
  if myUserLoc.getAt(1) > 400 then
    p = point(40, 70)
  else
    p = point(400, 70)
  end if
  isOpen = 1
  gGameContext = new(script("PopUp Context Class"), 2000000000, 30, 99, p)
  displayFrame(gGameContext, "card_intro")
end

on register me, oCard 
  if voidp(pCards) then
    pCards = [:]
  end if
  setaProp(pCards, cardNum, oCard)
  setCard(oCard, getAt(lCardTypes, cardNum))
  cardNum = cardNum + 1
end

on registerOtherCard me, oCard 
  if gGameContext.frame = "card_change" then
    setaProp(pOtherCards, oCard.playerNum && oCard.cardNum, oCard)
    sprite(oCard.spriteNum).visible = 0
  else
    l = getaProp(pPlayersCards, oCard.playerNum)
    if listp(l) then
      if count(l) >= 5 then
        setCard(oCard, l.getAt(6 - oCard.cardNum))
      else
        sprite(oCard.spriteNum).visible = 0
      end if
    else
      sprite(oCard.spriteNum).visible = 0
    end if
  end if
end

on startOver me 
  sendItemMessage(me, "OPEN")
  sendItemMessage(me, "STARTOVER")
  changed = 0
end

on change me 
  if changed then
    return()
  end if
  s = ""
  i = 1
  repeat while i <= count(pCards)
    o = pCards.getAt(i)
    if o.selected then
      s = s && i - 1
      sprite(o.spriteNum).member = getmemnum("BACKSIDE")
      select(o, 0)
    end if
    i = 1 + i
  end repeat
  sendItemMessage(me, "CHANGE" && s)
  changed = 1
  member("cards.helptext").text = "Waiting for the other players"
end

on processItemMessage me, content 
  ln1 = content.line[2]
  put(content)
  if ln1 contains "START" then
    pOtherCards = [:]
    member("cards.helptext").text = "Choose the cards to change"
  end if
  if ln1 contains "OPPONENTS" then
    if gGameContext.frame = "card_change" then
      j = 1
      i = 1
      repeat while i <= 4
        if getmemnum("cards.names." & i) > 0 then
          member("cards.names." & i).text = ""
          member("cards.ready." & i).text = ""
        end if
        i = 1 + i
      end repeat
      i = 1
      repeat while i <= 4
        ln = content.line[2 + i]
        if ln.length > 0 then
          if ln.word[1] <> gMyName then
            member("cards.names." & j).text = ln.word[1]
            if ln.word[2] = "0" then
              member("cards.ready." & j).text = "NOT READY"
            else
              member("cards.ready." & j).text = "DONE - changed" && ln.word[2]
            end if
            u = 1
            repeat while u <= 5
              oCard = getaProp(pOtherCards, j && u)
              if not voidp(oCard) then
                sprite(oCard.spriteNum).visible = 1
              end if
              u = 1 + u
            end repeat
            j = j + 1
          else
          end if
        else
        end if
        i = 1 + i
      end repeat
    end if
  end if
  if ln1 contains "CHANGED" then
    ln = content.line[3]
    the itemDelimiter = "/"
    player = ln.item[1]
    cardNos = ln.item[2]
    the itemDelimiter = ","
    j = 1
    repeat while j <= 3
      if member("cards.names." & j).text = player then
        playerNo = j
      end if
      j = 1 + j
    end repeat
    put(playerNo, "pn")
    if not voidp(playerNo) then
      j = 1
      repeat while j <= the number of word in cardNos
        oc = getaProp(pOtherCards, playerNo && 6 - integer(1 + cardNos.word[j]))
        if not voidp(oc) then
          select(oc, 1)
        else
          put(playerNo && 6 - integer(1 + cardNos.word[j]), "not found")
        end if
        j = 1 + j
      end repeat
    end if
    member("cards.ready." & playerNo).text = "Done" && "- changed " && the number of word in cardNos
  end if
  if ln1 contains "REVEALCARDS" then
    pOtherCards = [:]
    j = 1
    pPlayersCards = [:]
    i = 3
    repeat while i <= the number of line in content
      the itemDelimiter = "/"
      ln = content.line[i]
      playerName = ln.item[1]
      if playerName = gMyName then
        num = 0
        fieldNum = 1
      else
        j = j + 1
        num = j - 1
        fieldNum = j
      end if
      member("cards.names." & fieldNum).text = playerName
      l = []
      e = 3
      repeat while e <= the number of item in ln
        add(l, ln.item[e])
        e = 1 + e
      end repeat
      addProp(pPlayersCards, num, l)
      the itemDelimiter = ","
      i = 1 + i
    end repeat
    displayFrame(gGameContext, "card_end")
  end if
  if ln1 contains "YOURCARDS" then
    cardNum = 1
    lCardTypes = []
    sCards = ln1.word[2]
    the itemDelimiter = "/"
    i = 3
    repeat while i <= the number of item in sCards
      add(lCardTypes, sCards.item[i])
      if not voidp(pCards) then
        if count(pCards) = 5 and i - 2 <= 5 then
          o = pCards.getAt(i - 2)
          if not voidp(o) then
            setCard(o, lCardTypes.getAt(i - 2))
          end if
        end if
      end if
      i = 1 + i
    end repeat
    the itemDelimiter = ","
    if gGameContext.frame <> "card_change" then
      displayFrame(gGameContext, "card_change")
    end if
  end if
end
