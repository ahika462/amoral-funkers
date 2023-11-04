function onCreate()
    makeLuaSprite('blackscreen', '')
    makeGraphic('blackscreen', 1280, 720, '000000')
    setObjectCamera('blackscreen', 'hud')
    addLuaSprite('blackscreen', true)
    doTweenAlpha('bs-invis', 'blackscreen', 0, 0.01, 'linear')
end

function onSongStart()
    setProperty("defaultCamZoom", 0.85)
    doTweenZoom('camz_intro','camGame', 0.85, 10.65,'cubeIn')
end

function onBeatHit()
    if (curBeat >= 32 and curBeat < 96) then
        if curBeat % 4 == 0 or curBeat % 4 == 1 or curBeat % 4 == 3 then
            triggerEvent('Add Camera Zoom', '0.01', '0.01')
        elseif curBeat % 4 == 2 or curbeat % 4 == 3.5 then
            triggerEvent('Add Camera Zoom', '0.02', '0.015')
        end
    end

    if ((curBeat >= 96 and curBeat < 160) or (curBeat >= 288 and curBeat < 320)) and curBeat % 2 == 1 then
        triggerEvent('Add Camera Zoom', '0.025', '0.015')
    end

    if (curBeat >= 168 and curBeat < 188) or (curBeat >= 192 and curBeat < 224) then
        if curBeat % 2 == 0 then
            triggerEvent('Add Camera Zoom', '0.01', '0.02')
        elseif curBeat % 2 == 1 then
            triggerEvent('Add Camera Zoom', '0.02', '0.01')
        end
    end

    if (curBeat >= 224 and curBeat < 256) then
        if curBeat % 2 == 0 then
            triggerEvent('Add Camera Zoom', '0.005', '0.01')
        elseif curBeat % 2 == 1 then
            triggerEvent('Add Camera Zoom', '0.01', '0.01')
        end
    end

    if curBeat == 356 then
        setProperty("defaultCamZoom", 0.4)
        doTweenZoom('camz','camGame', 0.4, 7, 'cubeIn')
    end
end

function onStepHit()
    if curStep == 1288 then
        setProperty("defaultCamZoom", 0.85)
        doTweenZoom('camz','camGame', 0.85, 10, 'cubeIn')
    elseif curStep == 1408 then
        doTweenAlpha('bs', 'blackscreen', 0.4, 6.5, 'linear') 
    elseif curStep == 1488 then
        doTweenAlpha('bs_', 'blackscreen', 1, 0.01, 'linear') 
    end
end