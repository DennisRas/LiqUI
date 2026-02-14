local C = LiqUI.Config

local ButtonDefaults = {
  width = 120,
  height = C.control.height,
  label = "Button",
  border = false,
  backgroundColor = C.primary.defaultColor,
  backgroundColorHover = C.primary.hoverColor,
  backgroundColorPressed = C.primary.pressedColor,
  OnClick = nil,
}

function LiqUI.Widgets.CreateButton(parent, options)
  local frame = CreateFrame("Button", nil, parent, "BackdropTemplate")
  Mixin(frame, LiqUI.Widgets.BaseMixin)
  frame.options = frame:Init(ButtonDefaults, options)
  frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.label:SetPoint("CENTER")
  frame.label:SetText(frame.options.label)

  frame:SetScript("OnEnter", function()
    frame:SetBorderState("highlight")
    frame:SetBackgroundState("highlight")
  end)
  frame:SetScript("OnLeave", function()
    frame:SetBorderState("normal")
    frame:SetBackgroundState("normal")
  end)
  frame:SetScript("OnMouseDown", function()
    frame:SetBackgroundState("pressed")
  end)
  frame:SetScript("OnMouseUp", function()
    frame:SetBackgroundState("normal")
  end)
  frame:SetScript("OnClick", frame.options.OnClick or function() end)
  return frame
end
