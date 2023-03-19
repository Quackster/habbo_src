on showInfo me, tWindowList, tdata, tMode
  return 1
end

on getTitleText me
  return getText("ig_ag_flag_user_left")
end

on getLayout me, tMode
  tLayout = ["ig_ag_tip_title.window"]
  return tLayout
end
