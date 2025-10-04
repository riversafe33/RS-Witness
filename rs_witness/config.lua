Config = Config or {}

-- You can change this value to any number between 1 and 100
Config.WitnessProbability = 100 

-- Time that the blips last on the screen
Config.BlipCallTimer = 120

-- if true, sends a notification to the sheriffs every 30 seconds along with an indicator on the map with the player's position, for a total duration of 5 minutes.
Config.EscapeNotification = {
    enabled = true 
}

-- Add the jobs that will receive the notification
Config.Jobs = {"police", "sheriff", "marshal",} 

-- Don't remove `mp_male`, `mp_female`, otherwise a witness will also be sent when players attack each other, if you want this to happen remove them from the list
-- This is useful if you have a bounty hunt script or quests that spawn npcs, if you include them in the list they will not send a witness.
--   `` ,  use this type of quotation marks or it won’t work.
Config.ExcludedModels = {
    `mp_male`, `mp_female`,
}


-- If the player is not wearing a bandana, the notification to the sheriffs will include the name of the player attacking the NPCs. 
-- If the player is wearing a bandana, it will only send the notification and mark their position on the map.
Config.Bandana = function()
    -- If you are using vorp clothing stores, use this check:

    return LocalPlayer.state.IsBandanaOn

    -- If you are using kd_clotheswheel, replace the return with:
    
    -- return Entity(PlayerPedId()).state["wearableState:neckwear"] == -1829635046      
    
end

-- translate it into the language you like
Config.Notifications = {
    player = "From now on, your position will be marked every 30 seconds for 5 minutes.",
    escape = "The bandits are escaping!",
    witnessCreated = "Witness",
    policeAlertMessage = " is committing a crime in ",
    crime = " A crime is happening in ",
    hooded = " but the suspect is wearing a mask",
    playerAlt = "Sheriffs have been notified of your assault on civilians",

}