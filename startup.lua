-- Sla dit op als /startup.lua
local w, h = term.getSize()

-- 1. Animatie (3 seconden)
local function startAnimatie()
    local tekens = {"/", "-", "\\", "|"}
    local eindTijd = os.clock() + 3
    local i = 1
    while os.clock() < eindTijd do
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(w/2 - 5, h/2)
        -- VERBETERING: colors.yellow in plaats van colors.gold
        term.setTextColor(colors.yellow) 
        term.write("Laden " .. tekens[i])
        i = i % #tekens + 1
        sleep(0.1)
    end
end

-- 2. Menu Tekenen
local function tekenMenu()
    term.setBackgroundColor(colors.gray)
    term.clear()
    
    -- Titel
    term.setCursorPos(w/2 - 7, 2)
    term.setTextColor(colors.white)
    term.write("SYSTEM ONLINE")

    -- Knop 1: Programma (Rij 5)
    term.setCursorPos(4, 5)
    term.setBackgroundColor(colors.blue)
    term.setTextColor(colors.white)
    term.write(" [ START PROGRAMMA ] ")
    
    -- Knop 2: Nieuw Bestand (Rij 8)
    term.setCursorPos(4, 8)
    term.setBackgroundColor(colors.green)
    term.write(" [ NIEUW SCRIPT    ] ")
end

-- 3. Hoofdprogramma
startAnimatie()
while true do
    tekenMenu()
    local event, side, x, y = os.pullEvent("mouse_click")
    
    -- Check of er op de blauwe knop is geklikt (Rij 5)
    if y == 5 and x >= 4 and x <= 24 then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        shell.run("hello") -- Verander "hello" in jouw bestandsnaam
        print("\nPress any key to return...")
        os.pullEvent("key")

    -- Check of er op de groene knop is geklikt (Rij 8)
    elseif y == 8 and x >= 4 and x <= 24 then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        term.setTextColor(colors.yellow)
        write("Naam van nieuw script: ")
        local naam = read()
        if naam ~= "" then
            shell.run("edit", naam)
        end
    end
end
