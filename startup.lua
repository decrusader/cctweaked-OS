local w, h = term.getSize()
local blacklist = {["startup.lua"]=true, ["rom"]=true, ["installatie_klaar"]=true}
local verwijderModus = false

-- 1. CONFIGURATIE: Voeg hier je favoriete programma's toe
-- Formaat: { "bestandsnaam", "directe_link_naar_raw_github_bestand" }
local installatieLijst = {
    { "inventory_scan", "https://pastebin.com/raw/example1" },
    { "quarry_script", "https://raw.githubusercontent.com/user/repo/main/miner.lua" }
}

-- 2. INSTALLATIE FUNCTIE (Draait alleen de eerste keer)
local function checkInstallatie()
    if not fs.exists("installatie_klaar") then
        term.clear()
        term.setCursorPos(1, 1)
        term.setTextColor(colors.yellow)
        print("Systeem voor de eerste keer opstarten...")
        print("Bezig met downloaden van basis-apps...")

        for _, item in ipairs(installatieLijst) do
            local naam, url = item[1], item[2]
            write("Downloaden: " .. naam .. "... ")
            
            local response = http.get(url)
            if response then
                local file = fs.open(naam, "w")
                file.write(response.readAll())
                file.close()
                response.close()
                print("OK")
            else
                print("FOUT")
            end
        end
        
        -- Maak een marker-bestand zodat dit niet elke keer gebeurt
        local f = fs.open("installatie_klaar", "w")
        f.write("klaar")
        f.close()
        print("\nInstallatie voltooid! Starten...")
        sleep(2)
    end
end

-- 3. ANIMATIE
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

-- 4. MENU TEKENEN
local function tekenMenu()
    term.setBackgroundColor(colors.gray)
    term.clear()
    
    term.setCursorPos(w/2 - 7, 1)
    term.setTextColor(colors.white)
    term.write("GEMINI OS v2.0")

    -- KNOPPEN RIJ
    term.setCursorPos(2, 3)
    term.setBackgroundColor(colors.green)
    term.setTextColor(colors.black)
    term.write(" [+] NIEUW ")

    term.setCursorPos(12, 3)
    term.setBackgroundColor(colors.purple)
    term.setTextColor(colors.white)
    term.write(" [ GITHUB ] ")

    term.setCursorPos(w - 7, 3)
    term.setBackgroundColor(verwijderModus and colors.orange or colors.red)
    term.write(" [ X ] ")

    -- BESTANDEN LIJST
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    term.setCursorPos(2, 5)
    term.write(verwijderModus and "VERWIJDER MODUS:" or "Mijn Apps:")

    local files = fs.list("/")
    local yPos = 6
    local fileMap = {}

    for _, file in ipairs(files) do
        if not blacklist[file] then
            term.setCursorPos(4, yPos)
            term.setBackgroundColor(verwijderModus and colors.red or colors.blue)
            term.write(" " .. file .. " ")
            fileMap[yPos] = file
            yPos = yPos + 2
            if yPos > h - 1 then break end
        end
    end
    return fileMap
end

-- 5. HOOFDPROGRAMMA
if not http then
    print("Error: HTTP moet aanstaan in de server config!")
    return
end

checkInstallatie()
startAnimatie()

while true do
    local fileMap = tekenMenu()
    local event, side, x, y = os.pullEvent("mouse_click")
    
    -- Nieuw Script
    if y == 3 and x >= 2 and x <= 10 then
        term.setBackgroundColor(colors.black); term.clear(); term.setCursorPos(1,1)
        write("Naam: "); local n = read()
        if n ~= "" then shell.run("edit", n) end

    -- GitHub Import
    elseif y == 3 and x >= 12 and x <= 22 then
        term.setBackgroundColor(colors.black); term.clear(); term.setCursorPos(1,1)
        term.setTextColor(colors.purple)
        print("-- GITHUB IMPORT --")
        write("Bestandsnaam: "); local n = read()
        write("Raw URL: "); local u = read()
        
        local res = http.get(u)
        if res then
            local f = fs.open(n, "w")
            f.write(res.readAll())
            f.close()
            res.close()
            print("Succesvol gedownload!")
        else
            print("Download mislukt. Controleer URL.")
        end
        sleep(2)

    -- Prullenbak
    elseif y == 3 and x >= w-7 then
        verwijderModus = not verwijderModus

    -- Bestand Actie
    elseif fileMap[y] and x >= 4 then
        local f = fileMap[y]
        if verwijderModus then
            fs.delete(f)
            verwijderModus = false
        else
            term.setBackgroundColor(colors.black); term.clear(); term.setCursorPos(1,1)
            shell.run(f)
            print("\nKlaar. Klik/Toets..."); os.pullEvent()
        end
    end
end
