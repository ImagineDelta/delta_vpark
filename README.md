# Vehicle Parking System for ESX (FiveM) 

This is a GTAW Inspired Vehicle Parking System for FiveM servers using the ESX framework. Players can spawn, park, and manage their vehicles with the ability to purchase parking slots. The system includes commands for vehicle spawning, parking, providing an immersive and user-friendly experience.

Preview: https://streamable.com/ouctp3

## Features
- **Vehicle Management:** Players can spawn their owned vehicles and park them.
- **Spawn Slot System:** Players must pay to receive their vehicle.
- **Database Integration:** Works with `oxmysql` to retrieve owned vehicles from the database.

- **Commands:**
  - `/vget` - Open the vehicle list menu to spawn owned vehicles.
  - `/vg` - Alias for `/vget`.
  - `/vb` - Alias for `/vbuy`.
  - `/vbuy` - Purchase's your parking spot.
  - `/vpark` - Park the vehicle you're currently in.
  - `/vp` - Alias for `/vpark`.
  - `/fixveh` - Teleport your vehicle to your current location.

## Installation

1. Download or clone this repository into your server's `resources` folder.
2. Add the resource to your `server.cfg`: ```ensure parking```
