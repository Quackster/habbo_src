on createTemplateHuman(me, tSize, tdir, tAction, tActionProps)
  tProps = []
  tObjectName = "temp_humanobj"
  if not objectExists(tObjectName) then
    if not createObject(tObjectName, "Human Template Class") then
      return(error(me, "Failed to init temporary human object!", #createTemplateHuman, #major))
    end if
    tProps.setAt(#userName, "temp_human_figurecreator")
    tProps.setAt(#figure, getObject(#session).GET("user_figure").duplicate())
    tProps.setAt(#direction, [tdir, 1, 1])
    tProps.setAt(#x, 10000)
    tProps.setAt(#y, 10000)
    tProps.setAt(#h, 10000)
    if tSize = "sh" then
      tProps.setAt(#type, 32)
    else
      tProps.setAt(#type, 64)
    end if
    tmember = getObject(tObjectName).define(tProps)
  else
    tmember = getObject(tObjectName).getMember()
  end if
  if me = "remove" then
    removeObject(tObjectName)
  else
    if me = "reset" then
      call(#resetTemplateHuman, [getObject(tObjectName)])
    else
      call(symbol("action_" & tAction), [getObject(tObjectName)], tActionProps)
    end if
  end if
  return(tmember)
  exit
end

on getHumanPartImg(me, tPartList, tFigure, tdir, tSize, tAction, tAnimFrame)
  me.createTemplateParts(tFigure, tPartList, tdir, tSize)
  tHumanImg = image(64, 102, 16)
  me.getPartImg(tPartList, tHumanImg, tdir, tSize, tAction, tAnimFrame)
  return(tHumanImg)
  exit
end

on createHumanPartPreview(me, tWindowTitle, tElement, tPartList, tFigure)
  if voidp(tFigure) then
    tFigure = getObject(#session).GET("user_figure")
    if tFigure.ilk = #propList then
      tFigure = tFigure.duplicate()
    else
      return(error(me, "Figure data not found!", #createHumanPartPreview, #major))
    end if
  end if
  me.createTemplateParts(tFigure, tPartList, 3)
  me.setParts(tFigure, tPartList)
  me.feedHumanPreview(tWindowTitle, tElement, tPartList)
  exit
end

on setParts(me, tFigure, tPartList)
  repeat while me <= tPartList
    tPart = getAt(tPartList, tFigure)
    if not tPart contains "it" then
      tmodel = tFigure.getAt(tPart).getAt("model")
      tColor = tFigure.getAt(tPart).getAt("color")
      if me = 1 then
        tmodel = "00" & tmodel
      else
        if me = 2 then
          tmodel = "0" & tmodel
        end if
      end if
      if not voidp(pBodyPartObjects) then
        call(#setColor, [pBodyPartObjects.getAt(tPart)], tColor)
        call(#setModel, [pBodyPartObjects.getAt(tPart)], tmodel)
      end if
    end if
  end repeat
  exit
end

on createTemplateParts(me, tFigure, tPartList, tdir, tSize)
  if voidp(tSize) then
    pPeopleSize = "h"
  end if
  pBuffer = image(1, 1, 8)
  pFlipList = [0, 1, 2, 3, 2, 1, 0, 7]
  pBodyPartObjects = []
  repeat while me <= tPartList
    tPart = getAt(tPartList, tFigure)
    if not tPart contains "it" then
      tmodel = tFigure.getAt(tPart).getAt("model")
      tColor = tFigure.getAt(tPart).getAt("color")
      tDirection = tdir
      tAction = "std"
      tAncestor = me
      if me = 1 then
        tmodel = "00" & tmodel
      else
        if me = 2 then
          tmodel = "0" & tmodel
        end if
      end if
      tTempPartObj = createObject(#temp, "Bodypart Template Class")
      tTempPartObj.define(tPart, tmodel, tColor, tDirection, tAction, tAncestor)
      pBodyPartObjects.addProp(tPart, tTempPartObj)
    end if
  end repeat
  exit
end

on feedHumanPreview(me, tWindowTitle, tElemID, tPartList)
  if not voidp(pBodyPartObjects) and windowExists(tWindowTitle) then
    tElem = getWindow(tWindowTitle).getElement(tElemID)
    tTempPartImg = image(64, 102, 16)
    me.getPartImg(tPartList, tTempPartImg, 3)
    tTempPartImg = tTempPartImg.trimWhiteSpace()
    tPrewImg = image(tElem.getProperty(#width), tElem.getProperty(#height), 16)
    tdestrect = tPrewImg.rect - tTempPartImg.rect
    tMargins = rect(0, 0, 0, 0)
    tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tTempPartImg.width + tdestrect.width / 2, tdestrect.height / 2 + tTempPartImg.height) + tMargins
    tPrewImg.copyPixels(tTempPartImg, tdestrect, tTempPartImg.rect, [#ink:8])
    tElem.clearImage()
    tElem.feedImage(tPrewImg)
  end if
  exit
end

on getPartImg(me, tPartList, tImg, tdir, tSize)
  if tPartList.ilk <> #list then
    list(tPartList)
  end if
  repeat while me <= tImg
    tPart = getAt(tImg, tPartList)
    if not tPart contains "it" then
      call(#copyPicture, [pBodyPartObjects.getAt(tPart)], tImg, tdir, tSize)
    end if
  end repeat
  exit
end