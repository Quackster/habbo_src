property pPlayer01, pPlayer02, pGameActive, pGameCounterID

on construct me
  pGameCounterID = "PaaluCounter"
  createObject(pGameCounterID, "Peelo Counter Class")
  createObject("PeeloPlayer01", "Paalu Player Class")
  createObject("PeeloPlayer02", "Paalu Player Class")
  pPlayer01 = getObject("PeeloPlayer01")
  pPlayer02 = getObject("PeeloPlayer02")
  pPlayer01.setDir(0)
  pPlayer02.setDir(4)
  pGameActive = 0
  return 1
end

on deconstruct me
  executeMessage(#resume_messenger_update)
  if objectExists(pGameCounterID) then
    removeObject(pGameCounterID)
  end if
  pPlayer01 = VOID
  if objectExists("PeeloPlayer01") then
    removeObject("PeeloPlayer01")
  end if
  pPlayer02 = VOID
  if objectExists("PeeloPlayer02") then
    removeObject("PeeloPlayer02")
  end if
  pGameActive = 0
  return 1
end

on prepareGame me, tPlayer01, tPlayer02
  executeMessage(#pause_messenger_update)
  getObject(#session).set("peelo_kesken", 1)
  tPlayerObj01 = getThread(#room).getComponent().getUserObject(tPlayer01)
  tPlayerObj02 = getThread(#room).getComponent().getUserObject(tPlayer02)
  if (tPlayerObj01 = 0) or (tPlayerObj02 = 0) then
    pGameActive = 0
    return 0
  end if
  pPlayer01.define([#name: tPlayer01, #dir: 0])
  pPlayer02.define([#name: tPlayer02, #dir: 4])
  pPlayer01.status([#bal: 0, #loc: -3])
  pPlayer02.status([#bal: 0, #loc: 4])
  tMyIndex = getObject(#session).get("user_index")
  if tPlayer01 = tMyIndex then
    tOwnPlayer = pPlayer01
  else
    if tPlayer02 = tMyIndex then
      tOwnPlayer = pPlayer02
    end if
  end if
  if objectp(tOwnPlayer) then
    me.getInterface().prepare(tOwnPlayer)
  end if
  pGameActive = 1
  getObject(pGameCounterID).start()
end

on startGame me, tPlayer01, tPlayer02
  executeMessage(#pause_messenger_update)
  if not pGameActive then
    me.getInterface().resetDialog()
    tPlayerObj01 = getThread(#room).getComponent().getUserObject(tPlayer01)
    tPlayerObj02 = getThread(#room).getComponent().getUserObject(tPlayer02)
    pPlayer01.define([#name: tPlayer01, #dir: 0])
    pPlayer02.define([#name: tPlayer02, #dir: 4])
    pPlayer01.status([#bal: 0, #loc: -3])
    pPlayer02.status([#bal: 0, #loc: 4])
    pGameActive = 1
  end if
  tMyIndex = getObject(#session).get("user_index")
  if tPlayer01 = tMyIndex then
    me.getInterface().start()
  else
    if tPlayer02 = tMyIndex then
      me.getInterface().start()
    end if
  end if
  if objectExists("dew_camera") then
    getObject("dew_camera").activatePaaluPlayer(tPlayer01, pPlayer01)
    getObject("dew_camera").activatePaaluPlayer(tPlayer02, pPlayer02)
  end if
end

on updateGame me, tStatus01, tStatus02
  if pGameActive then
    pPlayer01.status(tStatus01)
    pPlayer02.status(tStatus02)
  end if
end

on timeout me, tTime
  put "TIMEOUT"
end

on endGame me, tLooser
  if not pGameActive then
    return 
  end if
  getThread(#paalu).getInterface().stop()
  case tLooser of
    0:
      pPlayer01.drop()
      if objectExists("dew_camera") then
        tUserName = getThread(#room).getComponent().getUserObject(pPlayer02.pName).getName()
        getObject("dew_camera").fuseShow_showtext(getText("paalu.winner", "VOITTAJA:") & RETURN & tUserName)
      end if
    1:
      pPlayer02.drop()
      if objectExists("dew_camera") then
        tUserName = getThread(#room).getComponent().getUserObject(pPlayer01.pName).getName()
        getObject("dew_camera").fuseShow_showtext(getText("paalu.winner", "VOITTAJA:") & RETURN & tUserName)
      end if
    #both:
      pPlayer01.drop()
      pPlayer02.drop()
  end case
  executeMessage(#resume_messenger_update)
end

on resetGame me
  if objectExists("dew_camera") then
    getObject("dew_camera").deActivatePaaluPlayer(pPlayer01.pName)
    getObject("dew_camera").deActivatePaaluPlayer(pPlayer02.pName)
  end if
  pPlayer01.reset()
  pPlayer02.reset()
  me.getInterface().stop()
  pGameActive = 0
  executeMessage(#resume_messenger_update)
end
