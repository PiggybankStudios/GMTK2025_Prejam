
## --- Level Manager ---
## Creates the 3D course and collisions that will be interacted with.
## Uses a grid to create a loop of blocks of 3D meshes.
## ------

extends Node

## -- GRID ---

## The number of grid spaces in both X and Y axis.
@export var grid_count := 6

## The size of each grid space.
@export var grid_scale := 6
@onready var grid_scale_half = grid_scale / 2.0


## --- BLOCK DATA ---

## The list of paths that levels will be generated from. A single red pixel is the starting position.
@export var map_image_paths : Array[Image]

## The list of level blocks used to generate level. MUST BE IN ORDER: Tunnel, Corner, Intersection. 
## All block details are kept in separate arrays and tracked by index.
@export var block_list_straight : Array[PackedScene]
@export var block_list_corner : Array[PackedScene]


enum BlockType {
	TUNNEL,
	CORNER,
	INTERSECTION
}
var block_type := BlockType

enum SpaceType {
	BLACK = 1,
	RED = 2,
	YELLOW = 3,
	WHITE = 4
}
var space_type := SpaceType

var player_spawn_position = Vector3.ZERO
const PLAYER_SPAWN_HEIGHT = 10


## --- RNG ---

var rng = RandomNumberGenerator.new()



##----------------------------------------------
##              Level Generation               |
##----------------------------------------------

## Creates the level by placing blocks in a loop on a grid, and instatiates the Player Character at that level's spawn point.
func create_level(player: PackedScene) -> void:
	
	if block_list_straight.size() < 1 or block_list_corner.size() < 1:
		push_error("Level_Manager's block_list_straight or block_list_corner is empty - cannot generate level.")
	else:
		var map_index = randi_range(0, map_image_paths.size()-1)
		print("Map Selected: ", map_index)
		generate_blocks_from_map_image(map_index)
		spawn_player_character(player)
	pass


## Returns the center position of the cell from the passed index.
func get_cell_center_from_grid_index(index: int):
	var x_position = grid_scale_half + (grid_scale * (index % grid_count))
	var z_position = grid_scale_half + (grid_scale * ((index / grid_count) % grid_count))
	##print("--------------")
	##print(str("grid position: ", index, " - grid_scale_half: ", grid_scale_half, " - x: ", x_position, " - z: ", z_position))
	return Vector3(x_position, 0, z_position)


## Finds the Red Pixel (Score = 2) in the map image to start generating the level from.
## PIXEL SCORING: Black = 1, Red = 2, Yellow = 3, White = 4
func generate_blocks_from_map_image(index: int):
	
	if map_image_paths.size() < 1:
		push_error("Trying to generate level when no map image paths are in level_manager.")
		return
		
	if index >= map_image_paths.size():
		push_error("Trying to access a map image from outside the list range.")
		return
	
	var map = map_image_paths[index]
	
	for j in grid_count:
		for i in grid_count:
			var pixel_value = map.get_pixel(i,j)
			var pixel_score = pixel_value[0] + pixel_value[1] + pixel_value[2] + pixel_value[3]
			##print(str("pixel position: ", j, ", ", i, " - value: ", pixel_value, "  --  pixel score: ", pixel_score))
			generate_block(i, j, pixel_score, index)
	pass


func generate_block(grid_x: int, grid_z: int, space: int, map_index: int):
	var ignore = 0
	if space == SpaceType.BLACK:
		ignore = 0 ## generate scenery here
		
	elif space == SpaceType.YELLOW:
		ignore = 0 ## send position to boss script for when it sets up
		
	elif space == SpaceType.WHITE or space == SpaceType.RED:
		var neighbors = get_level_block_neighbors(grid_x, grid_z, map_index)
		var new_block
		var block_id
		
		## Up-Left: corner 1
		if neighbors[0] > 1 and neighbors[1] > 1:
			block_id = randi_range(0, block_list_corner.size()-1)
			new_block = block_list_corner[block_id].instantiate()
			new_block.name = "BLOCK_CORNER"
			new_block.rotate_y(deg_to_rad(270))
		
		## Left-Down: corner 2
		elif neighbors[1] > 1 and neighbors[2] > 1:
			block_id = randi_range(0, block_list_corner.size()-1)
			new_block = block_list_corner[block_id].instantiate()
			new_block.name = "BLOCK_CORNER"
			new_block.rotate_y(deg_to_rad(180))
		
		## Down-Right: corner 3
		elif neighbors[2] > 1 and neighbors[3] > 1:
			block_id = randi_range(0, block_list_corner.size()-1)
			new_block = block_list_corner[block_id].instantiate()
			new_block.name = "BLOCK_CORNER"
			new_block.rotate_y(deg_to_rad(90))
			
		## Right-Up: corner 4
		elif neighbors[3] > 1 and neighbors[0] > 1:
			block_id = randi_range(0, block_list_corner.size()-1)
			new_block = block_list_corner[block_id].instantiate()
			new_block.name = "BLOCK_CORNER"
			# No rotation needed
			
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

		## Finish this block's details
		if new_block != null:
			var x_position = (grid_x * grid_scale) + grid_scale_half
			var z_position = (grid_z * grid_scale) + grid_scale_half
			new_block.position = Vector3(x_position, 0,z_position)
			add_child(new_block)
			
			if space == SpaceType.RED:
				player_spawn_position = new_block.get_player_spawn_position()
				##print("player spawn position: ", player_spawn_position)
				##player_spawn_position = new_block.level_block.get_player_spawn_position()				
				##player_spawn_position = Vector3(x_position, PLAYER_SPAWN_HEIGHT, z_position)
				
	else:
		push_error(str("Pixel not recognized in map image: ", map_index, " - pixel score: ", space, " - position: ", grid_x, ", ", grid_z))
	pass


## Get the level block neighbors to the passed grid position. Returned as Vector4(Up, Left, Down, Right).
## TO DO: need to stop the pixel check if out of image bounds
func get_level_block_neighbors(grid_x: int, grid_z: int, map_index: int):
	var map = map_image_paths[map_index]
	var up = get_pixel_score( map.get_pixel(grid_x, grid_z+1) )
	var left = get_pixel_score( map.get_pixel(grid_x-1, grid_z) )
	var down = get_pixel_score( map.get_pixel(grid_x, grid_z-1) )
	var right = get_pixel_score( map.get_pixel(grid_x+1, grid_z) )
	return Vector4(up, left, down, right)


func get_pixel_score(pixel_value: Color):
	return pixel_value[0] + pixel_value[1] + pixel_value[2] + pixel_value[3]



##----------------------------------------------
##               Asset Placement               |
##----------------------------------------------

## Instantiates a player character controller 
func spawn_player_character(player: PackedScene):
	var newPlayer = player.instantiate()
	newPlayer.position = player_spawn_position
	newPlayer.name = "Player_Character"
	add_child(newPlayer)
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
