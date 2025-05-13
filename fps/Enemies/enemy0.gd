extends CharacterBody3D

#@export var player: Node3D
@export var floating_distance: Vector2
@export var move_speed: float = 5.0
@export var chase_speed: float = 7.0
@export var health := 100

@onready var target_area = $Area3D 
@onready var raycast = $RayCast
@onready var muzzle_a = $MuzzleA
@onready var muzzle_b = $MuzzleB

var time := 0.0
var player = null
var float_target_position: Vector3
var chasing_target_position: Vector3
var player_position: Vector3
var destroyed := false

func _ready():
	float_target_position = position # When ready, save the initial position
	player_position = position # When ready, save the initial position


func _process(delta):
	#self.look_at(player.position + Vector3(0, 0.5, 0), Vector3.UP, true)  # Look at player
	#
	#if floating_distance > Vector2.ZERO:
		##float_target_position.y += (cos(time * 5) * 1) * delta  # Sine movement (up and down)
		#float_target_position.x += (cos(time * floating_distance.x) * 1) * delta  # Sine movement (up and down)
	##el
	#time += delta
#
	#position = float_target_position
	pass


func _physics_process(delta):
	var velocity = Vector2.ZERO
	if player and chase_speed > 0:
		velocity = position.direction_to(player.position) * chase_speed
	#if chase_speed > 0: 
		#chasing_target_position += (position - player_position) * delta * chase_speed
	move_and_slide()
	

# Take damage from player
func damage(amount):
	#Audio.play("sounds/enemy_hurt.ogg")
	health -= amount

	if health <= 0 and !destroyed:
		destroy()


# Destroy the enemy when out of health


func destroy():
	#Audio.play("sounds/enemy_destroy.ogg")

	destroyed = true
	queue_free()


# Shoot when timer hits 0


func _on_timer_timeout():
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var collider = raycast.get_collider()

		if collider.has_method("damage"):  # Raycast collides with player
			# Play muzzle flash animation(s)

			muzzle_a.frame = 0
			muzzle_a.play("default")
			muzzle_a.rotation_degrees.z = randf_range(-45, 45)

			muzzle_b.frame = 0
			muzzle_b.play("default")
			muzzle_b.rotation_degrees.z = randf_range(-45, 45)

			#Audio.play("sounds/enemy_attack.ogg")

			collider.damage(5)  # Apply damage to player
