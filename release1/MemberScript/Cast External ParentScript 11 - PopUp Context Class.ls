property spriteSpaceStart, spriteSpaceEnd, locZStart, locShift, frame
global testo, pupsprNum

on new me, tLocZStart, tspriteSpaceStart, tspriteSpaceEnd, tlocShift
  spriteSpaceStart = tspriteSpaceStart
  spriteSpaceEnd = tspriteSpaceEnd
  locZStart = tLocZStart
  locShift = tlocShift
  repeat with i = spriteSpaceStart to spriteSpaceEnd
    if i > 0 then
      sprite(i).visible = 0
    end if
  end repeat
  return me
end

on close me
  repeat with i = spriteSpaceStart to spriteSpaceEnd
    if i > 0 then
      sprite(i).visible = 0
      call(#endSprite, sprite(i).scriptInstanceList)
      sprMan_releaseSprite(i)
    end if
  end repeat
end

on visible me
  if sprite(spriteSpaceStart).castNum = pupsprNum then
    return 0
  else
    return 1
  end if
end

on move me, dx, dy
  repeat with i = spriteSpaceStart to spriteSpaceEnd
    sprite(i).loc = sprite(i).loc + point(dx, dy)
  end repeat
  locShift = locShift + point(dx, dy)
end

on displayFrame me, tFrame
  if spriteSpaceStart < 1 then
    return 
  end if
  repeat with i = spriteSpaceStart to spriteSpaceEnd
    sprite(i).visible = 0
    sendSprite(i, #endSprite)
    sprite(i).scriptInstanceList = []
    sprMan_releaseSprite(i)
  end repeat
  if the number of member (tFrame & ".recorded") < 1 then
    return 
  end if
  data = field(tFrame & ".recorded")
  me.frame = tFrame
  castLibs = []
  lnCount = 1
  repeat with i = 1 to the number of lines in data
    s = line i of data
    if s contains "." then
      s = char 1 to offset(".", s) - 1 of s
    end if
    if s = "*" then
      exit repeat
    else
      add(castLibs, s)
    end if
    lnCount = lnCount + 1
  end repeat
  lnCount = lnCount + 1
  b = 1
  sprCounter = spriteSpaceStart
  repeat while lnCount < the number of lines in data
    lnCount = lnCount + 1
    sprInfo = line lnCount of data
    lnCount = lnCount + 1
    bhvInfo = line lnCount of data
    if sprInfo.length < 2 then
      exit repeat
    end if
    the itemDelimiter = "/"
    spr = sprite(sprCounter)
    if spr < 1 then
      put "Tried to open popup with below zero sprite. Info:"
      put "Sprite:", spr, " frame:", tFrame, " movie:", the movieName
      return 
    end if
    spr.visible = 1
    spr.member = member(integer(item 1 of sprInfo), castLibs[integer(item 2 of sprInfo)])
    spr.locH = integer(item 3 of sprInfo) + locShift[1]
    spr.locV = integer(item 4 of sprInfo) + locShift[2]
    spr.loc = point(spr.locH, spr.locV)
    spr.locZ = integer(item 5 of sprInfo) + locZStart
    spr.ink = integer(item 6 of sprInfo)
    spr.foreColor = value(item 7 of sprInfo)
    if (item 8 of sprInfo).length < 4 then
      spr.bgColor = paletteIndex(integer(item 8 of sprInfo))
    else
      spr.bgColor = value("rgb(" & item 8 of sprInfo & ")")
    end if
    spr.blend = value(item 9 of sprInfo)
    spr.width = value(item 10 of sprInfo)
    spr.height = value(item 11 of sprInfo)
    the itemDelimiter = "&"
    bhvItemCount = the number of items in bhvInfo
    repeat with j = 1 to bhvItemCount
      bhv = item j of bhvInfo
      if bhv.length > 2 then
        the itemDelimiter = "/"
        bhvMem = member(integer(item 1 of bhv), castLibs[integer(item 2 of bhv)])
        bhvParams = value(item 3 of bhv)
        o = new(script(bhvMem))
        if listp(bhvParams) then
          repeat with u = 1 to count(bhvParams)
            param = getPropAt(bhvParams, u)
            value = getAt(bhvParams, u)
            setaProp(o, symbol(param), value)
          end repeat
          testo = o
        end if
        setaProp(o, #spriteNum, spr.spriteNum)
        setaProp(o, #context, me)
        add(spr.scriptInstanceList, o)
        the itemDelimiter = "&"
      end if
    end repeat
    sprCounter = sprCounter + 1
  end repeat
  repeat with i = spriteSpaceStart to spriteSpaceEnd
    call(#beginSprite, sprite(i).scriptInstanceList)
  end repeat
  the itemDelimiter = ","
end
