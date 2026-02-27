local w, h = term.getSize()

-- Lijst van bestanden die we NIET op het bureaublad willen zien
local blacklist = {["startup.lua"]=true, ["rom"]=true}

-- 1. Animatie
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

-- 2. Menu Tekenen met Bestandenlijst
local function tekenMenu()
    term.setBackgroundColor(colors.gray)
    term.clear()
    
    -- Titel
    term.setCursorPos(w/2 - 7, 1)
    term.setTextColor(colors.white)
    term.write("MIJN COMPUTER")

    -- Knop: Nieuw Script (altijd bovenaan)
    term.setCursorPos(2, 3)
    term.setBackgroundColor(colors.green)
    term.setTextColor(colors.black)
    term.write(" [+] NIEUW SCRIPT ")

    -- Bestanden scannen en tonen
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(2, 5)
    term.write("Programma's:")

    local files = fs.list("/")
    local yPos = 6
    local fileMap = {} -- Om klik-locaties te onthouden

    for _, file in ipairs(files) do
        if not blacklist[file] then
            term.setCursorPos(4, yPos)
            term.setBackgroundColor(colors.blue)
            term.write(" " .. file .. " ")
            
            fileMap[yPos] = file -- Sla op welke file bij welke regel hoort
            yPos = yPos + 2 -- Ruimte tussen knoppen
            if yPos > h - 1 then break end -- Stop als scherm vol is
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
    if y == 3 and x >= 2 and x <= 18 then
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        term.setTextColor(colors.yellow)
        write("Naam van nieuw script: ")
        local naam = read()
        if naam ~= "" then
            shell.run("edit", naam)
        end

    -- Klik op een gegenereerd programma
    elseif fileMap[y] and x >= 4 then
        local gekozenFile = fileMap[y]
        term.setBackgroundColor(colors.black)
        term.clear()
        term.setCursorPos(1,1)
        shell.run(gekozenFile)
        print("\nKlaar. Druk op een toets...")
        os.pullEvent("key")
    end
end
