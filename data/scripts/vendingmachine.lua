
-- This is the first thing called as soon as the object is placed.
-- Set all of your variables here to a default value.
function Create()
    Object.SetProperty( "Stock", 120.0);  
    Object.SetProperty("StockType", "Snack" );
    Object.SetProperty("NeedsLoading", false);
	Object.SetProperty("Count", 0.0);
	Object.SetProperty("CurrentSnack", "Snack");
	Object.SetProperty("IsLoaded", true);
end

function Update( timePassed )

	-- Loading the map means all properties not saved will be nil, causing errors.
	-- Load everything again if it's not working.
	if Object.GetProperty("IsLoaded") == nil then
		Create();
	end
	
	-- Bringing these values in as numbers ensures later on that the system knows how to handle them.
	local currentStock = tonumber(Object.GetProperty("Stock"));
	local count = tonumber(Object.GetProperty("Count"));
	
	-- Increase the time counter and save it.
	count = count + timePassed;
	Object.SetProperty("Count", count);
    
	-- Make a job to load the machine if it needs to be loaded.
    if Object.GetProperty("NeedsLoading") then 
		Object.Delete(Object.GetProperty("CurrentSnack"));
		Object.SetProperty("CurrentSnack", "Snack");
		Object.CreateJob("LoadVendingMachine");
        Object.SetProperty("Tooltip", "tooltip_vending_loading");
        return;
    end
    
	-- Clear the tooltip.
    Object.SetProperty("Tooltip", "");  

	-- Every 20 seconds, delete the old snack and pop out a new one if the machine has enough stock for it.
	if count > 20.0 then
		if  currentStock > 0.0 then 
			Object.Delete(Object.GetProperty("CurrentSnack"));
			local currentSnack = Object.Spawn( "Snack", Object.GetProperty("Pos.x"), Object.GetProperty("Pos.y"));
			Object.SetProperty("CurrentSnack", currentSnack);
			Object.SetProperty( "Stock", currentStock - 1 );	
		end
		Object.SetProperty("Tooltip", "Count 0");  
		Object.SetProperty("Count", 0.0);
	end
	
	-- Let it know that it needs to be stocked if it doesn't have any snacks left.
	if currentStock < 1.0 then
			Object.SetProperty( "NeedsLoading", true );
	end
end

-- This function tells the machine what to do after it's been loaded.
function JobComplete_LoadVendingMachine()
	Object.SetProperty("Stock", 120.0);
    Object.SetProperty("NeedsLoading", false);
	Object.SetProperty("Count", 20.0);
end
