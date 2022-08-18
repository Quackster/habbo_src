property spriteNum, pCountriesThatNeedsPostCode, pReady

on beginSprite me 
  sprite(spriteNum).blend = 50
  member("country_pop_field").text = ""
  member("country_pop_field2").text = ""
  member("postcode_pop_field").text = ""
  pReady = 0
  pCountry = ""
  pPostCode = ""
  pCountriesThatNeedsPostCode = ["uk", "UK", "uK", "Uk", "United Kingdom"]
end

on mouseUp me 
  if sprite(spriteNum).blend <> 100 then
    dontPassEvent()
  end if
  tCountry = member("country_pop_field2").text
  tPostCode = member("postcode_pop_field").text
  if (tCountry = "") then
    dontPassEvent()
  else
    if pCountriesThatNeedsPostCode.getPos(tCountry) <> 0 and (tPostCode = "") then
      put("Missing postcode!")
      dontPassEvent()
    end if
  end if
  if tPostCode <> "" then
    tCodeFound = 0
    i = 1
    repeat while i <= member("PostCodeList").text.count(#line)
      if (tPostCode = member("PostCodeList").text.getProp(#line, i)) then
        tCodeFound = 1
      else
        i = (1 + i)
      end if
    end repeat
    if not tCodeFound then
      put("Invalid postcode!")
      dontPassEvent()
    end if
  end if
  sendEPFuseMsg("UPDATE_COUNTRY /" & tCountry & "/" & tPostCode)
  pReady = 1
  put("Countrydata added!")
end

on exitFrame me 
  tAllOK = 0
  tCountry = member("country_pop_field2").text
  tPostCode = member("postcode_pop_field").text
  if tCountry <> "" then
    tAllOK = 1
    if pCountriesThatNeedsPostCode.getPos(tCountry) <> 0 and (tPostCode = "") then
      tAllOK = 0
    end if
  end if
  if tAllOK then
    sprite(spriteNum).blend = 100
  else
    sprite(spriteNum).blend = 50
  end if
  if not pReady then
    go(the frame)
  end if
end
