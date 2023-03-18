property pBodyPartObjects

on createTemplateHuman me, tSize, tdir, tAction, tActionProps
  tProps = [:]
  if not objectExists("temp_humanobj") then
    if not createObject("temp_humanobj", "Human Template Class") then
      return error(me, "Failed to init temporary human object!", #createTemplateHuman)
    end if
    tProps[#userName] = "temp_human_figurecreator"
    tProps[#figure] = getObject(#session).get("user_figure").duplicate()
    tProps[#direction] = [tdir, 1, 1]
    tProps[#x] = 10000
    tProps[#y] = 10000
    tProps[#h] = 10000
    if tSize = "sh" then
      tProps[#type] = 32
    else
      tProps[#type] = 64
    end if
    tmember = getObject("temp_humanobj").define(tProps)
  end if
  case tAction of
    "remove":
      removeObject("temp_humanobj")
    "reset":
      call(#resetTemplateHuman, [getObject("temp_humanobj")])
    otherwise:
      call(symbol("action_" & tAction), [getObject("temp_humanobj")], tActionProps)
  end case
  return tmember
end

on getHumanPartImg me, tPartList, tFigure, tdir, tSize, tAction, tAnimFrame
  me.createTemplateParts(tFigure, tPartList, tdir, tSize)
  tHumanImg = image(64, 102, 16)
  me.getPartImg(tPartList, tHumanImg, tdir, tSize, tAction, tAnimFrame)
  return tHumanImg
end

on createHumanPartPreview me, tWindowTitle, tElement, tPartList, tFigure
  if voidp(tFigure) then
    tFigure = getObject(#session).get("user_figure")
    if tFigure.ilk = #propList then
      tFigure = tFigure.duplicate()
    else
      return error(me, "Figure data not found!", #createHumanPartPreview)
    end if
  end if
  me.createTemplateParts(tFigure, tPartList, 3)
  me.setParts(tFigure, tPartList)
  me.feedHumanPreview(tWindowTitle, tElement, tPartList)
end

on setParts me, tFigure, tPartList
  repeat with tPart in tPartList
    if not (tPart contains "it") then
      tmodel = tFigure[tPart]["model"]
      tColor = tFigure[tPart]["color"]
      case length(tmodel) of
        1:
          tmodel = "00" & tmodel
        2:
          tmodel = "0" & tmodel
      end case
      if not voidp(pBodyPartObjects) then
        call(#setColor, [pBodyPartObjects[tPart]], tColor)
        call(#setModel, [pBodyPartObjects[tPart]], tmodel)
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
  repeat with tPart in tPartList
    if not (tPart contains "it") then
      tmodel = tFigure[tPart]["model"]
      tColor = tFigure[tPart]["color"]
      tDirection = tdir
      tAction = "std"
      tAncestor = me
      case length(tmodel) of
        1:
          tmodel = "00" & tmodel
        2:
          tmodel = "0" & tmodel
      end case
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
    tdestrect = tPrewImg.rect - tTempPartImg.rect
    tMargins = rect(0, 0, 0, 0)
    tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tTempPartImg.width + (tdestrect.width / 2), (tdestrect.height / 2) + tTempPartImg.height) + tMargins
    tPrewImg.copyPixels(tTempPartImg, tdestrect, tTempPartImg.rect, [#ink: 8])
    tElem.clearImage()
    tElem.feedImage(tPrewImg)
  end if
end

on getPartImg me, tPartList, tImg, tdir, tSize
  if tPartList.ilk <> #list then
    list(tPartList)
  end if
  repeat with tPart in tPartList
    if not (tPart contains "it") then
      call(#copyPicture, [pBodyPartObjects[tPart]], tImg, tdir, tSize)
    end if
  end repeat
end
