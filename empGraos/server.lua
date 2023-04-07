 local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("empGraos",src)
vCLIENT = Tunnel.getInterface("empGraos")

vRP._prepare("sallyencia/InfosEmpregoGraos", "SELECT * FROM empregos_graos WHERE user_id = @user_id")
vRP._prepare("sallyencia/InsertEmpregoGraos", "INSERT INTO empregos_graos(user_id, rc, level, exp) VALUES(@user_id, @rc, @level, @exp)") 
--vRP._prepare("sallyencia/UpdateEXPGraos", "UPDATE empregos_graos SET user_id = @user_id, exp = exp + @exp") 
--vRP._prepare("sallyencia/UpdateEXP2Graos", "UPDATE empregos_graos SET user_id = @user_id,level = level + @level, exp = @exp") 
--vRP._prepare("sallyencia/UpdateEXP3Graos", "UPDATE empregos_graos SET user_id = @user_id,rc = rc + @rc") 
vRP._prepare("sallyencia/UpdateEXPGraos","UPDATE empregos_graos SET exp = exp + @exp WHERE user_id = @user_id")
vRP._prepare("sallyencia/UpdateEXP2Graos", "UPDATE empregos_graos SET level = level + @level, exp = @exp WHERE user_id = @user_id") 
vRP._prepare("sallyencia/UpdateEXP3Graos", "UPDATE empregos_graos SET rc = rc + @rc WHERE user_id = @user_id") 

vRP._prepare("sallyencia/empregos_graos", [[
    CREATE TABLE IF NOT EXISTS empregos_graos(
        user_id INTEGER,
		rc INTEGER,
        level INTEGER,
        exp INTEGER,
        PRIMARY KEY (`user_id`) USING BTREE
    )
]])


-- CHECK 
-----------------------------------------------------------------------------------------------------------------------------------------
src.checkItem = function()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id,"cnh") >= 1 then
			return true 
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui Habilitação.") 
			return false
		end
	end
end

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn)
    local source = source
    local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
    if user_id then
		
        	local infos = vRP.query("sallyencia/InfosEmpregoGraos", {
            	user_id = parseInt(user_id)
        	})

        	if infos[1] == nil then

            vRP.query("sallyencia/InsertEmpregoGraos", {
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
		local player = vRP.query("sallyencia/InfosEmpregoGraos", {user_id = user_id})
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

-- src.checkItem = function()
	-- local source = source
	-- local user_id = vRP.getUserId(source)
    -- if user_id then
        -- return true
    -- end
-- end

src.pagar = function(dinheiro_recebido)
    local source = source
	local user_id = vRP.getUserId(source)
	local quantidade = 2
	if user_id then
        local player = vRP.query("sallyencia/InfosEmpregoGraos", {user_id = user_id})
        local dinheiro = dinheiro_recebido*player[1].level
	    vRP.giveInventoryItem(user_id,"dinheiro",parseInt(dinheiro))
		vRP.giveInventoryItem(user_id,"trigo",quantidade)
		TriggerClientEvent("Notify",source,"sucesso","Você coletou 2x TRIGO.",5000)
		TriggerClientEvent("Notify",source,"sucesso","Você recebeu <b>$"..vRP.format(parseInt(dinheiro)).." dólares</b>.",5000)
        return dinheiro
	end
end

src.addRota = function()
    local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local player = vRP.query("sallyencia/InfosEmpregoGraos", {user_id = user_id})

        vRP.query("sallyencia/UpdateEXP3Graos", {
            user_id = user_id,
            rc = 1,
        })

	end
end



src.GetEXP = function(exp_ganho)
    local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
        local player = vRP.query("sallyencia/InfosEmpregoGraos", {user_id = user_id})

        if player[1].exp >= exp_por_level and player[1].level < 5 then
            vRP.query("sallyencia/UpdateEXP2Graos", {
                user_id = user_id,
                level = 1,
                exp = 0,
            })
            TriggerClientEvent("Notify",source,"importante","Parabens voce upou de level agora voce e level <b>$"..player[1].level.."</b>.",2000)
        else
            vRP.query("sallyencia/UpdateEXPGraos", {
                user_id = user_id,
                exp = exp_ganho,
            })
        end
	end
end
