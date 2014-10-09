
function Create()

    local plantTypes = {
        {
            name = "Cabbage",
            minGrowthRate = 0,0,
            maxGrowthRate = 3.0,
            requirements = {
                nutrients = 700,
                water = 1200,
                weeded = true
            },
            subTypeIndexStart = 0;
        },
        {
            name = "Potato",
            minGrowthRate = 0,0,
            maxGrowthRate = 2.0,
            requirements = {
                nutrients = 2200,
                water = 800,
                weeded = false
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

    Object.SetProperty("Mass", 0.0);
    Object.SetProperty("SubType", 0);
    Object.SetProperty("GrowthRate", 1.0);
    Object.SetProperty("VegType", vegType);
    Object.SetProperty("Requirements", requirements);
    Object.SetProperty("MinGrowthRate", minGrowthRate);
    Object.SetProperty("MaxGrowthRate", maxGrowthRate);
end

function Update(timePassed)

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
    local mass = Object.GetProperty("Mass");
    local growthRate = Object.GetProperty("GrowthRate");
    local vegType = Object.GetProperty("VegType");
    local requirements = Object.GetProperty("Requirements");
    local minGrowthRate = Object.GetProperty("MinGrowthRate");
    local maxGrowthRate = Object.GetProperty("MaxGrowthRate");


    -- Calculate growth rate


    -- Needs Weeded

    -- Needs Water

    -- Needs Fertilizer




    -- Increae mass
    mass = mass + (timePassed * growthRate);
    Object.SetProperty( "Mass", Mass );

    -- Calculate the state of the plant
    local subType = 0;
    local procentageGrown = 100 / (requirements.nutrients / mass);
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
        SetState(0);
        Object.SetProperty( "Mass", 0.0 );
    else
        SetState(subType);
    end

    -- Set tooltips for debug
    Object.SetProperty("Tooltip", "Mass: " .. tostring(mass) .. "\n" .. "subType: " .. tostring(subType) .. "\n" .. "Grown: " .. tostring(procentageGrown) .. "%" .. "\n" .. "vegType: " .. tostring(vegType));
end


function SetState(state)
    local currentSubtype = Object.GetProperty("SubType");
    if currentSubtype ~= state then
        Object.SetProperty("SubType", state);
    end
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