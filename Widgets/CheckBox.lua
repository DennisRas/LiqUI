local C = LiqUI.Config

local CheckBoxDefaults = {
  width = C.control.checkSize,
  height = C.control.checkSize,
  padding = C.control.padding,
  label = nil,
  checked = false,
  OnValueChanged = nil,
}

function LiqUI.Widgets.CreateCheckBox(parent, options)
  local frame = CreateFrame("Button", nil, parent, "BackdropTemplate")
  Mixin(frame, LiqUI.Widgets.BaseMixin)
  frame.options = frame:Init(CheckBoxDefaults, options)

  local checkedTexture = frame:CreateTexture(nil, "OVERLAY")
  checkedTexture:SetPoint("CENTER")
  checkedTexture:SetSize(frame.options.width - 6, frame.options.height - 6)
  checkedTexture:SetTexture("Interface/Buttons/UI-CheckBox-Check")
  checkedTexture:SetVertexColor(1, 1, 1, 1)
  frame.checkedTexture = checkedTexture

  local checked = frame.options.checked and true or false
  local function UpdateVisual()
    if checked then checkedTexture:Show() else checkedTexture:Hide() end
  end
  UpdateVisual()

  if frame.options.label and frame.options.label ~= "" then
    frame.label = LiqUI.Utils.CreateLabel(parent, frame.options.label,
      { point = "RIGHT", relativeTo = frame, relativePoint = "LEFT", x = -frame.options.padding, y = 0 })
    frame.label:SetJustifyH("RIGHT")
  end

  frame:SetScript("OnClick", function()
    checked = not checked
    UpdateVisual()
    if frame.options.OnValueChanged then frame.options.OnValueChanged(checked) end
  end)

  function frame:GetValue()
    return checked
  end

  function frame:SetValue(val)
    checked = val and true or false
    UpdateVisual()
  end

  return frame
end
