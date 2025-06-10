# simple_working_villages mod by RayFT,
<br> An updated version of the working_villages MOD by theFox6.

## Description:
The main purpose of this mod is to add a Mayor NPC Character to the Minetest Game. 

This being for two reasons:

1) Having an active lived in feel to a world area.

2) To help younger players automate the building and collection process.

Once deployed the Mayor will automatically start to build a small town, and Hire and Manage other Villagers to help.
These other Villagers will fulfill planned jobs in the town to aid in its development.

Your Role is to help manage the Villagers to complete their tasks.

NOTE: until the AI for the Workshop NPC is ready, the player must fulfill this role in the custom built workshop.

## screenshots

![Screenshot 1](screenshot.png)

![Screenshot 2](screenshot.2.png)

![Screenshot 3](screenshot.3.png)

![Screenshot 4](screenshot.4.png)


## Personal Objectives with this project:
    Having a little look into LUA programming.
    Having a little look into the workings of Minetest.
    Having a little play with 3d pathing.
    Having a little play in Simple Tasked based AI.  

# Code Status
My Code in this mod is "Get it Working" and is as dirty as ya mom.
Current build is experimental and concerned with information gathering.
Be Warned ::: I have not used LUA before taking on this project, its all a learning curve.

**MOSTLY WORKING, WORK IN PROGRESS..**

Not really wanting fixes or updates, as this build is currently experimental only.
Comments and suggestions are most welcome, and may even be implemented.

Complete Refactoring is Planned.

# MINETEST VERSION TESTED WITH THIS MOD.

**Version used for development = 5.12.0**

Planned min testing version = 5.6.1

# MINETEST MODULES TESTED WITH THIS MOD.

These are the minetest mods used with development:

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




# CURRENT NPC STATUS

## Mayor
**Working**

    Holds the Town development Plans
    Hires New Villagers
    Manages Moving in the Villagers
    Instructs/Managers the Villagers
    Brings a starter pack to start the construction

## Builder
**Working**

    Builds buildings for the town under instructions from the Town Mayor.
    Uses a designated chest for storage
    Notifies the owner if he runs out of supplies

## Empty
Does nothing.

## Farmer
**Working**

    Works under instruction from the Mayor
    Farms and Replants crops (Though, the player has to plant the first crops to show the farmer what do grow and where)
    Collects harvested crops and stores them in his chest

## Fireman
Working Prototype

    Buggy AI movement, needs updating to current AI
    Wonders around aimlessly Looking for wild fires
    If a fire is found, he attempts to extinguish it
        

## Follow_player
**Working**

## Gardener
**Working**

    Clears plots ready for Builder (currently under development)
    Clears weeds and cuts grass on a plot (currently under development)
    Currently Wonders around cutting grass.

## Lumberjack
**Working**

    Chops down trees under orders from the Mayor.
    Manages an Orchard
    Collects harvested wood and saplings in a chest

## Medic
Working Prototype

    Buggy AI movement, needs updating to current AI
    Wonders around looking for wounded friendly NPC's
    Heals them if he can catch them

## Miner
**Working**

    Currently digs a big hole down as far as he can (before he unloads from the game)
    He collects whats dug in a chest.
    Complexity of the Miner will be updated in the future, this will enable "scanning" for wanted items.

## Plant_collector
Working Prototype

    Buggy AI movement, needs updating to current AI
    Searches and collects wild farmable crops

## Snowclearer
Working Prototype

    Buggy AI movement, needs updating to current AI
    Looks for and removes snow

## Torcher
Untested

## Vet
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

There are a few.. but hopefully less each week.

One to be looked into shortly is the placement of Hires seems to be incorrect, not where I expect some of them to be created..  minor but annoying.
Medic Fixs people well, but his AI cannot handle fences for love nor money. Updated AI is in the works.

A Dirt with Grass node seems to have slipped in the field schematic..  will be removed at some point.. minor. I would test with creative at this point of development.
 
A few of the latest bugs Fixed:
    the old working_villages over-riding simple_working_villages in the Luanti game
    Lumberjack not trying to collect supplies from his chest.
    Miner not trying to collect supplies from his chest.
    Medic not healing the actual Object health, just the entitys health ?
    Farmer not moving into his house correctly
    Plot marker left in Town plan has now been replaced with a test building upgrade

## CURRENT TOWN TODOS ??


**Problem:** If a NPC dies its currently a pain to get them back.
**Solution:** A rewrite of the Town structural plan to include Hiring and Moving In Jobs as placed markers.
If you then lose a NPC, find the town marker for Hiring him and remove it. On the next Pass the Mayor will ReHire the NPC.
To Movein the New NPC, find his house marker and remove it. The Builder will check the Building and then the Mayor will move in the NPC.

**Problem:** Only one Town-plan is currently available
**Solution:** Have the Town-Planning-Data Selectable and Loadable from a file. Either Different Mayors for Different Towns, or a selection menu for the Town-Plan.

## Animation Updates
I want to add Fly, Swim, Crouch and Climb animations from the "Character Animations" MOD to the NPC's.


## Animation Updates
It is planned to look into the Wielded item display functions, which currently does not seem to work.


Mayor AI advanced Tasks, and implementing a more advanced town-plan.. 






## LASTLY

    One of the ideas for this mod is to start it in a non-creative mode, like a survival mode.
    Though I have not found the answer to the following question:
    Can a mod add a item to the single player inventory on game start (eg the Mayor NPC) ? 




## CREDITS

Thank you to theFox6 for the work invested in starting this mod.

More information on this MOD can be found on the creators page that this is Forked from..
[working_villages](https://github.com/theFox6/working_villages)


