
function Create()
    local plantTypes = {
        {
            name = "Cabbage",
            minGrowthRate = 0.0,
            maxGrowthRate = 2.2,
            spawnObjName = "BoxfarmCabbage",
            spawnNumber = 1,
            requirements = {
                nutrients = 700,
                maxTimeWithoutWater = 1200,
                weeded = true
            },
            subTypeIndexStart = 0
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
            subTypeIndexStart = 6
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

    -- Strings
    this.vegType = vegType;
    this.spawnObjName = spawnObjName;
    -- Numbers
    this.spawnNumber = spawnNumber;
    this.mass = 0.0;
    this.SubType = 0;
    this.growthRate = 1.0;
    this.growthPenalty = 0;
    this.minGrowthRate = minGrowthRate;
    this.maxGrowthRate = maxGrowthRate;
    this.reqNutrients = requirements.nutrients;
    this.maxTimeWithoutWater = requirements.maxTimeWithoutWater;
    this.timeSinceWeeded = 0;
    this.timeSinceWatered = 0;
    this.timeSinceFertilized = 0;
    -- Bools
    this.jobHavestRequested = false;
    this.jobWaterRequested = false;
    this.jobFertilizeRequested = false;

    --Debug values
    this.debugThis = requirements.nutrients;

    --this.something = true;
    --Game.DebugOut("c value this.something " .. tostring(this.something));
    --Game.DebugOut("c type this.something " .. type(this.something));
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
    local minTimeReqForWater = 500;

    -- Strings
    local vegType = this.vegType;
    -- Numbers
    local mass = tonumber(this.mass);
    local reqNutrients = tonumber(this.reqNutrients);
    local growthPenalty =  tonumber(this.growthPenalty);
    local growthPenalty =  tonumber(this.growthPenalty);
    local minGrowthRate =  tonumber(this.minGrowthRate);
    local maxGrowthRate = tonumber(this.maxGrowthRate);
    local timeSinceWeeded = tonumber(this.timeSinceWeeded);
    local timeSinceWatered = tonumber(this.timeSinceWatered);
    local timeSinceFertilized = tonumber(this.timeSinceFertilized);
    local maxTimeWithoutWater = tonumber(this.maxTimeWithoutWater);

    -- Make sure mass always has a value
    if mass == nil then
       mass = 0;
    end

    -- Increase Time
    timeSinceWeeded = timeSinceWeeded + timePassed;
    timeSinceWatered = timeSinceWatered + timePassed;
    timeSinceFertilized = timeSinceFertilized + timePassed;

    -- Calculate growth penalty
    local totalBonus = 0;
    local growthRate = 1;

    -- Needs Weeded

    -- Needs Water
    if timeSinceWatered > minTimeReqForWater then
        growthPenalty = growthPenalty + 0.0003;
        growthRate = growthRate - growthPenalty;
        if this.jobWaterRequested ~= true then
            Object.CreateJob("BoxfarmPlant_Water");
            this.jobWaterRequested = true;
        end
    else
        growthPenalty = growthPenalty - 0.0005;
    end

    -- Needs Fertilizer

    -- Calculate growth rate
    if growthPenalty > 1 then
        growthPenalty = 1;
    end
    if growthPenalty < 0 then
        growthPenalty = 0;
    end
    growthRate = growthRate * (1 - growthPenalty);

    -- Check for growthRate over or under limits
    if growthRate > maxGrowthRate then
        growthRate = maxGrowthRate;
    end
    if growthRate < minGrowthRate then
        growthRate = minGrowthRate;
    end

    -- Increae mass
    mass = mass + (timePassed * growthRate);

    -- Calculate the state of the plant
    local subType = 0;
    local procentageGrown = 100 / (reqNutrients / mass);
    local tempProcentage = 0;
    local i = 0;

    if (procentageGrown > 20 and procentageGrown <= 40) then
        subType = 1;
    end
    if (procentageGrown > 40 and procentageGrown <= 70) then
        subType = 2;
    end
    if (procentageGrown > 70 and procentageGrown < 100) then
        subType = 3;
    end
    if (procentageGrown >= 100) then
        subType = 4;
    end

    --[[
    while i < numOfStates do
        tempProcentage = 100 / numOfStates * i;
        if procentageGrown > tempProcentage then
            subType = i;
        end
        i = i + 1;
    end
    --]]

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
        if this.jobHavestRequested ~= true then
            Object.CreateJob("BoxfarmPlant_Havest");
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
    this.Tooltip = "debugThis: " .. tostring(debugThis) .. "\n" ..
            "growthRate: " .. tostring(growthRate) .. "\n" ..
            "Mass: " .. tostring(mass) .. "\n" ..
            "subType: " ..  tostring(subType) .. "\n" ..
            "timeSinceWatered: " ..  tostring(timeSinceWatered) .. "\n" ..
            "minTimeReqForWater: " ..  tostring(minTimeReqForWater) .. "\n" ..
            "growthPenalty: " ..  tostring(growthPenalty) .. "\n" ..
            --"Game.Time: " .. tostring(Game.Time()) .. "\n" ..
            "jobHavestRequested: " .. tostring(this.jobHavestRequested) .. "\n" ..
            "jobWaterRequested: " .. tostring(this.jobWaterRequested) .. "\n" ..
            "Grown: " .. tostring(procentageGrown) .. "%" .. "\n" ..
            "vegType: " .. tostring(vegType);


    -- Set object variables
    this.timeSinceWatered = timeSinceWatered;
    this.growthPenalty = growthPenalty;
    this.mass = mass;

end


function SetState(state)
    local currentSubtype = this.SubType;
    if currentSubtype ~= state then
        this.SubType = state;
    end
end

function resetPlant()
    this.mass = 0.0;
    this.SubType = 0;
    this.growthRate = 1.0;
    this.growthPenalty = 0;
    this.timeSinceWeeded = 0;
    this.timeSinceWatered = 0;
    this.timeSinceFertilized = 0;
    -- Bools
    this.jobHavestRequested = false;
    this.jobWaterRequested = false;
    this.jobFertilizeRequested = false;
end




function JobComplete_BoxfarmPlant_Havest()
    -- Reset
    resetPlant();

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
    this.jobWaterRequested = false;
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