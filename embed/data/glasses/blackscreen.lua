function onCreate()
    makeLuaSprite('blackscreen', '')
    makeGraphic('blackscreen', 1280, 720, '000000')
    setObjectCamera('blackscreen', 'hud')
    addLuaSprite('blackscreen', true)
    doTweenAlpha('bs-invis', 'blackscreen', 0, 0.01, 'linear')
end

function onStepHit()
    if curStep == 1440 then
        doTweenAlpha('bs', 'blackscreen', 0.6, 4, 'linear') 
    elseif curStep == 1472 then
        doTweenAlpha('bs_', 'blackscreen', 1, 0.01, 'linear') 
    end
end