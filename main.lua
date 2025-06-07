-- main.lua
ventName = nil

local chatHistory = {}
local userInput = ""

insultS = require 'phrasal.self.insult'

hello = require 'phrasal.hello'
vent = require 'phrasal.vent'
delve = require 'phrasal.delve'
insult = require 'phrasal.insult'
apology = require 'phrasal.apology'
emphasis = require 'phrasal.emphasis'
agree = require 'phrasal.agree'
mylove = require 'phrasal.love'
hate = require 'phrasal.hate'
kiss = require 'phrasal.kiss'
laugh = require 'phrasal.laugh'

comfort = require 'phrasal.comfort'
encourage = require 'phrasal.encourage'
regret = require 'phrasal.regret'
fear = require 'phrasal.fear'
doubt = require 'phrasal.doubt'
frustration = require 'phrasal.frustration'
sadness = require 'phrasal.sadness'
loneliness = require 'phrasal.loneliness'
overwhelmed = require 'phrasal.overwhelmed'
reminisce = require 'phrasal.reminisce'
question = require 'phrasal.question'
deflect = require 'phrasal.deflect'
grateful = require 'phrasal.grateful'
hope = require 'phrasal.hope'
sarcasm = require 'phrasal.sarcasm'

local selfResponse = {insultS}
local mainResponse = {
    apology, hello, delve, insult, emphasis, vent, agree, mylove, hate, kiss,
    laugh, comfort, encourage, regret, fear, doubt, frustration, sadness,
    loneliness, overwhelmed, question, reminisce, deflect, grateful, hope,
    sarcasm
}
local botResponses = mainResponse
local listeningResponses = require 'lr'
local mode = "listen"
local gender = "male"
ventName = nil

local font = love.graphics.newFont(14)
local inputFont = love.graphics.newFont(14)
local chatWidth = 400
local chatPadding = 10
local bubblePadding = 8
local scrollOffset = 0
local totalChatHeight = 0
local maxScrollOffset = 0
local timeToType = 0.3
local currentTime = 0
local sendResp = false
local incompleteResps = 0
local resp = ""

local flyingText = {}
local slashLines = {}

-- Add a profile picture and name
local profilePicture = nil
local chatName = "USER"
local headerHeight = 60 -- Height of the header
local profileImageHeight = 40 -- Desired height of the profile image
function love.load()
    love.graphics.setFont(font)
    love.window.setMode(chatWidth + 2 * chatPadding, 600)

    -- Load a placeholder profile picture
    profilePicture = love.graphics.newImage("profile.png") -- Replace with your image path
end

