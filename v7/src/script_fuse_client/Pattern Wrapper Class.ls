on feedImage me, tImage 
  me.pimage = tImage
  me.render()
  return TRUE
end

on moveTo me, tX, tY 
  me.pLocX = tX
  me.pLocY = tY
  me.render()
end

on moveBy me, tX, tY 
  me.pLocX = (me.pLocX + tX)
  me.pLocY = (me.pLocY + tY)
  me.render()
end

on resizeTo me, tX, tY 
  tOffH = (tX - me.pwidth)
  tOffV = (tY - me.pheight)
  return(me.resizeBy(tOffH, tOffV))
end

on resizeBy me, tOffH, tOffV 
  if tOffH <> 0 or tOffV <> 0 then
    if (me.pScaleH = #move) then
      me.pLocX = (me.pLocX + tOffH)
    else
      if (me.pScaleH = #scale) then
        me.pwidth = (me.pwidth + tOffH)
      else
        if (me.pScaleH = #center) then
          me.pLocX = (me.pLocX + (tOffH / 2))
        end if
      end if
    end if
    if (me.pScaleH = #move) then
      me.pLocY = (me.pLocY + tOffV)
    else
      if (me.pScaleH = #scale) then
        me.pheight = (me.pheight + tOffV)
      else
        if (me.pScaleH = #center) then
          me.pLocY = (me.pLocY + (tOffV / 2))
        end if
      end if
    end if
    me.render()
  end if
end

on render me 
  tW = me.pimage.width
  tH = me.pimage.height
  tXW = (me.pwidth / me.pimage.width)
  tXH = (me.pheight / me.pimage.height)
  i = 0
  repeat while i <= (tXW - 1)
    j = 0
    repeat while j <= (tXH - 1)
      tXi = (me.pLocX + (i * tW))
      tYi = (me.pLocY + (j * tH))
      tRect = rect(tXi, tYi, (tXi + tW), (tYi + tH))
      me.pBuffer.image.copyPixels(me.pimage, tRect, me.pimage.rect, me.pParams)
      j = (1 + j)
    end repeat
    i = (1 + i)
  end repeat
end

on draw me 
  me.pBuffer.image.draw(rect(me.pLocX, me.pLocY, (me.pLocX + me.pwidth), (me.pLocY + me.pheight)), [#shapeType:#rect, #color:rgb(255, 0, 128)])
end
