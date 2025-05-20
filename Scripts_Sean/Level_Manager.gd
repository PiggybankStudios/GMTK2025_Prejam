
## --- Level Manager ---
## Creates the 3D course and collisions that will be interacted with.
## Uses a grid to create a loop of blocks of 3D meshes.
## ------

extends Node

# ---- Boss Monster ----
var boss_monster_instance
var boss_monster_spawn_grid_position = Vector2.ZERO

# ---- Player ----
var player_spawn_position = Vector3.ZERO
const PLAYER_SPAWN_HEIGHT = 10

# ---- GRID ----
## The number of grid spaces in both X and Z axis.
@export var grid_count := 6
## The size of each block in both X and Z axis -- Determined by scale in BLENDER, needs to be consistent!
@export var level_block_size := 10
## The scale of each block in the scene
@export var level_block_scale := 1.0

## The size of each grid space.
@onready var grid_scale = 2 * level_block_size * level_block_scale
@onready var grid_scale_half = grid_scale / 2.0 	## setting as @onready allows 'grid_scale' to update before this is set.


# ---- BLOCK DATA ----
## The list of paths that levels will be generated from. A single red pixel is the starting position.
@export var map_image_paths : Array[Image]

## The list of level blocks used to generate level. MUST BE IN ORDER: Tunnel, Corner, Intersection. 
## All block details are kept in separate arrays and tracked by index.
@export var block_list_straight : Array[PackedScene]
@export var block_list_corner : Array[PackedScene]

enum SpaceType {
	BLACK = 1,
	RED = 2,
	YELLOW = 3,
	WHITE = 4
}
var space_type := SpaceType

var total_blocks_in_generated_level = 0


# ---- RNG ----
var rng = RandomNumberGenerator.new()



##----------------------------------------------
##              Level Generation               |
##----------------------------------------------

## Gets the total spaces in this grid.
func get_total_grid_spaces():
	return grid_count * grid_count


## Creates the level by placing blocks in a loop on a grid, and instatiates the Player Character at that level's spawn point.
func create_level(player: PackedScene, bossMonster: PackedScene) -> void:	
	if block_list_straight.size() < 1 or block_list_corner.size() < 1:
		push_error("Level_Manager's block_list_straight or block_list_corner is empty - cannot generate level.")
	else:
		var map_index = randi_range(0, map_image_paths.size()-1)
		print("Map Selected: ", map_index)
				
		generate_blocks_from_map_image(map_index)	
		spawn_player_character(player)
		spawn_boss_monster(bossMonster)
		set_boss_monster_navigation_loop(map_index)
		#boss_monster_instance.draw_grid_path()
		boss_monster_instance.set_move_state(true)
	pass


## Finds the Red Pixel (Score = 2) in the map image to start generating the level from.
## PIXEL SCORING: Black = 1, Red = 2, Yellow = 3, White = 4
func generate_blocks_from_map_image(index: int):
	# Guards	
	if map_image_paths.size() < 1:
		push_error("Trying to generate level when no map image paths are in level_manager.")
		return
		
	if index >= map_image_paths.size():
		push_error("Trying to access a map image from outside the list range.")
		return
	
	# Preset level data
	total_blocks_in_generated_level = 0
	var map = map_image_paths[index]
	
	# Loop over map image and generate each block
	for j in grid_count:
		for i in grid_count:
			var pixel_value = map.get_pixel(i,j)
			var pixel_score = pixel_value[0] + pixel_value[1] + pixel_value[2] + pixel_value[3]
			##print(str("pixel position: ", j, ", ", i, " - value: ", pixel_value, "  --  pixel score: ", pixel_score))
			generate_block(i, j, pixel_score, index)
	pass


