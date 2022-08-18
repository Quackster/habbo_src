property type
global gChess

on new me
  return me
end

on mouseDown me
  choose(me)
end

on choose me
  selectType(gChess, type)
end

on getPropertyDescriptionList
  return [#type: [#comment: "Type", #range: ["B", "W"], #format: #string, #default: "W"]]
end
