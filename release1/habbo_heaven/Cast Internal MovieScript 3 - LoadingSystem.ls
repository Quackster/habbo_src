on prepareMovie
  global gLoader
  if the runMode <> "Author" then
    gLoader = new(script("LoaderParent"))
    gLoader.AddpreloadNetThing(the moviePath & the movieName)
    repeat with f = 1 to the number of castLibs
      if (castLib(f).name <> "Internal") and (castLib(f).fileName.char[length(castLib(f).fileName) - 2..length(castLib(f).fileName)] <> "dcr") then
        gLoader.AddpreloadNetThing(the moviePath & castLib(f).name & ".cct")
      end if
    end repeat
  end if
end
