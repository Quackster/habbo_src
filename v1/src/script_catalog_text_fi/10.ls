property spriteNum, pImageSprite, pPosterIndexList, pCurrentFirstLine, pPosterListTxt, pCurrentPosterCode

on beginSprite me 
  pPosterIndexList = member("poster_IndexList").text
  pPosterListTxt = ""
  pCurrentFirstLine = 1
  pCurrentPosterCode = void()
  pImageSprite = spriteNum + 1
  sprite(pImageSprite).ink = 36
  updatePosterList(me)
  chooseItem(me, pPosterIndexList.getProp(#line, pCurrentFirstLine))
end

on updatePosterList me 
  pPosterListTxt = ""
  tSaveDelim = the itemDelimiter
  the itemDelimiter = ":"
  put("updateposterlist:" && pCurrentFirstLine)
  i = pCurrentFirstLine
  repeat while i <= pCurrentFirstLine + 9
    tLine = pPosterIndexList.getProp(#line, i)
    if tLine.getProp(#item, 1) = "" then
    else
      if tLine.count(#item) <= 1 then
      else
        pPosterListTxt = pPosterListTxt & i & "." && tLine.getPropRef(#item, 2).getProp(#word, 1, tLine.getPropRef(#item, 2).count(#word)) & "\r"
        i = 1 + i
      end if
    end if
  end repeat
  the itemDelimiter = tSaveDelim
  member("Poster list").text = pPosterListTxt
end

on mouseDown me 
  tMousePoint = the mouseLoc
  tLineNum = sprite(spriteNum).pointToLine(tMousePoint)
  tdata = pPosterIndexList.getProp(#line, pCurrentFirstLine + tLineNum - 1)
  if tLineNum > 0 and tLineNum <= 10 then
    chooseItem(me, tdata)
  end if
  sendAllSprites(#setPosterCode, pCurrentPosterCode)
end

on chooseItem me, tdata 
  if tdata = "" then
    return(void())
  end if
  tSaveDelim = the itemDelimiter
  the itemDelimiter = ":"
  member("Selected poster name").text = tdata.getPropRef(#item, 6).getProp(#word, 1, tdata.getPropRef(#item, 6).count(#word))
  pCurrentPosterCode = tdata.getPropRef(#item, 5).getProp(#word, 1, tdata.getPropRef(#item, 5).count(#word))
  sprite(pImageSprite).member = member("leftwall poster" && tdata.getPropRef(#item, 1).getProp(#word, 1, tdata.getPropRef(#item, 1).count(#word)))
  sprite(pImageSprite).width = member("leftwall poster" && tdata.getPropRef(#item, 1).getProp(#word, 1, tdata.getPropRef(#item, 1).count(#word))).width
  sprite(pImageSprite).height = member("leftwall poster" && tdata.getPropRef(#item, 1).getProp(#word, 1, tdata.getPropRef(#item, 1).count(#word))).height
  the itemDelimiter = tSaveDelim
end

on nextPosterSet me 
  if pPosterIndexList.getProp(#line, pCurrentFirstLine + 10) = "" then
    return(void())
  end if
  pCurrentFirstLine = pCurrentFirstLine + 10
  updatePosterList(me)
  chooseItem(me, pPosterIndexList.getProp(#line, pCurrentFirstLine))
end

on prevPosterSet me 
  if pCurrentFirstLine - 10 < 1 then
    return(void())
  end if
  pCurrentFirstLine = pCurrentFirstLine - 10
  updatePosterList(me)
  chooseItem(me, pPosterIndexList.getProp(#line, pCurrentFirstLine))
end
