global maxSprites, maxSprites2, pupsprNum, gpPopUps, gPupSprites, availablePuppetSpr, NextAvailableExtraSpr

on getmemnum memName
  global gmemnamedb
  if voidp(gmemnamedb) then
    gmemnamedb = [:]
    gpreloadedMembersString = "//"
    sort(gmemnamedb)
    preloadMemNums()
  end if
  n = getaProp(gmemnamedb, memName)
  if voidp(n) then
    return -1
  end if
  return n
end

on preloadMemNums
  global gmemnamedb, gpreloadedCastLib, gpreloadedMembersString
  put "Preload member nums"
  repeat with cl = 1 to the number of castLibs
    nnum = the number of castMembers of castLib cl
    repeat with i = 1 to nnum
      m = member(i, cl)
      if string(m.name).length > 0 then
        addProp(gmemnamedb, m.name, m.number)
      end if
    end repeat
    if the number of member (the name of castLib cl && "memberaliases") > 0 then
      s = field(castLib(cl).name && "memberaliases")
      repeat with i = 1 to the number of lines in s
        ln = line i of s
        if ln.length > 2 then
          rname = char offset("=", ln) + 1 to ln.length of ln
          if the last char in rname = "*" then
            rname = char 1 to rname.length - 1 of rname
            rnum = the number of member rname
            if rnum > 0 then
              num = rnum * -1
            end if
          else
            rnum = the number of member rname
            num = rnum
          end if
          if rnum > 0 then
            addProp(gmemnamedb, char 1 to offset("=", ln) - 1 of ln, num)
          end if
        end if
      end repeat
    end if
  end repeat
  put "..ok"
end

on sprMan_getPuppetSprite
  if (availablePuppetSpr = []) or not listp(availablePuppetSpr) then
    IamAvalable = random(200) + 300
    availablePuppetSpr.deleteOne(IamAvalable)
    put "No available PuppetSprites! Using Sprite" && IamAvalable
    return IamAvalable
  else
    IamAvalable = availablePuppetSpr.getLast()
    if availablePuppetSpr.count < 30 then
      put "Number of availablePuppetSpr " && availablePuppetSpr.count && "/ 600"
    end if
    availablePuppetSpr.deleteAt(availablePuppetSpr.count)
    return IamAvalable
  end if
end

on sprMan_releaseSprite spr
  if objectp(spr) then
    spr = spr.spriteNum
  end if
  set the castNum of sprite spr to pupsprNum
  set the locH of sprite spr to -1000
  sprite(spr).color = paletteIndex(255)
  sprite(spr).bgColor = paletteIndex(0)
  set the foreColor of sprite spr to 255
  set the scriptInstanceList of sprite spr to []
  set the ink of sprite spr to 8
  set the blend of sprite spr to 100
  sprite(spr).visible = 1
  sprite(spr).rotation = 0
  sprite(spr).skew = 0
  if ((spr > 99) and (spr < 601)) or ((spr > 749) and (spr < 851)) then
    if not listp(availablePuppetSpr) then
      availablePuppetSpr = []
    end if
    if (availablePuppetSpr = []) or (availablePuppetSpr.getOne(spr) = 0) then
      availablePuppetSpr.add(spr)
    end if
  end if
end

on sprMan_clearAll
  NextAvailableExtraSpr = maxSprites2
  gpPopUps = [:]
  availablePuppetSpr = []
  repeat with f = 850 down to 750
    sprMan_releaseSprite(f)
    sprite(f).visible = 1
  end repeat
  repeat with f = 600 down to 100
    sprMan_releaseSprite(f)
    sprite(f).visible = 1
  end repeat
end

on sprMan_init
end

on sprMan_bhvs
  repeat with i = 100 to maxSprites
    put sprite(i).scriptInstanceList, i
  end repeat
  repeat with i = 750 to maxSprites2
    put sprite(i).scriptInstanceList, i
  end repeat
end

on sprMan_report
  used = 0
  notinuse = 0
  pupsprNum = the number of member "PuppetSprite"
  repeat with i = 100 to maxSprites
    if (the member of sprite i).number = pupsprNum then
      notinuse = notinuse + 1
      next repeat
    end if
    used = used + 1
  end repeat
  pupsprNum = the number of member "PuppetSprite"
  repeat with i = 750 to maxSprites2
    if (the member of sprite i).number = pupsprNum then
      notinuse = notinuse + 1
      next repeat
    end if
    used = used + 1
  end repeat
  put "In use:" & used && " not in use " & notinuse
end

on sprMan_reportall
  used = 0
  notinuse = 0
  pupsprNum = the number of member "PuppetSprite"
  repeat with i = 100 to maxSprites
    put i, sprite(i).member.name
  end repeat
  repeat with i = 750 to maxSprites2
    put i, sprite(i).member.name
  end repeat
  put "In use:" & used && " not in use " & notinuse
end

on popup fld, loc0, id
  oldDelim = the itemDelimiter
  s = field(fld)
  lSprs = []
  repeat with i = 1 to the number of lines in s
    l = line i of s
    put l
    the itemDelimiter = ":"
    if l.length > 1 then
      spr = sprMan_getPuppetSprite()
      add(lSprs, spr)
      sprite(spr).castNum = the number of member item 1 of l
      sprite(spr).loc = loc0 + value(item 2 of l)
      sprite(spr).ink = value(item 3 of l)
      sprite(spr).blend = value(item 4 of l)
      sprite(spr).locZ = 1900000000 + i
      if (the number of items in l > 4) and (member(item 1 of l).type <> #field) then
        sprite(spr).bgColor = value(item 5 of l)
      end if
      if the number of items in l > 5 then
        MyNewScript = script(item 6 of l).new()
        sprite(spr).scriptInstanceList.add(MyNewScript)
      end if
    end if
  end repeat
  addProp(gpPopUps, id, lSprs)
  the itemDelimiter = oldDelim
end

on popupClose id
  l = getaProp(gpPopUps, id)
  if l <> VOID then
    repeat with spr in l
      sprMan_releaseSprite(spr)
    end repeat
    deleteProp(gpPopUps, id)
  end if
end
