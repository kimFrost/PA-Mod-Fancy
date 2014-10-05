
function Create()
	Game.DebugOut("boxfarmseedcontainer__create");

	local ourX = Object.GetProperty("Pos.x");
	local ourY = Object.GetProperty("Pos.y");

 	Object.SetProperty("SeedCount", 0.0);
	Object.SetProperty("SeedMaxCount", 120.0);
 	Object.SetProperty("StockType", "Seed");
 	Object.SetProperty("IsRestockPending", false);

	-- Force show debugger
    Game.DebugOut(2 + "break");
end



function T_Update(timePassed)

	Game.DebugOut("Time updated");
	Game.DebugOut(Object.GetProperty("IsLoaded"));
	Game.DebugOut(Object.GetProperty("SeedMaxCount"));

	local SeedCount = tonumber(Object.GetProperty("SeedCount"));
	local IsRestockPending = Object.GetProperty("IsRestockPending");

	if SeedCount < 20.0 or SeedCount >= 20 and IsRestockPending ~= true then
		Game.DebugOut('Create restock job');
		Object.SetProperty("IsRestockPending", true);
		Object.CreateJob("RestockBoxfarmSeedContainer");
	end

	Object.SetProperty("Tooltip", "seedcount: " .. tostring(SeedCount) .. "\n" .. "IsRestockPending: " .. tostring(IsRestockPending));
end


function JobComplete_RestockBoxfarmSeedContainer()
	local SeedCount = tonumber(Object.GetProperty("SeedCount"));
	Object.SetProperty("SeedCount", 20.0 + SeedCount);
	Object.SetProperty("IsRestockPending", false);
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
--Game.Damage
--Game.SendEntityToObject
--Game.Delivery
--Game.Spawn() Usage: Game.Spawn( "Object", "Object_Name", Xpos, Ypos )