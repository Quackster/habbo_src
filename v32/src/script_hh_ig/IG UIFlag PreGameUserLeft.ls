on showInfo(me, tWindowList, tdata, tMode)
  return(1)
  exit
end

on getTitleText(me)
  return(getText("ig_ag_flag_user_left"))
  exit
end

on getLayout(me, tMode)
  tLayout = ["ig_ag_tip_title.window"]
  return(tLayout)
  exit
end