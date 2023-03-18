on createTemplateHuman me, tSize, tdir, tAction, tActionProps
  tObjectName = "temp_humanobj"
  tFigure = getObject(#session).GET("user_figure").duplicate()
  tmember = me.createTemplateFigure(tObjectName, tFigure, tSize, tdir)
  case tAction of
    "remove":
      removeObject(tObjectName)
    "reset":
      call(#resetTemplateHuman, [getObject(tObjectName)])
    otherwise:
      call(symbol("action_" & tAction), [getObject(tObjectName)], tActionProps)
  end case
  return tmember
end

on getHumanPartImg me, tPartList, tFigure, tdir, tSize
  if voidp(tFigure) then
    tFigure = getObject(#session).GET("user_figure")
    if tFigure.ilk = #propList then
      tFigure = tFigure.duplicate()
    else
      return error(me, "Figure data not found!", #getHumanPartImg, #major)
    end if
  end if
  tObjectName = "humanobj_temp_temp"
  if voidp(tdir) then
    tdir = 3
  end if
  if voidp(tSize) then
    tSize = "h"
  end if
  me.createTemplateFigure(tObjectName, tFigure, tSize, tdir)
  tTempPartImg = image(64, 102, 16)
  call(#getPartialPicture, [getObject(tObjectName)], tPartList, tTempPartImg, tdir)
  tTempPartImg = tTempPartImg.trimWhiteSpace()
  removeObject(tObjectName)
  return tTempPartImg
end

on createHumanPartPreview me, tWindowTitle, tElement, tPartList, tFigure, tdir, tSize
  tTempPartImg = me.getHumanPartImg(tPartList, tFigure, tdir, tSize)
  if tTempPartImg.ilk = #image then
    me.feedHumanPreview(tWindowTitle, tElement, tTempPartImg)
  end if
end

on createTemplateFigure me, tObjectName, tFigure, tSize, tdir
  if not objectExists(tObjectName) then
    if not createObject(tObjectName, ["Human Class EX", "Human Template Class"]) then
      return error(me, "Failed to init temporary human object!", #createTemplateFigure, #major)
    end if
    tProps = [:]
    tProps[#userName] = "temp_human_figurecreator"
    tProps[#figure] = tFigure
    tProps[#direction] = [tdir, 1, 1]
    tProps[#x] = 10000
    tProps[#y] = 10000
    tProps[#h] = 10000
    if tSize = "sh" then
      tProps[#type] = 32
    else
      tProps[#type] = 64
    end if
    tmember = getObject(tObjectName).define(tProps)
  else
    tmember = getObject(tObjectName).getMember()
  end if
  return tmember
end

on feedHumanPreview me, tWindowTitle, tElemID, tTempPartImg
  if windowExists(tWindowTitle) then
    tElem = getWindow(tWindowTitle).getElement(tElemID)
    if tElem = 0 then
      return 0
    end if
    tPrewImg = image(tElem.getProperty(#width), tElem.getProperty(#height), 16)
    tdestrect = tPrewImg.rect - tTempPartImg.rect
    tMargins = rect(0, 0, 0, 0)
    tdestrect = rect(tdestrect.width / 2, tdestrect.height / 2, tTempPartImg.width + (tdestrect.width / 2), (tdestrect.height / 2) + tTempPartImg.height) + tMargins
    tPrewImg.copyPixels(tTempPartImg, tdestrect, tTempPartImg.rect, [#ink: 8])
    tElem.clearImage()
    tElem.feedImage(tPrewImg)
  end if
end
