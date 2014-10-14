
function Create()

    local plantTypes = {
        {
            name = "Cabbage",
            minGrowthRate = 0.0,
            maxGrowthRate = 2.0,
            spawnObjName = "BoxfarmCabbage",
            spawnNumber = 1,
            requirements = {
                nutrients = 700,
                maxTimeWithoutWater = 1200,
                weeded = true
            },
            subTypeIndexStart = 0;
        },
        {
            name = "Potato",
            minGrowthRate = 0.0,
            maxGrowthRate = 1.5,
            spawnObjName = "BoxfarmPotato",
            spawnNumber = 3,
            requirements = {
                nutrients = 2200,
                maxTimeWithoutWater = 800,
                weeded = true
            },
            subTypeIndexStart = 6;
        }
    }
    local numOfPlantTypes = 0;
    for i, plantType in ipairs(plantTypes) do
        numOfPlantTypes = numOfPlantTypes + 1;
    end

    -- + 1 because lua is not zero indexed
    local vegIndex = math.floor(math.random() * numOfPlantTypes) + 1;
    local vegType = plantTypes[vegIndex].name;
    local requirements = plantTypes[vegIndex].requirements;
    local minGrowthRate = plantTypes[vegIndex].minGrowthRate;
    local maxGrowthRate = plantTypes[vegIndex].maxGrowthRate;
    local spawnObjName = plantTypes[vegIndex].spawnObjName;
    local spawnNumber = plantTypes[vegIndex].spawnNumber;

    Object.SetProperty("Mass", 0.0);
    Object.SetProperty("SubType", 0);
    Object.SetProperty("GrowthRate", 1.0);
    Object.SetProperty("VegType", vegType);
    Object.SetProperty("ReqNutrients", requirements.nutrients);
    Object.SetProperty("MaxTimeWithoutWater", requirements.maxTimeWithoutWater);
    Object.SetProperty("SpawnObjName", spawnObjName);
    Object.SetProperty("SpawnNumber", spawnNumber);
    Object.SetProperty("MinGrowthRate", minGrowthRate);
    Object.SetProperty("MaxGrowthRate", maxGrowthRate);

    -- Time since requirement met
    Object.SetProperty("TimeSinceWeeded", 0);
    Object.SetProperty("TimeSinceWatered", 0);
    Object.SetProperty("TimeSinceFertilized", 0);

    --Debug values
    Object.SetProperty("DebugThis", requirements.nutrients);



    -- Job request states (Jobs need to be requested every frame, for some reason. Seems illogical)
    --Object.SetProperty("JobHavestRequested", false);
    --Object.SetProperty("JobWaterRequested", false);
    --Object.SetProperty("JobWeedRequested", false);
    --Object.SetProperty("JobFertilizeRequested", false);
end


