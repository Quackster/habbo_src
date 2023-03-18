on feedImage me, tImage
  me.pimage = tImage
  me.render()
  return 1
end

on moveTo me, tX, tY
  me.pLocX = tX
  me.pLocY = tY
  me.render()
end

on moveBy me, tX, tY
  me.pLocX = me.pLocX + tX
  me.pLocY = me.pLocY + tY
  me.render()
end

on resizeTo me, tX, tY
  tOffH = tX - me.pwidth
  tOffV = tY - me.pheight
  return me.resizeBy(tOffH, tOffV)
end

on resizeBy me, tOffH, tOffV
  if (tOffH <> 0) or (tOffV <> 0) then
    case me.pScaleH of
      #move:
        me.pLocX = me.pLocX + tOffH
      #scale:
        me.pwidth = me.pwidth + tOffH
      #center:
        me.pLocX = me.pLocX + (tOffH / 2)
    end case
    case me.pScaleV of
      #move:
        me.pLocY = me.pLocY + tOffV
      #scale:
        me.pheight = me.pheight + tOffV
      #center:
        me.pLocY = me.pLocY + (tOffV / 2)
    end case
    me.render()
  end if
end

on render me
  tW = me.pimage.width
  tH = me.pimage.height
  tXW = me.pwidth / me.pimage.width
  tXH = me.pheight / me.pimage.height
  repeat with i = 0 to tXW - 1
    repeat with j = 0 to tXH - 1
      tXi = me.pLocX + (i * tW)
      tYi = me.pLocY + (j * tH)
      tRect = rect(tXi, tYi, tXi + tW, tYi + tH)
      me.pBuffer.image.copyPixels(me.pimage, tRect, me.pimage.rect, me.pParams)
    end repeat
  end repeat
end

on draw me
  me.pBuffer.image.draw(rect(me.pLocX, me.pLocY, me.pLocX + me.pwidth, me.pLocY + me.pheight), [#shapeType: #rect, #color: rgb(255, 0, 128)])
end
