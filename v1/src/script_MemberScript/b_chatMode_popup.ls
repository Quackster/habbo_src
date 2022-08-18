property pSprite, pOpenHeight, pTopMargin, pBotMargin, pSelections, isOpen, popTop, selectionHeight, pChatmode, pShiftFlag, xoffset, sprWidth

on beginSprite me 
  pSprite = sprite(me.spriteNum)
  xoffset = pSprite.left
  sprWidth = pSprite.width
  isOpen = 0
  selectionHeight = (((pOpenHeight - pTopMargin) - pBotMargin) / pSelections)
  popTop = ((pSprite.top + pSprite.height) - pOpenHeight)
  pShiftFlag = 0
end

on mouseDown me 
  switchOpen(me)
end

on switchOpen me 
  if (isOpen = 1) then
    if mouseV() > (popTop + pTopMargin) and mouseV() <= ((popTop + pTopMargin) + selectionHeight) then
      pChatmode = 3
      gChatMode = 3
    else
      if mouseV() > ((popTop + pTopMargin) + selectionHeight) and mouseV() <= ((popTop + pTopMargin) + (selectionHeight * 2)) then
        pChatmode = 2
        gChatMode = 2
      else
        if mouseV() > ((popTop + pTopMargin) + (selectionHeight * 2)) and mouseV() <= (popTop + pOpenHeight) then
          pChatmode = 1
          gChatMode = 1
        end if
      end if
    end if
    pSprite.member = "speakmode_fi_" & pChatmode
    isOpen = 0
  else
    pSprite.member = "speakmode_fi_3"
    isOpen = 1
  end if
end

on exitFrame  
  if the shiftDown and (isOpen = 0) then
    pSprite.member = "speakmode_fi_2"
    pShiftFlag = 1
  else
    if (the shiftDown = 0) and (pShiftFlag = 1) then
      pSprite.member = "speakmode_fi_" & pChatmode
      pShiftFlag = 0
    end if
  end if
  if gChatMode <> pChatmode then
    pChatmode = 1
    gChatMode = 1
    pSprite.member = "speakmode_fi_" & pChatmode
  end if
  if (isOpen = 1) and mouseH() > xoffset and mouseH() < (xoffset + sprWidth) then
    if mouseV() > (popTop + pTopMargin) and mouseV() <= ((popTop + pTopMargin) + selectionHeight) then
      pSprite.member = "speakmode_fi_popup3"
    else
      if mouseV() > ((popTop + pTopMargin) + selectionHeight) and mouseV() <= ((popTop + pTopMargin) + (selectionHeight * 2)) then
        pSprite.member = "speakmode_fi_popup2"
      else
        if mouseV() > ((popTop + pTopMargin) + (selectionHeight * 2)) and mouseV() <= (popTop + pOpenHeight) then
          pSprite.member = "speakmode_fi_popup1"
        end if
      end if
    end if
  end if
end

on getPropertyDescriptionList me 
  p = [:]
  addProp(p, #pOpenHeight, [#comment:"Height when open", #default:"0", #format:#integer])
  addProp(p, #xoffset, [#comment:"x Offset", #default:"0", #format:#integer])
  addProp(p, #pTopMargin, [#comment:"Top margin", #default:"0", #format:#integer])
  addProp(p, #pBotMargin, [#comment:"Bottom margin", #default:"0", #format:#integer])
  addProp(p, #pSelections, [#comment:"Selections", #default:"3", #format:#integer])
  addProp(p, #pChatmode, [#comment:"Default value", #default:"1", #format:#integer])
  return(p)
end