function love.update(dt)
    if sendResp then
        currentTime = currentTime + 1 * dt
        if currentTime > timeToType * 3 then
            chatHistory[#chatHistory] = {sender = "bot", text = resp}
            sendResp = false
            currentTime = 0
            resp = ""
        elseif currentTime > timeToType * 2 then
            chatHistory[#chatHistory] = {sender = "bot", text = "..."}
        elseif currentTime > timeToType then
            chatHistory[#chatHistory] = {sender = "bot", text = ".."}
        end
    end


        for i, tab in pairs(flyingText) do
            tab.y = tab.y - 200 * dt
        
            -- Ensure each tab has a rotation speed
            tab.rotation = (tab.rotation or 0) + (tab.rotationSpeed or 6) * dt
        
            if tab.y < love.graphics:getHeight()/2 then
                table.remove(flyingText, i)
            end

            mx, my = love.mouse.getPosition()

            if mx > tab.x - 10 and mx < tab.x + 10 and my > tab.y - 10 and my < tab.y + 10 then
                table.remove(flyingText, i)
                
            end
        end
        for i = #slashLines, 1, -1 do
            local line = slashLines[i]
        
            -- Calculate the direction vector
            local dx = line.b.x - line.a.x
            local dy = line.b.y - line.a.y
            local distance = math.sqrt(dx * dx + dy * dy)
        
            -- Normalize direction and apply speed
            if distance > 0 then
                local speed = 200  -- Adjust this speed value as needed
                local dirX = dx / distance
                local dirY = dy / distance
        
                -- Move the line's start point diagonally
                line.a.x = line.a.x + dirX * speed * dt
                line.a.y = line.a.y + dirY * speed * dt
            end
        
            print(line.a.x, line.a.y)
        
            -- Remove line when it reaches the destination
            if math.abs(line.a.x - line.b.x) < 1 and math.abs(line.a.y - line.b.y) < 1 then
                table.remove(slashLines, i)
            end
        end
        
        
end

function love.draw()
    -- Draw chat background
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.rectangle("fill", 0, 0, chatWidth + 2 * chatPadding,
                            love.graphics.getHeight())

    -- Draw chat history
    love.graphics.setColor(1, 1, 1)
    local y = love.graphics.getHeight() - 50 - chatPadding + scrollOffset
    for i = #chatHistory, 1, -1 do
        local message = chatHistory[i]
        local textWidth = font:getWidth(message.text)
        local textHeight = font:getHeight()
        local bubbleWidth = textWidth + 2 * bubblePadding
        local bubbleHeight = textHeight + 2 * bubblePadding

        if message.sender == "user" then
            love.graphics.setColor(0.2, 0.6, 1)
            love.graphics.rectangle("fill",
                                    chatWidth - bubbleWidth + chatPadding,
                                    y - bubbleHeight, bubbleWidth, bubbleHeight,
                                    5)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(message.text, chatWidth - textWidth +
                                    chatPadding - bubblePadding,
                                y - textHeight - bubblePadding)
        else
            love.graphics.setColor(0.8, 0.8, 0.8)
            love.graphics.rectangle("fill", chatPadding, y - bubbleHeight,
                                    bubbleWidth, bubbleHeight, 5)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print(message.text, chatPadding + bubblePadding,
                                y - textHeight - bubblePadding)
        end

        y = y - bubbleHeight - 10
    end
    -- Draw chat header
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, chatWidth + 2 * chatPadding,
                            headerHeight) -- Header height is 60

    -- Calculate scaling factor for the profile image
    local scale = profileImageHeight / profilePicture:getHeight()
    local profileImageWidth = profilePicture:getWidth() * scale

    -- Calculate y position to center the image vertically in the header
    local profileY = (headerHeight - profileImageHeight) / 2

    -- Draw the rounded profile image using a stencil
    love.graphics.stencil(function()
        -- Draw a circle as the stencil mask
        love.graphics.circle("fill", 10 + profileImageWidth / 2,
                             profileY + profileImageHeight / 2,
                             profileImageHeight / 2)
    end, "replace", 1)

    love.graphics.setStencilTest("greater", 0) -- Only draw where the stencil is 1

    -- Draw the profile image (clipped by the stencil)

    love.graphics.setColor(1, 1, 1) -- Reset color to white

    --love.graphics.draw(profilePicture, 10, profileY, 0, scale, scale)

    love.graphics.setStencilTest() -- Disable stencil testing

    -- Draw the chat name next to the profile image
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(chatName, 10 + profileImageWidth + 10,
                        (headerHeight - font:getHeight()) / 2)

    -- Draw input box
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, love.graphics.getHeight() - 50,
                            love.graphics.getWidth(), 50)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(userInput, 10, love.graphics.getHeight() - 40)

    -- Draw scroll indicator
    if totalChatHeight > love.graphics.getHeight() then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", chatWidth + 2 * chatPadding - 10, 0, 10,
                                love.graphics.getHeight())
        local scrollBarHeight = love.graphics.getHeight() *
                                    (love.graphics.getHeight() / totalChatHeight)
        local scrollBarY = (scrollOffset /
                               (totalChatHeight - love.graphics.getHeight())) *
                               (love.graphics.getHeight() - scrollBarHeight)
        love.graphics.setColor(0.2, 0.6, 1)
        love.graphics.rectangle("fill", chatWidth + 2 * chatPadding - 10,
                                scrollBarY, 10, scrollBarHeight)
    end
    for i, v in pairs(flyingText) do
        love.graphics.push() -- Save the current coordinate system
        love.graphics.translate(v.x, v.y) -- Move the origin to the text position
        love.graphics.rotate(v.rotation) -- Apply rotation
        love.graphics.print(v.text, 0, 0) -- Draw at the new origin
        love.graphics.pop() -- Restore the previous coordinate system
    end
    love.graphics.setColor(0,0,0)
    for i, lines in pairs(slashLines) do

        love.graphics.line(lines.a.x, lines.a.y, lines.b.x, lines.b.y) -- Draw at the new origin
    end 
end

function love.textinput(t)   
    table.insert(flyingText, {x = 10 + font:getWidth(userInput), y = love.graphics:getHeight() - 40, rotation = math.random(1,1.2), text = t})
     userInput = userInput .. t
end

