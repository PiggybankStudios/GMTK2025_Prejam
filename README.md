# Loop Mechanic (GMTK 2025 Pre-Jam)
* When: Monday May 12th - Sunday May 18th
* Engine: Godot 4.4.1-stable

# Restriction Ideas (https://wheelofnames.com/95e-pp2)
Think inside the box
YOLO
Dis is 2 complicated
Fuel the fire
I need glasses
Just my luck
Git Gud
Gotta go fast
Limited 3D movement
Limited 3D aiming
obscure 80s/90s arcade mechanics
No place like home
Glamorous
Hidden Humor
Baby hell mode
More better more better
To infinity and beyond
Lock and Key
Another Mans Shoes
I speak in numbers
Dont trust the Devs
I cant help myself
Hidden danger
Tortoise and the Hare
Squeaker squeak squeakum
Its over 9000!!!
Keep it G rated
Tis only a flesh wound
You can pet the dog
A good high
Big Bad Wolf
Subliminal Advertising
Only input is typing words
Everything must be based on Kenny Assets
Only one image/sprite/texture for entire game
Must use GMTK logo extensively
Everything must have physics
Everything can be broken/destroyed
Mouse input only
Must use microphone input
Must have splitscreen
Healthy diet
Must have achievements 
Camera must be fixed
Only one level layout
Music recording on computer mic

# Genre Ideas (https://wheelofnames.com/eet-5fx)
Fighter
Shooter
Puzzle
Racing
Sport
Simulation
Idle
Story
Rogue
Survival
Strategy
RPG
Arcade
Terminal
Maze 
Scrolling Shooter/SHMUP
Falling/Matching Block Puzzle
Sokoban
Memory/Mathcing Game
Deck Builder
Demolition
Programming/Typing
Colony Builder
Rythm/Music
Multiple OS Windows
Text Adventure (ASCII-based)
Inventory/Space Management
Parkour
Mystery / Detective
Drawing (Line Rider, Pictionary) 
Lemmings-like
Rail shooter
Search Action 
Boomer Shooter/Doom clone
1st person Grid-based Dungeon Crawler

# Theme Ideas (https://wheelofnames.com/5at-62z)
Space
Prehistoric
Hippie
Nature
Oceanic
Microscopic
Medieval
Monochrome
Obra Dinn Style (1-bit + dithering)
Voxels
Steampunk
Dystopian Trailerpark (Ready Player One style)
Computer Simulation (Tron)
Pencil Drawings
Japanese Cutesy
Dwarves / Mines
Eldritch Horror (Cthulhu)

# Ideas
Programming problems that restrict space that you have to solve
Input using programming
Program a little robot while having first person controls
QWOP? Robot has QWOP mechanics? (Toribash, Repo)
2 player: Type name of objects, teleport to that object, other person is attempting to catch the person, they have to type tool names of stuff to counteract the place where the first player is
Cast spells and do actions by typing (RPG style?)
Type anything you wanted, the system tries to interpret it automatically
Scribblenauts
Rogue-like mechanics?
Gamedev Simulator? You get scores on the games you make?
Loop Hero in 3D (maybe doomlike 3D?), you're stuck moving in a loop, you have little computers on the side you program and then can't change them until you get back to them, you control risk and reward (control monster spawning?) Combat or Resource oriented? One big bad bug following you?

1 Battery you start with, monster can attack the battery as he goes by it
Everything automatically gets power from battery
Rotate a crank to generate power
3 types of stations: get resources, makes resources (refinement?), deals damage
Stations can take damage (spring that pushes monster back but degrades over time)
Boss drops resource, he drops more as he gets hurt, if hurt a lot, or maybe threshold, he drops "special" resource and it degrades if you don't pick it up quickly
Certain distance around boss, he attacks and you lose health
(A boss?) the further you get ahead of the boss the more he speeds up
(A boss?) He turns around if you're farther than 1/2 around the loop (May have cheese problems)
(A boss?) Get's mad while he can't see you, and rushes forward when he overflows with rage
Bosses have "phases", when they are below a certain health threshold they move faster, or drop poison floor, or etc.
Arena could be different for each boss?

# TODO List:
	[ ] First person movement walking around a fixed path
	[ ] Boss that moves around the loop slowly
	[ ] Boss attacks when you get near, player has health, dies when out of health
	[ ] Boss drops scrap slowly, player picks up scrap when walking over it
	[ ] HUD for resources, 2 resources "regular" scrap and "special" scrap
	[ ] Battery that has a capacity and fill percentage, player can see the battery amount when they look at it (WAILA style)
	[ ] Battery has crank that allows you to manually generate power
	[ ] Player can build robots, click on a space, option pops up for what you want to build.
		- 10 scrap to build a dart robot
		- 5 scrap to build a bomb
	[ ] Player can open up the GUI for a robot when clicking/interacting with it
	[ ] In robot GUI, you can drag commands from pool into a list of commands
	[ ] Robot GUI has start/stop button. Running robots do commands at some speed and pull power
	[ ] Battery can be upgraded to allow faster power gen, and to have more capacity
	[ ] Player can place pressure plates that provide inputs to robots
	[ ] 

# Extra
	[ ] Upgrade - Charge while running around the loop and discharge into battery
	[ ] Pressure plate that activates when boss walks over to generate power to nearby robots
	[ ] Warddrobe (steampunk version?) that you can hide in and it uses power
	[ ] Hammer robot that swings and knocks the boss forward/backward based on direction (need to reset while boss is not there in order to avoid speeding up the boss)
	[ ] 
	
# Sound Effect List
	[ ] Running Robot Loop
	[ ] Cranking battery
	[ ] Boss attack (roar)
	[ ] Boss getting hurt (grunt)
	[ ] Boss steps sound
	[ ] Dart machine attacks
	[ ] Pressure Plate Press/Release
	[ ] Bomb exploding
	[ ] Flamethrower sound (loop)
	[?] Open/Close GUI
	[ ] Main Menu Music
	[ ] Gameplay music/ambience
	[ ] Click effect
	[ ] 