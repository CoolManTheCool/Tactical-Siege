extends RigidBody3D

@export var pinned: bool = true
@export var thrown: bool = false
@export var starting_vel = 0
@export var update_vel = false
@export var deploy: int = 6
@export var fade: int = 20
var time_elapsed: float = 0
var deployed: bool = false
@onready var max_density: float = $Smoke.material.density

func _enter_tree():
	$Smoke.material.density = 0

func _process(delta):
	gravity_scale = 1
	if update_vel:
		linear_velocity = starting_vel
		update_vel = false
	time_elapsed += delta
	if not deployed and time_elapsed >= deploy:
		$Smoke.material.density = lerpf(0, max_density, time_elapsed/10)
	elif deployed and time_elapsed >= (fade+deploy):
		$Smoke.material.density = lerpf(max_density, 0, time_elapsed/10)
	if not thrown:
		gravity_scale = 0
