extends Label
@export var max_scale: float = 5
@export var min_scale: float = 2
@export var speed: float = 5
var time: float = 0
var sv: float = 0 # scale vector
var ps: float = 0 # positive sine

func _ready():
	var file = FileAccess.open("res://Assets/Gui/spashes.txt", FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	var splash_text = content.split("\n")
	var random_index = rand_from_seed(Time.get_ticks_usec())[0] % (splash_text.size()-1)
	text = splash_text[random_index]


func _process(delta):
	time += delta
	ps = (1+sin(time*speed))/2
	sv = ps*min_scale-(ps-1)*max_scale
	scale.x = sv
	scale.y = sv
