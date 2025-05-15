extends Node3D
class_name Enemy_Projectile

signal Hit_Successful

@export var Projectile_Velocity: float = 10
@export var Expirey_Time: int = 10
@export var Display_Debug_Decal: bool = true
@export var Fire_Towards_Camera: bool = false
@export var Rigid_Body_Projectile: PackedScene

@onready var Debug_Bullet = preload("res://GregFPSStuff/Objects/Spawnable_Objects/hit_debug.tscn")

var Damage: float = 0
var Projectiles_Spawned = []
var Projectile_Direction: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().create_timer(Expirey_Time).timeout.connect(_on_timer_timeout)

func _Set_Projectile(_Damage: int = 0,_spread:Vector2 = Vector2.ZERO, _Range: float = 1000, _source: Node3D = null):
	print("Setting Projectile")
	Damage = _Damage
	# global_transform.origin = _source.global_transform.origin
	# transform.origin = _source.transform.origin
	#transform.basis = _source.transform.basis
	# rotation.z = deg_to_rad(_source.transform.basis.get_euler().z)
	# look_at(_source.position, Vector3.UP)
	# rotate(_source.transform.basis.z, deg_to_rad(_source.transform.basis.get_euler().z))
	# Launch_Projectile(_source.position, Rigid_Body_Projectile)
	#Fire_Projectile(_Damage,_Range,_source)
	Fire_Projectile(_spread,_Range, Rigid_Body_Projectile, _source)

func Fire_Projectile(_damage,_range, _proj, _source: Node3D = null):
	#var Shooter_Collision = Shooter_Ray_Cast(_source, _range)
	# Launch_Projectile(_proj)
	Launch_Rigid_Body_Projectile(_source.transform.origin,_proj)

func Shooter_Ray_Cast(_source: Node3D, _range: float = 1000):
	var Ray_Origin = _source.global_transform.origin
	var Ray_End = (Ray_Origin + _source.global_transform.basis.z*_range)
	
	var New_Intersection = PhysicsRayQueryParameters3D.create(Ray_Origin,Ray_End)
	# New_Intersection.set_collision_mask(0b11101111)
	New_Intersection.set_collision_mask(0b11111111)
	
	var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	
	if not Intersection.is_empty():
		var Collision = [Intersection.collider,Intersection.position]
		return Collision
	else:
		return [null,Ray_End]

func Launch_Projectile(_projectile):
	print("Launching Projectile")
	var _proj = _projectile.instantiate()
	add_child(_proj)
	
	Projectiles_Spawned.push_back(_proj)

	_proj.body_entered.connect(_on_body_entered.bind(_proj))
	
	# var _Direction = (_Point - global_transform.origin).normalized()
	#_proj.set_linear_velocity(_Direction*Projectile_Velocity)
	
	_proj.set_linear_velocity(global_transform.basis.z *Projectile_Velocity)
	
func Launch_Rigid_Body_Projectile(_Point: Vector3, _projectile):
	print("Launching Projectile " + str(Projectiles_Spawned.size()))
	var _proj = _projectile.instantiate()
	add_child(_proj)
	_proj.global_transform.origin = _Point
	Projectiles_Spawned.push_back(_proj)

	_proj.body_entered.connect(_on_body_entered.bind(_proj))
	
	var _Direction = (_Point - global_transform.origin).normalized()
	if !Fire_Towards_Camera:
		_Direction = Vector3.FORWARD
	_proj.set_as_top_level(true)
	_proj.set_linear_velocity(_Direction*Projectile_Velocity)
	Projectile_Direction = _Direction
# func Camera_Ray_Cast(_spread: Vector2 = Vector2.ZERO, _range: float = 1000):
# 	var _Camera = get_viewport().get_camera_3d()
# 	var _Viewport = get_viewport().size
	
# 	var Ray_Origin = _Camera.project_ray_origin(_Viewport/2)
# 	var Ray_End = (Ray_Origin + _Camera.project_ray_normal((_Viewport/2)+Vector2i(_spread))*_range)

# 	var New_Intersection = PhysicsRayQueryParameters3D.create(Ray_Origin,Ray_End)
# 	New_Intersection.set_collision_mask(0b11101111)
	
# 	var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	
# 	if not Intersection.is_empty():
# 		var Collision = [Intersection.collider,Intersection.position]
# 		return Collision
# 	else:
# 		return [null,Ray_End]

func Hit_Scan_Collision(Collision: Array,_damage):
	var Point = Collision[1]
	var Bullet_Point = get_parent()
	
	if Collision[0]:
		Load_Decal(Point)
		
		if Collision[0].is_in_group("Target"):
			var Bullet = get_world_3d().direct_space_state

			var Bullet_Direction = (Point - Bullet_Point.global_transform.origin).normalized()
			var New_Intersection = PhysicsRayQueryParameters3D.create(Bullet_Point.global_transform.origin,Point+Bullet_Direction*2)

			var Bullet_Collision = Bullet.intersect_ray(New_Intersection)

			if Bullet_Collision:
				Hit_Scan_Damage(Bullet_Collision.collider, Bullet_Direction,Bullet_Collision.position,_damage)

func Hit_Scan_Damage(Collider, Direction, Position, _damage):
	if Collider.is_in_group("Target") and Collider.has_method("Hit_Successful"):
		Hit_Successful.emit()
		Collider.Hit_Successful(_damage, Direction, Position)
		queue_free()

func Load_Decal(_pos):
	if Display_Debug_Decal:
		var rd = Debug_Bullet.instantiate()
		var world = get_tree().get_root()
		world.add_child(rd)
		rd.global_translate(_pos)
		

func _on_body_entered(body, _proj):
	if body.is_in_group("Target") && body.has_method("Hit_Successful"):
		body.Hit_Successful(Damage)
		Hit_Successful.emit()
		print ("HitScan Successful")


	Load_Decal(_proj.get_position())
	_proj.queue_free()
		
	Projectiles_Spawned.erase(_proj)
	
	if Projectiles_Spawned.is_empty():
		queue_free()

func _on_timer_timeout():
	queue_free()