function Update(timePassed)

    --Game.DebugOut("Something");

    -- Get position and material the plant is on
    local ourX = Object.GetProperty("Pos.x");
    local ourY = Object.GetProperty("Pos.y");
    local material = Object.GetMaterial( ourX, ourY );

    -- Require Dirt
    if material ~= "Dirt" then
        Object.SetProperty("Tooltip", "tooltip_boxfarmplant_wrongmaterial");
        return;
    end
    -- clear the tooltip
    --Object.SetProperty("Tooltip", "");

    -- Set variables for later use
    local numOfStates = 5;
    local weedGrowTime = 100;
    local minTimeReqForWater = 200;
    local penaltyWater = 0.6;

    local mass = Object.GetProperty("Mass");
    --local growthRate = Object.GetProperty("GrowthRate");
    local vegType = Object.GetProperty("VegType");
    local reqNutrients = Object.GetProperty("ReqNutrients");
    local minGrowthRate = Object.GetProperty("MinGrowthRate");
    local maxGrowthRate = Object.GetProperty("MaxGrowthRate");
    local timeSinceWeeded = Object.GetProperty("TimeSinceWeeded");
    local timeSinceWatered = Object.GetProperty("TimeSinceWatered");
    local timeSinceFertilized = Object.GetProperty("TimeSinceFertilized");
    local maxTimeWithoutWater = Object.GetProperty("MaxTimeWithoutWater");

    --local jobHavestRequested = Object.GetProperty("JobHavestRequested");

    timeSinceWeeded = timeSinceWeeded + timePassed;
    timeSinceWatered = timeSinceWatered + timePassed;
    timeSinceFertilized = timeSinceFertilized + timePassed;

    if mass == nil then
       mass = 0;
    end

    --Object.SetProperty("DebugThis", type(timePassed) .. " " .. "timePassed: " .. timePassed );

    -- Calculate growth penalty
    local totalPenalty = 0;
    local totalBonus = 0;
    local growthRate = 1;

    -- Needs Weeded

    -- Needs Water
    if timeSinceWatered > minTimeReqForWater then
        totalPenalty = totalPenalty + penaltyWater;
        growthRate = growthRate - penaltyWater;
        Object.CreateJob("BoxfarmPlant_Water");
    else

    -- Needs Fertilizer

    -- Calculate growth rate
    if totalPenalty > 1 then
        totalPenalty = 1;
    end
    --growthRate = growthRate - (growthRate * totalPenalty);

    -- Check for growthRate over or under limits
    if growthRate > maxGrowthRate then
        growthRate = maxGrowthRate;
    end
    if growthRate < minGrowthRate then
        growthRate = minGrowthRate;
    end

    -- Increae mass
    mass = mass + (timePassed * growthRate);
    Object.SetProperty("Mass", mass);

    -- Calculate the state of the plant
    local subType = 0;
    local procentageGrown = 100 / (reqNutrients / mass);
    local i = 0;
    while i <= numOfStates do
        local TempProcentage = 100 / numOfStates * i;
        if procentageGrown > TempProcentage then
            subType = i;
        end
        i = i + 1;
    end

    -- Check if plant state is over number of state.
    if subType > (numOfStates-1) then
        -- Check for plant being too old
        -- Reset plant stage & age
        --SetState(0);
        --Object.SetProperty( "Mass", 0.0 );
    else
        SetState(subType);
    end

    -- Request havest if fully grown
    if procentageGrown >= 100 then
        --if jobHavestRequested ~= true then
            Object.CreateJob("BoxfarmPlant_Havest");
            Object.SetProperty("JobHavestRequested", true);
        --end
    end

    -- Plant vanish and spawn 0-5 adjencent plants center/up/right/down/left
    if procentageGrown > 150 then
        Object.Delete(this);
    end

    local debugThis = Object.GetProperty("DebugThis");

    -- Set tooltips for debug
    Object.SetProperty("Tooltip", "debugThis: " .. tostring(debugThis) .. "\n" .. "growthRate: " .. tostring(growthRate) .. "\n" .. "Mass: " .. tostring(mass) .. "\n" .. "subType: " .. tostring(subType) .. "\n" .. "Grown: " .. tostring(procentageGrown) .. "%" .. "\n" .. "vegType: " .. tostring(vegType));
end


function SetState(state)
    local currentSubtype = Object.GetProperty("SubType");
    if currentSubtype ~= state then
        Object.SetProperty("SubType", state);
    end
end


function JobComplete_BoxfarmPlant_Havest()
    -- Reset
    Object.SetProperty("SubType", 0);
    Object.SetProperty( "Mass", 0.0 );

    local ourX = Object.GetProperty("Pos.x");
    local ourY = Object.GetProperty("Pos.y");
    local spawnObjName = Object.GetProperty("SpawnObjName");
    local spawnNumber = Object.GetProperty("SpawnNumber");

    --Object.SetProperty("DebugThis", type(spawnNumber));

    -- Spawn objects
    local i = 1;
    while i  <= tonumber(spawnNumber) do
        local objID = Object.Spawn(spawnObjName, ourX, ourY );
        if objID ~= nil then
            local velX = -1.0 + math.random() + math.random();
            local velY = -1.0 + math.random() + math.random();
            Object.ApplyVelocity(objID, velX, velY);
        end
        i = i + 1;
    end
end


function JobComplete_BoxfarmPlant_Remove()
    Object.Delete(this);
end


--Object.SetProperty
--Object.GetProperty
--Object.GetMaterial
--Object.CreateJob
--Object.Spawn
--Object.ApplyVelocity
--Object.Delete( Object Name )
--local objects = GetNearbyObjects(Type, SearchDistance)
--Game.Spawn()
--Game.LoseEquipment()
--Game.Damage
--Game.SendEntityToObject
--Game.Delivery
--Game.Spawn() Usage: Game.Spawn( "Object", "Object_Name", Xpos, Ypos )