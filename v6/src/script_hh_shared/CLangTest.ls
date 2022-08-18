property m_cWindowID

on deconstruct me 
  if windowExists(m_cWindowID) then
    return(removeWindow(m_cWindowID))
  else
    return TRUE
  end if
end

on setWord me, tWord 
  if tWord.ilk <> #string then
    return(error(me, "String expected!", #setWord))
  end if
  m_cWindowID = "lang_test_wnd"
  if not windowExists(m_cWindowID) then
    if not createWindow(m_cWindowID) then
      return(error(me, "Failed to create window!", #construct))
    end if
  end if
  tWndObj = getWindow(m_cWindowID)
  tWndObj.merge("habbo_simple.window")
  tWndObj.merge("habbo_lang_test.window")
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
  tWndObj.registerProcedure(#eventProc, me.getID(), #keyDown)
  tWndObj.getElement("lang_test_example").setText(tWord)
  tWndObj.center()
  setText("lang_test_text", getText("lang_test_text_2"))
end

on testWord me 
  tWord = getWindow(m_cWindowID).getElement("lang_test_field").getText()
  if (tWord = "") then
    return FALSE
  end if
  if connectionExists(getVariable("connection.info.id")) then
    getConnection(getVariable("connection.info.id")).send("LANGCHECK", [#string:tWord])
  end if
  removeObject(me.getID())
end

on eventProc me, tEvent, tElemID 
  if (tEvent = #mouseUp) then
    if (tElemID = "ok") then
      me.testWord()
      return TRUE
    end if
  else
    if (tEvent = #keyDown) then
      if (the key = "\r") then
        me.testWord()
        return TRUE
      else
        return FALSE
      end if
    end if
  end if
end
