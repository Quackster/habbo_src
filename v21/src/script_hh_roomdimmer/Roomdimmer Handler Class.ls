on construct(me)
  return(me.regMsgList(1))
  exit
end

on deconstruct(me)
  return(me.regMsgList(0))
  exit
end

on handleDimmerPresets(me, tMsg)
  tConn = tMsg.getaProp(#connection)
  tNumOfPresets = tConn.GetIntFrom()
  tSelectedPresetID = tConn.GetIntFrom()
  tPresets = []
  tPresetNum = 1
  repeat while tPresetNum <= tNumOfPresets
    tPresetData = []
    tPresetID = tConn.GetIntFrom()
    tEffectId = tConn.GetIntFrom()
    tColor = tConn.GetStrFrom()
    tLightness = tConn.GetIntFrom()
    tPresetData.setaProp(#effectID, tEffectId)
    tPresetData.setaProp(#color, rgb(tColor))
    tPresetData.setaProp(#lightness, tLightness)
    tPresets.setaProp(tPresetID, tPresetData)
    tPresetNum = 1 + tPresetNum
  end repeat
  me.getComponent().setPresets(tPresets)
  return(tPresets)
  exit
end

on regMsgList(me, tBool)
  tMsgs = []
  tMsgs.setaProp(365, #handleDimmerPresets)
  tCmds = []
  tCmds.setaProp("MSG_ROOMDIMMER_GET_PRESETS", 341)
  tCmds.setaProp("MSG_ROOMDIMMER_SET_PRESET", 342)
  tCmds.setaProp("MSG_ROOMDIMMER_CHANGE_STATE", 343)
  if tBool then
    registerListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    registerCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  else
    unregisterListener(getVariable("connection.info.id"), me.getID(), tMsgs)
    unregisterCommands(getVariable("connection.info.id"), me.getID(), tCmds)
  end if
  return(1)
  exit
end