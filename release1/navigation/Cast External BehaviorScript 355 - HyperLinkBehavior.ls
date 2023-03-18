property pLinkTargetURL
global gCountryPrefix

on mouseUp me
  if member(sprite(me.spriteNum).member.name).word[sprite(me.spriteNum).pointToWord(the mouseLoc)].fontStyle = [#underline] then
    theUrl = pLinkTargetURL
    if gCountryPrefix = "ch" then
      saveDelim = the itemDelimiter
      the itemDelimiter = "/"
      webPage = theUrl.item[theUrl.item.count]
      the itemDelimiter = saveDelim
      tFolder = externalParamValue("sw1")
      ch_url = externalParamValue("sw2")
      if voidp(tFolder) then
        tFolder = "english"
      end if
      if voidp(ch_url) then
        ch_url = "213.55.128.132/"
      end if
      if tFolder contains "english" then
        theUrl = ch_url & "english/" & webPage
      else
        if tFolder contains "deutsch" then
          theUrl = ch_url & "deutsch/" & webPage
        else
          if tFolder contains "francais" then
            theUrl = ch_url & "francais/" & webPage
          else
            if tFolder contains "italiano" then
              theUrl = ch_url & "italiano/" & webPage
            end if
          end if
        end if
      end if
    end if
    put theUrl
    JumptoNetPage(theUrl, "_new")
  end if
end

on getPropertyDescriptionList
  description = [:]
  addProp(description, #pLinkTargetURL, [#default: "http://www.sulake.com", #format: #string, #comment: "URL to link"])
  return description
end
