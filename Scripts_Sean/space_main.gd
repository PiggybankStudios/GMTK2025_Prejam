
extends Node3D

@onready var levelManager := $level_manager as Node3D

func _ready() -> void:
	
	levelManager.create_level()
	levelManager.draw_grid()
	pass
	
	
func _process(_delta) -> void:

	pass
