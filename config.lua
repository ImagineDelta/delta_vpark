Config = {}

Config.CommandNames = {
    ListVehicles = 'vget',
    BuySpawnSlot = 'vbuy',
    ParkVehicle = 'vpark'
}

Config.SpawnFee = 150
Config.Currency = 'money'
Config.SafeSpawnDistance = 5.0
Config.MaxSpawnAttempts = 10

Config.Notifications = {
    NoVehicles = "You don't own any vehicles.",
    InsufficientFunds = "You need $%s to purchase a vehicle spawn slot.",
    SlotPurchased = "Vehicle spawn slot purchased for $%s.",
    NoSlotAvailable = "You need to purchase a spawn slot with /vbuy first.",
    VehicleSpawned = "Your %s has been delivered nearby.",
    VehicleAlreadyOut = "This vehicle is already spawned.",
    SpawnBlocked = "Cannot spawn vehicle - area is blocked.",
    NotInVehicle = "You need to be in a vehicle to park it.",
    VehicleMoving = "Stop the vehicle before parking it.",
    NotYourVehicle = "You can only park vehicles you spawned.",
    VehicleParked = "You have parked the vehicle."
}

Config.Debug = false