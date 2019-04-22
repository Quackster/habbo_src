on render(me, tText, tRect)
  pMember.text = tText
  if tRect.ilk = #rect then
    if pMember.width <> tRect.width then
      pMember.rect = tRect
    end if
  else
    if voidp(me.pTxtRect) then
      tAlignment = pMember.alignment
      pMember.alignment = #left
      pMember.rect = me.pDefRect
      tTotal = 0
      tLine = tText.getProp(#line, 1)
      i = 1
      repeat while i <= length(tLine)
        tTotal = tTotal + 1 + charToNum(tLine.getProp(#char, i)) > 255
        i = 1 + i
      end repeat
      tWidth = pMember.charPosToLoc(tTotal).locH
      if tText.count(#line) > 1 then
        i = 2
        repeat while i <= tText.count(#line)
          tLine = tText.getProp(#line, i)
          j = 1
          repeat while j <= length(tLine)
            tTotal = tTotal + 1 + charToNum(tLine.getProp(#char, j)) > 255
            j = 1 + j
          end repeat
          tNext = pMember.charPosToLoc(tTotal).locH
          if tNext > tWidth then
            tWidth = tNext
          end if
          i = 1 + i
        end repeat
      end if
      0.rect = rect(tWidth, me + pMember.fontSize, me, pMember.height)
      pMember.alignment = tAlignment
    else
      if me <> pTxtRect.width then
        pMember.rect = me.pTxtRect
      end if
    end if
  end if
  executeMessage(#invalidateCrapFixRegion)
  if me.pTextRenderMode = 1 then
    return(pMember.image)
  else
    if me.pTextRenderMode = 2 then
      return(me.fakeAlphaRender())
    end if
  end if
  exit
end