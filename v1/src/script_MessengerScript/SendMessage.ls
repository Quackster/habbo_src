on mouseDown me 
  receivers = field(0)
  if receivers.length < 1 then
    ShowAlert("ChooseWhoToSentMessage")
    return()
  end if
  message = member("messenger.message.new").text
  if message.length < 1 then
    return()
  else
    if (gMModeChosenMode = "MESSENGER") then
      sendEPFuseMsg("MESSENGER_SENDMSG" && receivers & "\r" & message)
    else
      if (gMModeChosenMode = "EMAIL") then
        sendEPFuseMsg("MESSENGER_SENDEMAILMSG" && receivers & "\r" & message)
      else
        if (gMModeChosenMode = "SMS") then
          smsPrice = (the number of word in receivers * 1)
          if smsPrice > gCredits then
            s = AddTextToField("smsCreditsNo1")
            s = stringReplace(s, "XXX", smsPrice)
            s = s & "\r" & "\r" & AddTextToField("smsCredits2")
            s = stringReplace(s, "XXX", gCredits)
            s = s & "\r" & "\r" & AddTextToField("smsCredits3")
            member("sms_conf_nocredits_e").text = s
            goContext("msg_sms_conf_nocredits")
          else
            s = AddTextToField("smsCredits1")
            s = stringReplace(s, "XXX", smsPrice)
            s = s & "\r" & "\r" & AddTextToField("smsCredits2")
            s = stringReplace(s, "XXX", gCredits)
            s = s & "\r" & "\r" & AddTextToField("smsCreditsSure")
            member("sms_conf_e").text = s
            goContext("msg_sms_conf")
          end if
          return()
        end if
      end if
    end if
    goContext("buddies")
  end if
  member("messenger.message.new").text = ""
  member("messenger.message.new").scrollTop = 0
  member("message.charCount").text = "0/255"
  puppetSound(2, "messagesent")
end
