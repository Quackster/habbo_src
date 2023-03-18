property pSongID, pSongName, pSongAuthor, pSongLength, pBurnDay, pBurnMonth, pBurnYear, pTextTemplate

on construct me
  pSongID = 0
  pSongName = EMPTY
  pSongLength = 0
  pBurnDay = EMPTY
  pBurnMonth = EMPTY
  pBurnYear = EMPTY
  pSongAuthor = EMPTY
  pTextTemplate = getText("song_disk_text_template")
  callAncestor(#construct, [me])
  return 1
end

on deconstruct me
  callAncestor(#deconstruct, [me])
  return 1
end

on define me, tProps
  callAncestor(#define, [me], tProps)
  if not voidp(tProps[#props]) then
    tdata = tProps[#props]
    if not voidp(tdata[#extra]) then
      pSongID = tdata[#extra]
    end if
    if not voidp(tdata[#stuffdata]) then
      tArray = [#source: tdata[#stuffdata]]
      executeMessage(#get_disk_data, tArray)
      if not voidp(tArray[#author]) then
        pSongAuthor = tArray[#author]
      end if
      if not voidp(tArray[#burnDay]) and not voidp(tArray[#burnMonth]) and not voidp(tArray[#burnYear]) then
        pBurnDay = tArray[#burnDay]
        pBurnMonth = tArray[#burnMonth]
        pBurnYear = tArray[#burnYear]
      end if
      if not voidp(tArray[#songLength]) then
        pSongLength = tArray[#songLength]
      end if
      if not voidp(tArray[#songName]) then
        pSongName = tArray[#songName]
      end if
    end if
  end if
  return 1
end

on getInfo me
  tInfo = callAncestor(#getInfo, [me])
  if ilk(tInfo) <> #propList then
    tInfo = [:]
  end if
  tCustom = pTextTemplate
  tTagList = ["%author%", "%day%", "%month%", "%year%", "%length%", "%name%"]
  tTextList = [pSongAuthor, pBurnDay, pBurnMonth, pBurnYear, pSongLength, pSongName]
  repeat with i = min(tTagList.count, tTextList.count) down to 1
    tCustom = replaceChunks(tCustom, tTagList[i], tTextList[i])
  end repeat
  tInfo[#custom] = tCustom
  return tInfo
end

on select me
  return callAncestor(#select, [me])
  return 1
end

on setState me, tNewState
  callAncestor(#setState, [me], tNewState)
end
