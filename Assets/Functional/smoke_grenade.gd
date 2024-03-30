extends Node3D
@export var deploy: int = 10
@export var fade: int = 10
var time_elapsed: float = 0
var deployed: bool = false
@onready var density: float = $Smoke.material.density

func _on_ready():
	$Smoke.material.density = 0

func _process(delta):
	time_elapsed += delta
	if not deploy and time_elapsed >= deploy:
		$Smoke.material.density = move_toward(0, 3, time_elapsed/10)
	elif deploy and time_elapsed >= (fade+deploy):
		$Smoke.material.density = move_toward(3, 0, time_elapsed/10)
	pass
