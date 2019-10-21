on construct(me)
  pData = void()
  pimage = void()
  pwidth = 0
  pheight = 0
  pClickAreas = void()
  exit
end

on deconstruct(me)
  pData = void()
  exit
end

on feedData(me, tdata)
  pData = tdata
  pData.getRootNode().setState(#open)
  exit
end

on define(me, tProps)
  pwidth = tProps.getAt(#width)
  pheight = tProps.getAt(#height)
  pClickAreas = []
  exit
end

on getImage(me)
  if voidp(pimage) then
    me.render()
  end if
  return(pimage)
  exit
end

on appendRenderToImage(me, tImageDest, tImageSrc, tRectDest, tRectSrc)
  if tImageDest.height > tRectDest.bottom then
    tImageDest.copyPixels(tImageSrc, tRectDest, tRectSrc, [#useFastQuads:1])
    return(tImageDest)
  else
    tImageNew = image(tImageDest.width, tRectDest.bottom, tImageDest.depth)
    tImageNew.copyPixels(tImageDest, tImageDest.rect, tImageDest.rect, [#useFastQuads:1])
    tImageNew.copyPixels(tImageSrc, tRectDest, tRectSrc, [#useFastQuads:1])
    return(tImageNew)
  end if
  exit
end

on renderNode(me, tNode, tOffsetY)
  if not tNode = pData.getRootNode() and not tNode.getData(#navigateable) then
    return(tOffsetY)
  end if
  if tNode.getData(#navigateable) then
    tNodeImage = tNode.getImage()
    me.pimage = me.appendRenderToImage(me.pimage, tNodeImage, tNodeImage.rect + rect(0, tOffsetY, 0, tOffsetY), tNodeImage.rect)
    pClickAreas.add([#min:tOffsetY, #max:tOffsetY + tNodeImage.height, #data:tNode])
    tOffsetY = tOffsetY + tNodeImage.height
  end if
  if tNode.getState() = #open and tNode.getChildren().count > 0 then
    repeat while me <= tOffsetY
      tChild = getAt(tOffsetY, tNode)
      tOffsetY = me.renderNode(tChild, tOffsetY)
    end repeat
  end if
  return(tOffsetY)
  exit
end

on render(me)
  pimage = image(pwidth, pheight, 32)
  pClickAreas = []
  tOffsetY = 0
  me.renderNode(pData.getRootNode(), tOffsetY)
  exit
end

on selectNode(me, tNode, tSelectedNode)
  if tNode = tSelectedNode then
    tNode.select(1)
  else
    tNode.select(0)
  end if
  repeat while me <= tSelectedNode
    tChild = getAt(tSelectedNode, tNode)
    me.selectNode(tChild, tSelectedNode)
  end repeat
  exit
end

on select(me, tNodeObj)
  me.selectNode(pData.getRootNode(), tNodeObj)
  exit
end

on simulateClickByName(me, tNodeName)
  tClickLoc = point(2, 0)
  i = 1
  repeat while i <= pClickAreas.count
    if pClickAreas.getAt(i).getAt(#data).getData(#nodename) = tNodeName then
      tClickLoc.locV = pClickAreas.getAt(i).getAt(#min) + 1
    else
      i = 1 + i
    end if
  end repeat
  me.handleClick(tClickLoc)
  exit
end

on handleClick(me, tloc)
  tNode = void()
  i = 1
  repeat while i <= pClickAreas.count
    if pClickAreas.getAt(i).getAt(#min) < tloc.locV and pClickAreas.getAt(i).getAt(#max) > tloc.locV then
      tNode = pClickAreas.getAt(i).getAt(#data)
    else
      i = 1 + i
    end if
  end repeat
  if voidp(tNode) then
    return(0)
  end if
  if tNode.getChildren().count > 0 then
    if tNode.getState() = #open then
      tNode.setState(#closed)
    else
      tNode.setState(#open)
    end if
  end if
  if tNode.getData(#level) <= 1 then
    pData.getRootNode().setState(#open)
    repeat while me <= undefined
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
  return(1)
  exit
end