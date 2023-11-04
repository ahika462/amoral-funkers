function onCreatePost()
	makeLuaSprite('kolodishi', '', -1280, -720)
    makeGraphic('kolodishi', 1280, 720, 'FFFFFF')
    setScrollFactor('kolodishi', 0, 0);
    scaleObject('kolodishi', 3, 3)
    addLuaSprite('kolodishi', false)

    setProperty("gf.visible", 0)
    setTimeBarColors("0xBF000000", "0x59000000")

	close(true);
end