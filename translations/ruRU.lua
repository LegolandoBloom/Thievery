--Translator: ZamestoTV
if (GAME_LOCALE or GetLocale()) ~= "ruRU" then
  return
end

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

T["Play Sound Effect"] = "Воспроизвести звуковой эффект"
T["When checked, plays a sound effect when the pickpocket key is pressed"] = "Если отмечено, воспроизводится звуковой эффект при нажатии клавиши обшаривания карманов"
T["Enable Sap"] = "Включить оглушение"
T["Cast sap before pick pocket, with the same keybind."] = "Применить оглушение перед обшариванием карманов с той же привязкой клавиши."
T["Debug Mode"] = "Режим отладки"
T["The next key you press will be set as the Thievery key"] = "Следующая нажатая вами клавиша будет\nустановлена как клавиша Thievery"
T["Awaiting additional key press. Modifier key down: "] = "Ожидается дополнительное нажатие клавиши.\nМодификатор нажат: "
T["Thievery Keybind"] = "Привязка клавиши\nThievery"

T["Reset"] = "Сброс"
T["Change Visual Location"] = "Изменить визуальное расположение"

T["After pressing the button, drag the blue highlighted frame anywhere on your screen and click \'Okay\'."
.. "\n\nClicking the button again, or clicking the reset icon " 
.. "to the top-right of the highlighted frame will reset the visual to its default position."] = "После нажатия кнопки перетащите " 
.. colorBlu:WrapTextInColorCode("синюю выделенную рамку ") .. "в любое место на экране и нажмите " 
.. colorYello:WrapTextInColorCode("\'ОК\'") .. ".\n\nПовторное нажатие кнопки или нажатие на " 
.. colorYello:WrapTextInColorCode("иконку сброса ") 
.. "в правом верхнем углу выделенной рамки вернёт визуальный элемент в его положение по умолчанию."

T["Speedy Mode"] = colorPurple:WrapTextInColorCode("С") .. colorPink:WrapTextInColorCode("к") .. colorTeal:WrapTextInColorCode("о") .. colorOrange:WrapTextInColorCode("р")
.. colorGreen:WrapTextInColorCode("о") .. colorDarkBlu:WrapTextInColorCode("с") .. colorPurple:WrapTextInColorCode("т") .. colorPink:WrapTextInColorCode("н")
.. colorTeal:WrapTextInColorCode("о") .. colorOrange:WrapTextInColorCode("й")

T["Turns on soft targetting for enemies(if off) and auto-loot(if off) upon first pick-pocket, then keeps it on as long as you are stealthed. Zip from pocket to pocket!"] = "Включает:\n" 
.. colorYello:WrapTextInColorCode("Включает мягкое наведение на врагов") .. colorGrae:WrapTextInColorCode("(если выключено)\n") .. "и\n" .. colorYello:WrapTextInColorCode("Автосбор лута") 
.. colorGrae:WrapTextInColorCode("(если выключено)\n") .. "при первом обшаривании карманов,\nзатем оставляет включённым, пока вы находитесь в " .. colorGrae:WrapTextInColorCode("[режиме скрытности] ") .. ".\n\nМолниеносно перемещайтесь от кармана к карману!"

T["Pickpocket"] = "Pickpocket"
T["Sap"] = "Sap"


-- Full Release Additions
T["Visual Scale"] = "Visual Scale"

T["Right-Click Lockpicking"] = "Right-Click Lockpicking"
T["Right-Click Lockboxes in your inventory to unlock them!"] = "Right-Click Lockboxes in your inventory to unlock them!"

T["Play Animation"] = "Play Animation"
T["Plays a hand-drawn lockpicking animation overlayed on the lockboxes when casting \'Pick Lock\'."] = "Plays a hand-drawn lockpicking animation overlayed on the lockboxes when casting \'Pick Lock\'."

T["Sound Effect"] = "Sound Effect"
T["Plays a lockpicking sound effect when you successfully unlock a lockbox."] = "Plays a lockpicking sound effect when you successfully unlock a lockbox."
