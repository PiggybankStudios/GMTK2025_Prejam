extends Node3D
class_name Projectile

signal Hit_Successful

@export_enum ("Hitscan","Rigidbody_Projectile") var Projectile_Type: String = "Hitscan"
@export var Projectile_Velocity: int
@export var Expirey_Time: int = 10
@export var Display_Debug_Decal: bool = true
@export var Fire_Towards_Camera: bool = true
@export var Rigid_Body_Projectile: PackedScene
@export var Destroy_RB_Projectile_On_Hit: bool = true
@onready var Debug_Bullet = preload("res://GregFPSStuff/Objects/Spawnable_Objects/hit_debug.tscn")

var Damage: float = 0
var Projectiles_Spawned = []
var Projectile_Direction: Vector3 = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().create_timer(Expirey_Time).timeout.connect(_on_timer_timeout)

func _Set_Projectile(_Damage: int = 0,_spread:Vector2 = Vector2.ZERO, _Range: int = 1000, _source: Node3D = null):
	Damage = _Damage
	Fire_Projectile(_spread,_Range, Rigid_Body_Projectile, _source)

#Direction to Fire Projectile
func Fire_Projectile(_spread,_range, _proj, _source: Node3D = null):
	var Camera_Collision = Camera_Ray_Cast(_spread,_range)
	match Projectile_Type:
		"Hitscan":
			if Fire_Towards_Camera == true:
				Hit_Scan_Collision(Camera_Collision, Damage)
		"Rigidbody_Projectile":
			if Fire_Towards_Camera == true:
				Launch_Rigid_Body_Projectile(Camera_Collision[1], _proj)
			else:
				var Shooter_Collision = Shooter_Ray_Cast(_source, _spread,_range)
				Launch_Rigid_Body_Projectile(Shooter_Collision[1], _proj)

func Shooter_Ray_Cast(_source: Node3D = self, _spread: Vector2 = Vector2.ZERO, _range: float = 1000):
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
	
#Raycast from camera
func Camera_Ray_Cast(_spread: Vector2 = Vector2.ZERO, _range: float = 1000):
	var _Camera = get_viewport().get_camera_3d()
	var _Viewport = get_viewport().size
	
	var Ray_Origin = _Camera.project_ray_origin(_Viewport/2)
	var Ray_End = (Ray_Origin + _Camera.project_ray_normal((_Viewport/2)+Vector2i(_spread))*_range)

	var New_Intersection = PhysicsRayQueryParameters3D.create(Ray_Origin,Ray_End)
	New_Intersection.set_collision_mask(0b11101111)
	
	var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	
	if not Intersection.is_empty():
		var Collision = [Intersection.collider,Intersection.position]
		return Collision
	else:
		return [null,Ray_End]

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
		print ("HitScan Successful")
		Hit_Successful.emit()
		Collider.Hit_Successful(_damage, Direction, Position)
		queue_free()

func Load_Decal(_pos):
	if Display_Debug_Decal:
		var rd = Debug_Bullet.instantiate()
		var world = get_tree().get_root()
		world.add_child(rd)
		rd.global_translate(_pos)

#Launch RB Projectile with point from camera collision & projectile to load
func Launch_Rigid_Body_Projectile(_Point, _projectile):
	print("Launching Projectile " + str(Projectiles_Spawned.size()))
	var _proj = _projectile.instantiate()
	add_child(_proj)
	
	Projectiles_Spawned.push_back(_proj)

	_proj.body_entered.connect(_on_body_entered.bind(_proj))
	
	var _Direction = (_Point - global_transform.origin).normalized()
	if !Fire_Towards_Camera:
		_Direction = Vector3.FORWARD
	_proj.set_as_top_level(true)
	_proj.set_linear_velocity(_Direction*Projectile_Velocity)
	Projectile_Direction = _Direction

func _on_body_entered(body, _proj):
	if body.is_in_group("Target") && body.has_method("Hit_Successful"):
		print("Hit Successful")
		# body.Hit_Successful(Damage, _proj.global_transform.basis.z, _proj.global_transform.origin)
		body.Hit_Successful(Damage, Projectile_Direction, _proj.global_transform.origin, 10)
		Hit_Successful.emit()

	Load_Decal(_proj.get_position())
	if Destroy_RB_Projectile_On_Hit:
		_proj.queue_free()
			
		Projectiles_Spawned.erase(_proj)
		
		if Projectiles_Spawned.is_empty():
			queue_free()

func _on_timer_timeout():
	queue_free()
