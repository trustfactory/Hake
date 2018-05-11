local Blocker = {}

local creep_melee_collision_size = 16
local key = Menu.AddKeyOption({"Utility"}, "[Bot] CreepBlock", Enum.ButtonCode.KEY_SPACE)
Blocker.skipRangedCreep = Menu.AddOption({ "Utility", "[Bot] Skip ranged creep" }, "Enabled", "Bot will try to skip ranged creep.")

local last_stop = 0
local sleep = 0

function Blocker.OnGameStart()
	last_stop = 0
	sleep = 0
end

function Blocker.OnDraw()
	if not Menu.IsKeyDown(key) then
		return false
	end

	local myHero = Heroes.GetLocal()
	if not myHero or not Entity.IsAlive(myHero) then return end
	local hero_collision_size = NPC.GetHullRadius(myHero)
	local radius = 500

	local creeps = NPC.GetUnitsInRadius(myHero, radius, Enum.TeamType.TEAM_FRIEND)
	local origin = Entity.GetAbsOrigin(myHero)

	local best_position = nil
	local best_distance = 99999

	local curtime = GameRules.GetGameTime()

	for i, npc in ipairs(creeps) do
		if NPC.IsCreep(npc) and not Entity.IsDormant(npc) and Entity.IsAlive(npc) then -- and not Entity.IsTurning(npc)
			local npc_id = Entity.GetIndex(npc)
			local creep_origin = Entity.GetAbsOrigin(npc)

			local x, y = Renderer.WorldToScreen(creep_origin)
			Renderer.SetDrawColor(255, 255, 255, 255)
			Blocker.DrawCircle(creep_origin, creep_melee_collision_size, 90)

			local moves_to = Blocker.GetPredictedPosition(npc, 0.74)

			if NPC.IsRunning(npc) and (not Menu.IsEnabled(Blocker.skipRangedCreep) or not NPC.IsRanged(npc)) then
				local x2, y2 = Renderer.WorldToScreen(moves_to)
				Renderer.DrawLine(x, y, x2, y2)

				local distance = (origin - creep_origin):Length()
				distance = distance - hero_collision_size

				if distance <= best_distance then
					best_position = moves_to
					best_distance = distance
				end
			end
		end
	end

	if best_position then
		if curtime > sleep then
			Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, myHero, best_position, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY)
		end
		local dist = (best_position - origin):Length()
		local speed = NPC.GetMoveSpeed(myHero)
		if curtime > last_stop and dist >= 10 and (dist <= 150 and speed <= 300 or dist <= 190 and speed <= 325 or dist <= 200 and speed > 325) then
			last_stop = curtime + 0.30 * 315 / speed
			sleep = curtime + 0.05 * 315 / speed
			Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_STOP, myHero, best_position, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_HERO_ONLY)
		end
	end
end

-- return predicted position
function Blocker.GetPredictedPosition(npc, delay)
	local pos = Entity.GetAbsOrigin(npc)
	if not NPC.IsRunning(npc) or not delay then return pos end
	local totalLatency = (NetChannel.GetAvgLatency(Enum.Flow.FLOW_INCOMING) + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING)) -- * 2 -- this may fix bot is not stopping at high ping
	delay = delay + totalLatency

	local dir = Entity.GetRotation(npc):GetForward():Normalized()
	local speed = NPC.GetMoveSpeed(npc)

	return pos + dir:Scaled(speed * delay)
end

function Blocker.DrawCircle(UnitPos, radius, degree)
	local x, y, visible = Renderer.WorldToScreen(UnitPos + Vector(0, radius, 0))
	if visible == 1 then
		for angle = 0, 360 / degree do
			local x1, y1 = Renderer.WorldToScreen(UnitPos + Vector(0, radius, 0):Rotated(Angle(0, angle * degree, 0)))
			Renderer.DrawLine(x, y, x1, y1)
			x, y = x1, y1
		end
	end
end

return Blocker