property pWindowID, pVote, pPerformerID

on construct me 
  pWindowID = #judge_tool_window
  return TRUE
end

on deconstruct me 
  me.close()
  return TRUE
end

on close me 
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
end

on setState me, tstate, tPerformerID 
  if not integerp(tstate) then
    return FALSE
  end if
  if (tstate = 0) then
    return(me.close())
  end if
  if not createWindow(pWindowID) then
    me.close()
    return FALSE
  end if
  tWindow = getWindow(pWindowID)
  tWindow.setProperty(#title, getText("judge_tool_title"))
  tWindow.merge("habbo_full.window")
  if (tstate = 1) then
    tWindow.merge("judge_waiting.window")
  else
    if (tstate = 2) then
      if not integerp(tPerformerID) then
        me.close()
        return()
      end if
      pPerformerID = tPerformerID
      tWindow.merge("judge_voting.window")
      tWindow.registerProcedure(#eventProcVote, me.getID(), #mouseUp)
      me.updatePerformerInfo()
    else
      if (tstate = 3) then
        tWindow.merge("judge_ready.window")
        if tWindow.elementExists("vote_result") then
          if (tstate = -1) then
            tWindow.getElement("vote_result").setText(getText("judge_voted_no"))
          else
            if (tstate = 1) then
              tWindow.getElement("vote_result").setText(getText("judge_voted_yes"))
            else
              return(me.close())
            end if
          end if
        end if
        me.updatePerformerInfo()
      else
        me.close()
        return FALSE
      end if
    end if
  end if
  if tWindow.elementExists("close") then
    tWindow.getElement("close").hide()
  end if
end

on updatePerformerInfo me 
  if not threadExists(#room) then
    return FALSE
  end if
  tuser = getThread(#room).getComponent().getUserObjectByWebID(pPerformerID)
  if not tuser then
    return(me.close())
  end if
  tWindow = getWindow(pWindowID)
  if not tWindow then
    return FALSE
  end if
  if tWindow.elementExists("performer_name") then
    tWindow.getElement("performer_name").setText(tuser.getName())
  end if
  tImage = tuser.getPartialPicture(#head, void(), 2, "sh")
  tImage = tImage.trimWhiteSpace()
  if tWindow.elementExists("performer_image") then
    tWindow.getElement("performer_image").feedImage(tImage)
  end if
end

on eventProcVote me, tEvent, tSprID, tParam 
  tConn = getConnection(getVariable("connection.info.id"))
  if not tConn then
    return(me.close())
  end if
  if (tSprID = "vote_button_yes") then
    pVote = 1
    me.setState(3)
    tConn.send("VOTE_PERFORMANCE", [#integer:1])
  else
    if (tSprID = "vote_button_no") then
      pVote = -1
      me.setState(3)
      tConn.send("VOTE_PERFORMANCE", [#integer:-1])
    end if
  end if
end
