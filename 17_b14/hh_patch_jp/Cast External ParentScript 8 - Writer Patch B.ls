on render me, tText, tRect
  me.pMember.text = tText
  if tRect.ilk = #rect then
    if me.pMember.width <> tRect.width then
      me.pMember.rect = tRect
    end if
  else
    if voidp(me.pTxtRect) then
      tAlignment = me.pMember.alignment
      me.pMember.alignment = #left
      me.pMember.rect = me.pDefRect
      tTotal = 0
      tLine = tText.line[1]
      repeat with i = 1 to length(tLine)
        tTotal = tTotal + 1 + (charToNum(tLine.char[i]) > 255)
      end repeat
      tWidth = me.pMember.charPosToLoc(tTotal).locH
      if tText.line.count > 1 then
        repeat with i = 2 to tText.line.count
          tLine = tText.line[i]
          repeat with j = 1 to length(tLine)
            tTotal = tTotal + 1 + (charToNum(tLine.char[j]) > 255)
          end repeat
          tNext = me.pMember.charPosToLoc(tTotal).locH
          if tNext > tWidth then
            tWidth = tNext
          end if
        end repeat
      end if
      me.pMember.rect = rect(0, 0, tWidth + me.pMember.fontSize, me.pMember.height)
      me.pMember.alignment = tAlignment
    else
      if me.pMember.width <> me.pTxtRect.width then
        me.pMember.rect = me.pTxtRect
      end if
    end if
  end if
  return me.pMember.image
end
