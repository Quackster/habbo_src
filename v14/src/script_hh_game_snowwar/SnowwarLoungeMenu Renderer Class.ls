property pWriterPlainNormLeft, pWriterListPlainNormLeft, pWriterPlainNormRight, pWriterLinkRight, pGoButtonImages, pJoinButtonImage, pMainWindowId, pWriterPlainBoldLeft

on construct me 
  pMainWindowId = "GAME"
  tPlainFontStruct = getStructVariable("struct.font.plain")
  createWriter("gs_plain_norm_left", tPlainFontStruct)
  pWriterPlainNormLeft = getWriter("gs_plain_norm_left")
  pWriterPlainNormLeft.define([#wordWrap:0, #fixedLineSpace:tPlainFontStruct.getAt(#lineHeight)])
  createWriter("gs_list_plain_norm_left", tPlainFontStruct)
  pWriterListPlainNormLeft = getWriter("gs_list_plain_norm_left")
  pWriterListPlainNormLeft.define([#wordWrap:0, #fixedLineSpace:16])
  createWriter("gs_plain_norm_right", tPlainFontStruct)
  pWriterPlainNormRight = getWriter("gs_plain_norm_right")
  pWriterPlainNormRight.setProperty(#alignment, #right)
  pWriterPlainNormRight.define([#wordWrap:0])
  tBoldFontStruct = getStructVariable("struct.font.bold")
  createWriter("gs_plain_bold_left", tBoldFontStruct)
  pWriterPlainBoldLeft = getWriter("gs_plain_bold_left")
  tStruct = getStructVariable("struct.font.link")
  tStruct.setaProp(#fontStyle, [#underline])
  tStruct.setaProp(#font, tBoldFontStruct.getAt(#font))
  createWriter("gs_link_right", tStruct)
  pWriterLinkRight = getWriter("gs_link_right")
  me.renderButtonImages()
  return TRUE
end

on deconstruct me 
  removeWriter("gs_plain_norm_left")
  pWriterPlainNormLeft = void()
  removeWriter("gs_list_plain_norm_left")
  pWriterListPlainNormLeft = void()
  removeWriter("gs_plain_norm_right")
  pWriterPlainNormRight = void()
  removeWriter("gs_plain_bold_left")
  pWriterPlainBoldLeft = void()
  removeWriter("gs_link_right")
  pWriterLinkRight = void()
  pGoButtonImages = void()
  pJoinButtonImage = void()
  return TRUE
end

on defineWindow me, tID 
  pMainWindowId = tID
  return TRUE
end

on renderButtonImages me 
  pGoButtonImages = [:]
  repeat while ["created", "started", "finished"] <= 1
    tstate = getAt(1, count(["created", "started", "finished"]))
    tButtonImage = image(92, 12, 8)
    tImage = pWriterLinkRight.render(getText("gs_button_go_" & tstate))
    tLocH = (80 - tImage.width)
    tButtonImage.copyPixels(tImage, (tImage.rect + rect(tLocH, 0, tLocH, 0)), tImage.rect)
    tImage = member(getmemnum("sw_arr")).image
    tButtonImage.copyPixels(tImage, (tImage.rect + rect(84, 1, 84, 1)), tImage.rect)
    pGoButtonImages.addProp(tstate, tButtonImage)
  end repeat
  pJoinButtonImage = image(191, 16, 8)
  tImage = pWriterLinkRight.render(getText("bb_link_join"))
  tLocH = (176 - tImage.width)
  pJoinButtonImage.copyPixels(tImage, (tImage.rect + rect(tLocH, 3, tLocH, 3)), tImage.rect)
  tImage = member(getmemnum("sw_arr")).image
  pJoinButtonImage.copyPixels(tImage, (tImage.rect + rect(180, 4, 180, 4)), tImage.rect)
  return TRUE
end

on renderTournamentLogo me, tTournamentLogoMemNum 
  tWndObj = getWindow(pMainWindowId)
  if (tWndObj = 0) then
    return FALSE
  end if
  if (tTournamentLogoMemNum = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("gs_logo_tournament")
  if tElem <> 0 then
    tmember = member(tTournamentLogoMemNum)
    if (tmember.type = #bitmap) and tElem <> 0 then
      tElem.setProperty(#cursor, "cursor.finger")
      tElem.setProperty(#image, tmember.image)
    end if
  end if
  return TRUE
end

on renderInstanceList me, tList, tStartIndex, tCount 
  tWndObj = getWindow(pMainWindowId)
  if (tWndObj = 0) then
    return FALSE
  end if
  i = 1
  repeat while i <= tCount
    tIndex = (tStartIndex + (i - 1))
    tElem = tWndObj.getElement("gs_area_gameList" & i)
    if (tElem = 0) then
      return FALSE
    end if
    if tIndex <= tList.count then
      tItem = tList.getAt(tIndex)
      tImage = me.getInstanceListItemBg(tItem.getAt(#state))
      tTextImg = pWriterPlainBoldLeft.render(tItem.getAt(#name))
      tImage.copyPixels(tTextImg, (tTextImg.rect + rect(32, 3, 32, 3)), tTextImg.rect)
      tTextImg = pWriterPlainNormRight.render(me.convertSecToMinSec(tItem.getAt(#gameLength)))
      tLocH = ((tImage.width - tTextImg.width) - 3)
      tImage.copyPixels(tTextImg, (tTextImg.rect + rect(tLocH, 3, tLocH, 3)), tTextImg.rect)
      tTextImg = pWriterPlainNormLeft.render(tItem.getAt(#host).getAt(#name))
      tImage.copyPixels(tTextImg, (tTextImg.rect + rect(32, 15, 32, 15)), tTextImg.rect)
      tTextImg = pWriterPlainNormLeft.render(getText("sw_fieldname_" & tItem.getAt(#fieldType)))
      tImage.copyPixels(tTextImg, (tTextImg.rect + rect(32, 28, 32, 28)), tTextImg.rect)
      tGoButtonImage = pGoButtonImages.getAt(tItem.getAt(#state))
      if tGoButtonImage <> void() then
        tLocH = ((tImage.width - tGoButtonImage.width) - 5)
        tImage.copyPixels(tGoButtonImage, (tGoButtonImage.rect + rect(tLocH, 26, tLocH, 26)), tGoButtonImage.rect, [#ink:36])
      end if
      tElem.setProperty(#cursor, "cursor.finger")
    else
      tImage = me.getInstanceListItemBg(#empty)
      tTextImg = pWriterPlainNormLeft.render("---")
      tImage.copyPixels(tTextImg, (tTextImg.rect + rect(32, 24, 32, 24)), tTextImg.rect)
      tElem.setProperty(#cursor, 0)
    end if
    tElem.feedImage(tImage)
    i = (1 + i)
  end repeat
  return TRUE
end

on getInstanceListItemBg me, tstate 
  if (tstate = #created) then
    tImage1 = member(getmemnum("sw_bg_grn4")).image
    tImage2 = member(getmemnum("sw_ico_thumb")).image
    tRegPoint2 = member(getmemnum("sw_ico_thumb")).regPoint
  else
    if (tstate = #started) then
      tImage1 = member(getmemnum("sw_bg_red4")).image
      tImage2 = member(getmemnum("sw_ico_bounce")).image
      tRegPoint2 = member(getmemnum("sw_ico_bounce")).regPoint
    else
      if (tstate = #finished) then
        tImage1 = member(getmemnum("sw_bg_gry4")).image
        tImage2 = member(getmemnum("sw_ico_flag")).image
        tRegPoint2 = member(getmemnum("sw_ico_flag")).regPoint
      else
        if (tstate = #empty) then
          tImage1 = member(getmemnum("sw_bg_emp3")).image
        end if
      end if
    end if
  end if
  tImage = image(191, 40, 8, member(getmemnum("snow_war2 Palette")))
  tImage.copyPixels(tImage1, tImage.rect, tImage1.rect)
  if tImage2 <> void() then
    tImage.copyPixels(tImage2, (tImage2.rect + rect((3 - tRegPoint2.locH), (7 - tRegPoint2.locV), (3 - tRegPoint2.locH), (7 - tRegPoint2.locV))), tImage2.rect, [#ink:8, #maskImage:tImage2.createMatte()])
  end if
  return(tImage)
end

on renderInstanceDetailTop me, tName, tHostName, tstate, tStateStr, tSpecs 
  tWndObj = getWindow(pMainWindowId)
  if (tWndObj = 0) then
    return FALSE
  end if
  tElem = tWndObj.getElement("gs_header_gameChsn")
  if tElem <> 0 then
    tElem.setText(tName)
  end if
  tImage = image(191, 48, 8, member(getmemnum("snow_war2 Palette")))
  if (tstate = #created) then
    tStateIconMember = member(getmemnum("sw_ico_thumb"))
    tBgImageMember = member(getmemnum("sw_gameinfo_bg_1"))
  else
    if (tstate = #started) then
      tStateIconMember = member(getmemnum("sw_ico_bounce"))
      tBgImageMember = member(getmemnum("sw_gameinfo_bg_1"))
    else
      if (tstate = #finished) then
        tStateIconMember = member(getmemnum("sw_ico_flag"))
        tBgImageMember = member(getmemnum("sw_gameinfo_bg_1"))
      end if
    end if
  end if
  if (tBgImageMember = member(0)) then
    return FALSE
  end if
  tBgImage = tBgImageMember.image
  tImage.copyPixels(tBgImage, tImage.rect, tBgImage.rect)
  tAddOffset = 0
  tTextImg = pWriterPlainNormLeft.render(tHostName)
  tImage.copyPixels(tTextImg, (tTextImg.rect + rect(32, (4 + tAddOffset), 32, (4 + tAddOffset))), tTextImg.rect)
  tTextImg = pWriterPlainNormLeft.render(tStateStr)
  tImage.copyPixels(tTextImg, (tTextImg.rect + rect(32, (20 + tAddOffset), 32, (20 + tAddOffset))), tTextImg.rect)
  tTextImg = pWriterPlainNormLeft.render(tSpecs)
  tImage.copyPixels(tTextImg, (tTextImg.rect + rect(32, (36 + tAddOffset), 32, (36 + tAddOffset))), tTextImg.rect)
  if (tStateIconMember = void()) then
    return FALSE
  end if
  tStateIcon = tStateIconMember.image
  tStRegpoint = tStateIconMember.regPoint
  tImage.copyPixels(tStateIcon, (tStateIcon.rect + rect((3 - tStRegpoint.locH), (13 - tStRegpoint.locV), (3 - tStRegpoint.locH), (13 - tStRegpoint.locV))), tStateIcon.rect, [#ink:8, #maskImage:tStateIcon.createMatte()])
  tElem = tWndObj.getElement("gs_area_gameInfo")
  if tElem <> 0 then
    tElem.feedImage(tImage)
  end if
  return TRUE
end

on renderInstanceDetailButton me, tButtonState, tGameState 
  tResult = image(191, 16, 8)
  tBlend = 255
  if tButtonState <> #start then
    if (tButtonState = #start_dimmed) then
      tBg = member(getmemnum("sw_lnk_px_1")).image
      tText = getText("gs_button_start")
      if (tButtonState = #start_dimmed) then
        tBlend = 50
        tButtonState = #start
      end if
    else
      if (tButtonState = #spectate) then
        tBg = member(getmemnum("sw_bg_px")).image
        tText = getText("gs_button_spectate")
      else
        if (tButtonState = #spectateInfo) then
          tBg = member(getmemnum("sw_bg_px")).image
          tText = getText("gs_text_spectate")
        else
          tText = ""
        end if
      end if
    end if
    if ilk(tBg) <> #image then
      return FALSE
    end if
    tResult.paletteRef = tBg.paletteRef
    tResult.copyPixels(tBg, tResult.rect, tBg.rect)
    tWidth = tResult.width
    if (tButtonState = #start) or (tButtonState = #spectate) then
      tImage = pWriterLinkRight.render(tText)
      tLocH = ((tWidth - tImage.width) - 10)
      tResult.copyPixels(tImage, (tImage.rect + rect((tLocH - 5), 3, (tLocH - 5), 3)), tImage.rect, [#blendLevel:tBlend])
      tImage = member(getmemnum("sw_arr")).image
      tResult.copyPixels(tImage, (tImage.rect + rect((tWidth - 12), 4, (tWidth - 12), 4)), tImage.rect, [#ink:36, #blendLevel:tBlend])
    else
      if tText <> #empty then
        tImage = pWriterPlainBoldLeft.render(tText)
        tLocH = ((tWidth / 2) - (tImage.width / 2))
        tResult.copyPixels(tImage, (tImage.rect + rect(tLocH, 3, tLocH, 3)), tImage.rect)
      end if
    end if
    tWndObj = getWindow(pMainWindowId)
    if (tWndObj = 0) then
      return FALSE
    end if
    tElem = tWndObj.getElement("gs_link_gameInfo")
    tElem.feedImage(tResult)
    if tButtonState <> #empty then
      if (tButtonState = #spectateInfo) then
        tElem.setProperty(#cursor, 0)
      else
        tElem.setProperty(#cursor, "cursor.finger")
      end if
    end if
  end if
end

on renderInstanceDetailTeams me, tParams, tUserName, tHost, tOwnTeam 
  tWndObj = getWindow(pMainWindowId)
  if (tWndObj = 0) then
    return FALSE
  end if
  tTeamNum = 1
  repeat while tTeamNum <= tParams.getAt(#numTeams)
    tImage = tWndObj.getElement("gs_area_team" & tTeamNum).getProperty(#buffer)
    if tImage.type <> #bitmap then
      return FALSE
    end if
    tImage = tImage.image
    tBallImage = member(getmemnum("sw_ico_team" & tParams.getAt(#teams).getAt(tTeamNum).getAt(#id))).image
    if tBallImage <> void() then
      tImage.copyPixels(tBallImage, (tBallImage.rect + rect(5, 6, 5, 6)), tBallImage.rect)
    end if
    tText = ""
    tPlayers = tParams.getAt(#teams).getAt(tTeamNum).getAt(#players)
    tPlayerNum = 1
    repeat while tPlayerNum <= tPlayers.count
      tText = tText & tPlayers.getAt(tPlayerNum).getAt(#name) & "\r"
      tElem = tWndObj.getElement("bb_kick" & tTeamNum & "_" & tPlayerNum)
      tNotMe = tPlayers.getAt(tPlayerNum).getAt(#name) <> tUserName
      if tElem <> 0 then
        tElem.setProperty(#visible, tHost and (tParams.getAt(#state) = #created) and tNotMe)
      end if
      tPlayerNum = (1 + tPlayerNum)
    end repeat
    tPlayerNum = (tPlayers.count + 1)
    repeat while tPlayerNum <= 12
      tElem = tWndObj.getElement("bb_kick" & tTeamNum & "_" & tPlayerNum)
      if tElem <> 0 then
        tElem.setProperty(#visible, 0)
      end if
      tPlayerNum = (1 + tPlayerNum)
    end repeat
    tAddedOffset = 0
    tTextImg = pWriterListPlainNormLeft.render(tText)
    tImage.copyPixels(tTextImg, (tTextImg.rect + rect(30, (-3 + tAddedOffset), 30, (-3 + tAddedOffset))), tTextImg.rect)
    if (tParams.getAt(#state) = #finished) then
      tText = ""
      tPlayerNum = 1
      repeat while tPlayerNum <= tPlayers.count
        tText = tText & tPlayers.getAt(tPlayerNum).getAt(#score) & "\r"
        tPlayerNum = (1 + tPlayerNum)
      end repeat
      pWriterPlainNormRight.define([#fixedLineSpace:16])
      tTextImg = pWriterPlainNormRight.render(tText)
      tOffsetH = 158
      tImage.copyPixels(tTextImg, (tTextImg.rect + rect(tOffsetH, (-3 + tAddedOffset), tOffsetH, (-3 + tAddedOffset))), tTextImg.rect)
      tTextImg = pWriterListPlainNormLeft.render(getText("gs_scores_team_" & tParams.getAt(#teams).getAt(tTeamNum).getAt(#id)))
      tOffsetV = (tImage.height - 18)
      tImage.copyPixels(tTextImg, (tTextImg.rect + rect(30, tOffsetV, 30, tOffsetV)), tTextImg.rect, [#ink:36])
      tTextImg = pWriterPlainNormRight.render(string(tParams.getAt(#teams).getAt(tTeamNum).getAt(#score)))
      tImage.copyPixels(tTextImg, (tTextImg.rect + rect(tOffsetH, tOffsetV, tOffsetH, tOffsetV)), tTextImg.rect)
    end if
    tTeamNum = (1 + tTeamNum)
  end repeat
  tTeamNum = 1
  repeat while tTeamNum <= 4
    tElem = tWndObj.getElement("gs_link_team" & tTeamNum)
    if tElem <> 0 then
      if (tTeamNum = tOwnTeam) or tParams.getAt(#state) <> #created then
        tElem.setProperty(#visible, 0)
      else
        tElem.setProperty(#visible, 1)
        tElem.feedImage(pJoinButtonImage)
      end if
    end if
    tTeamNum = (1 + tTeamNum)
  end repeat
end

on renderPageNumber me, tPage, tNumPages 
  tWndObj = getWindow(pMainWindowId)
  if (tWndObj = 0) then
    return FALSE
  end if
  tWndObj.getElement("gs_txt_pageNumber").setText(tPage & "/" & tNumPages)
  tElem = tWndObj.getElement("gs_arrow_pageBack")
  if tPage > 1 then
    tElem.setProperty(#blend, 100)
    tElem.setProperty(#cursor, "cursor.finger")
  else
    tElem.setProperty(#blend, 30)
    tElem.setProperty(#cursor, 0)
  end if
  tElem = tWndObj.getElement("gs_arrow_pageFwd")
  if tPage < tNumPages then
    tElem.setProperty(#blend, 100)
    tElem.setProperty(#cursor, "cursor.finger")
  else
    tElem.setProperty(#blend, 30)
    tElem.setProperty(#cursor, 0)
  end if
end

on updateRadioButton me, tElement, tListOfOthersElements 
  tOnImg = member(getmemnum("button.radio.on")).image
  tOffImg = member(getmemnum("button.radio.off")).image
  tWndObj = getWindow(pMainWindowId)
  if (tWndObj = 0) then
    return FALSE
  end if
  if tWndObj.elementExists(tElement) then
    tWndObj.getElement(tElement).setProperty(#image, tOnImg)
  end if
  repeat while tListOfOthersElements <= 1
    tRadioElement = getAt(1, count(tListOfOthersElements))
    if tWndObj.elementExists(tRadioElement) then
      tWndObj.getElement(tRadioElement).setProperty(#image, tOffImg)
    end if
  end repeat
end

on convertSecToMinSec me, tTime 
  tMin = (tTime / 60)
  tSec = (tTime mod 60)
  if tSec < 10 then
    tSec = "0" & tSec
  end if
  return(tMin & ":" & tSec)
end
