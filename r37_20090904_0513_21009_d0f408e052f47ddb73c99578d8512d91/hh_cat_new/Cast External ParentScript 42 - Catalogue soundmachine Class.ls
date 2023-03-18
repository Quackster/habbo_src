property pSoundPackagePreviewPrefix, pPlayTimeoutMillis, pLastPlayTime

on construct me
  pSoundPackagePreviewPrefix = "sound_set_preview_"
  pPlayTimeoutMillis = 1000
  pLastPlayTime = 0
  return 1
end

on deconstruct me
  return 1
end

on define me, tPageProps
  me.setPreviewState(#hidden)
end

on setPreviewState me, tstate
  tWindowObj = getThread(#catalogue).getInterface().getCatalogWindow()
  if not tWindowObj then
    tWindowObj = VOID
    return error(me, "Couldn't access catalogue window!", #setPreviewState, #major)
  end if
  tPreviewTextElem = "play_preview_text"
  tPreviewIconElem = "play_preview_icon"
  if not tWindowObj.elementExists(tPreviewTextElem) then
    return 0
  end if
  if not tWindowObj.elementExists(tPreviewIconElem) then
    return 0
  end if
  if voidp(tstate) then
    then(tstate = #hidden)
  end if
  tTextElem = tWindowObj.getElement(tPreviewTextElem)
  tIconElem = tWindowObj.getElement(tPreviewIconElem)
  case tstate of
    #hidden:
      tTextElem.setProperty(#visible, 0)
      tIconElem.setProperty(#visible, 0)
    #download:
      tTextElem.setProperty(#visible, 1)
      tTextElem.setText(getText("preview_downloading"))
      tIconElem.setProperty(#visible, 1)
      tIconElem.setProperty(#blend, 50)
    #playable:
      tTextElem.setProperty(#visible, 1)
      tTextElem.setText(getText("play_preview"))
      tIconElem.setProperty(#visible, 1)
      tIconElem.setProperty(#blend, 100)
  end case
end

on prepareItemPreview me, tItem
  tSoundSetClass = tItem[#class]
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tSoundSetNo = tSoundSetClass.item[3]
  the itemDelimiter = tDelim
  tPreviewPackage = pSoundPackagePreviewPrefix & tSoundSetNo
  if not memberExists(tPreviewPackage) then
    if threadExists(#dynamicdownloader) then
      tParentId = "sound_set_" & tSoundSetNo
      getThread(#dynamicdownloader).getComponent().downloadCastDynamically(tPreviewPackage, #sound, me.getID(), #soundDownloadCompleted, VOID, VOID, tParentId)
    else
      return error(me, "Dynamic downloader does not exist, cannot download sound.", #startSampleDownload, #major)
    end if
    me.setPreviewState(#download)
  else
    me.setPreviewState(#playable)
  end if
end

on soundDownloadCompleted me, tPreviewPackage
  tThread = getThread(#catalogue)
  tCatInterface = tThread.getInterface()
  tSelectedProduct = tCatInterface.getSelectedProduct()
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tSelectedProductPreviewNo = tSelectedProduct[#class].item[3]
  tPreviewPackageNo = tPreviewPackage.item[4]
  the itemDelimiter = tDelim
  if tSelectedProductPreviewNo = tPreviewPackageNo then
    me.setPreviewState(#playable)
  end if
end

on playPreviewOfSelected me
  if (the milliSeconds - pLastPlayTime) < pPlayTimeoutMillis then
    return 0
  end if
  pLastPlayTime = the milliSeconds
  tThread = getThread(#catalogue)
  tCatInterface = tThread.getInterface()
  tSelectedProduct = tCatInterface.getSelectedProduct()
  tDelim = the itemDelimiter
  the itemDelimiter = "_"
  tSelectedProductPreviewNo = tSelectedProduct[#class].item[3]
  the itemDelimiter = tDelim
  tPreviewPackage = pSoundPackagePreviewPrefix & tSelectedProductPreviewNo
  if memberExists(tPreviewPackage) then
    playSound(tPreviewPackage, #cut, [#loopCount: 1, #infiniteloop: 0, #volume: 255])
  end if
end

on eventProc me, tEvent, tSprID, tProp
  tThread = getThread(#catalogue)
  tCatInterface = tThread.getInterface()
  tSelectedProduct = tCatInterface.getSelectedProduct()
  if tEvent = #mouseUp then
    if tSprID contains "ctlg_small_img" then
      if ilk(tSelectedProduct) = #propList then
        if tSelectedProduct[#class] contains "sound_set" then
          me.prepareItemPreview(tSelectedProduct)
        else
          me.setPreviewState(#hidden)
        end if
      else
        me.setPreviewState(#hidden)
      end if
    else
      case tSprID of
        "play_preview_icon":
          me.playPreviewOfSelected()
      end case
    end if
  end if
end
