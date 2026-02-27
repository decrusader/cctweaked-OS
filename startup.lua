local w, h = term.getSize()
local blacklist = {["startup.lua"]=true, ["rom"]=true}
local verwijderModus = false

-- 1. Animatie (3 sec)
local function startAnimatie()
    local tekens = {"/", "-", "\\", "|"}
    local eindTijd = os.clock() + 3
    local i = 1
    while os.clock() < eindTijd do
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(w/2 - 5, h/2)
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
    term.setCursorPos(w/2 - 7, 1)
    term.setTextColor(colors.white)
    term.write("MIJN COMPUTER")

    -- KNOP: Nieuw Script
    term.setCursorPos(2, 3)
    term.setBackgroundColor(colors.green)
    term.setTextColor(colors.black)
    term.write(" [+] NIEUW ")

    -- KNOP: Verwijder Modus (Prullenbak)
    term.setCursorPos(14, 3)
    if verwijderModus then
        term.setBackgroundColor(colors.orange)
        term.write(" [ ANNULEREN ] ")
    else
        term.setBackgroundColor(colors.red)
        term.write(" [ PRULLENBAK ] ")
    end

    -- Bestanden Lijst
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(2, 5)
    term.write(verwijderModus and "Kies om te WISSEN:" or "Programma's:")

    local files = fs.list("/")
    local yPos = 6
    local fileMap = {}

    for _, file in ipairs(files) do
        if not blacklist[file] then
            term.setCursorPos(4, yPos)
            -- Kleur verandert op basis van modus
            term.setBackgroundColor(verwijderModus and colors.red or colors.blue)
            term.setTextColor(colors.white)
            term.write(" " .. file .. " ")
            
            fileMap[yPos] = file
            yPos = yPos + 2
            if yPos > h - 1 then break end
        end
    end
    
    return fileMap
end

-- 3. Hoofdprogramma
startAnimatie()
while true do
    local fileMap = tekenMenu()
    local event, side, x, y = os.pullEvent("mouse_click")
    
    -- Klik op "Nieuw Script"
    if y == 3 and x >= 2 and x <= 11 then
        verwijderModus = false
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        term.setTextColor(colors.yellow)
        write("Naam van nieuw script: ")
        local naam = read()
        if naam ~= "" then shell.run("edit", naam) end

    -- Klik op "Prullenbak / Annuleren"
    elseif y == 3 and x >= 14 and x <= 28 then
        verwijderModus = not verwijderModus

    -- Klik op een bestand in de lijst
    elseif fileMap[y] and x >= 4 then
        local gekozenFile = fileMap[y]
        
        if verwijderModus then
            -- VERWIJDEREN
            fs.delete(gekozenFile)
            verwijderModus = false -- Zet modus uit na verwijderen
        else
            -- UITVOEREN
            term.setBackgroundColor(colors.black)
            term.clear()
            term.setCursorPos(1,1)
            shell.run(gekozenFile)
            print("\nKlaar. Druk op een toets...")
            os.pullEvent("key")
        end
    end
end
