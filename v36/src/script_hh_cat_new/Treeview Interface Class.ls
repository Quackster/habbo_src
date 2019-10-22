property pData, pimage, pClickAreas, pwidth, pheight

on construct me 
  pData = void()
  pimage = void()
  pwidth = 0
  pheight = 0
  pClickAreas = []
  sendProcessTracking(600)
end

on deconstruct me 
  pData = void()
end

on feedData me, tdata 
  sendProcessTracking(601)
  if tdata <> 0 and not voidp(tdata) then
    pData = tdata
    tRootNode = pData.getRootNode()
    if tRootNode <> 0 and not voidp(tRootNode) then
      tRootNode.setState(#open)
    end if
  end if
  sendProcessTracking(602)
end

on define me, tProps 
  pwidth = tProps.getAt(#width)
  pheight = tProps.getAt(#height)
  pClickAreas = []
end

on getImage me 
  if voidp(pimage) then
    me.render()
  end if
  return(pimage)
end

on appendRenderToImage me, tImageDest, tImageSrc, tRectDest, tRectSrc 
  if tImageDest.height > tRectDest.bottom then
    tImageDest.copyPixels(tImageSrc, tRectDest, tRectSrc, [#useFastQuads:1])
    return(tImageDest)
  else
    tImageNew = image(tImageDest.width, tRectDest.bottom, tImageDest.depth)
    tImageNew.copyPixels(tImageDest, tImageDest.rect, tImageDest.rect, [#useFastQuads:1])
    tImageNew.copyPixels(tImageSrc, tRectDest, tRectSrc, [#useFastQuads:1])
    return(tImageNew)
  end if
end

on renderNode me, tNode, tOffsetY 
  sendProcessTracking(603)
  if (pData = 0) or voidp(pData) then
    return FALSE
  end if
  if (tNode = 0) or voidp(tNode) then
    return FALSE
  end if
  sendProcessTracking(604)
  if not (tNode = pData.getRootNode()) and not tNode.getData(#navigateable) then
    return(tOffsetY)
  end if
  sendProcessTracking(605)
  if tNode.getData(#navigateable) then
    tNodeImage = tNode.getImage()
    me.pimage = me.appendRenderToImage(me.pimage, tNodeImage, (tNodeImage.rect + rect(0, tOffsetY, 0, tOffsetY)), tNodeImage.rect)
    pClickAreas.add([#min:tOffsetY, #max:(tOffsetY + tNodeImage.height), #data:tNode])
    tOffsetY = (tOffsetY + tNodeImage.height)
  end if
  sendProcessTracking(606)
  tChildren = tNode.getChildren()
  if (ilk(tChildren) = #list) then
    if (tNode.getState() = #open) and tChildren.count > 0 then
      repeat while tChildren <= tOffsetY
        tChild = getAt(tOffsetY, tNode)
        tOffsetY = me.renderNode(tChild, tOffsetY)
      end repeat
    end if
  end if
  sendProcessTracking(607)
  return(tOffsetY)
end

on render me 
  sendProcessTracking(610)
  pimage = image(pwidth, pheight, 32)
  pClickAreas = []
  tOffsetY = 0
  if (pData = 0) or voidp(pData) then
    return FALSE
  end if
  me.renderNode(pData.getRootNode(), tOffsetY)
end

on selectNode me, tNode, tSelectedNode 
  sendProcessTracking(620)
  if (tNode = tSelectedNode) then
    tNode.select(1)
  else
    tNode.select(0)
  end if
  repeat while tNode.getChildren() <= tSelectedNode
    tChild = getAt(tSelectedNode, tNode)
    me.selectNode(tChild, tSelectedNode)
  end repeat
end

on select me, tNodeObj 
  sendProcessTracking(630)
  if (pData = 0) or voidp(pData) then
    return FALSE
  end if
  me.selectNode(pData.getRootNode(), tNodeObj)
end

on simulateClickByName me, tNodeName 
  sendProcessTracking(640)
  if ilk(pClickAreas) <> #list then
    return FALSE
  end if
  tClickLoc = point(2, 0)
  i = 1
  repeat while i <= pClickAreas.count
    if (ilk(pClickAreas.getAt(i)) = #propList) then
      if objectp(pClickAreas.getAt(i).getAt(#data)) then
        if (pClickAreas.getAt(i).getAt(#data).getData(#nodename) = tNodeName) then
          tClickLoc.locV = (pClickAreas.getAt(i).getAt(#min) + 1)
        else
          i = (1 + i)
        end if
        me.handleClick(tClickLoc)
      end if
    end if
  end repeat
end

on handleClick me, tloc 
  sendProcessTracking(650)
  if (pData = 0) or voidp(pData) then
    return FALSE
  end if
  if ilk(tloc) <> #point then
    return()
  end if
  tNode = void()
  i = 1
  repeat while i <= pClickAreas.count
    if pClickAreas.getAt(i).getAt(#min) < tloc.locV and pClickAreas.getAt(i).getAt(#max) > tloc.locV then
      tNode = pClickAreas.getAt(i).getAt(#data)
    else
      i = (1 + i)
    end if
  end repeat
  if voidp(tNode) then
    return FALSE
  end if
  if tNode.getChildren().count > 0 then
    if (tNode.getState() = #open) then
      tNode.setState(#closed)
    else
      tNode.setState(#open)
    end if
  end if
  if tNode.getData(#level) <= 1 then
    pData.getRootNode().setState(#open)
    repeat while pData.getRootNode().getChildren() <= undefined
      tChild = getAt(undefined, tloc)
      if tNode <> tChild then
        tChild.setState(#closed)
      end if
    end repeat
  end if
  me.select(tNode)
  me.render()
  if tNode.getData(#pageid) <> -1 then
    pData.handlePageRequest(tNode.getData(#pageid))
  end if
  return TRUE
end
