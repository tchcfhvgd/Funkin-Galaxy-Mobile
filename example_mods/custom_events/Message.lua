-- Event notes hooks
function onEvent(name, value1, value2)
    local var string = (value1)
    local var length = tonumber(0 + value2)
    if name == "Message" then

        makeLuaText('yappin', 'Lyrics go here!', 1200, 64, 250)
        setTextString('yappin',  '' .. string)
        setTextFont('yappin', 'vcr.ttf')
        setTextColor('yappin', '0xffffff')
        setTextSize('yappin', 60);
        setTextBorder('yappin', 5, '40006b')
        addLuaText('yappin')
        setTextAlignment('yappin', 'center')
        setObjectCamera("yappin", 'hud');
        runTimer('lyricalTho', length, 1)
        --removeLuaText('yappin', true)
        
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'lyricalTho' then
        removeLuaText('yappin', true)
    end
end