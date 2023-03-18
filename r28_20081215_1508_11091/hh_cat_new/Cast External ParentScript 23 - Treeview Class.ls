property pNodes, pInterface

on construct me
  pNodes = VOID
  pInterface = createObject(#random, "Treeview Interface Class")
end

on deconstruct me
  if objectp(pNodes) then
    if pNodes.valid then
      removeObject(pNodes.getID())
    end if
  end if
  pNodes = VOID
  if objectExists(pInterface.getID()) then
    removeObject(pInterface.getID())
  end if
end

on define me, tdata, tWidth, tHeight
  pNodes = me.createNode(tdata, tWidth, 0)
  pInterface.feedData(me)
  pInterface.define([#width: tWidth, #height: tHeight])
end

on getRootNode me
  return pNodes
end

on getInterface me
  return pInterface
end

on handlePageRequest me, tPageID
  getThread(#catalogue).getComponent().preparePage(tPageID)
end

on createNode me, tdata, tWidth, tLevel
  tNode = createObject(#random, "Treeview Node Class")
  tNode.feedData([#level: tLevel, #navigateable: tdata.navigateable, #color: tdata.color, #icon: tdata.icon, #pageid: tdata.pageid, #nodename: tdata.nodename], tWidth)
  if not voidp(tdata.getaProp(#subnodes)) then
    repeat with tSubNodeData in tdata.subnodes
      tSubNode = me.createNode(tSubNodeData, tWidth, tLevel + 1)
      tNode.addChild(tSubNode)
    end repeat
  end if
  return tNode
end
