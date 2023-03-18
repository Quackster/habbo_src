property id, data_url, data_type, text, link, netId

on new me, fuse_s
  id = integer(line 1 of fuse_s)
  data_url = line 2 of fuse_s
  data_type = line 3 of fuse_s
  text = line 4 of fuse_s
  link = line 5 of fuse_s
  netId = -1
  if data_url contains "http:" then
    netId = preloadNetThing(data_url)
  end if
  return me
end

on click me
  if me.id > 0 then
    sendEPFuseMsg("ADCLICK" && me.id)
  end if
  if link contains "http:" then
    JumptoNetPage(link, "_new")
  end if
end

on show me
  m = member("the_banner")
  if (netId >= 0) and netDone(netId) and (netError(netId) = "OK") then
    importFileInto(m, data_url)
    m.name = "the_banner"
    member("banner_text").text = text
    sendEPFuseMsg("ADVIEW" && me.id)
  else
    dirbanner(me)
  end if
end

on dirbanner me
end
