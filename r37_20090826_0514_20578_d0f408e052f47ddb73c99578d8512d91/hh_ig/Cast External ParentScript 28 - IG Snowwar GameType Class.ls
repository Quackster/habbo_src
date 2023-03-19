on getAction me, tKey, tParam1, tParam2
  case tKey of
    #get_room_class:
      return "Snowwar Arena Class"
    #get_create_defaults:
      return me.getCreateDefaults()
    #get_icon_image:
      return me.getIconImage()
    #get_casts:
      return me.getCastList()
    #parse_create_game_info:
      return me.parseCreateGameInfo(tParam1, tParam2)
    #parse_short_data:
      return me.parseShortData(tParam1, tParam2)
    #parse_long_data:
      return me.parseLongData(tParam1, tParam2)
    #get_bottombar_layout:
      return 0
      return "sw_ui.window"
  end case
  return error(me, "Undefined action for this type:" && tKey, #getAction)
end

on getCreateDefaults me
  tParams = [:]
  tParams.addProp(#private, [#ilk: #integer, #default: 0])
  tParams.addProp(#number_of_teams, [#ilk: #integer, #min: 1, #max: 4, #default: 2])
  tParams.addProp(#duration, [#ilk: #integer, #default: 120])
  return tParams
end

on getIconImage me
  tName = "ig_icon_gamemode_0"
  tMemNum = getmemnum(tName)
  if tMemNum = 0 then
    return 0
  end if
  tmember = member(tMemNum)
  return tmember.image
end

on getCastList me
  tCastList = ["hh_ig_gamesys", "hh_ig_game_snowwar", "hh_ig_game_snowwar_ui", "hh_ig_game_snowwar_room"]
  return tCastList
end

on parseCreateGameInfo me, tdata, tConn
  tdata.setaProp(#use_1_team, 1)
  tdata.setaProp(#game_type_icon, me.getIconImage())
  tParams = me.getCreateDefaults()
  if tParams = 0 then
    return 0
  end if
  repeat with i = 1 to tParams.count
    tKey = tParams.getPropAt(i)
    if tdata.findPos(tKey) = 0 then
      tItem = tParams[i]
      if tItem <> 0 then
        tdata.setaProp(tKey, tItem.getaProp(#default))
      end if
    end if
  end repeat
  tdata.setaProp(#level_name, getText("sw_fieldname_" & tdata.getaProp(#field_type)))
  return tdata
end

on parseLongData me, tdata, tConn
  tdata.setaProp(#level_name, getText("sw_fieldname_" & tdata.getaProp(#field_type)))
  tdata.setaProp(#duration, tConn.GetIntFrom())
  return tdata
end

on parseShortData me, tdata, tConn
  tdata.setaProp(#level_name, getText("sw_fieldname_" & tdata.getaProp(#field_type)))
  return tdata
end
