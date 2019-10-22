on getAction me, tKey, tParam1, tParam2 
  if (tKey = #get_room_class) then
    return("BB Arena Class")
  else
    if (tKey = #get_create_defaults) then
      return(me.getCreateDefaults())
    else
      if (tKey = #get_icon_image) then
        return(me.getIconImage())
      else
        if (tKey = #get_casts) then
          return(me.getCastList())
        else
          if (tKey = #parse_create_game_info) then
            return(me.parseCreateGameInfo(tParam1, tParam2))
          else
            if (tKey = #parse_short_data) then
              return(me.parseShortData(tParam1, tParam2))
            else
              if (tKey = #parse_long_data) then
                return(me.parseLongData(tParam1, tParam2))
              else
                if (tKey = #set_create_property) then
                  return(me.setCreateProperty(tParam1, tParam2))
                else
                  if (tKey = #get_bottombar_layout) then
                    return("bb_ui.window")
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(error(me, "Undefined action for this type:" && tKey, #getAction))
end

on setCreateProperty me, tKey, tValue 
  put("* setCreateProperty" && tKey && tValue)
  if (tKey = #ig_checkbox_powerup) then
  end if
  return TRUE
end

on getCreateDefaults me 
  tParams = [:]
  tParams.addProp(#private, [#ilk:#integer, #default:0])
  tParams.addProp(#number_of_teams, [#ilk:#integer, #min:2, #max:4, #default:2])
  tParams.addProp(#bb_pups, [#ilk:#list, #default:[1, 2, 3, 4, 5, 6, 7, 8]])
  return(tParams)
end

on getIconImage me 
  tName = "ig_icon_gamemode_1"
  tMemNum = getmemnum(tName)
  if (tMemNum = 0) then
    return FALSE
  end if
  tmember = member(tMemNum)
  return(tmember.image)
end

on getCastList me 
  tCastList = ["hh_ig_gamesys", "hh_ig_game_bb", "hh_ig_game_bb_ui", "hh_ig_game_bb_room"]
  return(tCastList)
end

on parseCreateGameInfo me, tdata, tConn 
  tdata.setaProp(#use_1_team, 0)
  tdata.setaProp(#game_type_icon, me.getIconImage())
  tdata.setaProp(#allow_powerups, tConn.GetIntFrom())
  tParams = me.getCreateDefaults()
  if (tParams = 0) then
    return FALSE
  end if
  if not tdata.getaProp(#allow_powerups) then
    tdata.setaProp(#bb_pups, [])
  end if
  i = 1
  repeat while i <= tParams.count
    tKey = tParams.getPropAt(i)
    if (tdata.findPos(tKey) = 0) then
      tItem = tParams.getAt(i)
      if tItem <> 0 then
        tdata.setaProp(tKey, tItem.getaProp(#default))
      end if
    end if
    i = (1 + i)
  end repeat
  tdata.setaProp(#level_name, getText("bb_fieldname_" & tdata.getaProp(#field_type)))
  return(tdata)
end

on parseLongData me, tdata, tConn 
  tdata.setaProp(#level_name, getText("bb_fieldname_" & tdata.getaProp(#field_type)))
  tList = []
  tCount = tConn.GetIntFrom()
  i = 1
  repeat while i <= tCount
    tList.append(tConn.GetIntFrom())
    i = (1 + i)
  end repeat
  tdata.setaProp(#bb_pups, tList)
  return(tdata)
end

on parseShortData me, tdata, tConn 
  tdata.setaProp(#level_name, getText("bb_fieldname_" & tdata.getaProp(#field_type)))
  return(tdata)
end
