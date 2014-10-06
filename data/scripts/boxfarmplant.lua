
function Create()
    Object.SetProperty("Age", 0.0);
    Object.SetProperty("VegType", "NOT SET" );
    Object.SetProperty("SubType", 0);

    local plantTypes = {
        {
            name = "Cabbage",
            requirements = {
                nutrients = 2500,
                water = 600,
                weeded = true
            }
        },
        {
            name = "Potato",
            requirements = {
                nutrients = 2000,
                water = 800,
                weeded = false
            }
        }
    }
    local numOfPlantTypes = 0;
    for i,plantType in ipairs(plantTypes) do
        numOfPlantTypes = numOfPlantTypes + 1;
        --pressed = CheckEntityType( plantType, searchDistance, ourX, ourY ) or pressed
    end

end


function Update(timePassed)

    -- Set variables for later use
    local maxAge = 300.0;
    local numOfStates = 5;

    -- Get position and material the plant is on
    local ourX = Object.GetProperty("Pos.x");
    local ourY = Object.GetProperty("Pos.y");
    local material = Object.GetMaterial( ourX, ourY );

    if material ~= "Dirt" then
        Object.SetProperty("Tooltip", "tooltip_boxfarmplant_wrongmaterial");
        return;
    end
    -- clear the tooltip
    Object.SetProperty("Tooltip", "");

    -- Increase Age
    local age = Object.GetProperty("Age");
    age = age + timePassed;
    Object.SetProperty( "Age", age );

    -- Calculate the state of the plant
    local subType = 0;
    local procentageGrown = 100 / (maxAge / age);
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
        Object.SetProperty("Age", 0.0);
    else
        SetState(subType);
    end

    -- Set tooltips for debug
    --Object.SetProperty("Tooltip", "Age: " .. tostring(age) .. "\n" .. "subType: " .. tostring(subType) .. "\n" .. "Grown: " .. tostring(procentageGrown) .. "%");
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