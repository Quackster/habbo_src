on construct(me)
  pBuddyListPntr = void()
  pRenderObjList = []
  pSelectionList = []
  pRenderIndex = 1
  pBufferWidth = 203
  pBufferHeight = 40
  pCompleteFlag = 0
  pWriterID_name = getUniqueID()
  pWriterID_msgs = getUniqueID()
  pWriterID_last = getUniqueID()
  pWriterID_text = getUniqueID()
  tPlain = getStructVariable("struct.font.plain")
  tBold = getStructVariable("struct.font.bold")
  tLink = getStructVariable("struct.font.link")
  tMetrics = [#font:tBold.getaProp(#font), #fontStyle:tBold.getaProp(#fontStyle), #color:rgb("#EEEEEE")]
  createWriter(pWriterID_name, tMetrics)
  tMetrics = [#font:tPlain.getaProp(#font), #fontStyle:tLink.getaProp(#fontStyle), #color:rgb("#EEEEEE")]
  createWriter(pWriterID_msgs, tMetrics)
  tMetrics = [#font:tPlain.getaProp(#font), #fontStyle:tPlain.getaProp(#fontStyle), #color:rgb("#EEEEEE")]
  createWriter(pWriterID_last, tMetrics)
  tMetrics = [#font:tPlain.getaProp(#font), #fontStyle:tPlain.getaProp(#fontStyle), #color:rgb("#EEEEEE")]
  createWriter(pWriterID_text, tMetrics)
  return(1)
  exit
end

on deconstruct(me)
  pBuddyListPntr = void()
  removeWriter(pWriterID_name)
  removeWriter(pWriterID_msgs)
  removeWriter(pWriterID_last)
  removeWriter(pWriterID_text)
  return(1)
  exit
end

on define(me, tBuddyListPntr)
  pBuddyListPntr = tBuddyListPntr
  pRenderObjList = []
  pCompleteFlag = 0
  tTheBuddyList = pBuddyListPntr.getaProp(#value).getaProp(#buddies)
  repeat while me <= undefined
    tdata = getAt(undefined, tBuddyListPntr)
    pRenderObjList.setAt(tdata.getAt(#name), me.createRenderObj(tdata))
  end repeat
  return(me.buildBufferImage())
  exit
end

on update(me, tBuddyList)
  call(#update, pRenderObjList)
  return(me.buildBufferImage())
  exit
end

on prepare(me)
  tName = 0
  pRenderObjList.getAt(pRenderIndex).render(pBufferImage, pRenderIndex)
  pRenderIndex = pRenderIndex + 1
  if pRenderIndex > pRenderObjList.count then
    removePrepare(me.getID())
    pCompleteFlag = 1
  end if
  exit
end

on appendBuddy(me, tdata)
  if voidp(pRenderObjList.getAt(tdata.getAt(#name))) then
    pRenderObjList.setAt(tdata.getAt(#name), me.createBuddyDrawObj(tdata))
  end if
  return(me.buildListBuffer())
  exit
end

on createRenderObj(me, tdata)
  tObject = createObject(#temp, "Draw Friend Class")
  tProps = []
  tProps.setAt(#width, pBufferWidth)
  tProps.setAt(#height, pBufferHeight)
  tProps.setAt(#writer_name, pWriterID_name)
  tProps.setAt(#writer_msgs, pWriterID_msgs)
  tProps.setAt(#writer_last, pWriterID_last)
  tProps.setAt(#writer_text, pWriterID_text)
  tObject.define(tdata, tProps)
  return(tObject)
  exit
end

on buildBufferImage(me)
  pRenderIndex = 1
  tBuddyCount = pBuddyListPntr.getaProp(#value).count
  if tBuddyCount = 0 then
    pBufferImage = image(pBufferWidth, pBufferHeight, 8)
  else
    pBufferImage = image(pBufferWidth, tBuddyCount * pBufferHeight, 8)
    receivePrepare(me.getID())
  end if
  return(1)
  exit
end