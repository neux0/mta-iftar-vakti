-- iftar sayacı by neux#8720

function ScriptBaslayinca()
    for k, player in ipairs(getElementsByType("player")) do
        hesap = getPlayerAccount(player)
        if not isGuestAccount(hesap) then
            BilgiCek(player)      
        end
    end
end
addEventHandler("onResourceStart", resourceRoot, ScriptBaslayinca)

addEvent("İftarVakti:VeriGetir", true)
addEventHandler("İftarVakti:VeriGetir", root, function( sehirAdi)
    bugunT, yarinT, yarininYariniT = TarihCek()
    sehir = sehirAdi
    setAccountData(getPlayerAccount(client), "yasadigiSehir", sehir)
    fetchRemote ( "https://namaz-vakti.vercel.app/api/timesFromPlace?country=Turkey&region="..sehir.."&city="..sehir.."&date="..bugunT.."&days=3&timezoneOffset=180", callBack, "", false, client, bugunT, yarinT, yarininYariniT)
end)

addEventHandler("onPlayerLogin", root, function(_, hesap)
    BilgiCek(source)
end)

function callBack(responseData, errorCode, playerToReceive, bugunT, yarinT, yarininYariniT)
    if errorCode == 0 then
        tablem = fromJSON(responseData)
        vakit = {
            [""..bugunT..""] = {tablem["times"][bugunT][1],tablem["times"][bugunT][5]},
            [""..yarinT..""] = {tablem["times"][yarinT][1],tablem["times"][yarinT][5]},
            [""..yarininYariniT..""] = {tablem["times"][yarininYariniT][1],tablem["times"][yarininYariniT][5]},
        }
    else
        vakit = "hata"
    end
    triggerClientEvent (playerToReceive, "İftarVakti:VeriGeldi", playerToReceive, vakit)
end
--www.atomgaming.net
function BilgiCek(oyuncu)
    data = getAccountData(getPlayerAccount(oyuncu), "yasadigiSehir")
    if data then 
        bugunT, yarinT, yarininYariniT = TarihCek()
        sehir = data
        fetchRemote ( "https://namaz-vakti.vercel.app/api/timesFromPlace?country=Turkey&region="..sehir.."&city="..sehir.."&date="..bugunT.."&days=3&timezoneOffset=180", callBack, "", false, oyuncu, bugunT, yarinT, yarininYariniT)
    else
        triggerClientEvent(oyuncu, "iftarVakti:PanelAc", oyuncu)
    end
end

function TarihCek()
    local t = os.time()
    local bugunT = os.date("%Y-%m-%d",t)
    local yarinT = os.date("%Y-%m-%d",t + 86400) 
    local yarininYariniT = os.date("%Y-%m-%d",t + 172800)        
    return bugunT, yarinT, yarininYariniT
end
