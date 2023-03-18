property type
global gTicTacToe

on new me
  return me
end

on mouseDown me
  choose(me)
end

on choose me
  selectTicType(gTicTacToe, type)
end

on getPropertyDescriptionList
  return [#type: [#comment: "Type", #range: ["X", "O"], #format: #string, #default: "X"]]
end
