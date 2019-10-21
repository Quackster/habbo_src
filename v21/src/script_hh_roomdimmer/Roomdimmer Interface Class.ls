property pSliderEventAgentID, pWindowID, pPaletteColorsRGB, pPaletteColorsHSL, pSelectedEffectID, pMinLightnesses, pUIShown, pSelectedPresetID, pSelectedColor, pSelectedLightness

on construct me 
  pWindowID = "RoomdimmerWindow"
  pSliderEventAgentID = getUniqueID()
  pMinLightnesses = [1:0.6, 2:0.3]
  pUIShown = 0
  pSelectedEffectID = 1
  pPaletteColorsRGB = []
  pPaletteColorsHSL = []
  createObject(pSliderEventAgentID, getClassVariable("event.agent.class"))
  return TRUE
end

on deconstruct me 
  return TRUE
end

on showControlPanel me 
  if not windowExists(pWindowID) then
    createWindow(pWindowID, "roomdimmer_control_panel.window")
  end if
  pUIShown = 1
  me.preparePaletteSlots()
  tPresetID = me.getComponent().getPresetID()
  me.selectPreset(tPresetID)
  receiveUpdate(me.getID())
  tWnd = getWindow(pWindowID)
  tWnd.registerClient(me.getID())
  tWnd.registerProcedure(#eventProc, me.getID(), #mouseUp)
  tWnd.registerProcedure(#eventProc, me.getID(), #mouseDown)
end

on update me 
  me.updateInterface()
  removeUpdate(me.getID())
end

on hide me 
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  pUIShown = 0
  return TRUE
end

on preparePaletteSlots me 
  tWnd = getWindow(pWindowID)
  tColorCount = getVariable("dimmer.color.count")
  tSlotNum = 1
  repeat while tSlotNum <= tColorCount
    tSlot = tWnd.getElement("dimmer.paletteslot." & tSlotNum)
    tWidth = tSlot.getProperty(#width)
    tHeight = tSlot.getProperty(#height)
    tImage = image(tWidth, tHeight, 8)
    tColor = rgb(string(getVariable("dimmer.color." & tSlotNum)))
    pPaletteColorsRGB.setAt(tSlotNum, tColor)
    pPaletteColorsHSL.setAt(tSlotNum, RGBtoHSL(tColor))
    tImage.fill(tImage.rect, tColor)
    tSlot.feedImage(tImage)
    tSlotNum = (1 + tSlotNum)
  end repeat
end

on selectPaletteSlot me, tSlotNum 
  tSlotColor = rgb(string(getVariable("dimmer.color." & tSlotNum)))
  pSelectedColor = tSlotColor
  me.highlightPaletteSlot(tSlotNum)
  me.updatePreview()
end

on selectPreset me, tPresetNum 
  tPreset = me.getComponent().getPreset(tPresetNum)
  pSelectedPresetID = tPresetNum
  pSelectedEffectID = tPreset.getaProp(#effectID)
  pSelectedColor = tPreset.getaProp(#color)
  pSelectedLightness = tPreset.getaProp(#lightness)
  me.updateInterface()
end

on highlightPaletteSlot me, tSlotNum 
  tWnd = getWindow(pWindowID)
  tSlot = tWnd.getElement("dimmer.paletteslot." & tSlotNum)
  tHighlighter = tWnd.getElement("dimmer.color.highlighter")
  tLocH = (tSlot.getProperty(#locH) - 2)
  tLocV = (tSlot.getProperty(#locV) - 2)
  tHighlighter.moveTo(tLocH, tLocV)
end

on toggleEffect me 
  pSelectedEffectID = (3 - pSelectedEffectID)
  me.updateInterface()
end

on initSliderAgent me, tBoolean 
  tAgent = getObject(pSliderEventAgentID)
  if tBoolean then
    tAgent.registerEvent(me, #mouseUp, #sliderMouseUp)
    tAgent.registerEvent(me, #mouseWithin, #sliderMouseWithin)
  else
    tAgent.unregisterEvent(#mouseUp)
    tAgent.unregisterEvent(#mouseWithin)
  end if
  pDrag = tBoolean
end

on sliderMouseUp me 
  me.initSliderAgent(0)
end

on sliderMouseWithin me 
  tWndObj = getWindow(pWindowID)
  tScaleElem = tWndObj.getElement("dimmer.slider.scale")
  tRect = tScaleElem.getProperty(#rect)
  tValue = (float((the mouseH - tRect.getAt(1))) / tRect.width)
  if tValue < 0 then
    tValue = 0
  else
    if tValue > 1 then
      tValue = 1
    end if
  end if
  tMinLightness = pMinLightnesses.getaProp(pSelectedEffectID)
  tMappedLightness = (tMinLightness + ((1 - tMinLightness) * tValue))
  pSelectedLightness = integer((tMappedLightness * 255))
  me.updateSlider()
  me.updatePreview()
end

on updateInterface me 
  if not pUIShown then
    return TRUE
  end if
  me.updateOnOff()
  me.updatePresetSelection()
  me.updateColorSelection()
  me.updateSlider()
  me.updateCheckbox()
  me.updatePreview()
end

on updateOnOff me 
  tIsOn = me.getComponent().isOn()
  tWnd = getWindow(pWindowID)
  tButton = tWnd.getElement("dimmer.button.onoff.text")
  if tIsOn then
    tButton.setText(getText("dimmer_turn_off"))
  else
    tButton.setText(getText("dimmer_turn_on"))
  end if
  tElem = tWnd.getElement("dimmer.disable.layer")
  if me.getComponent().isOn() then
    tElem.hide()
  else
    tElem.show()
  end if
end

on updatePresetSelection me 
  tPresetID = pSelectedPresetID
  tWnd = getWindow(pWindowID)
  tNum = 1
  repeat while tNum <= 3
    tElem = tWnd.getElement("dimmer.button.preset." & tNum)
    if (tNum = tPresetID) then
      tmember = member(getmemnum("dimmer.button.radio.on"))
    else
      tmember = member(getmemnum("dimmer.button.radio.off"))
    end if
    tElem.setProperty(#member, tmember)
    tNum = (1 + tNum)
  end repeat
end

on updateColorSelection me 
  tColor = pSelectedColor
  if voidp(pSelectedColor) then
    return FALSE
  end if
  tPos = pPaletteColorsRGB.findPos(tColor)
  if (tPos = 0) then
    tHSL = RGBtoHSL(tColor)
    tHueDiff = []
    repeat while pPaletteColorsHSL <= undefined
      tPaletteColor = getAt(undefined, undefined)
      tHueDiff.add(abs((tPaletteColor.getAt(1) - tHSL.getAt(1))))
    end repeat
    tPos = tHueDiff.findPos(tHueDiff.min())
    pSelectedColor = pPaletteColorsRGB.getAt(tPos)
  end if
  me.highlightPaletteSlot(tPos)
end

on updateSlider me 
  tLightness = pSelectedLightness
  tLightness = (tLightness / 255)
  tMinLightness = pMinLightnesses.getaProp(pSelectedEffectID)
  tMappedValue = ((tLightness - tMinLightness) / (1 - tMinLightness))
  if tMappedValue < 0 then
    tMappedValue = 0
  end if
  tWndObj = getWindow(pWindowID)
  tScale = tWndObj.getElement("dimmer.slider.scale")
  tHandle = tWndObj.getElement("dimmer.slider.handle")
  tRect = tScale.getProperty(#rect)
  tLocV = tHandle.getProperty(#locV)
  tLocH = ((tScale.getProperty(#locH) + (tRect.width * tMappedValue)) - (tHandle.getProperty(#width) / 2))
  tHandle.moveTo(tLocH, tLocV)
end

on updateCheckbox me 
  tEffectId = pSelectedEffectID
  tWndObj = getWindow(pWindowID)
  tElem = tWndObj.getElement("dimmer.bgonly.checkbox")
  if (tEffectId = 1) then
    tElem.setProperty(#member, member("dimmer.checkbox.unchecked"))
  else
    tElem.setProperty(#member, member("dimmer.checkbox.checked"))
  end if
  pCheckboxValue = tEffectId
end

on updatePreview me 
  tColor = pSelectedColor
  tLightness = pSelectedLightness
  tEffectId = pSelectedEffectID
  if voidp(tColor) or voidp(tLightness) or voidp(tEffectId) then
    return FALSE
  end if
  tHSL = RGBtoHSL(tColor)
  tHSL.setAt(3, tLightness)
  tColor = HSLtoRGB(tHSL)
  tImage = member("dimmer.preview.all").image.duplicate()
  tNewImage = image(tImage.width, tImage.height, 32)
  tNewImage.copyPixels(tImage, tNewImage.rect, tImage.rect, [#ink:41, #bgColor:tColor])
  tWnd = getWindow(pWindowID)
  tElem = tWnd.getElement("dimmer.preview.bg")
  tElem.feedImage(tNewImage)
  tForeground = tWnd.getElement("dimmer.preview.foreground")
  if (tEffectId = 1) then
    tForeground.hide()
  else
    tForeground.show()
  end if
end

on applyEffect me 
  tPreset = [:]
  tPreset.setaProp(#presetID, pSelectedPresetID)
  tPreset.setaProp(#effectID, pSelectedEffectID)
  tPreset.setaProp(#color, pSelectedColor)
  tPreset.setaProp(#lightness, pSelectedLightness)
  tPreset.setaProp(#apply, 1)
  me.getComponent().savePreset(tPreset)
end

on eventProc me, tEvent, tElemID, tParam 
  if (tEvent = #mouseUp) then
    if tElemID <> "dimmer.bgonly.text" then
      if (tElemID = "dimmer.bgonly.checkbox") then
        me.toggleEffect()
      else
        if (tElemID = "close") then
          me.hide()
        else
          if tElemID <> "dimmer.button.onoff" then
            if (tElemID = "dimmer.button.onoff.text") then
              me.getComponent().toggleOnoff()
            else
              if tElemID <> "dimmer.button.apply" then
                if (tElemID = "dimmer.button.apply.text") then
                  me.applyEffect()
                else
                  if tElemID contains "dimmer.paletteslot" then
                    tSlotNum = tElemID.getProp(#char, tElemID.length)
                    me.selectPaletteSlot(tSlotNum)
                  end if
                  if tElemID contains "dimmer.button.preset" then
                    tItems = explode(tElemID, ".")
                    tPresetNum = value(tItems.getAt(4))
                    me.selectPreset(tPresetNum)
                  end if
                end if
                if (tEvent = #mouseDown) and tElemID contains "dimmer.slider" then
                  me.initSliderAgent(1)
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end
