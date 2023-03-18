property pBuddyListPntr, pRenderObjList, pSelectionList, pRenderIndex, pBufferImage, pBufferWidth, pBufferHeight, pCompleteFlag, pWriterID_name, pWriterID_msgs, pWriterID_last, pWriterID_text

on construct me
  pBuddyListPntr = VOID
  pRenderObjList = [:]
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
  tMetrics = [#font: tBold.getaProp(#font), #fontStyle: tBold.getaProp(#fontStyle), #color: rgb("#EEEEEE")]
  createWriter(pWriterID_name, tMetrics)
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tLink.getaProp(#fontStyle), #color: rgb("#EEEEEE")]
  createWriter(pWriterID_msgs, tMetrics)
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#EEEEEE")]
  createWriter(pWriterID_last, tMetrics)
  tMetrics = [#font: tPlain.getaProp(#font), #fontStyle: tPlain.getaProp(#fontStyle), #color: rgb("#EEEEEE")]
  createWriter(pWriterID_text, tMetrics)
  return 1
end

on deconstruct me
  pBuddyListPntr = VOID
  removeWriter(pWriterID_name)
  removeWriter(pWriterID_msgs)
  removeWriter(pWriterID_last)
  removeWriter(pWriterID_text)
  return 1
end

on define me, tBuddyListPntr
  pBuddyListPntr = tBuddyListPntr
  pRenderObjList = [:]
  pCompleteFlag = 0
  tTheBuddyList = pBuddyListPntr.getaProp(#value).getaProp(#buddies)
  repeat with tdata in tTheBuddyList
    pRenderObjList[tdata[#name]] = me.createRenderObj(tdata)
  end repeat
  return me.buildBufferImage()
end

on update me, tBuddyList
  call(#update, pRenderObjList)
  return me.buildBufferImage()
end

on prepare me
  tName = 0
  pRenderObjList[pRenderIndex].render(pBufferImage, pRenderIndex)
  pRenderIndex = pRenderIndex + 1
  if pRenderIndex > pRenderObjList.count then
    removePrepare(me.getID())
    pCompleteFlag = 1
  end if
end

on appendBuddy me, tdata
  if voidp(pRenderObjList[tdata[#name]]) then
    pRenderObjList[tdata[#name]] = me.createBuddyDrawObj(tdata)
  end if
  return me.buildListBuffer()
end

on createRenderObj me, tdata
  tObject = createObject(#temp, "Draw Friend Class")
  tProps = [:]
  tProps[#width] = pBufferWidth
  tProps[#height] = pBufferHeight
  tProps[#writer_name] = pWriterID_name
  tProps[#writer_msgs] = pWriterID_msgs
  tProps[#writer_last] = pWriterID_last
  tProps[#writer_text] = pWriterID_text
  tObject.define(tdata, tProps)
  return tObject
end

on buildBufferImage me
  pRenderIndex = 1
  tBuddyCount = pBuddyListPntr.getaProp(#value).count
  if tBuddyCount = 0 then
    pBufferImage = image(pBufferWidth, pBufferHeight, 8)
  else
    pBufferImage = image(pBufferWidth, tBuddyCount * pBufferHeight, 8)
    receivePrepare(me.getID())
  end if
  return 1
end
