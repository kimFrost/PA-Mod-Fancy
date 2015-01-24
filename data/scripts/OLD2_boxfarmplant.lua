
function Create()
    local plantTypes = {
        {
            name = "Cabbage",
            minGrowthRate = 0.0,
            maxGrowthRate = 2.2,
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


    this.mass = 0.0;
    this.subType = 0;
    this.growthRate = 1.0;
    this.vegType = vegType;
    this.reqNutrients = requirements.nutrients;
    this.maxTimeWithoutWater = requirements.maxTimeWithoutWater;
    this.spawnObjName = spawnObjName;
    this.spawnNumber = spawnNumber;
    this.minGrowthRate = minGrowthRate;
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
    this.jobHavestRequested = false;
    --Object.SetProperty("JobWaterRequested", false);
    --Object.SetProperty("JobWeedRequested", false);
    --Object.SetProperty("JobFertilizeRequested", false);


    this.something = true;
	Game.DebugOut("c value this.something " .. this.something);
	Game.DebugOut("c type this.something " .. type(this.something));
	-- show debugger by error force
	--print();
end


function Update(timePassed)

    -- Get position and material the plant is on
    local ourX = this.Pos.x;
    local ourY = this.Pos.y;
    local material = Object.GetMaterial( ourX, ourY );

    -- Require Dirt
    if material ~= "Dirt" then
        this.tooltip = "tooltip_boxfarmplant_wrongmaterial";
        return;
    end

    -- Set variables for later use
    local numOfStates = 5;
    local weedGrowTime = 100;
    local minTimeReqForWater = 200;
    local penaltyWater = 0.6;

    -- Strings
    local vegType = this.vegType;
    -- Numbers
    local mass = tonumber(this.mass);
    local reqNutrients = tonumber(this.reqNutrients);
    local minGrowthRate =  tonumber(this.minGrowthRate);
    local maxGrowthRate = tonumber(this.maxGrowthRate);
    local timeSinceWeeded = tonumber(this.timeSinceWeeded);
    local timeSinceWatered = tonumber(this.timeSinceWatered);
    local timeSinceFertilized = tonumber(this.timeSinceFertilized);
    local maxTimeWithoutWater = tonumber(this.maxTimeWithoutWater);
    -- Bools
    local jobHavestRequested = this.jobHavestRequested

    timeSinceWeeded = timeSinceWeeded + timePassed;
    timeSinceWatered = timeSinceWatered + timePassed;
    timeSinceFertilized = timeSinceFertilized + timePassed;

    if mass == nil then
       mass = 0;
    end

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
    this.timeSinceWatered = timeSinceWatered;

    -- Needs Fertilizer

    -- Calculate growth rate
    if totalPenalty > 1 then
        totalPenalty = 1;
    end
    --growthRate = growthRate - (growthRate * totalPenalty);

    -- Check for growthRate over or under limits
	minGrowthRate = tonumber(minGrowthRate);
	maxGrowthRate = tonumber(maxGrowthRate);
    if growthRate > maxGrowthRate then
        growthRate = maxGrowthRate;
    end
    if growthRate < minGrowthRate then
        growthRate = minGrowthRate;
    end

    -- Increae mass
    mass = mass + (timePassed * growthRate);
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

    local debugThis = this.jobHavestRequested;
    -- Set tooltips for debug
    this.Tooltip = "debugThis: " .. tostring(debugThis) .. "\n" .. "growthRate: " .. tostring(growthRate) .. "\n" .. "Mass: " .. tostring(mass) .. "\n" .. "subType: " .. tostring(subType) .. "\n" .. "Grown: " .. tostring(procentageGrown) .. "%" .. "\n" .. "vegType: " .. tostring(vegType);
end


function SetState(state)
    local currentSubtype = this.subType;
    if currentSubtype ~= state then
        this.subType = state;
    end
end




function JobComplete_BoxfarmPlant_Havest()
    -- Reset
    this.subType = 0;
    this.mass = 0.0;
    this.jobHavestRequested = false;

    local ourX = this.Pos.x;
    local ourY = this.Pos.y;
    local spawnObjName = this.spawnObjName;
    local spawnNumber = this.spawnNumber;

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