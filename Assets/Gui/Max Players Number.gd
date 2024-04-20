extends Label
@onready var slider: HSlider = %"Max Players"
@onready var slider_value: float = slider.value
@onready var init_pos: float = position.x
@onready var notch_offset: float = slider.size.x / (slider.tick_count-0.5)

func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	slider_value = slider.value
	text = str(slider_value)
	position.x = init_pos + notch_offset * (slider_value-2)/4.8
