
function Create()

    -- property doesn't exist on the object by default, so it must be created now
    Object.SetProperty( "Age", 0.0);  
    
    -- pick randomly between potato or cabbage
    local vegType = "RawPotato";
    if math.random() > 0.5 then
        vegType = "RawCabbage";
    end
    Object.SetProperty("VegType", vegType );
    
    Object.SetProperty("SubType", 1);
    Object.SetProperty("NeedsTending", false);
end


function Update( timePassed )

    -- get the material that the object is currently placed in
    local ourX = Object.GetProperty("Pos.x");
    local ourY = Object.GetProperty("Pos.y");
    local material = Object.GetMaterial( ourX, ourY );
    
    -- seeds will only grow in compost!
    if material ~= "Farmland" then
        Object.SetProperty("Tooltip", "tooltip_seeds_compost");
        return;
    end      
    
    local maxAge = 720.0;
    
    if Object.GetProperty("NeedsTending") then       
        Object.CreateJob("TendVegetables");
        Object.SetProperty("Tooltip", "tooltip_seeds_needtending");
        return;
    end    
    
    -- clear the tooltip
    Object.SetProperty("Tooltip", "");  
        
    -- increase our age and save it back to the object
    local age = Object.GetProperty("Age");    
    age = age + timePassed;    
    Object.SetProperty( "Age", age );
    
    -- set our subtype (and thus, our sprite) based on our age
    local subType = 0;
    if age < maxAge * 0.33 then
        subType = 1;    
    elseif age < maxAge * 0.66 then
        subType = 2;    
    else
        subType = 3;
    end
    
    local currentSubtype = Object.GetProperty("SubType");
    if currentSubtype ~= subType then
        Object.SetProperty("SubType", subType);    
    end
    
    if age > maxAge then
        -- spawn a vegetable at our position
        local name = Object.Spawn( Object.GetProperty("VegType"), ourX, ourY );
        
        if name ~= nil then
            local velX = -1.0 + math.random() + math.random();
            local velY = -1.0 + math.random() + math.random();
            
            -- make the vegetable move slightly away from the plant, then reset our age
            Object.ApplyVelocity(name, velX, velY);
        end
        
        Object.SetProperty( "Age", 0 );
        Object.SetProperty( "NeedsTending", true );
        Object.SetProperty( "SubType", 1 );    
    end

end


-- this function is called when the job created by the Object.CreateJob("TendVegetables") call is completed by the appropriate worker
-- the name of the function called follows the format "JobComplete_" plus the name of the job (as created in jobs.txt, and called in the CreateJob function)

function JobComplete_TendVegetables()

    Object.SetProperty("NeedsTending", false);    

end

