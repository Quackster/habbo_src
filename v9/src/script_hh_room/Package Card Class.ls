on construct(me)
  pMessage = ""
  pPackageID = ""
  pCardWndID = "Card" && getUniqueID()
  registerMessage(#leaveRoom, me.getID(), #hideCard)
  registerMessage(#changeRoom, me.getID(), #hideCard)
  return(1)
  exit
end

on deconstruct(me)
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  return(1)
  exit
end

on define(me, tProps)
  pPackageID = tProps.getAt(#id)
  pMessage = tProps.getAt(#Msg)
  me.showCard(tProps.getAt(#loc) + [0, -220])
  return(1)
  exit
end

on showCard(me, tloc)
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  if voidp(tloc) then
    tloc = [100, 100]
  end if
  if the stage > rect.width - 260 then
    1.setAt(the stage, rect.width - 260)
  end if
  if tloc.getAt(2) < 2 then
    tloc.setAt(2, 2)
  end if
  if not createWindow(pCardWndID, "package_card.window", tloc.getAt(1), tloc.getAt(2)) then
    return(0)
  end if
  tWndObj = getWindow(pCardWndID)
  tUserRights = getObject(#session).get("user_rights")
  tUserCanOpen = getObject(#session).get("room_owner") or tUserRights.findPos("fuse_pick_up_any_furni")
  if not tUserCanOpen and tWndObj.getElement("open_package") <> 0 then
    tWndObj.getElement("open_package").hide()
  end if
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcCard, me.getID(), #mouseUp)
  tWndObj.getElement("package_msg").setText(pMessage)
  return(1)
  exit
end

on hideCard(me)
  unregisterMessage(#leaveRoom, me.getID())
  unregisterMessage(#changeRoom, me.getID())
  if windowExists(pCardWndID) then
    removeWindow(pCardWndID)
  end if
  return(1)
  exit
end

on openPresent(me)
  return(getThread(#room).getComponent().getRoomConnection().send("PRESENTOPEN", pPackageID))
  exit
end

on showContent(me, tdata)
  if not windowExists(pCardWndID) then
    return(0)
  end if
  ttype = tdata.getAt(#type)
  tCode = tdata.getAt(#code)
  tMemNum = void()
  if ttype contains "*" then
    tDelim = the itemDelimiter
    the itemDelimiter = "*"
    ttype = ttype.getProp(#item, 1)
    the itemDelimiter = tDelim
  end if
  if memberExists(tCode & "_small") then
    tMemNum = getmemnum(tCode & "_small")
  else
    if memberExists("ctlg_pic_small_" & tCode) then
      tMemNum = getmemnum("ctlg_pic_small_" & tCode)
    end if
  end if
  if tMemNum = 0 then
    tImg = getObject("Preview_renderer").renderPreviewImage(void(), void(), void(), tdata.getAt(#type))
  else
    tImg = undefined.duplicate()
  end if
  tWndObj = getWindow(pCardWndID)
  tWndObj.getElement("card_icon").hide()
  tWndObj.getElement("small_img").feedImage(tImg)
  tWndObj.getElement("small_img").setProperty(#blend, 100)
  tWndObj.getElement("open_package").hide()
  exit
end

on eventProcCard(me, tEvent, tElemID, tParam)
  if tEvent <> #mouseUp then
    return(0)
  end if
  if me = "close" then
    return(me.hideCard())
  else
    if me = "open_package" then
      return(me.openPresent())
    end if
  end if
  exit
end