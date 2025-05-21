extends Area3D

@export var main_target: CharacterBody3D
@export var isDamaging: bool
@export var isTargetInArea: bool
@export var damage: int = 1
@export var damage_collider: CollisionShape3D
@export var sphere_mesh: MeshInstance3D

@export var active_timer: Timer
@export var deactive_timer: Timer
@export var damage_timer: Timer

@onready var Debug_aoe_tower = preload("res://GregFPSStuff/Objects/Spawnable_Objects/aoe_tower.tscn")
@onready var Debug_turret = preload("res://GregFPSStuff/Objects/Spawnable_Objects/proj_turret_static.tscn")


func _on_body_entered(body):
	print("body entered")
	isTargetInArea = true
	# if body == main_target:

func _on_body_exited(body):
	print("body exited")
	isTargetInArea = false
	# if body == main_target:

func _process(delta):
	if isTargetInArea && isDamaging:
		print("damage taken: " + str(damage))
		# main_target.take_damage(10)

func _on_timer_timeout():
	isDamaging = true

func _on_timer_2_timeout():
	isDamaging = false


func _on_active_timer_timeout() -> void:
	print("active")
	isDamaging = true
	damage_collider.disabled = false
	sphere_mesh.set_visible(isDamaging)
	damage_collider.set_process_mode(Node.PROCESS_MODE_INHERIT)
	active_timer.stop()
	deactive_timer.start()
	pass # Replace with function body.

func _on_deactive_timer_timeout() -> void:
	print("deactive")
	isDamaging = false
	damage_collider.disabled = true
	sphere_mesh.set_visible(isDamaging)
	damage_collider.set_process_mode(Node.PROCESS_MODE_DISABLED) 
	deactive_timer.stop()
	active_timer.start()
	pass # Replace with function body.

func _on_damage_timeout() -> void:
	pass # Replace with function body.


func _on_countdown_to_inactive_timeout() -> void:
	pass # Replace with function body.
