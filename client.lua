--www.atomgaming.net | by neux#8720

local screenW, screenH = guiGetScreenSize()
local iftarVakti
local fullMetin
local gettok = gettok
local panel = {
    button = {},
    window = {},
    combobox = {},
    label = {}
}
addEvent( "iftarVakti:PanelAc", true )
addEvent( "İftarVakti:VeriGeldi", true )

function PaneliAc()
	guiSetVisible( panel.window[1], true )
	showCursor(true)
end	
addEventHandler( "iftarVakti:PanelAc", root, PaneliAc )

function VeriGeldi(vakitS)
    iftarVakti = vakitS
    if iftarVakti == nil or type(iftarVakti) ~= "table" then return outputChatBox("[!] #ffffffİftar sayacı siteden veri çekemiyor. Lütfen Kurucuya bunu bildir.", 255, 0, 0, true) end 
    addEventHandler("onClientRender", root, SayacGoster)
end	
addEventHandler( "İftarVakti:VeriGeldi", root, VeriGeldi )

addEventHandler("onClientResourceStart", resourceRoot,
    function()
        panel.window[1] = guiCreateWindow((screenW - 240) / 2, (screenH - 200) / 2, 240, 200, "Atom Gaming İftar Sayacı Sistemi", false)
        panel.combobox[1] = guiCreateComboBox(10, 30, 220, 200, "Şehir seç", false, panel.window[1])
        panel.button[2] = guiCreateButton(10, 170, 220, 20, "Kaydet", false, panel.window[1])
        panel.label[1] = guiCreateLabel(10, 80, 220, 60, "Mini haritanın altında, iftara kaç\nsaat kaldığını bu sistem\nsayesinde göreceksin.\nAllah kabul etsin. ~neux", false, panel.window[1])
        guiLabelSetHorizontalAlign(panel.label[1],"center")
        guiSetFont(panel.label[1], "clear-normal")
        guiSetVisible(panel.window[1],false)
        abo = ""
        for i=1, #sehirler do
            guiComboBoxAddItem(panel.combobox[1], sehirler[i])
        end
    end
)

addEventHandler('onClientGUIClick', resourceRoot, 
    function() 
        if (source == panel.button[2]) then
            secili = guiComboBoxGetSelected(panel.combobox[1])
            sehir = guiComboBoxGetItemText(panel.combobox[1], secili)
            if secili == -1 then return print("Lütfen bir şehir seçiniz.") end
            triggerServerEvent("İftarVakti:VeriGetir", localPlayer, sehir)
            guiSetVisible( panel.window[1], false )
	        showCursor(false)
        end 
    end 
)

function SayacGoster()
    if not iftarVakti then return end
    SahurIftarHesapla()
    dxDrawText (fullMetin, 24, screenH - 41, screenW, screenH, tocolor ( 0, 0, 0, 255 ), 1.3, "clear-normal" ) --golge
    dxDrawText (fullMetin, 24, screenH - 43, screenW, screenH, tocolor ( 255, 255, 255, 255 ), 1.3, "clear-normal" ) --yazi
end

function SahurIftarHesapla()
    local bugunT, yarinT  = TarihCek()
    local tarih = getRealTime()
    local gun = 86400
    local saatDakika = tarih.hour*3600+tarih.minute*60+tarih.second
    local sahurBugun = strToMinHour(iftarVakti[bugunT][1])
    local sahurYarin = strToMinHour(iftarVakti[yarinT][1])
    local iftar = strToMinHour(iftarVakti[bugunT][2])
    local iftarKalan = iftar-saatDakika
    if iftarKalan<0 then iftarKalan=iftarKalan+gun end
    local sahurKalan = (saatDakika>sahurBugun and sahurYarin or sahurBugun)-saatDakika
    if sahurKalan<0 then sahurKalan=sahurKalan+gun end
    local guncelKalan = iftarKalan<sahurKalan and iftarKalan or sahurKalan
    local metin = iftarKalan<sahurKalan and "İftara " or "Sahurun bitimine "
    fullMetin = metin..""..totime(guncelKalan)
end

function totime(timestamp)
    kalanim = ""
	local timestamp = timestamp - (math.floor(timestamp/86400) * 86400)
	local hours = math.floor(timestamp/3600)
	timestamp = timestamp - (math.floor(timestamp/3600) * 3600)
	local mins = math.floor(timestamp/60)
	local secs = timestamp - (math.floor(timestamp/60) * 60)
    if hours > 0 then 
        kalanim = hours.." saat "
    end
    if mins > 0 then 
        kalanim = kalanim..mins.." dakika "
    end      
    if secs > 0 then 
        kalanim = kalanim..secs.." saniye"
    end       
	return kalanim
end

function strToMinHour(str)
    return gettok(str,1,":")*3600+gettok(str,2,":")*60
end

function TarihCek()
    local t = os.time()
    local bugunT = os.date("%Y-%m-%d",t)
    local yarinT = os.date("%Y-%m-%d",t + 86400)              
    return bugunT, yarinT
end

addCommandHandler("iftar", function(command, parametre)
    if parametre == "ac" then
    if isEventHandlerAdded( 'onClientRender', root, SayacGoster) then return outputChatBox("[!] #ffffffİftar sayacı zaten açık.", 255, 0, 0, true) end
        addEventHandler("onClientRender", root, SayacGoster)
        outputChatBox("[!] #ffffffİftar sayacı açıldı.", 0, 255, 0, true) 
    elseif parametre == "kapat" then
        removeEventHandler("onClientRender", root, SayacGoster)
        outputChatBox("[!] #ffffffİftar sayacı kapatıldı.", 0, 255, 0, true) 
    elseif parametre == "degistir" then 
        if isEventHandlerAdded( 'onClientRender', root, SayacGoster) then
            removeEventHandler("onClientRender", root, SayacGoster)      
        end  
        guiSetVisible( panel.window[1], true )
        showCursor(true)
    else
        outputChatBox("[!] #ffffffLütfen geçerli bir parametre gir. (ac-kapat-degistir)", 255, 0, 0, true)
    end
end, false)


function isEventHandlerAdded( sEventName, pElementAttachedTo, func )
    if type( sEventName ) == 'string' and isElement( pElementAttachedTo ) and type( func ) == 'function' then
        local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
        if type( aAttachedFunctions ) == 'table' and #aAttachedFunctions > 0 then
            for i, v in ipairs( aAttachedFunctions ) do
                if v == func then
                    return true
                end
            end
        end
    end
    return false
end