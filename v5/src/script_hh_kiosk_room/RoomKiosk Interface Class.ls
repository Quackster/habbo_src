property pWindowTitle, pRoomProps, pRoomModels, pTempPassword

on construct me 
  pTempPassword = [:]
  pWindowTitle = "RoomMatic"
  pRoomModels = ["a", "b", "c", "d", "e", "f", "g", "h"]
  pRoomProps = [:]
  return(1)
end

on deconstruct me 
  if windowExists(pWindowTitle) then
    removeWindow(pWindowTitle)
  end if
  return(1)
end

on showHideRoomKiosk me 
  if windowExists(pWindowTitle) then
    me.getComponent().updateState("start")
    removeWindow(pWindowTitle)
  else
    pTempPassword = [:]
    pRoomProps = [:]
    me.ChangeWindowView("roomatic1.window")
  end if
end

on ChangeWindowView me, tWindowName 
  createWindow(pWindowTitle)
  if windowExists(pWindowTitle) then
    tWndObj = getWindow(pWindowTitle)
    tWndObj.merge(tWindowName)
    tWndObj.moveTo(0, -4)
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProc, me.getID(), #keyDown)
    me.setPageValues(tWindowName)
  end if
end

on createRoom me 
  pRoomProps.setAt(#marker, "model_" & pRoomModels.getAt(value(pRoomProps.getAt("model"))))
  tFlatData = "/first floor/"
  repeat while [#name, #marker, #door, #showownername] <= undefined
    f = getAt(undefined, undefined)
    tFlatData = tFlatData & replaceChars(pRoomProps.getAt(f), "/", space()) & "/"
  end repeat
  tFlatData = tFlatData.getProp(#char, 1, length(tFlatData) - 1)
  me.getComponent().sendNewRoomData(tFlatData)
end

on flatcreated me, tFlatData 
  if tFlatData.ilk <> #propList then
    return(me.showHideRoomKiosk())
  end if
  me.ChangeWindowView("roomatic7.window")
  tWndObj = getWindow(pWindowTitle)
  pRoomProps.setAt(#id, tFlatData.getAt(#id))
  pRoomProps.setAt(#ip, tFlatData.getAt(#ip))
  pRoomProps.setAt(#port, tFlatData.getAt(#port))
  if pRoomProps.getAt(#door) = "password" then
    pRoomProps.setAt(#password, me.getPassword())
  else
    pRoomProps.setAt(#password, "")
  end if
  tText = getText("roomatic_roomnumber", "Room number:") && pRoomProps.getAt(#id)
  if tWndObj.elementExists("roomatic_newnumber") then
    tWndObj.getElement("roomatic_newnumber").setText(tText)
  end if
  tText = getText("roomatic_roomname", "Room name:") && pRoomProps.getAt(#name)
  if tWndObj.elementExists("roomatic_newname") then
    tWndObj.getElement("roomatic_newname").setText(tText)
  end if
  return(me.sendFlatInfo())
end

on sendFlatInfo me 
  tFlatMsg = "/" & replaceChars(string(pRoomProps.getAt(#id)), "/", space()) & "/" & "\r"
  tFlatMsg = tFlatMsg & "description=" & replaceChars(pRoomProps.getAt(#description), "/", space()) & "\r"
  tFlatMsg = tFlatMsg & "password=" & pRoomProps.getAt(#password) & "\r"
  tFlatMsg = tFlatMsg & "allsuperuser=" & pRoomProps.getAt(#ableothersmovefurniture)
  me.getComponent().sendSetFlatInfo(tFlatMsg)
end

on updateRadioButton me, tElement, tListOfOtherElements 
  tOnImg = member(getmemnum("button.checkbox_green.on")).image
  tOffImg = member(getmemnum("button.checkbox_green.off")).image
  tWindowObj = getWindow(pWindowTitle)
  if tWindowObj.elementExists(tElement) then
    tWindowObj.getElement(tElement).feedImage(tOnImg)
  end if
  repeat while tListOfOtherElements <= tListOfOtherElements
    tElement = getAt(tListOfOtherElements, tElement)
    if tWindowObj.elementExists(tElement) then
      tWindowObj.getElement(tElement).feedImage(tOffImg)
    end if
  end repeat
end

on updateCheckButton me, tElement, tProp, tChangeMode 
  tWindowObj = getWindow(pWindowTitle)
  tOnImg = member(getmemnum("button.checkbox_green.on")).image
  tOffImg = member(getmemnum("button.checkbox_green.off")).image
  if voidp(pRoomProps.getAt(tProp)) then
    pRoomProps.setAt(tProp, "0")
  end if
  if voidp(tChangeMode) then
    tChangeMode = 0
  end if
  if tChangeMode then
    if pRoomProps.getAt(tProp) = "1" then
      pRoomProps.setAt(tProp, "0")
    else
      pRoomProps.setAt(tProp, "1")
    end if
  end if
  if pRoomProps.getAt(tProp) = "1" then
    if tWindowObj.elementExists(tElement) then
      tWindowObj.getElement(tElement).feedImage(tOnImg)
    end if
  else
    if tWindowObj.elementExists(tElement) then
      tWindowObj.getElement(tElement).feedImage(tOffImg)
    end if
  end if
end

on checkPassword me 
  if voidp(pTempPassword.getAt("roomatic_password_field")) then
    tPw1 = []
  else
    tPw1 = pTempPassword.getAt("roomatic_password_field")
  end if
  if voidp(pTempPassword.getAt("roomatic_password2_field")) then
    tPw2 = []
  else
    tPw2 = pTempPassword.getAt("roomatic_password2_field")
  end if
  return(tPw1 = tPw2)
end

on getPassword me 
  tPw = ""
  f = 1
  repeat while f <= count(pTempPassword.getAt("roomatic_password_field"))
    tPw = tPw & pTempPassword.getAt("roomatic_password_field").getAt(f)
    f = 1 + f
  end repeat
  return(tPw)
end

on setPageValues me, tWindowName 
  if tWindowName = "roomatic2.window" then
    tWndObj = getWindow(pWindowTitle)
    if not voidp(pRoomProps.getAt(#name)) then
      tWndObj.getElement("roomatic_roomname_field").setText(pRoomProps.getAt(#name))
    end if
    if not voidp(pRoomProps.getAt(#description)) then
      tWndObj.getElement("romatic_roomdescription_field").setText(pRoomProps.getAt(#description))
    end if
    pRoomProps.setAt(#owner, getObject(#session).get("user_name"))
    tWndObj.getElement("roomatic_ownername_field").setText(pRoomProps.getAt(#owner))
    if not voidp(pRoomProps.getAt(#showownername)) then
      if pRoomProps.getAt(#showownername) = 1 then
        me.updateRadioButton("roomatic_namedisplayed_yes_check", ["roomatic_namedisplayed_no_check"])
      else
        me.updateRadioButton("roomatic_namedisplayed_no_check", ["roomatic_namedisplayed_yes_check"])
      end if
    else
      pRoomProps.setAt(#showownername, 1)
      me.updateRadioButton("roomatic_namedisplayed_yes_check", ["roomatic_namedisplayed_no_check"])
    end if
  else
    if tWindowName <> "roomatic3.window" then
      if tWindowName = "roomatic_club.window" then
        tOthers = []
        if voidp(pRoomProps.getAt("model")) then
          pRoomProps.setAt("model", "1")
        end if
        tRoomModel = pRoomProps.getAt("model")
        f = 1
        repeat while f <= count(pRoomModels)
          if f <> value(tRoomModel) then
            tOthers.add("roomatic_roomchoose_" & f)
          end if
          f = 1 + f
        end repeat
        me.updateRadioButton("roomatic_roomchoose_" & tRoomModel, tOthers)
        if tWindowName = "roomatic3.window" then
          if not getObject(#session).get("user_rights").getPos("special_room_layouts") then
            getWindow(pWindowTitle).getElement("goto_club_layouts").hide()
          end if
        end if
      else
        if tWindowName = "roomatic4.window" then
          pTempPassword = [:]
          if not voidp(pRoomProps.getAt(#door)) then
            tOthers = ["open":"roomatic_security_open", "closed":"roomatic_security_locked", "password":"roomatic_security_pwc"]
            tActive = tOthers.getAt(pRoomProps.getAt(#door))
            tOthers.deleteProp(pRoomProps.getAt(#door))
            me.updateRadioButton(tActive, tOthers)
          else
            pRoomProps.setAt(#door, "open")
            tOthers = ["roomatic_security_locked", "roomatic_security_pwc"]
            me.updateRadioButton("roomatic_security_open", tOthers)
          end if
          me.updateCheckButton("roomatic_security_letmove", #ableothersmovefurniture, 0)
        end if
      end if
    end if
  end if
end

on eventProc me, tEvent, tSprID, tParm 
  if tEvent = #mouseUp then
    if tSprID = "roomatic_1_button_start" then
      me.ChangeWindowView("roomatic2.window")
    else
      if tSprID = "roomatic_1_button_cancel" then
        me.showHideRoomKiosk()
      else
        if tSprID = "roomatic_2_button_cancel" then
          me.showHideRoomKiosk()
        else
          if tSprID = "roomatic_2_button_next" then
            tRoomName = getWindow(pWindowTitle).getElement("roomatic_roomname_field").getText()
            if tRoomName = "" then
              return(executeMessage(#alert, [#msg:"roomatic_givename"]))
            end if
            pRoomProps.setAt(#name, tRoomName)
            pRoomProps.setAt(#description, getWindow(pWindowTitle).getElement("romatic_roomdescription_field").getText())
            me.ChangeWindowView("roomatic3.window")
          else
            if tSprID = "roomatic_1_button_cancel" then
              me.ChangeWindowView("roomatic1.window")
            else
              if tSprID = "roomatic_namedisplayed_yes_check" then
                pRoomProps.setAt(#showownername, 1)
                me.updateRadioButton("roomatic_namedisplayed_yes_check", ["roomatic_namedisplayed_no_check"])
              else
                if tSprID = "roomatic_namedisplayed_no_check" then
                  pRoomProps.setAt(#showownername, 0)
                  me.updateRadioButton("roomatic_namedisplayed_no_check", ["roomatic_namedisplayed_yes_check"])
                else
                  if tSprID = "roomatic_3_button_next" then
                    me.ChangeWindowView("roomatic4.window")
                  else
                    if tSprID = "roomatic_3_button_previous" then
                      me.ChangeWindowView("roomatic2.window")
                    else
                      if tSprID = "roomatic_4_button_done" then
                        if pRoomProps.getAt(#door) = "password" then
                          if not me.checkPassword() then
                            return(me.ChangeWindowView("roomatic5.window"))
                          end if
                        end if
                        me.createRoom()
                        me.ChangeWindowView("roomatic6.window")
                      else
                        if tSprID = "roomatic_4_button_previous" then
                          me.ChangeWindowView("roomatic3.window")
                        else
                          if tSprID = "goto_club_layouts" then
                            me.ChangeWindowView("roomatic_club.window")
                          else
                            if tSprID = "roomatic_security_open" then
                              pRoomProps.setAt(#door, "open")
                              tOthers = ["roomatic_security_locked", "roomatic_security_pwc"]
                              me.updateRadioButton("roomatic_security_open", tOthers)
                            else
                              if tSprID = "roomatic_security_locked" then
                                pRoomProps.setAt(#door, "closed")
                                tOthers = ["roomatic_security_open", "roomatic_security_pwc"]
                                me.updateRadioButton("roomatic_security_locked", tOthers)
                              else
                                if tSprID = "roomatic_security_pwc" then
                                  pRoomProps.setAt(#door, "password")
                                  tOthers = ["roomatic_security_open", "roomatic_security_locked"]
                                  me.updateRadioButton("roomatic_security_pwc", tOthers)
                                else
                                  if tSprID = "roomatic_security_letmove" then
                                    me.updateCheckButton("roomatic_security_letmove", #ableothersmovefurniture, 1)
                                  else
                                    if tSprID = "roomatic_5_button_back" then
                                      me.ChangeWindowView("roomatic4.window")
                                    else
                                      if tSprID = "roomatic_7_button_go" then
                                        me.showHideRoomKiosk()
                                        if threadExists(#navigator) then
                                          getThread(#navigator).getComponent().roomkioskGoingFlat(pRoomProps)
                                        end if
                                      else
                                        if tSprID = "roomatic_7_button_cancel" then
                                          me.showHideRoomKiosk()
                                        else
                                          if tSprID contains "roomatic_roomchoose" then
                                            tDelim = the itemDelimiter
                                            the itemDelimiter = "_"
                                            tRoomModel = tSprID.getProp(#item, 3)
                                            the itemDelimiter = tDelim
                                            pRoomProps.setAt("model", tRoomModel)
                                            tOthers = []
                                            f = 1
                                            repeat while f <= count(pRoomModels)
                                              if f <> value(tRoomModel) then
                                                tOthers.add("roomatic_roomchoose_" & f)
                                              end if
                                              f = 1 + f
                                            end repeat
                                            me.updateRadioButton("roomatic_roomchoose_" & tRoomModel, tOthers)
                                          end if
                                        end if
                                      end if
                                    end if
                                  end if
                                end if
                              end if
                            end if
                          end if
                        end if
                      end if
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  else
    if tEvent = #keyDown then
      if tSprID <> "roomatic_password_field" then
        if tSprID = "roomatic_password2_field" then
          if voidp(pTempPassword.getAt(tSprID)) then
            pTempPassword.setAt(tSprID, [])
          end if
          if tSprID = 48 then
            return(0)
          else
            if tSprID = 51 then
              if pTempPassword.getAt(tSprID).count > 0 then
                pTempPassword.getAt(tSprID).deleteAt(pTempPassword.getAt(tSprID).count)
              end if
            else
              if tSprID = 117 then
                pTempPassword.setAt(tSprID, [])
              else
                tValidKeys = getVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
                tTheKey = the key
                tASCII = charToNum(tTheKey)
                if tASCII > 31 and tASCII < 128 then
                  if tValidKeys contains tTheKey or tValidKeys = "" then
                    if pTempPassword.getAt(tSprID).count < 32 then
                      pTempPassword.getAt(tSprID).append(tTheKey)
                    end if
                  end if
                end if
              end if
            end if
          end if
          tStr = ""
          repeat while tSprID <= tSprID
            tChar = getAt(tSprID, tEvent)
          end repeat
          getWindow(pWindowTitle).getElement(tSprID).setText(tStr)
          the selStart = pTempPassword.getAt(tSprID).count
          the selEnd = pTempPassword.getAt(tSprID).count
          return(1)
        end if
      end if
    end if
  end if
end
