global gMyName, gCountryPrefix

on mouseUp me
  webPage = "purchase.jsp?userName=" & gMyName
  url = "http://www.habbohotel.com/"
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
      url = ch_url & "english/"
    else
      if tFolder contains "deutsch" then
        url = ch_url & "deutsch/"
      else
        if tFolder contains "francais" then
          url = ch_url & "francais/"
        else
          if tFolder contains "italiano" then
            url = ch_url & "italiano/"
          end if
        end if
      end if
    end if
  end if
  put url & webPage
  JumptoNetPage(url & webPage, "_new")
end
