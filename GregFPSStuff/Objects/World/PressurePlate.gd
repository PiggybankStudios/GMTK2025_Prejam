extends Area3D

func _ready():
	pass

func _on_body_entered(body):
	messageStepOn()

func _on_body_exited(body):
	messageStepOff()

func messageStepOn():
	print("Pressure plate stepped on at " + str(global_transform.origin))

func messageStepOff():
	print("Pressure plate stepped off at " + str(global_transform.origin))  
