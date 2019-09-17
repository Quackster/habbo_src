on JumptoNetPage url, targetName 
  the itemDelimiter = "/"
  nameOffset = url.count(#item)
  webPage = url.getProp(#item, nameOffset)
  if gCountryPrefix = "ch" then
    tFolder = externalParamValue("sw1")
    ch_url = externalParamValue("sw2")
    if voidp(tFolder) then
      tFolder = "english"
    end if
    if voidp(ch_url) then
      ch_url = "213.55.128.132/"
    end if
    if tFolder contains "english" then
      url = ch_url & "english/" & webPage
    else
      if tFolder contains "deutsch" then
        url = ch_url & "deutsch/" & webPage
      else
        if tFolder contains "francais" then
          url = ch_url & "francais/" & webPage
        else
          if tFolder contains "italiano" then
            url = ch_url & "italiano/" & webPage
          end if
        end if
      end if
    end if
  end if
  gotoNetPage(url, targetName)
end
