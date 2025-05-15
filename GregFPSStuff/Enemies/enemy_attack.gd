extends Node3D

@export var projectile_to_load: PackedScene
@export var bullet_to_load: PackedScene
@export var fire_rate: float = 10
@export var damage = 1
@export var spread: Vector2 = Vector2.ZERO
@export var range =  1000

@onready var Bullet_Point = get_node("%BulletPoint")
@onready var Debug_Bullet = preload("res://GregFPSStuff/Objects/Spawnable_Objects/hit_debug.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_timer_timeout():
	Load_Projectile()
	pass


func Load_Projectile():
	print("Loading Projectile")
	var _projectile:Enemy_Projectile = projectile_to_load.instantiate()
	Bullet_Point.add_child(_projectile)
	_projectile.global_transform.origin = Bullet_Point.global_transform.origin
	#_projectile.rotate(Vector3.UP,deg_to_rad(Bullet_Point.transform.rotation))
	#_projectile.body_entered.connect(_on_detection_area_body_entered.bind(_projectile))
	_projectile._Set_Projectile(damage,spread,range,Bullet_Point)

	
	#Add_Signal_To_HUD.emit(_projectile)
	# Launch_Rigid_Body_Projectile(_projectile, projectile_to_load)
	# _projectile._Set_Projectile(damage,spread,range,Bullet_Point)
	# var _Direction = (Vector3.FORWARD - global_transform.origin).normalized()
	# _projectile.set_linear_velocity(_Direction*float(projectile_to_load.Projectile_Velocity))
	# if !Fire_Towards_Camera:
		# _Direction = Vector3.FORWARD

# func Set_Projectile(_projectile:Projectile, _Damage: int = 0,_spread:Vector2 = Vector2.ZERO, _Range: float = 1000, _source: Node3D = null):
# 	pass

# func Launch_Rigid_Body_Projectile(_projectile:Projectile, _proj: PackedScene):
# 	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_detection_area_body_entered(body):
	pass # Replace with function body.