## Generates a single level block based on this block's neighbors. Looks through every pixel in the passed map image.
## Also sets spawn positions for the Player and Boss Monster.
func generate_block(grid_x: int, grid_z: int, space: int, map_index: int):
	var ignore = 0
	
	# Generate scenery
	if space == SpaceType.BLACK:
		ignore = 0 ## generate scenery here
	
	# Generate the level and spawn information
	elif space == SpaceType.WHITE or space == SpaceType.RED or space == SpaceType.YELLOW:
		var neighbors = get_level_block_neighbors(grid_x, grid_z, map_index)
		var new_block
		var block_id
		
		## Up-Left: corner 1
		if neighbors[0] > 1 and neighbors[1] > 1:
			block_id = randi_range(0, block_list_corner.size()-1)
			new_block = block_list_corner[block_id].instantiate()
			new_block.name = "BLOCK_CORNER"
			new_block.rotate_y(deg_to_rad(180))
		
		## Left-Down: corner 2
		elif neighbors[1] > 1 and neighbors[2] > 1:
			block_id = randi_range(0, block_list_corner.size()-1)
			new_block = block_list_corner[block_id].instantiate()
			new_block.name = "BLOCK_CORNER"
			new_block.rotate_y(deg_to_rad(270))
		
		## Down-Right: corner 3
		elif neighbors[2] > 1 and neighbors[3] > 1:
			block_id = randi_range(0, block_list_corner.size()-1)
			new_block = block_list_corner[block_id].instantiate()
			new_block.name = "BLOCK_CORNER"
			# No rotation needed
			
		## Right-Up: corner 4
		elif neighbors[3] > 1 and neighbors[0] > 1:
			block_id = randi_range(0, block_list_corner.size()-1)
			new_block = block_list_corner[block_id].instantiate()
			new_block.name = "BLOCK_CORNER"
			new_block.rotate_y(deg_to_rad(90))
			
		## Up-Down: straight 1
		elif neighbors[0] > 1 and neighbors[2] > 1:
			block_id = randi_range(0, block_list_straight.size()-1)
			new_block = block_list_straight[block_id].instantiate()
			new_block.name = "BLOCK_STRAIGHT"
			## no rotation needed
			
		## Left-Right: straight 2
		elif neighbors[1] > 1 and neighbors[3]> 1:
			block_id = randi_range(0, block_list_straight.size()-1)
			new_block = block_list_straight[block_id].instantiate()
			new_block.name = "BLOCK_STRAIGHT"
			new_block.rotate_y(deg_to_rad(90))

		## -- Finish this block's details --
		if new_block != null:
			## Block Details
			var x_position = (grid_x * grid_scale) + grid_scale_half
			var z_position = (grid_z * grid_scale) + grid_scale_half
			new_block.position = Vector3(x_position, 0,z_position)
			new_block.scale *= level_block_scale
			add_child(new_block)
			total_blocks_in_generated_level += 1
			
			## Player Details
			if space == SpaceType.RED:
				player_spawn_position = new_block.get_player_spawn_position()
			
			## Monster Details
			elif space == SpaceType.YELLOW:
				boss_monster_spawn_grid_position = Vector2(grid_x, grid_z)
			
	else:
		push_error("Pixel not recognized in map image: ", map_index, " - pixel score: ", space, " - position: ", grid_x, ", ", grid_z)
	pass


## Creates a navigation path in the passed map for the Boss Monster. 
## Starting at the Boss Monster spawn position, only looks through neighbors along the path.
func set_boss_monster_navigation_loop(map_index: int):
	## variable declarations
	var added_grid_positions: Array[Vector2] = []
	var cell = Vector2(boss_monster_spawn_grid_position.x, boss_monster_spawn_grid_position.y)
	var block_counter = 1
	var neighbors
	var cell_check
	
	## start as known player start position - will always be on the path
	boss_monster_instance.clear_grid_path()
	var player_spawn_cell = Vector3((cell.x * grid_scale) + grid_scale_half, 0, (cell.y * grid_scale) + grid_scale_half)
	boss_monster_instance.add_block_to_grid_path(player_spawn_cell)
	
	## local function to add a new path point
	var check_neighbor = func is_neighbor_valid_and_added(direction, x, z):
		var grid_position = Vector2(x, z)
		#print("CHECKING - direction: ", direction, " - position: ", grid_position, " - added: ", added_grid_positions.find(grid_position))
		if direction > 1 and added_grid_positions.find(grid_position) == -1:
			added_grid_positions.append(grid_position)
			var pos_x = (x * grid_scale) + grid_scale_half
			var pos_z = (z * grid_scale) + grid_scale_half
			boss_monster_instance.add_block_to_grid_path(Vector3(pos_x, 0, pos_z))
			#print(	"grid: ", grid_position, " - position: ", Vector3(pos_x, 0, pos_z), " - grid index: ", boss_monster_instance.get_path_size()-1)
			return Vector2(x, z)	
		return Vector2(-1, -1)
	
	## begin while loop - once player start position is found as a neighbor, we're done
	while block_counter < total_blocks_in_generated_level:
		neighbors = get_level_block_neighbors(cell.x, cell.y, map_index)
		block_counter += 1
		#print("---------------------------")
		#print(" --- Block Counter: ", block_counter, " - Total Blocks: ", total_blocks_in_generated_level, " - cell: ", cell)
		# UP
		cell_check = check_neighbor.call(neighbors[0], cell.x, cell.y-1)
		if cell_check != Vector2(-1, -1):
			cell = cell_check
			continue	
		# LEFT
		cell_check = check_neighbor.call(neighbors[1], cell.x-1, cell.y)
		if cell_check != Vector2(-1, -1):
			cell = cell_check
			continue	
		# DOWN
		cell_check = check_neighbor.call(neighbors[2], cell.x, cell.y+1)
		if cell_check != Vector2(-1, -1):
			cell = cell_check
			continue	
		# RIGHT
		cell_check = check_neighbor.call(neighbors[3], cell.x+1, cell.y)
		if cell_check != Vector2(-1, -1):
			cell = cell_check
			continue

		print("No valid neighbors for this block: ", block_counter, " - boss monster path finding aborted.")
		return
	
	pass


