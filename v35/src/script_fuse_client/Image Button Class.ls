on prepare(me)
  me.pBlend = me.getProp(#pProps, #blend)
  me.pButtonImg = []
  if voidp(me.pFixedSize) then
    me.pFixedSize = 0
  end if
  tTemp = the itemDelimiter
  the itemDelimiter = "."
  tMemName = me.getProp(#pProps, #member)
  tMemName = tMemName.getProp(#item, 1, tMemName.count(#item) - 1)
  the itemDelimiter = tTemp
  me.UpdateImageObjects(void(), #up, tMemName)
  me.UpdateImageObjects(void(), #down, tMemName)
  me.pimage = me.createButtonImg(#up)
  tTempOffset = member.regPoint
  me.image = me.pimage
  me.regPoint = tTempOffset
  me.pwidth = me.width
  me.pheight = me.height
  pSprite.width = me.pwidth
  pSprite.height = me.pheight
  return(1)
  exit
end

on changeState(me, tstate)
  me.pimage = me.createButtonImg(tstate)
  me.render()
  exit
end

on UpdateImageObjects(me, tPalette, tstate, tMemName)
  if voidp(tPalette) then
    tPalette = me.pPalette
  else
    if stringp(tPalette) then
      tPalette = member(getmemnum(tPalette))
    end if
  end if
  if tstate = #up then
    tMemName = tMemName & ".active"
  else
    if tstate = #down then
      tMemName = tMemName & ".pressed"
    end if
  end if
  tMemNum = getmemnum(tMemName)
  if tMemNum = 0 then
    return(error(me, "Member not found:" && tMemName, #UpdateImageObjects, #minor))
  end if
  tmember = member(tMemNum)
  tImage = tmember.duplicate()
  if tImage.paletteRef <> tPalette then
    tImage.paletteRef = tPalette
  end if
  me.addProp(symbol(tstate), tImage)
  exit
end

on createButtonImg(me, tstate)
  return(me.getProp(tstate))
  exit
end

on handlers()
  return([])
  exit
end