on gotoFrame tMarker
  if integerp(tMarker) then
    go(tMarker)
  else
    tMarker = string(tMarker)
    if label(tMarker) > 0 then
      go(tMarker)
    else
      put "Marker" && tMarker && "not found."
      sendEPFuseMsg("STAT /wrongmarker/" & tMarker)
    end if
  end if
end
