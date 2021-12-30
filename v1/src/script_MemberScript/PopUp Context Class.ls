property spriteSpaceStart, spriteSpaceEnd, locShift, locZStart

on new me, tLocZStart, tspriteSpaceStart, tspriteSpaceEnd, tlocShift 
  spriteSpaceStart = tspriteSpaceStart
  spriteSpaceEnd = tspriteSpaceEnd
  locZStart = tLocZStart
  locShift = tlocShift
  i = spriteSpaceStart
  repeat while i <= spriteSpaceEnd
    if i > 0 then
      sprite(i).visible = 0
    end if
    i = (1 + i)
  end repeat
  return(me)
end

on close me 
  i = spriteSpaceStart
  repeat while i <= spriteSpaceEnd
    if i > 0 then
      sprite(i).visible = 0
      call(#endSprite, sprite(i).scriptInstanceList)
      sprMan_releaseSprite(i)
    end if
    i = (1 + i)
  end repeat
end

on visible me 
  if (sprite(spriteSpaceStart).castNum = pupsprNum) then
    return FALSE
  else
    return TRUE
  end if
end

on move me, dx, dy 
  i = spriteSpaceStart
  repeat while i <= spriteSpaceEnd
    sprite(i).loc = (sprite(i).loc + point(dx, dy))
    i = (1 + i)
  end repeat
  locShift = (locShift + point(dx, dy))
end

on displayFrame me, tFrame 
  if spriteSpaceStart < 1 then
    return()
  end if
  i = spriteSpaceStart
  repeat while i <= spriteSpaceEnd
    sprite(i).visible = 0
    sendSprite(i, #endSprite)
    sprite(i).scriptInstanceList = []
    sprMan_releaseSprite(i)
    i = (1 + i)
  end repeat
  if sprite(0).number < 1 then
    return()
  end if
  data = field(0)
  me.frame = tFrame
  castLibs = []
  lnCount = 1
  i = 1
  repeat while i <= the number of line in data
    s = data.line[i]
    if s contains "." then
      s = s.char[1..(offset(".", s) - 1)]
    end if
    if (s = "*") then
    else
      add(castLibs, s)
    end if
    lnCount = (lnCount + 1)
    i = (1 + i)
  end repeat
  lnCount = (lnCount + 1)
  b = 1
  sprCounter = spriteSpaceStart
  repeat while lnCount < the number of line in data
    lnCount = (lnCount + 1)
    sprInfo = data.line[lnCount]
    lnCount = (lnCount + 1)
    bhvInfo = data.line[lnCount]
    if sprInfo.length < 2 then
    else
      the itemDelimiter = "/"
      spr = sprite(sprCounter)
      if spr < 1 then
        put("Tried to open popup with below zero sprite. Info:")
        put("Sprite:", spr, " frame:", tFrame, " movie:", the movieName)
        return()
      end if
      spr.visible = 1
      spr.member = member(integer(sprInfo.item[1]), castLibs.getAt(integer(sprInfo.item[2])))
      spr.locH = (integer(sprInfo.item[3]) + locShift.getAt(1))
      spr.locV = (integer(sprInfo.item[4]) + locShift.getAt(2))
      spr.loc = point(spr.locH, spr.locV)
      spr.locZ = (integer(sprInfo.item[5]) + locZStart)
      spr.ink = integer(sprInfo.item[6])
      spr.foreColor = value(sprInfo.item[7])
      if sprInfo.item[8].length < 4 then
        spr.bgColor = paletteIndex(integer(sprInfo.item[8]))
      else
        spr.bgColor = value("rgb(" & sprInfo.item[8] & ")")
      end if
      spr.blend = value(sprInfo.item[9])
      spr.width = value(sprInfo.item[10])
      spr.height = value(sprInfo.item[11])
      the itemDelimiter = "&"
      bhvItemCount = the number of item in bhvInfo
      j = 1
      repeat while j <= bhvItemCount
        bhv = bhvInfo.item[j]
        if bhv.length > 2 then
          the itemDelimiter = "/"
          bhvMem = member(integer(bhv.item[1]), castLibs.getAt(integer(bhv.item[2])))
          bhvParams = value(bhv.item[3])
          o = new(script(bhvMem))
          if listp(bhvParams) then
            u = 1
            repeat while u <= count(bhvParams)
              param = getPropAt(bhvParams, u)
              value = getAt(bhvParams, u)
              setaProp(o, symbol(param), value)
              u = (1 + u)
            end repeat
            testo = o
          end if
          setaProp(o, #spriteNum, spr.spriteNum)
          setaProp(o, #context, me)
          add(spr.scriptInstanceList, o)
          the itemDelimiter = "&"
        end if
        j = (1 + j)
      end repeat
      sprCounter = (sprCounter + 1)
    end if
  end repeat
  i = spriteSpaceStart
  repeat while i <= spriteSpaceEnd
    call(#beginSprite, sprite(i).scriptInstanceList)
    i = (1 + i)
  end repeat
  the itemDelimiter = ","
end
