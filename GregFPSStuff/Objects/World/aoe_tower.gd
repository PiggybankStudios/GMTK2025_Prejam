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

func _on_area_3d_body_entered(body):
	if body == main_target:
		isTargetInArea = true

func _on_area_3d_body_exited(body):
	if body == main_target:
		isTargetInArea = false

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
