extends Area3D

@export var main_target: CharacterBody3D
@export var isDamaging: bool
@export var isTargetInArea: bool
@export var damage: int = 1

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
