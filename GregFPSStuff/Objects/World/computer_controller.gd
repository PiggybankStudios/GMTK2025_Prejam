extends Area3D

@export var player: Node3D

func _ready():
	pass
	
#func _on_body_entered(body : CharacterBody3D):
	#pass
	

func _on_body_entered(body: Node3D) -> void:
	if (body == player && Input.is_action_just_pressed("ui_accept")):
		print("pressed")
	#bring up programming menu 
	#pass # Replace with function body.
