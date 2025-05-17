extends Sprite2D

var MenuOptions = ["New Game", "Levels", "Options", "Credits", "Exit"]
var fontSize = 30
var startX = 0
var startY = -140
var temp_font = load("res://Fonts/The Centurion.otf")


func _ready():
	var spokes = MenuOptions.size()
	var degrees = 2 * PI / spokes
	var newText = load("res://Prefabs/obj_text.tscn")
	for n in spokes:
		var newOption = newText.instantiate()
		var curRot = degrees * n
		add_child(newOption)
		newOption.position = Vector2(startX*cos(curRot) - startY*sin(curRot),startX*sin(curRot) + startY*cos(curRot))
		newOption.rotation = curRot
		newOption.name = "Spot" + str(n)
		var TempNode = get_node("Spot" + str(n))
		TempNode.SetFontAndSize(temp_font,fontSize,MenuOptions[n])
		if n == 0 :
			TempNode.SetAsActive()
		#newOptionText.add_theme_font_override("font", temp_font) 
		#newOptionText.add_theme_font_size_override("font_size", fontSize) 
		#print(newOptionText.size)
