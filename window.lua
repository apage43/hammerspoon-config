local prefix = require("prefix")
local utils = require("utils")

hs.window.animationDuration = 0

----------------
-- Focus
----------------

local function focusTerm ()
    local termApp = hs.application.find('iTerm')
    if termApp == nil then
        return
    end
    local termWin = termApp:mainWindow()
    if termWin ~= nil then
        termWin:focus(true)
        termWin:move({0, 0, 1, 1})
    end
end

local function focusChrome ()
    local app = hs.application.find('Google Chrome')
    if app == nil then
        return
    end
    local win = app:mainWindow()
    if win ~= nil then
        win:focus(true)
        win:move({1/6, 0, 2/3, 1})
    end
end

prefix.bind('', 'f1', focusTerm)
prefix.bind('', 'f2', focusChrome)
----------------
-- Grid
----------------
hs.grid.setGrid('6x4', nil, nil)
hs.grid.setMargins({0, 0})
hs.grid.ui.fontName = 'Menlo'
hs.grid.ui.textSize = 120
hs.grid.ui.selectedColor = {0.2,0.8,0,0.8}
hs.grid.ui.highlightColor = {0.5,0.8,0,0.8}
prefix.bind('', 'g', function() hs.grid.show() end)

----------------
-- Switch
----------------
hs.hints.hintChars = utils.strToTable('ASDFGQWERTZXCVB12345')
prefix.bind('', 'w', function() hs.hints.windowHints() end)

local switcher = hs.window.switcher.new(nil, {
    fontName = "Input Sans",
    textSize = 16,
    textColor = { white = 0, alpha = 1 },
    highlightColor = { white = 0.5, alpha = 0.3 },
    backgroundColor = { white = 0.95, alpha = 0.9 },
    titleBackgroundColor = { white = 0.95, alpha = 0 },
    showThumbnails = false,
    showSelectedThumbnail = false,
})

local function nextWindow()
    switcher:next()
end

local function previousWindow()
    switcher:previous()
end

hs.hotkey.bind('alt', 'tab', nextWindow, nil, nextWindow)
hs.hotkey.bind('alt-shift', 'tab', previousWindow, nil, previousWindow)

----------------
-- resize & move
----------------
local arrowKeys = {'a', 'l', 'n', 'f', '1', '2', '3'}

local rectMap = {
    -- left 2/3
    ['a'] = {0, 0, 2/3, 1},
    -- left 2/3
    ['l'] = {1/3, 0, 2/3, 1},
    -- center 2/3
    ['n'] = {1/6, 0, 2/3, 1},
    -- center 2/3 & top 2/3
    ['f'] = {1/6, 0, 2/3, 2/3},
    -- left 1/3
    ['1'] = {0, 0, 1/3, 1},
    -- center 1/3
    ['2'] = {1/3, 0, 1/3, 1},
    -- right 1/3
    ['3'] = {2/3, 0, 1/3, 1},
}
local wasPressed = {false, false, false, false}
local pressed = {false, false, false, false}

local function resizeWindow()
    for i = 1, #pressed do
        if pressed[i] then
            return
        end
    end

    local win = hs.window.focusedWindow()
    if win ~= nil then
        local keys = ''
        for i = 1, #wasPressed do
            if wasPressed[i] then
                keys = keys .. arrowKeys[i]
                wasPressed[i] = false
            end
        end
        local rect = rectMap[keys]
        if rect ~= nil then
            win:move(rect)
        elseif keys == 'jk' then
            win:centerOnScreen()
        end
    end
    -- prefix.exit()
end

for i = 1, #arrowKeys do
    local pressedFn = function()
        wasPressed[i] = true
        pressed[i] = true
    end
    local releasedFn = function()
        pressed[i] = false
        resizeWindow()
    end
    prefix.bindMultiple('', arrowKeys[i], pressedFn, releasedFn, nil)
end

prefix.bind('', 'space', function()
	win = hs.window.focusedWindow()
	if win ~= nil then
		win:move({0, 0, 1, 1})
	end
end)

-- prefix + 0 -> move window to the next screen

local function getNextScreen(s)
    all = hs.screen.allScreens()
    for i = 1, #all do
        if all[i] == s then
            return all[(i - 1 + 1) % #all + 1]
        end
    end
    return nil
end

local function moveToNextScreen()
    local win = hs.window.focusedWindow()
    if win ~= nil then
        currentScreen = win:screen()
        nextScreen = getNextScreen(currentScreen)
        if nextScreen then
            win:moveToScreen(nextScreen)
        end
    end
end

prefix.bind('', '0', moveToNextScreen)
