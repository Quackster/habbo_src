on construct(me)
  pNodes = void()
  pInterface = createObject(#random, "Treeview Interface Class")
  exit
end

on deconstruct(me)
  if objectp(pNodes) then
    if pNodes.valid then
      removeObject(pNodes.getID())
    end if
  end if
  pNodes = void()
  if objectExists(pInterface.getID()) then
    removeObject(pInterface.getID())
  end if
  exit
end

on define(me, tdata, tWidth, tHeight)
  pNodes = me.createNode(tdata, tWidth, 0)
  pInterface.feedData(me)
  pInterface.define([#width:tWidth, #height:tHeight])
  exit
end

on getRootNode(me)
  return(pNodes)
  exit
end

on getInterface(me)
  return(pInterface)
  exit
end

on handlePageRequest(me, tPageID)
  getThread(#catalogue).getComponent().preparePage(tPageID)
  exit
end

on createNode(me, tdata, tWidth, tLevel)
  if ilk(tdata) <> #propList then
    return(0)
  end if
  tNode = createObject(#random, "Treeview Node Class")
  tNode.feedData([#level:tLevel, #navigateable:tdata.navigateable, #color:tdata.color, #icon:tdata.icon, #pageid:tdata.pageid, #nodename:tdata.nodename], tWidth)
  if not voidp(tdata.getaProp(#subnodes)) then
    repeat while me <= tWidth
      tSubNodeData = getAt(tWidth, tdata)
      tSubNode = me.createNode(tSubNodeData, tWidth, tLevel + 1)
      tNode.addChild(tSubNode)
    end repeat
  end if
  return(tNode)
  exit
end