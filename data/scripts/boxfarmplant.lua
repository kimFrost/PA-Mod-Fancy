
function Create()
    local plantTypes = {
        {
            name = "Cabbage",
            minGrowthRate = 0.0,
            maxGrowthRate = 2.0,
            spawnObjName = "BoxfarmCabbage",
            spawnNumber = 1,
            requirements = {
                nutrients = 70,
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
                nutrients = 220,
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



    --Object.SetProperty("Mass", 0.0);
    this.mass = 0.0;
    --Object.SetProperty("SubType", 0);
    this.subType = 0;
    --Object.SetProperty("GrowthRate", 1.0);
    this.growthRate = 1.0;
    --Object.SetProperty("VegType", vegType);
    this.vegType = vegType;
    --Object.SetProperty("ReqNutrients", requirements.nutrients);
    this.reqNutrients = requirements.nutrients;
    --Object.SetProperty("MaxTimeWithoutWater", requirements.maxTimeWithoutWater);
    this.maxTimeWithoutWater = requirements.maxTimeWithoutWater;
    --Object.SetProperty("SpawnObjName", spawnObjName);
    this.spawnObjName = spawnObjName;
    --Object.SetProperty("SpawnNumber", spawnNumber);
    this.spawnNumber = spawnNumber;
    --Object.SetProperty("MinGrowthRate", minGrowthRate);
    this.minGrowthRate = minGrowthRate;
    --Object.SetProperty("MaxGrowthRate", maxGrowthRate);
    this.maxGrowthRate = maxGrowthRate;

    -- Time since requirement met
    --Object.SetProperty("TimeSinceWeeded", 0);
    --Object.SetProperty("TimeSinceWatered", 0);
    --Object.SetProperty("TimeSinceFertilized", 0);
    this.timeSinceWeeded = 0;
    this.timeSinceWatered = 0;
    this.timeSinceFertilized = 0;

    --Debug values
    --Object.SetProperty("DebugThis", requirements.nutrients);
    this.debugThis = requirements.nutrients;



    -- Job request states (Jobs need to be requested every frame, for some reason. Seems illogical)
    --Object.SetProperty("JobHavestRequested", false);
    this.jobHavestRequested = false;
    --Object.SetProperty("JobWaterRequested", false);
    --Object.SetProperty("JobWeedRequested", false);
    --Object.SetProperty("JobFertilizeRequested", false);

    -- show debugger
    --print();
    Game.DebugOut("Show Debugger");
end


function Update(timePassed)

    --Game.DebugOut("Something");

    -- Get position and material the plant is on
    -- ourX = Object.GetProperty("Pos.x");
    local ourX = this.pos.x;
    --local ourY = Object.GetProperty("Pos.y");
    local ourY = this.pos.y;
    local material = Object.GetMaterial( ourX, ourY );

    -- Require Dirt
    if material ~= "Dirt" then
        --Object.SetProperty("Tooltip", "tooltip_boxfarmplant_wrongmaterial");
        this.tooltip = "tooltip_boxfarmplant_wrongmaterial";
        return;
    end
    -- clear the tooltip
    --Object.SetProperty("Tooltip", "");

    -- Set variables for later use
    local numOfStates = 5;
    local weedGrowTime = 100;
    local minTimeReqForWater = 200;
    local penaltyWater = 0.6;

    --local mass = Object.GetProperty("Mass");
    local mass = this.mass;
    --local growthRate = Object.GetProperty("GrowthRate");
    --local vegType = Object.GetProperty("VegType");
    local vegType = this.vegType;
    --local reqNutrients = Object.GetProperty("ReqNutrients");
    local reqNutrients = this.reqNutrients;
    --local minGrowthRate = tonumber(Object.GetProperty("MinGrowthRate"));
    local minGrowthRate = this.minGrowthRate;
    --local maxGrowthRate = tonumber(Object.GetProperty("MaxGrowthRate"));
    local maxGrowthRate = tonumber(this.maxGrowthRate);
    --local timeSinceWeeded = Object.GetProperty("TimeSinceWeeded");
    local timeSinceWeeded = this.timeSinceWeeded;
    --local timeSinceWatered = Object.GetProperty("TimeSinceWatered");
    local timeSinceWatered = this.timeSinceWatered;
    --local timeSinceFertilized = Object.GetProperty("TimeSinceFertilized");
    local timeSinceFertilized = this.timeSinceFertilized;
    --local maxTimeWithoutWater = Object.GetProperty("MaxTimeWithoutWater");
    local maxTimeWithoutWater = this.maxTimeWithoutWater;

    local jobHavestRequested = Object.GetProperty("JobHavestRequested");

    timeSinceWeeded = timeSinceWeeded + timePassed;
    timeSinceWatered = timeSinceWatered + timePassed;
    timeSinceFertilized = timeSinceFertilized + timePassed;

    if mass == nil then
       mass = 0;
    end

    --Object.SetProperty("DebugThis", type(timePassed) .. " " .. "timePassed: " .. timePassed );
    --Object.SetProperty("DebugThis", "timeSinceWatered: " .. timeSinceWatered );
    this.debugThis =  "timeSinceWatered: " .. timeSinceWatered;

    -- Calculate growth penalty
    local totalPenalty = 0;
    local totalBonus = 0;
    local growthRate = 1;

    -- Needs Weeded

    -- Needs Water
    if timeSinceWatered > minTimeReqForWater then
        totalPenalty = totalPenalty + penaltyWater;
        growthRate = growthRate - penaltyWater;
        --Object.CreateJob("BoxfarmPlant_Water");
    else

    end
    --Object.SetProperty("TimeSinceWatered", timeSinceWatered);
    this.timeSinceWatered = timeSinceWatered;


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
    --Object.SetProperty("Mass", mass);
    this.mass = mass;

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
        if jobHavestRequested ~= true then
            Object.CreateJob("BoxfarmPlant_Havest");
            --Object.SetProperty("JobHavestRequested", true);
            this.jobHavestRequested = true;
        end
    end

    -- Plant vanish and spawn 0-5 adjencent plants center/up/right/down/left
    if procentageGrown > 150 then
        --Object.Delete(this);
        --Object.Delete(self);
        --Object.CreateJob("BoxfarmPlant_Remove");
    end


    --local debugThis = Object.GetProperty("DebugThis");
    --local debugThis = Object.GetProperty("JobHavestRequested");
    local debugThis = this.jobHavestRequested;

    -- Set tooltips for debug
    --Object.SetProperty("Tooltip", "debugThis: " .. tostring(debugThis) .. "\n" .. "growthRate: " .. tostring(growthRate) .. "\n" .. "Mass: " .. tostring(mass) .. "\n" .. "subType: " .. tostring(subType) .. "\n" .. "Grown: " .. tostring(procentageGrown) .. "%" .. "\n" .. "vegType: " .. tostring(vegType));
    this.Tooltip = "debugThis: " .. tostring(debugThis) .. "\n" .. "growthRate: " .. tostring(growthRate) .. "\n" .. "Mass: " .. tostring(mass) .. "\n" .. "subType: " .. tostring(subType) .. "\n" .. "Grown: " .. tostring(procentageGrown) .. "%" .. "\n" .. "vegType: " .. tostring(vegType);
end


function SetState(state)
    --local currentSubtype = Object.GetProperty("SubType");
    local currentSubtype = this.subType;
    if currentSubtype ~= state then
        --Object.SetProperty("SubType", state);
        this.subType = state;
    end
end




function JobComplete_BoxfarmPlant_Havest()
    -- Reset
    --Object.SetProperty("SubType", 0);
    this.subType = 0;
    --Object.SetProperty( "Mass", 0.0 );
    this.mass = 0.0;
    --Object.SetProperty("JobHavestRequested", false);
    this.jobHavestRequested = false;

    --local ourX = Object.GetProperty("Pos.x");
    local ourX = this.pos.x;
    --local ourY = Object.GetProperty("Pos.y");
    local ourY = this.pos.y;
    --local spawnObjName = Object.GetProperty("SpawnObjName");
    local spawnObjName = this.spawnObjName;
    --local spawnNumber = Object.GetProperty("SpawnNumber");
    local spawnNumber = this.spawnNumber;

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



function JobComplete_BoxfarmPlant_Water()

    --Object.SetProperty("TimeSinceWatered", 0);
    this.timeSinceWatered = 0;
    --Object.Delete(this);
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