extends Marker3D
enum lethals { SMOKE, HIGH_EXPLOSIVE, IMPACT, FLASH }

@export_group("Grenades")
@export_range(0, 2) var Lethal_CD: float = 1 ## Cooldown for using lethals, in seconds
@export var Selected_Lethal: lethals = lethals.SMOKE
var Packed_Lethals: Array[PackedScene] = [
	load("res://Assets/Weapons/Lethals/smoke_grenade.tscn")
]
var Lethal_Speeds: PackedFloat32Array = [
	15,
	20,
	25,
	20
]

var Packed_Guns: Array[PackedScene] = [
	load("res://Assets/Weapons/Assault Rifle/Assault_Rifle.tscn")
]

@onready var gun: Node3D

var Spawned_Lethal
var Held_Lethal: CharacterBody3D
var Lethal_CD_Elapsed: float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $"../../".is_me and not $"../../../GUI/Pause Menu".visible:
		leathals(delta)

func leathals(delta):
	# lethals (grenades)
	if Lethal_CD_Elapsed < Lethal_CD:
		Lethal_CD_Elapsed += delta
	elif Input.is_action_just_pressed("lethal"):
		Held_Lethal = Packed_Lethals[Selected_Lethal].instantiate()
		add_child(Held_Lethal, true)
		Held_Lethal.thrown = false
	elif Input.is_action_just_released("lethal") and is_instance_valid(Held_Lethal):
		Held_Lethal.queue_free()
		rpc("spawn_lethal", $"../../")
		Lethal_CD_Elapsed = 0

@rpc("reliable", "call_local")
func spawn_lethal(thrower):
	Spawned_Lethal = Packed_Lethals[Selected_Lethal].instantiate()
	$"../../../".add_child(Spawned_Lethal, true)
	Spawned_Lethal.position = thrower.position + Vector3(0, 0.8, 0)
	Spawned_Lethal.thrown = true
	print("Smoke!")
	var direction = -thrower.find_child("Head").global_transform.basis.z.normalized()
	Spawned_Lethal.velocity = direction.normalized() * Lethal_Speeds[Selected_Lethal]
