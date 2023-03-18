global gChosenUnitIp, gChosenUnitHost, gConnectionInstance, goNetMovieId

on goMovie movieName, markerName
  if the runMode contains "Plugin" then
    movieName = movieName & ".dcr"
    goNetMovieId = gotoNetMovie(movieName & "#" & markerName)
    return 
  end if
  go(markerName, movieName)
end

on goUnit unitName, door
  global gBannerUrl, hiliter, gDoor, NowinUnit, gCountryPrefix, gCRNavi
  NowinUnit = unitName
  hiliter = VOID
  gDoor = door
  member("item.info_name").text = EMPTY
  member("item.info_text").text = EMPTY
  if gCountryPrefix = "ch" then
    if unitName = "lobby" then
      unitName = "lobby.ch"
    end if
    if unitName = "Orange Cinema" then
      unitName = "Cinema.ch"
    end if
  end if
  put unitName, gDoor
  s = member("UnitMovies").text
  oldDelim = the itemDelimiter
  the itemDelimiter = TAB
  movieName = "?"
  loadingTextKey = "?"
  repeat with i = 2 to the number of lines in s
    ln = s.line[i]
    if ln.item[1] = unitName then
      movieName = ln.item[3]
      loadingTextKey = ln.item[2]
    end if
  end repeat
  put "Found", movieName, loadingTextKey
  the itemDelimiter = oldDelim
  member("loading_txt").text = AddTextToField(loadingTextKey)
  gConnectionInstance = VOID
  if the movieName contains "cr_entry" then
    put "please_wait"
    goContext("please_wait", gCRNavi)
    updateStage()
  end if
  if movieName <> VOID then
    setBanner()
    goMovie(movieName, "connection_init")
  end if
end

on setBanner
  global gAd
  if objectp(gAd) then
    show(gAd)
  else
    setDirBanner()
  end if
end

on setDirBanner
  global gBannerUrl
end

on goToHotel
  global gCountryPrefix
  if gCountryPrefix = "ch" then
    goMovie("habbo_ch_entry", "hotel")
  else
    if gCountryPrefix = "cr" then
      goMovie("cr_entry", "hotel")
    else
      goMovie("habbo_entry", "hotel")
    end if
  end if
end
