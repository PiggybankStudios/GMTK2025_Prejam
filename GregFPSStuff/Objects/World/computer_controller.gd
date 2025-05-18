extends Area3D

@export var player: Node3D
var player_in_range = false

func _ready():
	pass
	
#func _on_body_entered(body : CharacterBody3D):
	#pass
func _input(event):
	if(player_in_range): 
		if (event.is_action_pressed("Secondary_Fire") or event.is_action_pressed("Primary_Fire")):
			print("Computer Activated")	

func _on_body_entered(body: Node3D) -> void:
	if (body == player):
		print("Player in range")
		player_in_range = true

func _on_body_exited(body: Node3D) -> void:
	if (body == player):
		print("Player out of range")
		player_in_range = false
	#bring up programming menu 
	#pass # Replace with function body.
