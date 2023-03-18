global gBuddyList, gMessageManager, gChosenBuddyId, gMModeChosenMode

on mouseDown me
  global gCredits
  receivers = field("receivers")
  if receivers.length < 1 then
    ShowAlert("ChooseWhoToSentMessage")
    return 
  end if
  message = member("messenger.message.new").text
  if message.length < 1 then
    return 
  else
    if gMModeChosenMode = "MESSENGER" then
      sendEPFuseMsg("MESSENGER_SENDMSG" && receivers & RETURN & message)
    else
      if gMModeChosenMode = "EMAIL" then
        sendEPFuseMsg("MESSENGER_SENDEMAILMSG" && receivers & RETURN & message)
      else
        if gMModeChosenMode = "SMS" then
          smsPrice = the number of words in receivers * 1
          if smsPrice > gCredits then
            s = AddTextToField("smsCreditsNo1")
            s = stringReplace(s, "XXX", smsPrice)
            s = s & RETURN & RETURN & AddTextToField("smsCredits2")
            s = stringReplace(s, "XXX", gCredits)
            s = s & RETURN & RETURN & AddTextToField("smsCredits3")
            member("sms_conf_nocredits_e").text = s
            goContext("msg_sms_conf_nocredits")
          else
            s = AddTextToField("smsCredits1")
            s = stringReplace(s, "XXX", smsPrice)
            s = s & RETURN & RETURN & AddTextToField("smsCredits2")
            s = stringReplace(s, "XXX", gCredits)
            s = s & RETURN & RETURN & AddTextToField("smsCreditsSure")
            member("sms_conf_e").text = s
            goContext("msg_sms_conf")
          end if
          return 
        end if
      end if
    end if
    goContext("buddies")
  end if
  put EMPTY into field "receivers"
  member("messenger.message.new").text = EMPTY
  member("messenger.message.new").scrollTop = 0
  member("message.charCount").text = "0/255"
  puppetSound(2, "messagesent")
end
