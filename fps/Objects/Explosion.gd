extends Node3D #Spatial is now Node3D

@onready var particles:GPUParticles3D# = $Explosion/Particles

func _ready():
	#unparent self
	
	#particles = get_parent().get_node("Particles")
	pass


func _on_Timer_timeout():
	queue_free()



func _on_area_3d_body_entered(body):
	pass # Replace with function body.
