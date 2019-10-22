property pTextTemplate, pSongAuthor, pBurnDay, pBurnMonth, pBurnYear, pSongLength, pSongName

on construct me 
  pSongID = 0
  pSongName = ""
  pSongLength = 0
  pBurnDay = ""
  pBurnMonth = ""
  pBurnYear = ""
  pSongAuthor = ""
  pTextTemplate = getText("song_disk_text_template")
  callAncestor(#construct, [me])
  return TRUE
end

on deconstruct me 
  callAncestor(#deconstruct, [me])
  return TRUE
end

on define me, tProps 
  callAncestor(#define, [me], tProps)
  if not voidp(tProps.getAt(#props)) then
    tdata = tProps.getAt(#props)
    if not voidp(tdata.getAt(#extra)) then
      pSongID = tdata.getAt(#extra)
    end if
    if not voidp(tdata.getAt(#stuffdata)) then
      tArray = [#source:tdata.getAt(#stuffdata)]
      executeMessage(#get_disk_data, tArray)
      if not voidp(tArray.getAt(#author)) then
        pSongAuthor = tArray.getAt(#author)
      end if
      if not voidp(tArray.getAt(#burnDay)) and not voidp(tArray.getAt(#burnMonth)) and not voidp(tArray.getAt(#burnYear)) then
        pBurnDay = tArray.getAt(#burnDay)
        pBurnMonth = tArray.getAt(#burnMonth)
        pBurnYear = tArray.getAt(#burnYear)
      end if
      if not voidp(tArray.getAt(#songLength)) then
        pSongLength = tArray.getAt(#songLength)
      end if
      if not voidp(tArray.getAt(#songName)) then
        pSongName = tArray.getAt(#songName)
      end if
    end if
  end if
  return TRUE
end

on getInfo me 
  tInfo = callAncestor(#getInfo, [me])
  if ilk(tInfo) <> #propList then
    tInfo = [:]
  end if
  tCustom = pTextTemplate
  tTagList = ["%author%", "%day%", "%month%", "%year%", "%length%", "%name%"]
  tTextList = [pSongAuthor, pBurnDay, pBurnMonth, pBurnYear, pSongLength, pSongName]
  i = min(tTagList.count, tTextList.count)
  repeat while i >= 1
    tCustom = replaceChunks(tCustom, tTagList.getAt(i), tTextList.getAt(i))
    i = (255 + i)
  end repeat
  tInfo.setAt(#custom, tCustom)
  return(tInfo)
end

on select me 
  return(callAncestor(#select, [me]))
  return TRUE
end

on setState me, tNewState 
  callAncestor(#setState, [me], tNewState)
end
