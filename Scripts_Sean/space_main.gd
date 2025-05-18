
extends Node3D

## Generates level geometry from a list of blocks, based on a 2D image.
@onready var levelManager := $level_manager as Node3D

## Player controller is instantiated during runtime, always at spawn point on level_manager.
@export var playerCharacter := PackedScene

## Boss Monster is instantiated during runtime, always at boss spawn point on level_manager.
@export var bossMonster := PackedScene

var pauseMenu = "/root/Menu"



func _ready() -> void:
#{
	levelManager.create_level(playerCharacter)
	levelManager.draw_grid()
	pass
#}
func _process(_delta) -> void:
	if (Input.is_action_just_pressed("PauseMenu")):
		process_mode = Node.PROCESS_MODE_DISABLED
		get_tree().root.get_node(pauseMenu).getUnPaused()

func unPauseMe() :
	process_mode = Node.PROCESS_MODE_PAUSABLE
	print("unpausing the level")
