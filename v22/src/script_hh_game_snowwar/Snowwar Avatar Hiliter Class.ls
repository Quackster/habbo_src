property pNameSpriteNum, pBottomSpriteNum, pNameFieldMemName

on display me, tName, tScore, tTeamId, tloc, tOwnPlayer
  if not stringp(tName) then
    return error(me, "String expected by hiliter.", #display)
  end if
  pNameSpriteNum = reserveSprite((("sw_hiliter1_" & tName) & tTeamId))
  pBottomSpriteNum = reserveSprite((("sw_hiliter2_" & tName) & tTeamId))
  if ((pNameSpriteNum = 0) or (pBottomSpriteNum = 0)) then
    return 0
  end if
  tText = getText("gs_mouseover_player")
  tText = replaceChunks(tText, "\x", tName)
  tText = replaceChunks(tText, "\r", RETURN)
  tText = replaceChunks(tText, "\y", tScore)
  tmember = me.getNameFieldMember(tText, tTeamId)
  tsprite = sprite(pNameSpriteNum)
  if (tmember <> 0) then
    tsprite.member = tmember
  end if
  tsprite.locZ = 1000000
  tsprite.loc = point((tloc[1] - (tmember.width / 2)), (tloc[2] + 10))
  tsprite.ink = 36
  if not tOwnPlayer then
    tmember = member(getmemnum(("sw_avatar_hilite_team_" & tTeamId)))
    tsprite = sprite(pBottomSpriteNum)
    if (tmember.type = #bitmap) then
      tsprite.member = tmember
    end if
    tsprite.locZ = (tloc[3] - 1)
    tsprite.loc = point(tloc[1], tloc[2])
    tsprite.ink = 36
  end if
  return 1
end

on hide me
  if memberExists(pNameFieldMemName) then
    removeMember(pNameFieldMemName)
  end if
  if (pNameSpriteNum > 0) then
    releaseSprite(pNameSpriteNum)
  end if
  if (pBottomSpriteNum > 0) then
    releaseSprite(pBottomSpriteNum)
  end if
  pNameSpriteNum = VOID
  pBottomSpriteNum = VOID
  return 0
end

on getNameFieldMember me, tText, tTeamId
  pNameFieldMemName = "____sw_hilite_field"
  if not memberExists(pNameFieldMemName) then
    tNameFieldMem = member(createMember(pNameFieldMemName, #text))
  else
    tNameFieldMem = getMember(pNameFieldMemName)
  end if
  if (tNameFieldMem.type = #empty) then
    return 0
  end if
  tTeamColor = rgb(string(getVariable(("snowwar.teamcolors.team" & tTeamId))))
  tFontStruct = getStructVariable("struct.font.bold")
  tNameFieldMem.color = tTeamColor
  tNameFieldMem.fontSize = tFontStruct[#fontSize]
  tNameFieldMem.alignment = #center
  tNameFieldMem.fontStyle = tFontStruct[#fontStyle]
  tNameFieldMem.font = tFontStruct[#font]
  tNameFieldMem.text = tText
  return tNameFieldMem
end
