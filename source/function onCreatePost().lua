function onCreatePost()
    local tags = {"songTxt", "diff", "deathCount"}
    local texts = {"Song: " .. songName, "Difficulty: " .. difficultyName, "Blueballed: " .. getPropertyFromClass("states.PlayState", "deathCounter")}
    local xs = {screenWidth - 310, getProperty("songTxt.x"), getProperty("diff.x")}
    local ys = {15, getProperty("songTxt.y") + 40, getProperty("diff.y") + 40}
    
    for i = 1, #tags do
        makeLuaText(tags[i], texts[i], 300, xs[i], ys[i])
        setTextSize(tags[i], 32)
        setTextAlignment(tags[i], "right")
        setObjectCamera(tags[i], "camHUD")
        addLuaText(tags[i])
    end
end