property pChange, emailOk, BirthdayOK

on mouseUp me
  if field("password_field").length < 3 then
    ShowAlert("YourPasswordIstooShort")
    return 
  end if
  if (field("password_field") <> field("password_field2")) or (field("password_field") = EMPTY) or (field("Agreement_field") <> "1") or (field("charactername_field") = EMPTY) then
    if (field("password_field") <> field("password_field2")) or (field("password_field") = EMPTY) then
      ShowAlert("CheckPassword")
    end if
    if field("Agreement_field") <> "1" then
      ShowAlert("YouMustAgree")
    end if
  else
    put field("password_field") into field "loginpw"
    put field("charactername_field") into field "loginname"
    BirthdayANDemailcheck()
    if emailOk and BirthdayOK then
      if pChange then
        gotoFrame("change2")
      else
        gotoFrame("figure")
      end if
    end if
  end if
end

on getPropertyDescriptionList me
  pList = [:]
  addProp(pList, #pChange, [#comment: "is this a change user properies form", #format: #boolean, #default: 0])
  return pList
end

on BirthdayANDemailcheck me
  Birthday = "Birthday_field"
  emailfield = "email_field"
  BirthdayOK = 1
  if field(Birthday).length > 8 then
    if (field(Birthday).char[field(Birthday).length - 3..field(Birthday).length - 2] = "19") or (field(Birthday).char[field(Birthday).length - 3..field(Birthday).length - 2] = "20") then
      BirthdayOK = 1
    else
      BirthdayOK = 0
    end if
  else
    BirthdayOK = 0
  end if
  if (field(emailfield).length > 6) and (field(emailfield) contains "@") then
    emailOk = 0
    repeat with f = offset("@", field(emailfield)) + 1 to field(emailfield).length
      if field(emailfield).char[f] = "." then
        emailOk = 1
      end if
      if field(emailfield).char[f] = "@" then
        emailOk = 0
        exit repeat
      end if
    end repeat
    if (emailOk = 0) and (BirthdayOK = 1) then
      ShowAlert("emailNotCorrect")
    else
      if (emailOk = 1) and (BirthdayOK = 0) then
        ShowAlert("CheckBirthday")
      else
        if (emailOk = 0) and (BirthdayOK = 0) then
          ShowAlert("CheckEmailandBirthday")
        end if
      end if
    end if
  else
    if BirthdayOK = 0 then
      ShowAlert("CheckEmailandBirthday")
    else
      ShowAlert("emailNotCorrect")
    end if
  end if
end
