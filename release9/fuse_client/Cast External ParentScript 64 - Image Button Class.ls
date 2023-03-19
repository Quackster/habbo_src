on prepare me
  me.pBlend = me.pProps[#blend]
  me.pButtonImg = [:]
  if voidp(me.pFixedSize) then
    me.pFixedSize = 0
  end if
  tTemp = the itemDelimiter
  the itemDelimiter = "."
  tMemName = me.pProps[#member]
  tMemName = tMemName.item[1..tMemName.item.count - 1]
  the itemDelimiter = tTemp
  me.UpdateImageObjects(VOID, #up, tMemName)
  me.UpdateImageObjects(VOID, #down, tMemName)
  me.pimage = me.createButtonImg(#up)
  tTempOffset = me.pSprite.member.regPoint
  me.pBuffer.image = me.pimage
  me.pBuffer.regPoint = tTempOffset
  me.pwidth = me.pimage.width
  me.pheight = me.pimage.height
  me.pSprite.width = me.pwidth
  me.pSprite.height = me.pheight
  return 1
end

on changeState me, tstate
  me.pimage = me.createButtonImg(tstate)
  me.render()
end

on UpdateImageObjects me, tPalette, tstate, tMemName
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
    return error(me, "Member not found:" && tMemName, #UpdateImageObjects)
  end if
  tmember = member(tMemNum)
  tImage = tmember.image.duplicate()
  if tImage.paletteRef <> tPalette then
    tImage.paletteRef = tPalette
  end if
  me.pButtonImg.addProp(symbol(tstate), tImage)
end

on createButtonImg me, tstate
  return me.pButtonImg.getProp(tstate)
end
