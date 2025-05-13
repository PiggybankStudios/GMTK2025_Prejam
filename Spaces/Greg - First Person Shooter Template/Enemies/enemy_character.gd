extends CharacterBody3D

@export var player: CharacterBody3D
var cooldown:bool = false
@export var floating_distance: Vector2
@export var move_speed: float = 5.0
@export var chase_speed: float = 7.0
@export var health := 100
@export var invincible = false
#@export var player = null

#@onready var target_area = $Area3D 
#@onready var raycast = $RayCast
#@onready var muzzle_a = $MuzzleA
#@onready var muzzle_b = $MuzzleB
@onready var detection_area = $DetectionArea
@onready var attack_timer = $Enemy_Attack_Holder/AttackTimer
@onready var enemy_attack_holder = $Enemy_Attack_Holder

var target_velocity = Vector3.ZERO
var time := 0.0
var curr_chase_speed = 0.0
var float_target_position: Vector3
var chasing_target_position: Vector3
var player_position: Vector3
var destroyed := false
var Applied_Force : Vector3

#vars for alt enemy attack logic
var target: CharacterBody3D
@export var rigid_body_projectile: PackedScene
@export var spawn_point: Marker3D
@export var attack_rate: int = 3
@export var projectile_velocity: int = 2
@export var projectile_damage: float = 10


func _ready():
	float_target_position = position # When ready, save the initial position
	player_position = position # When ready, save the initial position

func _process(delta):
	#look_at(player.position, Vector3.UP, true)  # Look at player
	
	#if floating_distance > Vector2.ZERO:
		##float_target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)
		#float_target_position.x += (cos(time * floating_distance.x) * 1) * delta  # Sine movement (up and down)
	##el
	#time += delta
#
	#position = float_target_position
	pass

#Alt enemy attack logic
func start_attack(new_target:CharacterBody3D)->void:
	if not cooldown:
		target = new_target
		var new_rigid_body_projectile = rigid_body_projectile.instantiate()
		var target_position = target.global_position
		var direction:Vector3 = (target_position - spawn_point.global_position).normalized()
		new_rigid_body_projectile.global_transform = spawn_point.global_transform
		new_rigid_body_projectile.set_as_top_level(true)
		new_rigid_body_projectile.set_linear_velocity(direction*projectile_velocity)
		new_rigid_body_projectile.damage = projectile_damage
		get_tree().get_root().add_child(new_rigid_body_projectile)
		cooldown = true
		get_tree().create_timer(attack_rate).timeout.connect(on_attack_cooldown)
	
func on_attack_cooldown()->void:
	cooldown = false
func _on_timer_timeout():
	start_attack(player)

func _physics_process(delta):
	#look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)  # Look at player	
	#if player and curr_chase_speed == 0:
		#look_at(player.position, Vector3.UP, false)  # Look at player	
		#target_velocity = curr_chase_speed
	#if player and curr_chase_speed > 0:
		#look_at(player.position)
		#velocity = position.direction_to(player.position) * curr_chase_speed
	if player != null:
		look_at(player.position, Vector3.UP, false)  # Look at player	
		target_velocity = position.direction_to(player.position) * curr_chase_speed
	# target_velocity.x = curr_chase_speed
	# target_velocity.z = curr_chase_speed
	
	# velocity = target_velocity + (Applied_Force * delta)
	velocity = target_velocity + Applied_Force
	move_and_slide()

	# Applied_Force = Vector3.ZERO
	#if chase_speed > 0: 
		#chasing_target_position += (position - player_position) * delta * chase_speed
	

# Take damage from player
func damage(amount):
	#Audio.play("sounds/enemy_hurt.ogg")
	if invincible: 
		return
	health -= amount

	if health <= 0 and !destroyed:
		destroy()

func Hit_Successful(Damage, _Direction: Vector3 = Vector3.FORWARD, _Position: Vector3 = Vector3.ZERO, _pushes_back:float = 0):
	if destroyed:
		return
	
	health -= Damage
	#Audio.play("sounds/enemy_hurt.ogg")
	#add force to enemy back in opposite direction of hit 
	# if _pushes_back:		
		#add force from direction of hit
	Applied_Force += _Direction * _pushes_back

	#wait for 0.5 seconds
	#set to default velocity from previous state
	await get_tree().create_timer(0.5).timeout
	Applied_Force *= Vector3.ZERO

	if health <= 0:
		destroy()


# Destroy the enemy when out of health
func destroy():
	#Audio.play("sounds/enemy_destroy.ogg")
	axis_lock_angular_x = false
	axis_lock_angular_z = false
	destroyed = true
	#queue_free()

# Shoot when timer hits 0
#func _on_timer_timeout():
	#pass
	#raycast.force_raycast_update()

	#if raycast.is_colliding():
		#var collider = raycast.get_collider()
#
		#if collider.has_method("damage"):  # Raycast collides with player
			## Play muzzle flash animation(s)
#
			#muzzle_a.frame = 0
			#muzzle_a.play("default")
			#muzzle_a.rotation_degrees.z = randf_range(-45, 45)
#
			#muzzle_b.frame = 0
			#muzzle_b.play("default")
			#muzzle_b.rotation_degrees.z = randf_range(-45, 45)
#
			##Audio.play("sounds/enemy_attack.ogg")
#
			#collider.damage(5)  # Apply damage to player


func _on_detection_area_area_entered(area):
	#if area.get
	pass
	
func _on_detection_area_body_entered(body):
	if destroyed:
		return
	print_debug("Enter: ", body)
	if body.is_in_group("Player"):
		player = body
		curr_chase_speed = chase_speed
		attack_timer.process_mode = PROCESS_MODE_INHERIT
		print_debug("chasing Player!")
		# enemy_attack_holder.target = player
	pass # Replace with function body.


func _on_detection_area_body_exited(body):
	if destroyed:
		return
	print_debug("Exiting: ", body)
	if body.is_in_group("Player"):
		player = body
		curr_chase_speed = 0.0
		attack_timer.process_mode = PROCESS_MODE_DISABLED
		print_debug("Stopped Chasing Player...")
		
	pass # Replace with function body.
