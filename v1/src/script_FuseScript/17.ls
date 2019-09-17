on exitFrame  
  if gConnectionOk = 0 or gConnectionsSecured = 0 then
    go(#loop)
  else
    if gGoTo = "scene_transition" then
      init()
      fuseLogin("loginpw", field(0))
      goToFrame("scene")
    else
      if gGoTo = "maja" then
        init()
        member("gameinfo_1").text = ""
        member("gameinfo_2").text = ""
        fuseLogin("loginpw", field(0))
        goToFrame(gGoTo)
      else
        if gGoTo = "change1" then
          oldPassword = field(0)
          fuseRetrieveInfo("loginpw", field(0))
          goToFrame("change1wait")
        else
          if gGoTo = "register" then
            fuseRegister()
            init()
            fuseLogin("loginpw", field(0))
            gGoTo = "scene_transition"
            goToFrame("connect_ok")
          else
            if gGoTo = "registerUpdate" then
              fuseRegister(1)
              goToFrame(gGoTo)
            end if
          end if
        end if
      end if
    end if
  end if
end
