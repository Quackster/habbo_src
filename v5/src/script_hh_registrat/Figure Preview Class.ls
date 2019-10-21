property pBodyPartObjects

on createTemplateHuman me, tSize, tdir, tAction, tActionProps 
  tProps = [:]
  if not objectExists(#temp_humanobj_figurecreator) then
    if not createObject(#temp_humanobj_figurecreator, "Human Template Class") then
      return(error(me, "Failed to init temporary human object!", #createTemplateHuman))
    end if
    tProps.setAt(#userName, "temp_human_figurecreator")
    tProps.setAt(#figure, getObject(#session).get("user_figure").duplicate())
    tProps.setAt(#direction, [tdir, 1, 1])
    tProps.setAt(#x, 10000)
    tProps.setAt(#y, 10000)
    tProps.setAt(#h, 10000)
    if (tSize = "sh") then
      tProps.setAt(#type, 32)
    else
      tProps.setAt(#type, 64)
    end if
    tmember = getObject(#temp_humanobj_figurecreator).define(tProps)
  end if
  if (tAction = "remove") then
    removeObject(#temp_humanobj_figurecreator)
  else
    if (tAction = "reset") then
      call(#resetTemplateHuman, [getObject(#temp_humanobj_figurecreator)])
    else
      call(symbol("action_" & tAction), [getObject(#temp_humanobj_figurecreator)], tActionProps)
    end if
  end if
  return(tmember)
end

on getHumanPartImg me, tPartList, tFigure, tdir, tSize, tAction, tAnimFrame 
  me.createTemplateParts(tFigure, tPartList, tdir, tSize)
  tHumanImg = image(64, 102, 16)
  me.getPartImg(tPartList, tHumanImg, tdir, tSize, tAction, tAnimFrame)
  return(tHumanImg)
end

on createHumanPartPreview me, tWindowTitle, tElement, tPartList, tFigure 
  if voidp(tFigure) then
    tFigure = getObject(#session).get("user_figure")
    if (tFigure.ilk = #propList) then
      tFigure = tFigure.duplicate()
    else
      return(error(me, "Figure data not found!", #createHumanPartPreview))
    end if
  end if
  me.createTemplateParts(tFigure, tPartList, 3)
  me.setParts(tFigure, tPartList)
  me.feedHumanPreview(tWindowTitle, tElement, tPartList)
end

on setParts me, tFigure, tPartList 
  repeat while tPartList <= tPartList
    tPart = getAt(tPartList, tFigure)
    if not tPart contains "it" then
      tmodel = tFigure.getAt(tPart).getAt("model")
      tColor = tFigure.getAt(tPart).getAt("color")
      if (tPartList = 1) then
        tmodel = "00" & tmodel
      else
        if (tPartList = 2) then
          tmodel = "0" & tmodel
        end if
      end if
      if not voidp(pBodyPartObjects) then
        call(#setColor, [pBodyPartObjects.getAt(tPart)], tColor)
        call(#setModel, [pBodyPartObjects.getAt(tPart)], tmodel)
      end if
    end if
  end repeat
end

on createTemplateParts me, tFigure, tPartList, tdir, tSize 
  if voidp(tSize) then
    pPeopleSize = "h"
  end if
  pBuffer = image(1, 1, 8)
  pFlipList = [0, 1, 2, 3, 2, 1, 0, 7]
  pBodyPartObjects = [:]
  repeat while tPartList <= tPartList
    tPart = getAt(tPartList, tFigure)
    if not tPart contains "it" then
      tmodel = tFigure.getAt(tPart).getAt("model")
      tColor = tFigure.getAt(tPart).getAt("color")
      tDirection = tdir
      tAction = "std"
      tAncestor = me
      if (tPartList = 1) then
        tmodel = "00" & tmodel
      else
        if (tPartList = 2) then
          tmodel = "0" & tmodel
        end if
      end if
      tTempPartObj = createObject(#temp, "Bodypart Template Class")
      tTempPartObj.define(tPart, tmodel, tColor, tDirection, tAction, tAncestor)
      pBodyPartObjects.addProp(tPart, tTempPartObj)
    end if
  end repeat
end

on feedHumanPreview me, tWindowTitle, tElemID, tPartList 
  if not voidp(pBodyPartObjects) and windowExists(tWindowTitle) then
    tElem = getWindow(tWindowTitle).getElement(tElemID)
    tTempPartImg = image(64, 102, 16)
    me.getPartImg(tPartList, tTempPartImg, 3)
    tTempPartImg = tTempPartImg.trimWhiteSpace()
    tPrewImg = image(tElem.getProperty(#width), tElem.getProperty(#height), 16)
    tdestrect = (tPrewImg.rect - tTempPartImg.rect)
    tMargins = rect(0, 0, 0, 0)
    tdestrect = (rect((tdestrect.width / 2), (tdestrect.height / 2), (tTempPartImg.width + (tdestrect.width / 2)), ((tdestrect.height / 2) + tTempPartImg.height)) + tMargins)
    tPrewImg.copyPixels(tTempPartImg, tdestrect, tTempPartImg.rect, [#ink:8])
    tElem.clearImage()
    tElem.feedImage(tPrewImg)
  end if
end

on getPartImg me, tPartList, tImg, tdir, tSize 
  if tPartList.ilk <> #list then
    list(tPartList)
  end if
  repeat while tPartList <= tImg
    tPart = getAt(tImg, tPartList)
    if not tPart contains "it" then
      call(#copyPicture, [pBodyPartObjects.getAt(tPart)], tImg, tdir, tSize)
    end if
  end repeat
end
