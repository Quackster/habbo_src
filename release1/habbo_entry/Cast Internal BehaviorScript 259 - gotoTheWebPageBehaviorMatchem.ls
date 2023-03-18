property spriteNum, theUrl, theWord, pUnderline, theWord2, theUrl2, numberOfLines

on enterFrame me
  if rollover(me.spriteNum) then
    pointClicked = the mouseLoc
    currentMember = sprite(spriteNum).member
    wordNum = sprite(spriteNum).pointToWord(pointClicked)
    wordText = currentMember.word[wordNum]
    if (wordText = theWord) or (wordText = theWord2) or (sprite(spriteNum).pointToLine(pointClicked) = 23) then
      iSpr = me.spriteNum
      set the cursor of sprite iSpr to [the number of member "cursor_finger", the number of member "cursor_finger_mask"]
    else
      iSpr = me.spriteNum
      set the cursor of sprite iSpr to 0
    end if
  end if
end

on mouseDown me
  pointClicked = the mouseLoc
  currentMember = sprite(spriteNum).member
  wordNum = sprite(spriteNum).pointToWord(pointClicked)
  wordText = currentMember.word[wordNum]
  if wordText = theWord then
    gotoNetPage(theUrl, "_new")
  else
    if wordText = theWord2 then
      gotoNetPage(theUrl2, "_new")
    else
      if sprite(spriteNum).pointToLine(pointClicked) = 23 then
        gotoNetPage(theUrl, "_new")
      end if
    end if
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #theUrl, [#comment: "The url to go", #format: #string, #default: "http://www.sulake.com/"])
  addProp(pList, #theWord, [#comment: "word that is a link", #format: #string, #default: "sulake"])
  addProp(pList, #theUrl2, [#comment: "The url2 to go", #format: #string, #default: "http://www.sulake.com/"])
  addProp(pList, #theWord2, [#comment: "word2 that is a link", #format: #string, #default: "sulake"])
  addProp(pList, #pUnderline, [#comment: "uderline the link word?", #format: #boolean, #default: 1])
  return pList
end
