Thievery_Translate = {}
local T = Thievery_Translate

local colorYello = CreateColor(1.0, 0.82, 0.0)
local colorGrae = CreateColor(0.85, 0.85, 0.85)
local colorBlu = CreateColor(0.61, 0.85, 0.92)

T["Play Sound Effect"] = "Play Sound Effect"
T["When checked, plays a sound effect when the pickpocket key is pressed"] = "When checked, plays a sound effect when the pickpocket key is pressed"
T["Enable Sap"] = "Enable Sap"
T["Cast sap before pick pocket, with the same keybind."] = "Cast sap before pick pocket, with the same keybind."
T["Debug Mode"] = "Debug Mode"
T["The next key you press will be set as the Thievery key"] = "The next key you press will be\nset as the Thievery key"
T["Awaiting additional key press. Modifier key down: "] = "Awaiting additional key press.\nModifier key down: "
T["Thievery Keybind"] = "Thievery Keybind"

T["Reset"] = "Reset"
T["Change Visual Location"] = "Change Visual Location"


T["After pressing the button, drag the blue highlighted frame anywhere on your screen and click \'Okay\'."
.. "\n\nClicking the button again, or clicking the reset icon " 
.. "to the top-right of the highlighted frame will reset the visual to its default position."] = "After pressing the button, drag the " 
.. colorBlu:WrapTextInColorCode("blue highlighted frame ") .. "anywhere on your screen and click " 
.. colorYello:WrapTextInColorCode("\'Okay\'") .. ".\n\nClicking the button again, or clicking the " 
.. colorYello:WrapTextInColorCode("reset icon ") 
.. "to the top-right of the highlighted frame will reset the visual to its default position."
