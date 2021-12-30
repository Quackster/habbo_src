on goMovie movieName, markerName 
  if the runMode contains "Plugin" then
    movieName = movieName & ".dcr"
    goNetMovieId = gotoNetMovie(movieName & "#" & markerName)
    return()
  end if
  go(markerName, movieName)
end

on goUnit unitName, door 
  NowinUnit = unitName
  hiliter = void()
  gDoor = door
  member("item.info_name").text = ""
  member("item.info_text").text = ""
  if (gCountryPrefix = "ch") then
    if (unitName = "lobby") then
      unitName = "lobby.ch"
    end if
    if (unitName = "Orange Cinema") then
      unitName = "Cinema.ch"
    end if
  end if
  put(unitName, gDoor)
  s = member("UnitMovies").text
  oldDelim = the itemDelimiter
  the itemDelimiter = "\t"
  movieName = "?"
  loadingTextKey = "?"
  i = 2
  repeat while i <= the number of line in s
    ln = s.getProp(#line, i)
    if (ln.getProp(#item, 1) = unitName) then
      movieName = ln.getProp(#item, 3)
      loadingTextKey = ln.getProp(#item, 2)
    end if
    i = (1 + i)
  end repeat
  put("Found", movieName, loadingTextKey)
  the itemDelimiter = oldDelim
  member("loading_txt").text = AddTextToField(loadingTextKey)
  gConnectionInstance = void()
  if the movieName contains "cr_entry" then
    put("please_wait")
    goContext("please_wait", gCRNavi)
    updateStage()
  end if
  if movieName <> void() then
    setBanner()
    goMovie(movieName, "connection_init")
  end if
end

on setBanner  
  if objectp(gAd) then
    show(gAd)
  else
    setDirBanner()
  end if
end

on setDirBanner  
end

on goToHotel  
  if (gCountryPrefix = "ch") then
    goMovie("habbo_ch_entry", "hotel")
  else
    if (gCountryPrefix = "cr") then
      goMovie("cr_entry", "hotel")
    else
      goMovie("habbo_entry", "hotel")
    end if
  end if
end
