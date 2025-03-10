# working_villages mod forked from theFox6


Updating to a workable mod for adding extra people in the town you create.

Added roles of

NPC Medic
Animal Vet
Lawn Cutter

Fixed Plant gatherer to only pick up wild plants
Added Farming Redo Plants
Fixed Farmer to only pick up cultivated plants


Pathing is an Issue that will be shortly looked into, though with the better collision avoidance the NPC's are a less likely to become stuck.
The NPC's are only allowed to paddle and not swim.
The NPC's will only go down where they can get back up, no more dropping into caverns.
Added Animaion for the Vet and Medic when healing something, though will need to add usage of materials.



Current Roles:
builder.lua		-- Not functional due to pathing ?
empty.lua		-- Meant to do Nothing
farmer.lua		-- Working
follow_player.lua	-- Working
grass_cutter.lua	-- Working
guard.lua		-- Not Tested, but not sure if it's Attacking code is finished
medic.lua		-- Working
plant_collector.lua	-- Working
snowclearer.lua		-- Working
torcher.lua		-- Not Tested
vet.lua			-- Working
woodcutter.lua		-- Not Working Correctly yet


To be added in the near future:

Rubbish Collector
Sheep Shearer
Cow Milker
Roaming Hunter
Body guard
Landscaper
egg collector

Would you want a butcher ? not for the kids Eh..


Current problems are mostly related to pathfinding errors.
On the first hand a temporary fix, like with the collision avoidance function, to get it working and see what is needed.
Then to have a play with pathfinding algorithm.

At the moment Entity recognisation is being written in:
/home/ray/.minetest/mods/working_villages/working_villagers/jobs/entitys_def.lua

Which will define characteristics used by the NPC to deal with the Entity's... Its all a playground.


I have had a quick try with the "Building sign", but only got the map to crash.


TO GET THE NPC's WORKING (AFAIAK)


Build a 7x7 house with a standard wood door ( only one it currently recognise's : [is on the list])

Place a Standard Simple Bed on the wall oposite the Door with the Standard Chest next to it
Place the NPC in the center of the house
With the control wand right click and select "change data" and change the following to

Villager Name 		: Name your NPC
House Door Position	: set to "near"
Bed Position		: set to "near" 
Chest Position		: set to "near" 
Food Position		: set to "near" 
Tools Position		: set to "near" 
Storage Position	: set to "near"

Press Set and the locations of the Above items should be found.
If not move the NPC closer to the item he missed and rewrite "near" and do Set for that Item.

Lastly I usually select the Job of follower to start with as I want the new NPC to follow me to where he will start work.
On arriving to the work area ( he will roam about, but will always go here to start.) Press F5 to see your location on the top on the screen. this gives you the coordinates to enter in the last NPC data field "Job Position"

Change the NPC to the Job you want and away he/she goes...


There is yet unfound bug (minor) with corrupted start data with the NPC's setup. But the initial setup above overwrites this spurious data.



There you Go working villagers going around doing jobs..  



 



NONE OF THE CODE IS FINISHED OR CORRECTIONS ARE FINISHED, JUST BUG FIXING FOR A USABLE MOD.
Take what you want and leave the rest :)








More information on this MOD can be found on the creators page that this is Forked from..
https://github.com/theFox6/working_villages

Thanks theFox6 for the creation 

