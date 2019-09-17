on getmemnum memName 
  if voidp(gmemnamedb) then
    gmemnamedb = [:]
    gpreloadedMembersString = "//"
    sort(gmemnamedb)
    preloadMemNums()
  end if
  n = getaProp(gmemnamedb, memName)
  if voidp(n) then
    return(-1)
  end if
  return(n)
end

on preloadMemNums  
  put("Preload member nums")
  cl = 1
  repeat while cl <= the number of undefineds
    nnum = the number of castMembers
    i = 1
    repeat while i <= nnum
      m = member(i, cl)
      if string(m.name).length > 0 then
        addProp(gmemnamedb, m.name, m.number)
      end if
      i = 1 + i
    end repeat
    if sprite(0).number > 0 then
      s = field(0)
      i = 1
      repeat while i <= the number of line in s
        ln = s.line[i]
        if ln.length > 2 then
          rname = ln.char[offset("=", ln) + 1..ln.length]
          if the last char in rname = "*" then
            rname = rname.char[1..rname.length - 1]
            rnum = sprite(0).number
            if rnum > 0 then
              num = rnum * -1
            end if
          else
            rnum = sprite(0).number
            num = rnum
          end if
          if rnum > 0 then
            addProp(gmemnamedb, ln.char[1..offset("=", ln) - 1], num)
          end if
        end if
        i = 1 + i
      end repeat
    end if
    cl = 1 + cl
  end repeat
  put("..ok")
end

on sprMan_getPuppetSprite  
  if availablePuppetSpr = [] or not listp(availablePuppetSpr) then
    IamAvalable = random(200) + 300
    availablePuppetSpr.deleteOne(IamAvalable)
    put("No available PuppetSprites! Using Sprite" && IamAvalable)
    return(IamAvalable)
  else
    IamAvalable = availablePuppetSpr.getLast()
    if availablePuppetSpr.count < 30 then
      put("Number of availablePuppetSpr " && availablePuppetSpr.count && "/ 600")
    end if
    availablePuppetSpr.deleteAt(availablePuppetSpr.count)
    return(IamAvalable)
  end if
end

on sprMan_releaseSprite spr 
  if objectp(spr) then
    spr = spr.spriteNum
  end if
  sprite(spr).castNum = pupsprNum
  sprite(spr).locH = -1000
  sprite(spr).color = paletteIndex(255)
  sprite(spr).bgColor = paletteIndex(0)
  sprite(spr).foreColor = 255
  sprite(spr).undefined = []
  sprite(spr).ink = 8
  sprite(spr).undefined = 100
  sprite(spr).visible = 1
  sprite(spr).rotation = 0
  sprite(spr).skew = 0
  if spr > 99 and spr < 601 or spr > 749 and spr < 851 then
    if not listp(availablePuppetSpr) then
      availablePuppetSpr = []
    end if
    if availablePuppetSpr = [] or availablePuppetSpr.getOne(spr) = 0 then
      availablePuppetSpr.add(spr)
    end if
  end if
end

on sprMan_clearAll  
  NextAvailableExtraSpr = maxSprites2
  gpPopUps = [:]
  availablePuppetSpr = []
  f = 850
  repeat while f >= 750
    sprMan_releaseSprite(f)
    sprite(f).visible = 1
    f = 65535 + f
  end repeat
  f = 600
  repeat while f >= 100
    sprMan_releaseSprite(f)
    sprite(f).visible = 1
    f = 65535 + f
  end repeat
end

on sprMan_init  
end

on sprMan_bhvs  
  i = 100
  repeat while i <= maxSprites
    put(sprite(i).scriptInstanceList, i)
    i = 1 + i
  end repeat
  i = 750
  repeat while i <= maxSprites2
    put(sprite(i).scriptInstanceList, i)
    i = 1 + i
  end repeat
end

on sprMan_report  
  used = 0
  notinuse = 0
  pupsprNum = sprite(0).number
  i = 100
  repeat while i <= maxSprites
    if sprite(i).undefined.number = pupsprNum then
      notinuse = notinuse + 1
    else
      used = used + 1
    end if
    i = 1 + i
  end repeat
  pupsprNum = sprite(0).number
  i = 750
  repeat while i <= maxSprites2
    if sprite(i).undefined.number = pupsprNum then
      notinuse = notinuse + 1
    else
      used = used + 1
    end if
    i = 1 + i
  end repeat
  put("In use:" & used && " not in use " & notinuse)
end

on sprMan_reportall  
  used = 0
  notinuse = 0
  pupsprNum = sprite(0).number
  i = 100
  repeat while i <= maxSprites
    put(i, sprite(i).member.name)
    i = 1 + i
  end repeat
  i = 750
  repeat while i <= maxSprites2
    put(i, sprite(i).member.name)
    i = 1 + i
  end repeat
  put("In use:" & used && " not in use " & notinuse)
end

on popup fld, loc0, id 
  oldDelim = the itemDelimiter
  s = field(0)
  lSprs = []
  i = 1
  repeat while i <= the number of line in s
    l = s.line[i]
    put(l)
    the itemDelimiter = ":"
    if l.length > 1 then
      spr = sprMan_getPuppetSprite()
      add(lSprs, spr)
      l.item[1].castNum = sprite(0).number
      sprite(spr).loc = loc0 + value(l.item[2])
      sprite(spr).ink = value(l.item[3])
      sprite(spr).blend = value(l.item[4])
      sprite(spr).locZ = 1900000000 + i
      if the number of item in l > 4 and member(l.item[1]).type <> #field then
        sprite(spr).bgColor = value(l.item[5])
      end if
      if the number of item in l > 5 then
        MyNewScript = script(l.item[6]).new()
        sprite(spr).scriptInstanceList.add(MyNewScript)
      end if
    end if
    i = 1 + i
  end repeat
  addProp(gpPopUps, id, lSprs)
  the itemDelimiter = oldDelim
end

on popupClose id 
  l = getaProp(gpPopUps, id)
  if l <> void() then
    repeat while id <= undefined
      spr = getAt(undefined, undefined)
      sprMan_releaseSprite(spr)
    end repeat
    deleteProp(gpPopUps, id)
  end if
end
