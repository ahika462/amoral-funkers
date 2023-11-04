function onStepHit()
    if curStep == 1472 then
        makeLuaSprite("ok", '')
        makeGraphic("ok", screenWidth, screenHeight, '000000')
        setObjectCamera("ok", "camOther")
        addLuaSprite("ok", true)
    end
end