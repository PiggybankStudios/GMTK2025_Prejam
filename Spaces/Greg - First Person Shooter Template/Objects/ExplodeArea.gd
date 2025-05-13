extends Area3D

@export var explode_force = 500
@export var damage: int = 5
@export var hit_direction: Vector3 = Vector3.ZERO
@export var proj: Node3D

var my_delta

signal Hit_Successful


func _physics_process(delta):
	my_delta = delta
	for o in get_overlapping_bodies():
		if o is RigidBody3D:
			var force = (o.global_position - global_position).normalized()
			force *= explode_force
			o.apply_impulse(force)
		#elif o is CharacterBody3D:
			#o.Applied_Force += (global_position - o.global_position).normalized() * explode_force * delta

func _on_area_3d_body_entered(body):
	# if body != CharacterBody3D:
	# 	return
	# 	body.Applied_Force += (global_position - body.global_position).normalized() * explode_force
	#if body.is_in_group("Target") && body is CharacterBody3D: #body.has_method("Hit_Successful"):
	if body is CharacterBody3D and body.has_method("Hit_Successful"):
		hit_direction = (global_position - body.global_position).normalized()
		print_debug("Direction: ", hit_direction)
		# body.Hit_Successful(Damage, _proj.global_transform.basis.z, _proj.global_transform.origin)
		body.Hit_Successful(damage, -hit_direction, global_transform.origin, explode_force)
		Hit_Successful.emit()
