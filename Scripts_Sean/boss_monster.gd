extends RigidBody3D

# ---- Interaction Values
@export_category("Interaction Values")
@export var max_health = 100
@onready var _current_health = max_health

# ---- Movement Path ----
var _grid_path = PackedVector3Array()
var _grid_path_target_index = 0
const MINIMUM_DISTANCE_TO_CELL_CENTER = 20
const SPEED_THRESHOLD_TO_INCREASE_HEIGHT = 2

# ---- Movement ----
var _velocity = Vector3.ZERO

@export_category("Body Scale and Grid Height")
@export var body_scale := 5.0
@export var grid_height := 10
@export var spawn_height := 40

@export_category("Movement")
@export var max_speed := 5.0
@export var max_acceleration := 5.0
##Read Only
@export var current_speed = 0.0

# ---- States ----
var _can_move = false


##----------------------------------------------
##                Interaction                  |
##----------------------------------------------

func damage(amount: int):
	_current_health = max(_current_health - amount, 0)
	print("Boss Monster damaged - Health: ", _current_health)
	if _current_health == 0:
		print("Boss Monster health: ", _current_health, " - Removing from scene!")
		self.queue_free()
	pass


##----------------------------------------------
##                   Set Up                    |
##----------------------------------------------

## Prepares the boss monster's data just after it's spawned
func initialize() -> void:
	_grid_path_target_index = 1
	self.gravity_scale = 0.0
	self.get_child(0).set_scale(Vector3.ONE * body_scale)
	self.position.y = spawn_height
	pass



##----------------------------------------------
##                   Update                    |
##----------------------------------------------

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_move_boss_monster(state)
	pass



##----------------------------------------------
##                 Navigating                  |
##----------------------------------------------

## Boss Monster adjusts its velocity to move toward its target grid_path index.
func _move_boss_monster(state):
	# Cases where moving needs to be toggled: 
		#1. Before grid_path is created - crash will occur when trying to access grid_path index out-of-bounds.
	if _can_move == false:
		return
	
	# Keep track of Rigidbody Velocity
	_velocity = state.linear_velocity
	var delta = state.get_step()
	
	# Target Direction
	var target_direction = _grid_path[_grid_path_target_index]
	if current_speed < SPEED_THRESHOLD_TO_INCREASE_HEIGHT: # If the boss gets stuck, it moves upwards. Simple, but should get it un-stuck.
		target_direction.y = spawn_height
	else:
		target_direction.y = grid_height
	target_direction = (target_direction - self.position).normalized()
	
	# Desired Velocity
	var desired_velocity = target_direction * max_speed
	var max_speed_change = max_acceleration * delta
	
	# Updating Velocity
	var current_velocity_x = _velocity.dot(Vector3.RIGHT)
	var current_velocity_y = _velocity.dot(Vector3.UP)
	var current_velocity_z = _velocity.dot(Vector3.FORWARD)
	var new_velocity_x = move_toward(current_velocity_x, desired_velocity.x, max_speed_change)
	var new_velocity_y = move_toward(current_velocity_y, desired_velocity.y, max_speed_change)
	var new_velocity_z = move_toward(current_velocity_z, desired_velocity.z, max_speed_change)
	_velocity.x += new_velocity_x - current_velocity_x
	_velocity.y += new_velocity_y - current_velocity_y
	_velocity.z += new_velocity_z - current_velocity_z
	
	# Apply velocity and update rotation in direction of movement
	self.look_at(self.position - _velocity, Vector3.UP)
	current_speed = _velocity.length()
	state.linear_velocity = _velocity
	
	# Distance check to cell center - if close enough, set next target to the next cell in the list.
	var position_xz = Vector2(self.position.x, self.position.z)
	var target_xz = Vector2(_grid_path[_grid_path_target_index].x, _grid_path[_grid_path_target_index].z)
	var distance = position_xz.distance_to(target_xz)		
	if distance < MINIMUM_DISTANCE_TO_CELL_CENTER:
		if _grid_path_target_index < _grid_path.size()-1:
			_grid_path_target_index += 1
			#print("new target: ", grid_path_target_index)
		else:
			_grid_path_target_index = 0
			#print("new target reset: ", grid_path_target_index)
	
	pass


## Toggle to allow boss monster to perform move calculations or not.
func set_move_state(value: bool):
	_can_move = value
	pass
	

##----------------------------------------------
##              Navigation Path                |
##----------------------------------------------

## Adds a new position the boss monsters movement path based on the level that was generated
func add_block_to_grid_path(block_position: Vector3) -> void:
	_grid_path.append(block_position)
	pass


## Gets the current size of the boss monster's navigation path
func get_path_size():
	return _grid_path.size()


## Clears the boss monster's navigation path - a reset before creating a new path.
func clear_grid_path():
	_grid_path.clear()
	pass
	
	
##----------------------------------------------
##                 Debugging                   |
##----------------------------------------------
	
func draw_grid_path():
	var counter = 0
	var line_start = Vector3.ZERO
	var line_end = Vector3.ZERO
	var draw_height = 15
	while counter < _grid_path.size()-1:
		# Line
		line_start = _grid_path[counter]
		line_start.y = draw_height
		line_end = _grid_path[counter+1]
		line_end.y = draw_height
		Draw3d.line(line_start, line_end, Color.BLUE)
		# Position Number
		draw_grid_label(counter, line_start, draw_height)	
		# Next Position
		counter +=1
		
	line_start = _grid_path[counter]
	line_start.y = draw_height
	line_end = _grid_path[0]
	line_end.y = draw_height
	Draw3d.line(line_start, line_end, Color.BLUE)
	draw_grid_label(counter, _grid_path[counter], draw_height)
	pass
	

func draw_grid_label(label_name, draw_position: Vector3, draw_height: int):
	var grid_label = Label3D.new()
	grid_label.name = str("PATH_POINT_", label_name)
	grid_label.text = str(label_name)
	grid_label.font_size = 200
	grid_label.position = draw_position
	grid_label.position.y = draw_height+1
	#print("index: ", label_name, " - label position: ", grid_label.position)
	grid_label.billboard = true
	get_tree().get_root().add_child.call_deferred(grid_label)
	pass
