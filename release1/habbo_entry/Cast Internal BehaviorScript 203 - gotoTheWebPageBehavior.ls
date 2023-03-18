property spriteNum, theUrl, theWord, noFinger

on mouseDown me
  pointClicked = the mouseLoc
  currentMember = sprite(spriteNum).member
  wordNum = sprite(spriteNum).pointToWord(pointClicked)
  wordText = currentMember.word[wordNum]
  if wordText = theWord then
    put "Clicked URL:" && wordText
    gotoNetPage(theUrl, "_new")
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #theUrl, [#comment: "The url to go", #format: #string, #default: "http://www.sulake.com/"])
  addProp(pList, #theWord, [#comment: "word that is a link", #format: #string, #default: "sulake"])
  addProp(pList, #noFinger, [#comment: "is the whole text a link?", #format: #boolean, #default: 1])
  return pList
end
