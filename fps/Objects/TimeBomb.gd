extends RigidBody3D

const GOLDEN_ANGLE = PI * (3 - sqrt(5))

@export var base_damage_per_ray = 5
@export var radius := 5.0
@export var num_points := 250
@export var explosion_effect = preload("res://Objects/Explosion.tscn") #preload accepts scene objects but not .gd afaik
var rays := []


func _ready():
	_create_rays()


func _create_rays() -> void:
	var points = _get_points()
	for point in points:
		var ray = RayCast3D.new()
		add_child(ray)
		ray.target_position = point
		ray.enabled = false
		ray.exclude_parent = true
		rays.append(ray)


func _get_points() -> Array:
	var points = []
	
	for point in num_points:
		var y: float = 1.0 - (point / (num_points - 1.0)) * 2.0
		var r: float = sqrt(1 - y*y)
		
		var angle_increment: float = GOLDEN_ANGLE * point
		
		var x: float = cos(angle_increment) * r
		var z: float = sin(angle_increment) * r
		
		points.append(Vector3(x, y, z) * radius)
	
	return points


func _get_explosion_ray_data() -> Array:
	var colliding_rays = []
	for ray in rays:
		ray.enabled = true
		ray.force_raycast_update()
		
		if ray.get_collider():
			colliding_rays.append(ray)
	
	return colliding_rays


func _explode():
	var explosion_rays = _get_explosion_ray_data()
	for ray in explosion_rays:
		var collider = ray.get_collider()
		
		#if collider.get_method("take_damage"):
			#var damage = _calculate_damage(ray.get_collision_point())
			#collider.take_damage(damage)
	
	var explosion = explosion_effect.instantiate(PackedScene.GEN_EDIT_STATE_MAIN_INHERITED) #instantiate needs packedScene arguments to work
	get_parent().add_child(explosion)
	if !get_parent().is_in_group("World"):
		explosion.set_as_top_level(true)
	explosion.global_transform.origin = global_transform.origin
	queue_free()

func _explosion_force(_explosion_rays):
	for ray in _explosion_rays:
		var collider = ray.get_collider()
		
	pass
	
func _calculate_damage(collision_point: Vector3) -> float:
	var distance = global_transform.origin.distance_to(collision_point)
	var damage = base_damage_per_ray * (radius - distance)
	
	return damage if damage > 0 else 0


func _on_Timer_timeout():
	_explode()
