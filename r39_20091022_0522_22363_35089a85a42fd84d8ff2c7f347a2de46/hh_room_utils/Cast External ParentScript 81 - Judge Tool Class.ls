property pWindowID, pVote, pPerformerID

on construct me
  pWindowID = #judge_tool_window
  return 1
end

on deconstruct me
  me.close()
  return 1
end

on close me
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
end

on setState me, tstate, tPerformerID
  if not integerp(tstate) then
    return 0
  end if
  if tstate = 0 then
    return me.close()
  end if
  if not createWindow(pWindowID) then
    me.close()
    return 0
  end if
  tWindow = getWindow(pWindowID)
  tWindow.setProperty(#title, getText("judge_tool_title"))
  tWindow.merge("habbo_full.window")
  case tstate of
    1:
      tWindow.merge("judge_waiting.window")
    2:
      if not integerp(tPerformerID) then
        me.close()
        return 
      end if
      pPerformerID = tPerformerID
      tWindow.merge("judge_voting.window")
      tWindow.registerProcedure(#eventProcVote, me.getID(), #mouseUp)
      me.updatePerformerInfo()
    3:
      tWindow.merge("judge_ready.window")
      if tWindow.elementExists("vote_result") then
        case pVote of
          (-1):
            tWindow.getElement("vote_result").setText(getText("judge_voted_no"))
          1:
            tWindow.getElement("vote_result").setText(getText("judge_voted_yes"))
          otherwise:
            return me.close()
        end case
      end if
      me.updatePerformerInfo()
    otherwise:
      me.close()
      return 0
  end case
  if tWindow.elementExists("close") then
    tWindow.getElement("close").hide()
  end if
end

on updatePerformerInfo me
  if not threadExists(#room) then
    return 0
  end if
  tuser = getThread(#room).getComponent().getUserObjectByWebID(pPerformerID)
  if not tuser then
    return me.close()
  end if
  tWindow = getWindow(pWindowID)
  if not tWindow then
    return 0
  end if
  if tWindow.elementExists("performer_name") then
    tWindow.getElement("performer_name").setText(tuser.getName())
  end if
  tImage = tuser.getPartialPicture(#head, VOID, 2, "sh")
  tImage = tImage.trimWhiteSpace()
  if tWindow.elementExists("performer_image") then
    tWindow.getElement("performer_image").feedImage(tImage)
  end if
end

on eventProcVote me, tEvent, tSprID, tParam
  tConn = getConnection(getVariable("connection.info.id"))
  if not tConn then
    return me.close()
  end if
  case tSprID of
    "vote_button_yes":
      pVote = 1
      me.setState(3)
      tConn.send("VOTE_PERFORMANCE", [#integer: 1])
    "vote_button_no":
      pVote = -1
      me.setState(3)
      tConn.send("VOTE_PERFORMANCE", [#integer: -1])
  end case
end
