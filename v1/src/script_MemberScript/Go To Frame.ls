property sFrame

on mouseUp me 
  goToFrame(sFrame)
end

on getPropertyDescriptionList me 
  return([#sFrame:[#comment:"Marker", #format:#string, #default:""]])
end