## Get the level block neighbors to the passed grid position. Returned as Vector4(Up, Left, Down, Right).
## TO DO: need to stop the pixel check if out of image bounds
func get_level_block_neighbors(grid_x: int, grid_z: int, map_index: int):
	var map = map_image_paths[map_index]
	var up = get_pixel_score( map.get_pixel(grid_x, grid_z-1) )
	var left = get_pixel_score( map.get_pixel(grid_x-1, grid_z) )
	var down = get_pixel_score( map.get_pixel(grid_x, grid_z+1) )
	var right = get_pixel_score( map.get_pixel(grid_x+1, grid_z) )
	return Vector4(up, left, down, right)


## Get the combined total of the passed color as a single value. This indicates the type of block
## that this color represents.
func get_pixel_score(pixel_value: Color):
	return pixel_value[0] + pixel_value[1] + pixel_value[2] + pixel_value[3]



##----------------------------------------------
##                Grid Functions               |
##----------------------------------------------

## Returns the center position of the cell from the passed index.
func get_cell_center_from_grid_index(index: int):
	@warning_ignore("integer_division")
	var z_position = grid_scale_half + (grid_scale * ((index / grid_count) % grid_count))
	var x_position = grid_scale_half + (grid_scale * (index % grid_count))
	##print("--------------")
	##print(str("grid position: ", index, " - grid_scale_half: ", grid_scale_half, " - x: ", x_position, " - z: ", z_position))
	return Vector3(x_position, 0, z_position)



##----------------------------------------------
##               Asset Placement               |
##----------------------------------------------

## Instantiates a player character controller into the scene
func spawn_player_character(player: PackedScene):
	var newPlayer = player.instantiate()
	newPlayer.position = player_spawn_position
	newPlayer.name = "Player_Character"
	self.owner.add_child(newPlayer) #sets player as child of the root node
	pass


## Instantiates a bossMonster into the scene
func spawn_boss_monster(bossMonster: PackedScene):
	## Boss Monster creation
	boss_monster_instance = bossMonster.instantiate()
	boss_monster_instance.set_move_state(false)
	var spawn_x = (boss_monster_spawn_grid_position.x * grid_scale) + grid_scale_half
	var spawn_z = (boss_monster_spawn_grid_position.y * grid_scale) + grid_scale_half
	boss_monster_instance.position = Vector3(spawn_x, 0, spawn_z)
	boss_monster_instance.name = "Boss_Monster"
	self.owner.add_child(boss_monster_instance) # sets boss as child of the root node
	
	## Boss Monster data init
	boss_monster_instance.initialize()
	pass



##----------------------------------------------
##                 Debugging                   |
##----------------------------------------------

## Draws the grid, if it exists.
func draw_grid() -> void:
	
	var grid_counter = 0
	
	var draw_position = Vector3.ZERO
	var position_x = 0
	var position_y = 1
	var position_z = 0
	
	var line_start_position = Vector3.ZERO
	var line_end_position = Vector3.ZERO
	var line_x = 0
	var line_z = 0
	
	## draw grid POINTS and grid LABELS
	for i in grid_count:
		for j in grid_count:
			position_x = j * grid_scale
			position_z = i * grid_scale
			draw_position = Vector3(position_x, 0, position_z)
			Draw3d.point(draw_position, 0.05)
			## add grid label
			var grid_label = Label3D.new()
			grid_label.name = str("Grid Space: ", (i + j))
			grid_label.text = str(grid_counter)
			grid_counter += 1
			grid_label.font_size = 200
			grid_label.position = Vector3(position_x + (grid_scale * 0.5), position_y, position_z + (grid_scale * 0.5))
			grid_label.billboard = true
			add_child(grid_label)
			
	## draw gide LINES
	for i in grid_count+1:
		line_x = i * grid_scale
		line_z = i * grid_scale
		## X-Axis
		line_start_position = Vector3(line_x, 0, 0)
		line_end_position = Vector3(line_x, 0, grid_count * grid_scale)
		Draw3d.line(line_start_position, line_end_position)
		## Z-Axis
		line_start_position = Vector3(0, 0, line_z)
		line_end_position = Vector3(grid_count * grid_scale, 0, line_z)
		Draw3d.line(line_start_position, line_end_position)

	pass
