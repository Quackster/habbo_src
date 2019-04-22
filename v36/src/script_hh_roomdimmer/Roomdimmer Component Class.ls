property pEffects, pAppliedEffectID, pPresets, pFurniID, pPresetID, pTransitionTime, pIsOn, pTargetColor, pAppliedColor, pTargetLightness, pAppliedLightness, pTargetTime, pApplyTime, pEffectID

on construct me 
  pcolor = rgb(255, 255, 255)
  pLightness = 1
  pEffectID = 1
  pAppliedEffectID = 0
  pAppliedColor = rgb(255, 255, 255)
  pAppliedLightness = 255
  pTransitionTime = 1500
  pEffects = [:]
  pEffects.setaProp(1, #setDimmerColor)
  pEffects.setaProp(2, #colorizeRoom)
  registerMessage(#roomdimmer_defined, me.getID(), #roomdimmerDefined)
  registerMessage(#roomdimmer_selected, me.getID(), #select)
  registerMessage(#roomdimmer_removed, me.getID(), #Remove)
  registerMessage(#roomdimmer_set_state, me.getID(), #setState)
  return(1)
end

on deconstruct me 
  unregisterMessage(#roomdimmer_selected, me.getID())
  unregisterMessage(#roomdimmer_removed, me.getID())
  return(1)
end

on turnOff me 
  if pAppliedEffectID > 0 then
    me.removeEffect(pAppliedEffectID)
  end if
  pAppliedColor = rgb(255, 255, 255)
  pAppliedLightness = 255
end

on roomdimmerDefined me, tFurniID 
  pFurniID = tFurniID
  if connectionExists(getVariable("connection.info.id", #info)) then
    tConn = getConnection(getVariable("connection.info.id", #info))
    tConn.send("MSG_ROOMDIMMER_GET_PRESETS")
  end if
end

on select me 
  if voidp(pPresets) then
    return(0)
  end if
  me.getInterface().showControlPanel()
end

on Remove me, tID 
  if tID <> pFurniID then
    return(0)
  end if
  me.getInterface().hide()
  if pAppliedEffectID <> 0 then
    me.removeEffect(pAppliedEffectID)
  end if
end

on applyPreset me 
  me.savePreset(1)
end

on savePreset me, tPreset 
  tPresetData = [:]
  tPresetData.addProp(#integer, tPreset.getaProp(#presetID))
  tPresetData.addProp(#integer, tPreset.getaProp(#effectID))
  tColor = tPreset.getaProp(#color)
  if ilk(tColor) = #color then
    tPresetData.setaProp(#string, tColor.hexString())
  else
    tPresetData.setaProp(#string, tColor)
  end if
  tPresetData.addProp(#integer, tPreset.getaProp(#lightness))
  tPresetData.addProp(#boolean, tPreset.getaProp(#apply))
  if connectionExists(getVariable("connection.info.id", #info)) then
    tConn = getConnection(getVariable("connection.info.id", #info))
    tConn.send("MSG_ROOMDIMMER_SET_PRESET", tPresetData)
  end if
  pPresets.setaProp(tPreset.getaProp(#presetID), tPreset)
end

on getCurrentPreset me 
  return(pPresetID)
end

on setState me, tStateData 
  pDimmerID = tStateData.getaProp(#dimmerID)
  pIsOn = tStateData.getaProp(#isOn)
  pPresetID = tStateData.getaProp(#presetID)
  pEffectID = tStateData.getaProp(#effectID)
  tColor = tStateData.getaProp(#color)
  tLightness = tStateData.getaProp(#lightness)
  pTargetColor = tColor
  pTargetLightness = tLightness
  pTargetTime = the milliSeconds + pTransitionTime
  if pIsOn then
    pApplyTime = the milliSeconds
    receiveUpdate(me.getID())
  else
    removeUpdate(me.getID())
    me.turnOff()
  end if
  me.getInterface().updateInterface()
end

on update me 
  tDiffR = pTargetColor.red - pAppliedColor.red
  tDiffG = pTargetColor.green - pAppliedColor.green
  tDiffB = pTargetColor.blue - pAppliedColor.blue
  tDiffL = pTargetLightness - pAppliedLightness
  tCurrentTime = the milliSeconds
  if tCurrentTime >= pTargetTime then
    removeUpdate(me.getID())
    tNewColor = pTargetColor
    tNewLightness = pTargetLightness
  else
    tRatio = tCurrentTime - pApplyTime / float(pTargetTime - pApplyTime)
    tNewR = pAppliedColor.red + tRatio * tDiffR
    tNewG = pAppliedColor.green + tRatio * tDiffG
    tNewB = pAppliedColor.blue + tRatio * tDiffB
    tNewLightness = pAppliedLightness + tRatio * tDiffL
    tNewColor = rgb(tNewR, tNewG, tNewB)
  end if
  me.applyEffect(pEffectID, tNewColor, tNewLightness)
end

on getPreset me, tPresetID 
  return(pPresets.getaProp(tPresetID))
end

on getPresetID me 
  return(pPresetID)
end

on setPresets me, tPresets 
  pPresets = tPresets
end

on removeEffect me, tEffectID 
  tEffect = pEffects.getaProp(pAppliedEffectID)
  if voidp(tEffect) then
    return(0)
  end if
  executeMessage(tEffect, rgb(255, 255, 255))
  pAppliedEffectID = 0
end

on applyEffect me, tEffectID, tColor, tLightness 
  if pAppliedEffectID <> tEffectID and pAppliedEffectID <> 0 then
    me.removeEffect(pAppliedEffectID)
  end if
  tEffect = pEffects.getaProp(tEffectID)
  if voidp(tEffect) then
    return(0)
  end if
  tHSL = RGBtoHSL(tColor)
  tHSL.setAt(3, tLightness)
  executeMessage(tEffect, HSLtoRGB(tHSL))
  pAppliedEffectID = tEffectID
  pAppliedColor = tColor
  pAppliedLightness = tLightness
  pApplyTime = the milliSeconds
end

on toggleOnoff me 
  tConn = getConnection(getVariable("connection.info.id", #info))
  if not tConn then
    return(0)
  end if
  tConn.send("MSG_ROOMDIMMER_CHANGE_STATE")
  return(1)
end

on isOn me 
  return(pIsOn)
end
