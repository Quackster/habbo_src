on getAction(me, tKey, tParam1, tParam2)
  if me = #get_room_class then
    return("Snowwar Arena Class")
  else
    if me = #get_create_defaults then
      return(me.getCreateDefaults())
    else
      if me = #get_icon_image then
        return(me.getIconImage())
      else
        if me = #get_casts then
          return(me.getCastList())
        else
          if me = #parse_create_game_info then
            return(me.parseCreateGameInfo(tParam1, tParam2))
          else
            if me = #parse_short_data then
              return(me.parseShortData(tParam1, tParam2))
            else
              if me = #parse_long_data then
                return(me.parseLongData(tParam1, tParam2))
              else
                if me = #get_bottombar_layout then
                  return(0)
                  return("sw_ui.window")
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return(error(me, "Undefined action for this type:" && tKey, #getAction))
  exit
end

on getCreateDefaults(me)
  tParams = []
  tParams.addProp(#private, [#ilk:#integer, #default:0])
  tParams.addProp(#number_of_teams, [#ilk:#integer, #min:1, #max:4, #default:2])
  tParams.addProp(#duration, [#ilk:#integer, #default:120])
  return(tParams)
  exit
end

on getIconImage(me)
  tName = "ig_icon_gamemode_0"
  tMemNum = getmemnum(tName)
  if tMemNum = 0 then
    return(0)
  end if
  tmember = member(tMemNum)
  return(tmember.image)
  exit
end

on getCastList(me)
  tCastList = ["hh_ig_gamesys", "hh_ig_game_snowwar", "hh_ig_game_snowwar_ui", "hh_ig_game_snowwar_room"]
  return(tCastList)
  exit
end

on parseCreateGameInfo(me, tdata, tConn)
  tdata.setaProp(#use_1_team, 1)
  tdata.setaProp(#game_type_icon, me.getIconImage())
  tParams = me.getCreateDefaults()
  if tParams = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= tParams.count
    tKey = tParams.getPropAt(i)
    if tdata.findPos(tKey) = 0 then
      tItem = tParams.getAt(i)
      if tItem <> 0 then
        tdata.setaProp(tKey, tItem.getaProp(#default))
      end if
    end if
    i = 1 + i
  end repeat
  tdata.setaProp(#level_name, getText("sw_fieldname_" & tdata.getaProp(#field_type)))
  return(tdata)
  exit
end

on parseLongData(me, tdata, tConn)
  tdata.setaProp(#level_name, getText("sw_fieldname_" & tdata.getaProp(#field_type)))
  tdata.setaProp(#duration, tConn.GetIntFrom())
  return(tdata)
  exit
end

on parseShortData(me, tdata, tConn)
  tdata.setaProp(#level_name, getText("sw_fieldname_" & tdata.getaProp(#field_type)))
  return(tdata)
  exit
end