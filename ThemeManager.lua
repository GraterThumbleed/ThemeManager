
-- I do use scape's presets I asked and he's fine with it
-- Also the base64 is taken from https://stackoverflow.com/questions/34618946/lua-base64-encode
-- If you use scape's import codes they are compatible with my system and vice versa :)

------------------------------------------------------------------------------- Auto Updater

local version_number = "1.0.0"
local updated = false
local github_ver_num = http.Get("https://raw.githubusercontent.com/GraterThumbleed/ThemeManager/main/version.txt")

if version_number ~= string.gsub(github_ver_num, "\n", "") then
    updated = true
    local github_file = http.Get("https://raw.githubusercontent.com/GraterThumbleed/ThemeManager/main/ThemeManager.lua")
    local curren_file = file.Open(GetScriptName(), "w")
    curren_file:Write(github_file)
    curren_file:Close()
end
--------------------------------------------------------------------------------

file.Open( "ThemeS/urlpresets.txt", "a"):Close()
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end
local files = {} local base = "theme."
local basevars = {"footer.bg","footer.text","header.bg","header.line","header.text","nav.active","nav.bg","nav.shadow","nav.text","tablist.shadow","tablist.tabactivebg","tablist.tabdecorator","tablist.text","tablist.textactive","ui.bg1","ui.bg2","ui.border"} local completevars = {}
for i=1,#basevars do
    table.insert( completevars, base..basevars[i] )
end
local urlthemes = ""
local function getPresetsFromFile()

    local urlthemesfile = file.Open( "ThemeS/urlpresets.txt", "r")
    local urlthemereads = urlthemesfile:Read()
    urlthemesfile:Close()
    local urlthemesfull = ""
    for urlv in urlthemereads:gmatch("[^\r\n]+") do
        if urlv ~= "" or urlv ~= nil or urlv ~= " " then
            local urldata = http.Get( urlv)
            print(http.Get( urlv))
            urlthemesfull = urlthemesfull..urldata
        end
    end
    urlthemes = urlthemesfull
end
local function getSaved()
    files = {}
    file.Enumerate(function(name)
        if string.match( name,"ThemeS/" ) and not string.match( name,"urlpresets.txt" ) then
            name2 = string.gsub( name,"ThemeS/","" )
            table.insert( files, name2 )
        end
    end)
end
local function setTheme(themestring)
    for line in themestring:gmatch("[^\r\n]+") do
        linevars = {}
        for word in line:gmatch("%S+") do
            table.insert( linevars, word)
        end
        if #linevars == 5 then
            gui.SetValue(linevars[1], linevars[2], linevars[3], linevars[4], linevars[5])
        end
    end
end
local ref = gui.Reference("Settings")
local tab = gui.Tab( ref, "theme.manager", "Theme Manager" )
local groupbox = gui.Groupbox( tab, "Theme Saver", 15, 15, 600, 400 )
local name = gui.Editbox( groupbox, "name", "Theme Name" )
local listboxsaved = gui.Listbox( groupbox, "list.saved", 200, "Saved Themes")
local listboxpresets = gui.Listbox( groupbox, "list.presets", 200, "")
listboxsaved:SetPosY(15) listboxpresets:SetWidth(295) listboxsaved:SetWidth(295) name:SetWidth(267) name:SetPosX(305) 
local presetTable = {}
local presetTableNames = {}
local presettext1 = http.Get("https://raw.githubusercontent.com/lennonc1atwit/Luas/master/Theme%20Manager/Presets.txt", print("Got Presets 1") )
local presettext2 = http.Get("https://raw.githubusercontent.com/GraterThumbleed/ThemeManager/main/presets.txt", print("Got Presets 2") )
getPresetsFromFile()
gui.Command("clear")
local presettext3 = presettext1..presettext2..urlthemes
for line in presettext3:gmatch("[^\r\n]+") do
    presettable = {}
    for word in line:gmatch("([^,]+)") do
        word = string.gsub(word, "\"", "")
        table.insert(presettable, word)
    end
    table.insert( presetTable , presettable )
    table.insert( presetTableNames, presettable[1])
end
listboxpresets:SetOptions(unpack(presetTableNames))
local load = gui.Button( groupbox, "Load", function()
    path = ( "ThemeS/"..files[listboxsaved:GetValue()+1] )
    cfgfile = file.Open( path, "r" )
    cfgread = cfgfile:Read()
    cfgfile:Close()
    setTheme(cfgread)
end)
load:SetPosX(305) load:SetPosY(56)
local loadpreset = gui.Button( groupbox, "Load Preset", function()
    setTheme(dec(presetTable[listboxpresets:GetValue()+1][2]))
end)
loadpreset:SetPosX(445) loadpreset:SetPosY(56)
local delete = gui.Button( groupbox, "Delete", function()
    file.Delete("ThemeS/"..files[listboxsaved:GetValue()+1])
    getSaved()
    listboxsaved:SetOptions(unpack(files))
end)
delete:SetPosX(445) delete:SetPosY(144)
local basepath = "ThemeS/"
local save = gui.Button( groupbox, "Save", function()
    local fullstring = ""
    path = ( "ThemeS/"..files[listboxsaved:GetValue()+1] )
    for i=1,#completevars do
        local r,g,b,a = gui.GetValue(completevars[i])
        fullstring = fullstring..completevars[i].." "..r.." "..g.." "..b.." "..a.."\n"
        cfgfile = file.Open( path, "w" )
        cfgfile:Write(fullstring)
        cfgfile:Close()
    end
end)
save:SetPosX(305) save:SetPosY(100)
local create = gui.Button( groupbox, "Create", function()
    local fullstring = ""
    path = ( "ThemeS/"..name:GetValue()..".dat" )
    for i=1,#completevars do
        local r,g,b,a = gui.GetValue(completevars[i])
        fullstring = fullstring..completevars[i].." "..r.." "..g.." "..b.." "..a.."\n"
        cfgfile = file.Open( path, "w" )
        cfgfile:Write(fullstring)
        cfgfile:Close()
    end
    name:SetValue("")
    getSaved()
    listboxsaved:SetOptions(unpack(files))
end)
create:SetPosX(445) create:SetPosY(100)
local refresh = gui.Button( groupbox, "Refresh", function() getSaved() listboxsaved:SetOptions(unpack(files)) end)
refresh:SetPosX(305) refresh:SetPosY(144)
local importcode = gui.Editbox( groupbox, "import", "Import code" )
local import = gui.Button( groupbox, "Import Code", function() setTheme(dec(importcode:GetValue())) end)
local export = gui.Button( groupbox, "Export Code", function()
    local fullstring = ""
    for i=1,#completevars do
        local r,g,b,a = gui.GetValue(completevars[i])
        fullstring = fullstring..completevars[i].." "..r.." "..g.." "..b.." "..a.."\n"
    end
    encodedstring = enc(fullstring)
    print(encodedstring)
end)
importcode:SetWidth(267) importcode:SetPosX(305) 
import:SetPosX(305) import:SetPosY(247)
export:SetPosX(445) export:SetPosY(247)
if updated then
    local updatetext = gui.Text( groupbox, "Updated Lua Reload Please" )
    updatetext:SetPosY(300) updatetext:SetPosX(305)
end
getSaved()
listboxsaved:SetOptions(unpack(files))
