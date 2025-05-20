extends Node

## The node placed within this Level Block that acts as the Player Spawn Position
@export var player_spawn_node: Node3D

	

func get_player_spawn_position():	
	## If a spawn position node has not been placed yet, preset the spawn position to be above this level's blocks center.
	if player_spawn_node == null:
		print("Level Block spawn node is null! Sending center position.")
		var new_spawn_position = self.position
		new_spawn_position.y = 30
		return new_spawn_position
		
	## Otherwise get the spawn position of the attached node.
	else:
		return player_spawn_node.position + self.position
