on mouseDown
  if member("item.info_text").text contains "Matchem-nimi" then
    put "huuhaa"
    JumptoNetPage("http://kolumbus.fi/yhteiso/matchem", "_new")
  end if
end
