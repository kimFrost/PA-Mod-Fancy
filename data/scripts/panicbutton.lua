
function Create()
    local ourX = Object.GetProperty("Pos.x")
    local ourY = Object.GetProperty("Pos.y")
    
    -- Create a table for us to store people who are running towards us
    scaredEntities = {}
end


function Update( timePassed )
    -- Search distances
    local workersSearchDist = 10.0
    local guardSearchDist = 50.0
    
    local ourX = Object.GetProperty( "Pos.x" )
    local ourY = Object.GetProperty( "Pos.y" )
    
    -- Call scared people to us, and check to see if anyone is close to us
    local pressed = CheckForHurtEntities( workersSearchDist, ourX, ourY )
    
    -- If we've been set off, call all nearby guards to us
    if pressed then 
        CallGuards( guardSearchDist, ourX, ourY )
    end
    
    -- Check to see if the guards are close enough to stop routing
    -- If a large crowd has gathered, they can't get right on top of us
    CheckGuards()
end



function CheckForHurtEntities( searchDistance, ourX, ourY )
    -- Search for nearby workers who are hurt, and get them to run to us    
    local pressed = false
    
    -- Iterate over the list of entities we want to check
    local objectTypes = { "Workman", "Paramedic", "Cook", "Gardener", "Janitor" }
    for i,objectType in ipairs( objectTypes ) do 
        pressed = CheckEntityType( objectType, searchDistance, ourX, ourY ) or pressed
    end
    
    return pressed
end


function CheckEntityType( typeName, searchDistance, ourX, ourY )
    -- Iterate over the list of objects nearby to us that match the give type name
    local objects = Object.GetNearbyObjects( typeName, searchDistance )
    local pressed = false
    
    for name,dist in pairs( objects ) do
        -- See if the entity is hurt
        local damage = tonumber(Object.GetProperty( name, "Damage" )) or 0
        dist = tonumber(dist)   -- Because lua won't cast the arguments of comparison operators
        
        if damage > 0.3 then
            if dist > 1 then
                -- If they are "far" away from us (more than a cell) then bring them to us
                CallEntity( name, ourX, ourY, pressed )
            else
                -- Alarm can be pressed if they are "close" to us
                PressAlarm( name )
                pressed = true
            end
        end
    end
    
    return pressed
end


function CallEntity( name, ourX, ourY, pressed )
    local running = Object.GetProperty( name, "RunningToButton" ) or false
    local gameTime = Game.Time()
    
    -- If the button has been pressed, no need to bring anyone to us (they can hear it's already been pressed)
    if pressed then 
        Object.SetProperty( name, "DonePressing", gameTime )
        if running then
            -- Stop the entity coming to us
            Object.SetProperty( name, "RunningToButton", false )
            Object.ClearRouting( name )
        end
        
        return
    end
    
    -- Check to see if the entity has pressed the button in the last 30 seconds
    local lastPress = Object.GetProperty( name, "DonePressing" ) or -30.0
    if gameTime < lastPress + 30.0 then
        return
    end
    
    -- Check to see if the entity is already running to the button
    if not running then
        Object.SetProperty( name, "RunningToButton", true )
        Object.NavigateTo( name, ourX, ourY )
        table.insert( scaredEntities, name )
    end
end


function PressAlarm( name )
    local gameTime = Game.Time()
    Object.SetProperty( name, "RunningToButton", false )
    Object.SetProperty( name, "DonePressing", gameTime )
    
    -- As soon as someone presses the button, stop everyone else coming to us and return
    for i,entName in pairs( scaredEntities ) do
        Object.ClearRouting( entName )
        Object.SetProperty( entName, "RunningToButton", false )
        Object.SetProperty( entName, "DonePressing", gameTime )
    end
    scaredEntities = {}
end


function CallGuards( searchDistance, ourX, ourY )
    local objects = Object.GetNearbyObjects( "Guard", searchDistance )
    for guardName,dist in pairs( objects ) do
        dist = tonumber(dist) or -1
        if dist > 2.5 then
            -- Tell the guard to come to us
            Object.SetProperty( guardName, "RunningToButton", true )
            Object.NavigateTo( guardName, ourX, ourY )
        end
    end
    
    end

function CheckGuards()
    -- We only search for guards that are 2.5 cells away from us, and then clear their routing if they are coming to us
    local objects = Object.GetNearbyObjects( "Guard", 2.5 )
    for guardName,dist in pairs( objects ) do
        -- Is this guard coming to us
        local runningToUs = Object.GetProperty( guardName, "RunningToButton" ) or false
        if runningToUs then
            Object.ClearRouting( guardName )
            Object.SetProperty( guardName, "RunningToButton", false )
        end
    end
end
