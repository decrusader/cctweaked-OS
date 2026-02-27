-- Sla dit op als /startup.lua
local w, h = term.getSize()

-- 1. Animatie (3 seconden)
local function startAnimatie()
    local tekens = {"/", "-", "\\", "|"}
    local eindTijd = os.clock() + 3
    local i = 1
    while os.clock() < eindTijd do
        term.clear()
        term.setCursorPos(w/2 - 5, h/2)
        term.setTextColor(colors.gold)
        print("Laden " .. tekens[i])
        i = i % #tekens + 1
        sleep(0.1)
    end
end

-- 2. Menu Tekenen
local function tekenMenu()
    term.setBackgroundColor(colors.gray)
    term.clear()
    
    -- Knop 1: Programma A
    term.setCursorPos(2, 4)
    term.setBackgroundColor(colors.blue)
    term.write(" [ Programma A ] ")
    
    -- Knop 2: Nieuw Bestand
    term.setCursorPos(2, 8)
    term.setBackgroundColor(colors.green)
    term.write(" [ Nieuw Script ] ")
    
    term.setBackgroundColor(colors.gray)
    term.setCursorPos(2, 2)
    print("Welkom, Gebruiker (Touch)")
end

-- 3. Hoofdprogramma
startAnimatie()
while true do
    tekenMenu()
    local event, side, x, y = os.pullEvent("mouse_click")
    
    if y == 4 and x >= 2 and x <= 18 then
        shell.run("hello") -- Vervang door jouw programma
    elseif y == 8 and x >= 2 and x <= 18 then
        term.clear()
        term.setCursorPos(1,1)
        print("Bestandsnaam:")
        local naam = read()
        shell.run("edit", naam)
    end
end
