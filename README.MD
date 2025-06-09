# simple_working_villages mod by RayFT,
<br> forked from working_villages by theFox6 (link to be added)

MOSTLY WORKING, WORK IN PROGRESS..

Not wanting fixes or updates, as this mod is currently experimental only.
Comments and suggestions are most welcome, and may even be implemented.
Planned later Refactoring will make almost all bugs here obsolete.

<p>
## Personal Objectives with this project:
Having a little look into LUA programming.
Having a little look into the workings of Minetest.
Having a little play with 3d pathing.
Having a little play in Simple Tasked based AI.  
</p>

<p>
## Description
The main purpose of this mod is to add the Mayor NPC Character to the Minetest Game. Once deployed the Mayor will start to build a small town and Hire other Villagers to help.
These other Villagers will fulfill planned jobs in the town and aid in its development.
</p>

<p>
## Code Status
My Code in this mod is "Get it Working" and is as dirty as ya mom.
Current build is experimental and concerned with information gathering.
Be Warned ::: I have not used LUA before taking on this project, its all a learning curve.
</p>


# CURRENT MINETEST MODULES USED WITH THIS MOD.
**Basic Materials and items**<br>
    mt-mods<br>
**FakeLib**<br>
    OgelGames<br>
**Farming Redo**<br>
    TenPlus1<br>
**Mobs Redo**<br>
    TenPlus1<br>
**Mobs Animal**<br>
    TenPlus1<br>
**Mobs Monster**<br>
    TenPlus1<br>
**mod utilities**<br>
    theFox<br>
**Unified Inventory Plus**<br>
    mt-mods<br>
**Unified Dyes**<br>
    mt-mods<br>
**Visual Harm 1Ndicators**<br>
    Mantar<br>
**WorldEdit**<br>
    sfan5<br>
**Xcompat**<br>
    mt-mods<br>
**Charater Animations (planned implementation)**<br>
    LMD<br>
**HomeDecor**<br>
    mt-mods<br>


## MINETEST ENGINE LIMITATIONS:<br>

Once you are a set distance from the NPC they are saved and unloaded from the world

As a workaround I use the following settings added to the minetest.conf file:

active_block_range = 8
active_object_send_range_blocks = 8
max_block_send_distance = 12
block_send_optimize_distance = 8

TBH I have not really looked into these settings in any depth.
But it seems that the NPC's will stay in the world upto just over 100 Units away with them implemented.

If the NPC does unload, not all required data is saved or loaded, small bugs like forgetting what they are doing may happen.
(Waiting for the Refactor to fix)





## SKINS:
All skins used in this mod excluding the originals from working_villages are created by myself.




<p>CURRENT NPC STATUS</p>

### Builder

Working under management from the Mayor
Builds buildings for the town under instructions from the Town Mayor
### Empty

Does nothing.

### Farmer

Working under management from the Mayor
Farms and Replants crops - Thought the player has to plant the first crops to show the farmer what do grow.

### Fireman

Working Prototype
Buggy AI movement, needs updating to current AI
Looks for wild fires, if founds attempts to extinguish them

### Follow_player

Working

### Gardener

Working under management from the Mayor
Clears plots ready for Builder (currently under development)
Clears weeds and cuts grass on a plot

### Lumberjack

Working under management from the Mayor
Chops down trees under orders from the Mayor
Manages an Orchard for a wood supply

### Mayor

Working - Under continous Development
Manages the Town development and NPC's

### Medic

Working Prototype
Buggy AI movement, needs updating to current AI
Searches for wounded friendly NPC's and heals them

### Miner

Working under management from the Mayor
Complexity of the Mining will be updated in the future, this will enable "scanning" for wanted items.
Currently digs a big hole and collects whats dug.

### Plant_collector

Working Prototype
Buggy AI movement, needs updating to current AI
Searches and collects wild farmable crops

### Snowclearer

Working Prototype
Buggy AI movement, needs updating to current AI
Looks for and removes snow

### Torcher

Untested

### Vet

Working Prototype
Buggy AI movement, needs updating to current AI
Same as medic but for friendly animals


## FUTURE ROLE CONSIDERATIONS

**Rubbish Collector**

goes around looking for rubbish to collect

**Sheep Shearer**

Handles the shearing of sheep and collection of Wool

**Cow Milker**

Handles the  milking of Cows and collection of Milk

**Roaming Hunter**

Goes out and Hunts known enemys

**Body guard**

Follows a player and attacks known enemys within a distance

**Policeman**

Goes around the town looking for enemys

**Security guard**

Stands guard on a entrance to a building or Town

**Roadlayer**

Like the builder but only Builds roads and paths

**egg collector**

Collects Eggs from a chicken pen

**Shepard**

Looks after Sheep or Cows

**Waterboy**

Collects water for use by others

**Foundry Worker**

Handles all cooking of recipes 

**Engineer**

Handles Crafting of non-wood based items

**Carpenter**

Handles the crafting of Wood based items

**Baker**

Converts farmed goods into food

**Butcher**

Not sure if applicable ??

**School teacher**

stays with the children in a school enviroment for most of the day

**Child NPC's**
    
    Water boy
    rabbit feeder
    chicken feeder
    ect

## CURRENT / FIXES / KNOWN BUGS

Builder not finding Wall mounted torches in chest:
Quick fix.. give the builder some standard torches and reload the map.
He will then convert them to what is needed.
quick Fix is planned.. 
When he dumps his pack, grab some torches by default.(TODO)


Miner going mining without ladders and digs himself in a large pit (TODO)


Medic: Fixed problem when Medic is healing NPC's (will have to check Vet next) Healing the shown healthbar health but not the actual NPC object health.


Builder forgetting to tell you what he wants. E.G when going back to the chest to look for a item. If left too long the builders speech text forgets the item.
This can be annoying, Though I use the CLI to see what he is doing and what item he wants. Sadly the only other way is too reload the level and see the fresh speech before it goes.
(Fix is in the works)


The close range entity avoidance is very simple. currently I look at the bug as the NPC's having a arguement. Using the Lead mod I just pull one out of the way and they
both continue as normal.. I have left this bug in as it helps with owner interaction with the NPC's. charactor 

## CURRENTLY PLANNED UPDATES AND TODOS


**Problem:** If a NPC dies its currently a pain to get them back.
**Solution:** A rewrite of the Town structural plan to include Hiring and Moving In Jobs as placed markers.
If you then lose a NPC, find the town marker for Hiring him and remove it. On the next Pass the Mayor will ReHire the NPC.
To Movein the New NPC, find his house marker and remove it. The Builder will check the Building and then the Mayor will move in the NPC.

**Problem:** Only one Town-plan is currently available
**Solution:** Have the Town-Planning-Data Selectable and Loadable from a file. Either Different Mayors for Different Towns, or a selection menu for the Town-Plan.

### Animation Updates
Want to add Fly, Swim, Crouch and Climb animations from the "Charater Animations" MOD to the NPC's.


### Animation Updates
It is planned to look into the Wielded item display functions, which currently does not seem to work.


Mayor AI Tasks. 






## LASTLY

One of the ideas for this mod is to start it in a non-creative mode, like a survival mode.

Though I have not found the answer to the following question:

Can a mod add a item to the single player inventory on game start (eg the Mayor NPC) ? 








NONE OF THE CODE IS FINISHED OR CORRECTIONS ARE FINISHED, JUST BUG FIXING FOR A USABLE MOD.
Take what you want and leave the rest :)



More information on this MOD can be found on the creators page that this is Forked from..
[working_villages](https://github.com/theFox6/working_villages)

Thanks to the theFox6 for the work already invested in this mod.

