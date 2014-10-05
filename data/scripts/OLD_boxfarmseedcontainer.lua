
function Create()
	Game.DebugOut("boxfarmseedcontainer__create")

	local ourX = Object.GetProperty("Pos.x")
	local ourY = Object.GetProperty("Pos.y")

 	Object.SetProperty("SeedCount", 0.0)
	Object.SetProperty("SeedMaxCount", 120.0)
 	Object.SetProperty("StockType", "Seed")

	Object.SetProperty("IsLoaded", true)

	-- Force show debugger
	Object.SetProperty("Tooltip", 2 + "break")
end



function Update(timePassed)
	if Object.GetProperty("IsLoaded") ~= true then
		Game.DebugOut("--> Not Created")
		Create()
	else
		Game.DebugOut("--> Created")
	end

	Game.DebugOut("Time updated")
	Game.DebugOut(Object.GetProperty("IsLoaded"))
	Game.DebugOut(Object.GetProperty("SeedMaxCount"))

	local SeedCount = tonumber(Object.GetProperty("SeedCount"))
	if SeedCount < 20.0 or SeedCount >= 20 then
		Game.DebugOut('Create restock job')
		Object.CreateJob("RestockBoxfarmSeedContainer")
	end
	--Object.SetProperty("Tooltip", SeedCount)
	Object.SetProperty("Tooltip", SeedCount + "break")
end


function JobComplete_RestockBoxfarmSeedContainer()
	local SeedCount = tonumber(Object.GetProperty("SeedCount"))
	Object.SetProperty("SeedCount", 20.0 + SeedCount)
end


--Object.SetProperty
--Object.GetProperty
--Object.GetMaterial
--Object.CreateJob
--Object.Spawn
--Object.ApplyVelocity
--Object.Delete( Object Name )
--Game.Spawn()
--Game.LoseEquipment()