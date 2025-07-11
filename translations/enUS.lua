Thievery_Translate = {}
local T = Thievery_Translate

local colorYello = CreateColor(1.0, 0.82, 0.0)
local colorGrae = CreateColor(0.85, 0.85, 0.85)
local colorBlu = CreateColor(0.61, 0.85, 0.92)
local colorPurple = CreateColor(0.8, 0, 1)
local colorRed = CreateColor(0.94, 0.06, 0.1)
local colorTeal = CreateColor(0, 1, 0.76)
local colorDarkBlu = CreateColor(0.6, 0.21, 1)
local colorGreen = CreateColor(0, 1, 0.05)
local colorOrange = CreateColor(1, 0.47, 0)
local colorPink = CreateColor(1, 0, 0.6)

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


T["Speedy Mode"] = colorPurple:WrapTextInColorCode("S") .. colorPink:WrapTextInColorCode("p") .. colorTeal:WrapTextInColorCode("e") .. colorOrange:WrapTextInColorCode("e") 
.. colorGreen:WrapTextInColorCode("d") .. colorDarkBlu:WrapTextInColorCode("y") .. colorPurple:WrapTextInColorCode("M") .. colorPink:WrapTextInColorCode("o") 
.. colorTeal:WrapTextInColorCode("d") .. colorOrange:WrapTextInColorCode("e")

T["Turns on soft targetting for enemies(if off) and auto-loot(if off) upon first pick-pocket, then keeps it on as long as you are stealthed. Zip from pocket to pocket!"] = "Turns on:\n" 
.. colorYello:WrapTextInColorCode("Soft Targetting for enemies") .. colorGrae:WrapTextInColorCode("(if off)\n") .. "and\n" .. colorYello:WrapTextInColorCode("Auto-Loot") 
.. colorGrae:WrapTextInColorCode("(if off)\n") .. "upon first pick-pocket,\nthen keeps it on as long as you are " .. colorGrae:WrapTextInColorCode("[stealthed] ") .. ".\n\nZip from pocket to pocket!"

T["Pickpocket"] = "Pickpocket"
T["Sap"] = "Sap"