function love.keypressed(key)

    if key == "backspace" then
        userInput = userInput:sub(1, -2)
        if string.sub(userInput, -1) ~= " " then
        table.insert(slashLines, {a = {x = 10 + font:getWidth(userInput) + 5, y = love.graphics.getHeight() - 40}, 
                                  b = {x = 10 + font:getWidth(userInput) - 5, y = love.graphics.getHeight() + 25}})
        end
    elseif key == "return" then
        -- Add user input to chat history
        for i = 1, #chatHistory do
            val = chatHistory[i]
            if val.sender == "bot" then
                if val.text == "." or val.text == ".." or val.text == "..." then
                    incompleteResps = incompleteResps + 1
                    print(incompleteResps)
                end
            end
        end
    
        table.insert(chatHistory, {sender = "user", text = userInput})

        -- Check for bot responses based on keywords
        local response = listeningResponses[love.math.random(1, #listeningResponses)]
        userInput = userInput:lower()

        if mode == "listen" then
            local hasAm = userInput:match("%f[%a]am%f[%A]") -- Checks for "am" as a whole word
            local hasI = userInput:match("%f[%a]i%f[%A]") -- Checks for "I" as a whole word
            if hasAm and hasI then
                botResponses = selfResponse
            else
                botResponses = mainResponse
            end

            for index = 1, #botResponses do
                for keywordIndex = 1, #botResponses[index].prompts do
                    local keyword = botResponses[index].prompts[keywordIndex]
                    local cleanKeyword = keyword:gsub("%p", "")
                    
                    local keywordWords = {}
                    for word in cleanKeyword:gmatch("%S+") do
                        table.insert(keywordWords, word:lower())
                    end

                    local userInputWords = {}
                    for word in userInput:gmatch("%S+") do
                        table.insert(userInputWords, word:lower())
                    end

                    local found = true
                    local lastIndex = 0
                    for i, keywordWord in ipairs(keywordWords) do
                        local foundWord = false
                        for j = lastIndex + 1, #userInputWords do
                            local k = 1
                            for char in keywordWord:gmatch(".") do
                                k = userInputWords[j]:find(char, k, true)
                                if not k then
                                    foundWord = false
                                    break
                                end
                                foundWord = true
                            end
                            if foundWord then
                                lastIndex = j
                                break
                            end
                        end
                        if not foundWord then
                            found = false
                            break
                        end
                    end

                    if found then
                        response = botResponses[index].responses[love.math.random(1, #botResponses[index].responses)]
                        if botResponses[index].type == "vent" then
                            mode = "vent"
                        end
                        print(botResponses[index].type)

                        if math.random(1, 3) == 2 and botResponses[index].type == "insult-other" and ventName ~= nil then
                            local nameSe = {
                                ventName .. " right? ",
                                "Oh, about " .. ventName .. "? ",
                                "If it is " .. ventName .. ", ",
                                "You're talking about " .. ventName .. ", right? ",
                                "Oh, you mean " .. ventName .. "?",
                                "Are you referring to " .. ventName .. "? ",
                                "If it’s really " .. ventName .. ", then... ",
                                "Wait, " .. ventName .. "? You mean *that* " .. ventName .. "? ",
                                "Ah, " .. ventName .. "! I was just thinking about that. ",
                                "You mean " .. ventName .. ", don’t you? "
                            }
                            response = nameSe[math.random(1, #nameSe)] .. response
                        end
                        break
                    end
                end
            end
        elseif mode == "vent" then
            ventName = userInput:match("^(%S+)")
            print(ventName)
            mode = "listen"
            response = ventName .. "??"
        end

        -- Simulate typing delay effect
        sendResp = true
        resp = response
        timeToType = string.len(response) * .05
       
        if incompleteResps > 2 then
            timeToType = 0.1
            resp = "LET ME FUCKING SPEAK YOU FAGGOT"
            table.insert(chatHistory, {sender = "bot", text = "."})

        else
        table.insert(chatHistory, {sender = "bot", text = "."})
        end
        -- Clear user input
        userInput = ""

        -- Update scroll offset
        maxScrollOffset = #chatHistory - love.graphics.getHeight()
        if maxScrollOffset < 0 then maxScrollOffset = 0 end
        scrollOffset = maxScrollOffset
    elseif key == "up" then
        scrollOffset = math.max(0, scrollOffset - 20)
    elseif key == "down" then
        scrollOffset = math.min(maxScrollOffset, scrollOffset + 20)
    end
end


function love.wheelmoved(x, y)
    scrollOffset = math.max(0, math.min(maxScrollOffset, scrollOffset + y * 20))
end

function string:split(separator)
    local result = {}
    for match in (self .. separator):gmatch("(.-)" .. separator) do
        table.insert(result, match)
    end
    return result
end
