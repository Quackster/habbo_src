property num

on mouseDown me
  flatScroll(num)
end

on getPropertyDescriptionList me
  return [#num: [#comment: "Num to scroll", #default: 1, #format: #integer]]
end
