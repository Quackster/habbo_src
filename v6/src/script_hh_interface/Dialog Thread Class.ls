property pReadyFlag, pWindowList, pAlertList, pWriterPlain, pWriterLink, pWriterBold, pDefWndType

on construct me 
  pWindowList = []
  pAlertList = []
  pDefWndType = "habbo_basic.window"
  pReadyFlag = 0
  registerMessage(#openGeneralDialog, me.getID(), #showDialog)
  registerMessage(#alert, me.getID(), #ShowAlert)
  return TRUE
end

on deconstruct me 
  if pReadyFlag then
    repeat while pWindowList <= 1
      tid = getAt(1, count(pWindowList))
      if windowExists(tid) then
        removeWindow(tid)
      end if
    end repeat
    repeat while pAlertList <= 1
      tid = getAt(1, count(pAlertList))
      if windowExists(tid) then
        removeWindow(tid)
      end if
    end repeat
    if writerExists(pWriterPlain) then
      removeWriter(pWriterPlain)
    end if
    if writerExists(pWriterLink) then
      removeWriter(pWriterLink)
    end if
    if writerExists(pWriterBold) then
      removeWriter(pWriterBold)
    end if
  end if
  pWindowList = []
  pAlertList = []
  pReadyFlag = 0
  unregisterMessage(#openGeneralDialog, me.getID())
  unregisterMessage(#alert, me.getID())
  return TRUE
end

on ShowAlert me, tProps 
  if not pReadyFlag then
    me.buildResources()
  end if
  if voidp(tProps) then
    return(error(me, "Properties for window expected!", #showHideWindow))
  end if
  if stringp(tProps) then
    tProps = [#msg:tProps]
  end if
  tText = getText(tProps.getAt(#msg))
  tWndTitle = getText("win_error", "Notice!")
  tTextImg = getWriter(pWriterPlain).render(tText).duplicate()
  if voidp(tProps.getAt(#id)) then
    tActualID = "alert" && the milliSeconds
  else
    tActualID = "alert" && tProps.getAt(#id)
  end if
  if (tProps.getAt(#modal) = 1) then
    tSpecial = #modal
  else
    tSpecial = void()
  end if
  if pAlertList.getOne(tActualID) then
    me.removeDialog(tActualID, pAlertList)
  end if
  if not createWindow(tActualID, void(), void(), void(), tSpecial) then
    return FALSE
  end if
  tWndObj = getWindow(tActualID)
  tWndObj.setProperty(#title, tWndTitle)
  tWndObj.merge(pDefWndType)
  if stringp(tProps.getAt(#title)) then
    tWndObj.merge("habbo_alert_a.window")
    tTitle = getText(tProps.getAt(#title), "...")
    getWriter(pWriterBold).define([#alignment:#center])
    tTitleImg = getWriter(pWriterBold).render(tTitle).duplicate()
    tTitleElem = tWndObj.getElement("alert_title")
    tTitleElem.feedImage(tTitleImg)
    tTitleWidth = tTitleImg.width
    tTitleHeight = tTitleImg.height
  else
    tTitleWidth = 0
    tTitleHeight = 0
    tWndObj.merge("habbo_alert_b.window")
    tTitle = ""
  end if
  tTextElem = tWndObj.getElement("alert_text")
  tWidth = tTextElem.getProperty(#width)
  tHeight = tTextElem.getProperty(#height)
  tTextElem.moveBy(0, tTitleHeight)
  tOffW = 0
  tOffH = 0
  tTextElem.feedImage(tTextImg)
  if tTitleWidth > tTextImg.width then
    if tWidth < tTitleWidth then
      tOffW = (tTitleWidth - tWidth)
    end if
  else
    if tWidth < tTextImg.width then
      tOffW = (tTextImg.width - tWidth)
    end if
  end if
  if tHeight < (tTextImg.height + tTitleHeight) then
    tOffH = ((tTextImg.height + tTitleHeight) - tHeight)
  end if
  tWndObj.resizeBy(tOffW, tOffH)
  if tTitle <> "" then
    tTitleV = tTitleElem.getProperty(#locV)
    tTitleH = tTitleElem.getProperty(#locH)
    tTitleElem.moveTo((((tWndObj.getProperty(#width) / 2) - (tTitleWidth / 2)) - tTitleH), tTitleV)
  end if
  tWndObj.center()
  tLocOff = (pAlertList.count * 10)
  tWndObj.moveBy(tLocOff, tLocOff)
  tWndObj.registerClient(me.getID())
  if symbolp(tProps.getAt(#registerProcedure)) then
    tWndObj.registerProcedure(tProps.getAt(#registerProcedure), me.getID(), #mouseUp)
  else
    tWndObj.registerProcedure(#eventProcAlert, me.getID(), #mouseUp)
  end if
  pAlertList.add(tActualID)
  return TRUE
end

on showDialog me, tWndID, tProps 
  if not pReadyFlag then
    me.buildResources()
  end if
  if tWndID <> #alert then
    if tWndID <> "alert" then
      if tWndID <> #modal_alert then
        if (tWndID = "modal_alert") then
          return(me.ShowAlert(tProps))
        else
          if tWndID <> #purse then
            if (tWndID = "purse") then
              return(executeMessage(#show_hide_purse))
            else
              if tWndID <> #help then
                if (tWndID = "help") then
                  tWndTitle = getText("win_help", "Help")
                  if windowExists(tWndTitle) then
                    return(me.removeDialog(tWndTitle, pWindowList))
                  end if
                  me.createDialog(tWndTitle, pDefWndType, "habbo_help.window", #eventProcHelp)
                  tWndObj = getWindow(tWndTitle)
                  tStr = ""
                  i = 0
                  repeat while 1
                    i = (i + 1)
                    if textExists("help_txt_" & i) then
                      tStr = tStr & getText("help_txt_" & i) & "\r"
                      next repeat
                    end if
                  end repeat
                  tStr = tStr.getProp(#line, 1, (tStr.count(#line) - 1))
                  tLinkImg = getWriter(pWriterLink).render(tStr).duplicate()
                  tWndObj.getElement("link_list").feedImage(tLinkImg)
                  if threadExists(#room) then
                    if (getThread(#room).getComponent().getRoomID() = "") then
                      tWndObj.getElement("help_callforhelp_textlink").hide()
                    end if
                  end if
                else
                  if tWndID <> #call_for_help then
                    if (tWndID = "call_for_help") then
                      tWndTitle = getText("win_callforhelp", "Alert a Hobba")
                      if windowExists(tWndTitle) then
                        return(me.removeDialog(tWndTitle, pWindowList))
                      end if
                      me.createDialog(tWndTitle, pDefWndType, "habbo_hobba_compose.window", #eventProcCallHelp)
                    else
                      if tWndID <> #ban then
                        if (tWndID = "ban") then
                          tProps.setAt(#registerProcedure, #eventProcBan)
                          return(me.ShowAlert(tProps))
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
end

on buildResources me 
  pWriterPlain = "dialog_writer_plain"
  pWriterLink = "dialog_writer_link"
  pWriterBold = "dialog_writer_bold"
  tFontPlain = getStructVariable("struct.font.plain")
  tFontLink = getStructVariable("struct.font.link")
  tFontBold = getStructVariable("struct.font.bold")
  tFontPlain.setaProp(#lineHeight, 14)
  tFontLink.setaProp(#lineHeight, 14)
  tFontBold.setaProp(#lineHeight, 14)
  createWriter(pWriterPlain, tFontPlain)
  createWriter(pWriterLink, tFontLink)
  createWriter(pWriterBold, tFontBold)
  pReadyFlag = 1
  return TRUE
end

on createDialog me, tWndTitle, tWndType, tContentType, tEventProc 
  if not createWindow(tWndTitle, tWndType) then
    return FALSE
  end if
  tWndObj = getWindow(tWndTitle)
  tWndObj.merge(tContentType)
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(tEventProc, me.getID(), #mouseUp)
  pWindowList.add(tWndTitle)
  return TRUE
end

on removeDialog me, tWndTitle, tWndList 
  if tWndList.getOne(tWndTitle) then
    tWndList.deleteOne(tWndTitle)
    return(removeWindow(tWndTitle))
  else
    return(error(me, "Attempted to remove unknown dialog:" && tWndTitle, #removeDialog))
  end if
end

on eventProcAlert me, tEvent, tElemID, tParam, tWndID 
  if (tEvent = #mouseUp) then
    if tElemID <> "alert_ok" then
      if (tElemID = "close") then
        return(me.removeDialog(tWndID, pAlertList))
      end if
    end if
  end if
end

on eventProcPurse me, tEvent, tElemID, tParam, tWndID 
  if (tEvent = #mouseUp) then
    if tElemID <> "close" then
      if (tElemID = "purse_close") then
        return(executeMessage(#hide_purse))
      else
        if (tElemID = "purse_link_text") then
          tSession = getObject(#session)
          if tSession.get("user_rights").getOne("can_buy_credits") then
            tURL = getText("url_purselink")
          else
            tURL = getText("url_purse_subscribe")
          end if
          tURL = tURL & urlEncode(tSession.get("user_name"))
          if tSession.exists("user_checksum") then
            tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
          end if
          openNetPage(tURL, "_new")
        end if
      end if
    end if
  end if
end

on eventProcHelp me, tEvent, tElemID, tParam, tWndID 
  if (tEvent = #mouseUp) then
    if (tElemID = "link_list") then
      tLineNum = ((tParam.getAt(2) / 14) + 1)
      if textExists("url_help_" & tLineNum) then
        tSession = getObject(#session)
        tURL = getText("url_help_" & tLineNum)
        tName = urlEncode(tSession.get("user_name"))
        if (tURL = "") then
          return TRUE
        end if
        if tURL contains "\\user_name" then
          tURL = replaceChunks(tURL, "\\user_name", tName)
          if tSession.exists("user_checksum") then
            tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
          end if
        end if
        openNetPage(tURL, "_new")
      end if
      return TRUE
    else
      if tElemID <> "close" then
        if (tElemID = "help_ok") then
          return(me.removeDialog(tWndID, pWindowList))
        else
          if (tElemID = "help_callforhelp_textlink") then
            me.removeDialog(tWndID, pWindowList)
            me.showDialog(#call_for_help)
            return TRUE
          end if
        end if
      end if
    end if
  end if
end

on eventProcCallHelp me, tEvent, tElemID, tParam, tWndID 
  if (tEvent = #mouseUp) then
    if tElemID <> "close" then
      if tElemID <> "callhelp_cancel" then
        if (tElemID = "alertsent_ok") then
          return(me.removeDialog(tWndID, pWindowList))
        else
          if (tElemID = "callhelp_send") then
            tWndObj = getWindow(tWndID)
            executeMessage(#sendCallForHelp, tWndObj.getElement("callhelp_text").getText())
            tWndObj.unmerge()
            tWndObj.merge("habbo_hobba_alertsent.window")
            return TRUE
          end if
        end if
      end if
    end if
  end if
end

on eventProcBan me, tEvent, tElemID, tParam, tWndID 
  if (tEvent = #mouseUp) then
    if tElemID <> "alert_ok" then
      if (tElemID = "close") then
        me.removeDialog(tWndID, pAlertList)
        resetClient()
      end if
    end if
  end if
end
