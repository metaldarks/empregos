 local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("empJardineiro",src)
vCLIENT = Tunnel.getInterface("empJardineiro")

vRP._prepare("sallyencia/InfosEmpregoJardineiro", "SELECT * FROM empregos_jardineiro WHERE user_id = @user_id")
vRP._prepare("sallyencia/InsertEmpregoJardineiro", "INSERT INTO empregos_jardineiro(user_id, rc, level, exp) VALUES(@user_id, @rc, @level, @exp)") 
--vRP._prepare("sallyencia/UpdateEXPJardineiro", "UPDATE empregos_jardineiro SET user_id = @user_id, exp = exp + @exp") 
--vRP._prepare("sallyencia/UpdateEXP2Jardineiro", "UPDATE empregos_jardineiro SET user_id = @user_id,level = level + @level, exp = @exp") 
--vRP._prepare("sallyencia/UpdateEXP3Jardineiro", "UPDATE empregos_jardineiro SET user_id = @user_id,rc = rc + @rc") 
vRP._prepare("sallyencia/UpdateEXPJardineiro","UPDATE empregos_jardineiro SET exp = exp + @exp WHERE user_id = @user_id")
vRP._prepare("sallyencia/UpdateEXP2Jardineiro", "UPDATE empregos_jardineiro SET level = level + @level, exp = @exp WHERE user_id = @user_id") 
vRP._prepare("sallyencia/UpdateEXP3Jardineiro", "UPDATE empregos_jardineiro SET rc = rc + @rc WHERE user_id = @user_id") 

vRP._prepare("sallyencia/empregos_jardineiro", [[
    CREATE TABLE IF NOT EXISTS empregos_jardineiro(
        user_id INTEGER,
		rc INTEGER,
        level INTEGER,
        exp INTEGER,
        PRIMARY KEY (`user_id`) USING BTREE
    )
]])

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    local source = source
    local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
    if user_id then
		
        	local infos = vRP.query("sallyencia/InfosEmpregoJardineiro", {
            	user_id = parseInt(user_id)
        	})

        	if infos[1] == nil then

            vRP.query("sallyencia/InsertEmpregoJardineiro", {
                user_id = parseInt(user_id),
                rc = 0,
				level = 1,
				exp = 0,
            })

        end
    end
end)

src.CheckLevel = function()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local player = vRP.query("sallyencia/InfosEmpregoJardineiro", {user_id = user_id})
		return player[1].rc,player[1].level,player[1].exp
	end
end

src.return_dinheiro = function()
	local source = source
	local user_id = vRP.getUserId(source)
    if user_id then
        local dinheiro_jogador = vRP.getMoney(user_id)
        return dinheiro_jogador
    end
end


-- CHECK 
-----------------------------------------------------------------------------------------------------------------------------------------
src.checkItem = function()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id,"pazinha") >= 1 then
			return true 
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui a ferramenta apropriada.") 
			return false
		end
	end
end

src.pagar = function(dinheiro_recebido)
    local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local player = vRP.query("sallyencia/InfosEmpregoJardineiro", {user_id = user_id})
        local dinheiro = dinheiro_recebido*player[1].level
	    vRP.giveInventoryItem(user_id,"dinheiro",parseInt(dinheiro))
		TriggerClientEvent("Notify",source,"sucesso","Você recebeu <b>$"..vRP.format(parseInt(dinheiro)).." dólares</b>.",2000)
        return dinheiro
	end
end

src.addRota = function()
    local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local player = vRP.query("sallyencia/InfosEmpregoJardineiro", {user_id = user_id})

        vRP.query("sallyencia/UpdateEXP3Jardineiro", {
            user_id = user_id,
            rc = 1,
        })

	end
end



src.GetEXP = function(exp_ganho)
    local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local player = vRP.query("sallyencia/InfosEmpregoJardineiro", {user_id = user_id})

        if player[1].exp >= exp_por_level and player[1].level < 5 then
            vRP.query("sallyencia/UpdateEXP2Jardineiro", {
                user_id = user_id,
                level = 1,
                exp = 0,
            })
            TriggerClientEvent("Notify",source,"importante","Parabens voce upou de level agora voce e level <b>$"..player[1].level.."</b>.",2000)
        else
            vRP.query("sallyencia/UpdateEXPJardineiro", {
                user_id = user_id,
                exp = exp_ganho,
            })
        end
	end
end
