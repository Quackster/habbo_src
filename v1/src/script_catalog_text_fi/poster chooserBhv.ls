property pPosterIndexList, pPosterListTxt, pCurrentFirstLine, pImageSprite, pCurrentPosterCode, spriteNum

on beginSprite me
  pPosterIndexList = member("poster_IndexList").text
  pPosterListTxt = EMPTY
  pCurrentFirstLine = 1
  pCurrentPosterCode = VOID
  pImageSprite = (spriteNum + 1)
  sprite(pImageSprite).ink = 36
  updatePosterList(me)
  chooseItem(me, pPosterIndexList.line[pCurrentFirstLine])
end

on updatePosterList me
  pPosterListTxt = EMPTY
  tSaveDelim = the itemDelimiter
  the itemDelimiter = ":"
  put ("updateposterlist:" && pCurrentFirstLine)
  repeat with i = pCurrentFirstLine to (pCurrentFirstLine + 9)
    tLine = pPosterIndexList.line[i]
    if (tLine.item[1] = EMPTY) then
      exit repeat
    end if
    if (tLine.item.count <= 1) then
      exit repeat
    end if
    pPosterListTxt = ((((pPosterListTxt & i) & ".") && tLine.item[2].word[1]) & RETURN)
  end repeat
  the itemDelimiter = tSaveDelim
  member("Poster list").text = pPosterListTxt
end

on mouseDown me
  tMousePoint = the mouseLoc
  tLineNum = sprite(spriteNum).pointToLine(tMousePoint)
  tdata = pPosterIndexList.line[((pCurrentFirstLine + tLineNum) - 1)]
  if ((tLineNum > 0) and (tLineNum <= 10)) then
    chooseItem(me, tdata)
  end if
  sendAllSprites(#setPosterCode, pCurrentPosterCode)
end

on chooseItem me, tdata
  if (tdata = EMPTY) then
    return VOID
  end if
  tSaveDelim = the itemDelimiter
  the itemDelimiter = ":"
  member("Selected poster name").text = tdata.item[6].word[1]
  pCurrentPosterCode = tdata.item[5].word[1]
  sprite(pImageSprite).member = member(("leftwall poster" && tdata.item[1].word[1]))
  sprite(pImageSprite).width = member(("leftwall poster" && tdata.item[1].word[1])).width
  sprite(pImageSprite).height = member(("leftwall poster" && tdata.item[1].word[1])).height
  the itemDelimiter = tSaveDelim
end

on nextPosterSet me
  if (pPosterIndexList.line[(pCurrentFirstLine + 10)] = EMPTY) then
    return VOID
  end if
  pCurrentFirstLine = (pCurrentFirstLine + 10)
  updatePosterList(me)
  chooseItem(me, pPosterIndexList.line[pCurrentFirstLine])
end

on prevPosterSet me
  if ((pCurrentFirstLine - 10) < 1) then
    return VOID
  end if
  pCurrentFirstLine = (pCurrentFirstLine - 10)
  updatePosterList(me)
  chooseItem(me, pPosterIndexList.line[pCurrentFirstLine])
end
