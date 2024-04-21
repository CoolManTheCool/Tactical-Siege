extends CharacterBody3D
@export var thrown: bool = false
@export var deploy: int = 6
@export var fade: int = 20
var time_elapsed: float = 0
var deployed: bool = false
@onready var max_density: float = $Smoke.material.density
var Init_Position: Vector3

func _enter_tree():
	$Smoke.material.density = 0
	Init_Position = position

func _process(delta):
	time_elapsed += delta
	if not thrown:
		position = Init_Position
	elif not deployed and time_elapsed >= deploy:
		$Smoke.material.density = lerpf(0, max_density, time_elapsed/10)
	elif deployed and time_elapsed >= (fade+deploy):
		$Smoke.material.density = lerpf(max_density, 0, time_elapsed/10)
