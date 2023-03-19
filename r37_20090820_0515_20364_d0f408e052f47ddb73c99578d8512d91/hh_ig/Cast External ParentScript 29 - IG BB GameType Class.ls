on getAction me, tKey, tParam1, tParam2
  case tKey of
    #get_room_class:
      return "BB Arena Class"
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
    #set_create_property:
      return me.setCreateProperty(tParam1, tParam2)
    #get_bottombar_layout:
      return "bb_ui.window"
  end case
  return error(me, "Undefined action for this type:" && tKey, #getAction)
end

on setCreateProperty me, tKey, tValue
  put "* setCreateProperty" && tKey && tValue
  case tKey of
    #ig_checkbox_powerup:
  end case
  return 1
end

on getCreateDefaults me
  tParams = [:]
  tParams.addProp(#private, [#ilk: #integer, #default: 0])
  tParams.addProp(#number_of_teams, [#ilk: #integer, #min: 2, #max: 4, #default: 2])
  tParams.addProp(#bb_pups, [#ilk: #list, #default: [1, 2, 3, 4, 5, 6, 7, 8]])
  return tParams
end

on getIconImage me
  tName = "ig_icon_gamemode_1"
  tMemNum = getmemnum(tName)
  if tMemNum = 0 then
    return 0
  end if
  tmember = member(tMemNum)
  return tmember.image
end

on getCastList me
  tCastList = ["hh_ig_gamesys", "hh_ig_game_bb", "hh_ig_game_bb_ui", "hh_ig_game_bb_room"]
  return tCastList
end

on parseCreateGameInfo me, tdata, tConn
  tdata.setaProp(#use_1_team, 0)
  tdata.setaProp(#game_type_icon, me.getIconImage())
  tdata.setaProp(#allow_powerups, tConn.GetIntFrom())
  tParams = me.getCreateDefaults()
  if tParams = 0 then
    return 0
  end if
  if not tdata.getaProp(#allow_powerups) then
    tdata.setaProp(#bb_pups, [])
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
  tdata.setaProp(#level_name, getText("bb_fieldname_" & tdata.getaProp(#field_type)))
  return tdata
end

on parseLongData me, tdata, tConn
  tdata.setaProp(#level_name, getText("bb_fieldname_" & tdata.getaProp(#field_type)))
  tList = []
  tCount = tConn.GetIntFrom()
  repeat with i = 1 to tCount
    tList.append(tConn.GetIntFrom())
  end repeat
  tdata.setaProp(#bb_pups, tList)
  return tdata
end

on parseShortData me, tdata, tConn
  tdata.setaProp(#level_name, getText("bb_fieldname_" & tdata.getaProp(#field_type)))
  return tdata
end
