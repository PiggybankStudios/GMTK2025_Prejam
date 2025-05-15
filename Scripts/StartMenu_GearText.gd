extends Sprite2D

var MenuOptions = ["Continue", "Levels", "Options", "Credits", "Exit"]
var fontSize = 30
var startX = 0
var startY = -77
var temp_font = load("res://Fonts/The Centurion.otf")


func _ready():
	var spokes = MenuOptions.size()
	var degrees = 2 * PI / spokes
	var spriteTexture = load("res://ArtAssets/Gear5Spoke.png")
	for n in spokes:
		var newOption = Node2D.new()
		var newOptionText = Label.new()
		var newOptionSprite = Sprite2D.new()
		var curRot = degrees * n
		add_child(newOption)
		newOption.position = Vector2(startX*cos(curRot) - startY*sin(curRot),startX*sin(curRot) + startY*cos(curRot))
		newOption.rotation = curRot
		newOption.name = "Spot" + str(n)
		var TempNode = get_node("Spot" + str(n))
		TempNode.add_child(newOptionSprite)
		newOptionSprite.texture = spriteTexture
		TempNode.add_child(newOptionText)
		newOptionText.add_theme_font_override("font", temp_font) 
		newOptionText.add_theme_font_size_override("font_size", fontSize) 
		newOptionText.text = MenuOptions[n]
		newOptionText.horizontal_alignment = 1
		newOptionText.vertical_alignment = 1
		newOptionText.position = Vector2(newOptionText.position.x,newOptionText.position.y)
		newOptionText.position = Vector2(newOptionText.position.x - newOptionText.size.x/2,newOptionText.position.y - newOptionText.size.y)
		#print(newOptionText.size)
		
func _process(delta):
	rotation += 1 * delta
	var otherGear = get_parent().get_child(0)
	otherGear.rotation -= 1 * delta * 5/8
