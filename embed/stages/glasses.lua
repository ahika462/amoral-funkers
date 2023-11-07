function onCreatePost()
    setPropertyFromClass("flixel.FlxG", "camera.bgColor", getColorFromHex("0xFFFFFFFF"))
    setTimeBarColors("0xBF000000", "0x59000000")
end

function onDestroy()
    setPropertyFromClass("flixel.FlxG", "camera.bgColor", getColorFromHex("0xFF000000"))
end