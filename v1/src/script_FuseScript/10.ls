on new me 
  return(me)
end

on alertHook me, pErr, pMsg 
  errMsg = errMsg & "Error: " & pErr & "\r"
  errMsg = errMsg & "Message: " & pMsg & "\r"
  errMsg = errMsg & "Frame: " & the frame & "\r"
  if the frameLabel <> 0 then
    errMsg = errMsg & "Label: " & the frameLabel & "\r"
  end if
  errMsg = errMsg & "Movie: " & the movieName & "\r"
  mailMessage = "otto@sulake.com" & "\r" & "alert.habbo@habbo.com" & "\r" & "Habbo Alert" & "\r"
  mailMessage = mailMessage & errMsg & "\r" & "\r"
  mailMessage = mailMessage & "Environmet:" & the environment & "\r"
  mailMessage = mailMessage & "Memory: " & the memorysize / 1024 / 1024 & "\r" & "\r"
  mailMessage = mailMessage & "UserName: " & gMyName & "\r"
  if StreamBugFlag = void() then
    StreamBugFlag = 0
  end if
  if pMsg contains "streaming is not complete" and StreamBugFlag = 0 and the movieName <> "habbo_entry.dcr" then
    StreamBugFlag = 1
    gotoNetMovie(the moviePath & the movieName & "#" & "connection_init")
    return(1)
  end if
  ShowAlert(errMsg)
  return(1)
end
