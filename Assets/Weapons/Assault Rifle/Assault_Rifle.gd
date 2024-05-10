extends Node3D
@export_node_path("RayCast3D") var cursor_path: NodePath ## Path to head
@onready var cursor: Node3D = get_node(cursor_path)
var scoped: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("shoot"):
		pass
	#scoping stuff
	if ProjectSettings.get_setting("game/hold_to_scope"):
		scoped = Input.is_action_pressed("scope")
	elif Input.is_action_just_pressed("scope"):
		scoped = not scoped
