extends CharacterBody3D

enum lethals { IMPACT, M69, SMOKE, }
var lethal_speeds: PackedFloat32Array = [ 15, 20, 20]
# Player Variables
@export_category("Player")
@export_range(0, 100) var health: float = 100 ## Player's current health
@export_group("Movement")
@export_node_path("Node3D") var headPath : NodePath ## Path to head
@onready var head: Node3D = get_node(headPath)
@export_node_path("AnimationPlayer") var AnimPath : NodePath ## Path to animation player
@onready var Anim: AnimationPlayer = get_node(AnimPath)
@export var walk_speed: float = 4 ## movement speed
@export var sneak_offset: float = 2 ## movement speed when sneaking
@export var sprint_offset: float = 2 ## movement speed when running
@export var speed: float = 1  # this is a placeholder and is set to sprint sneak or walk speed
@export var jump_velocity: float = 4.5 ## Velocity += this when jumping
@export_range(0.1, 100.0) var sensitivity_x = 50 ## horizontal sensitivity
@export_range(0.1, 100.0) var sensitivity_y = 50 ## vertical sensitivity
@export_group("Weapons")
@export_range(0, 2) var lethal_cd: float = 1 ## Cooldown for using lethals, in seconds
@export var selected_lethal: lethals = lethals.SMOKE
var lethal_cd_elapsed: float = 0
var sneaking: bool = false
var mouse_delta := Vector2.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") # gravity
var last_mouse_pos = Vector2()
var is_me: bool = false ## is_mulitplayer_authority()
var body_count: int = 0 # This is NOT what is sounds like, its count of objects above the player.
var just_exited: bool = false
var held_lethal: RigidBody3D

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	is_me = is_multiplayer_authority()
	$Head/Camera3D.current = is_me
	$"Mesh".visible = !is_me

func _self_delete():
	queue_free()

func _physics_process(delta):
	if is_me and not $"../GUI/Pause Menu".visible:
		mouseMovement()
		movement(delta)
		leathals(delta)

func leathals(delta):
	# lethals (grenades)
	if lethal_cd_elapsed < lethal_cd:
		lethal_cd_elapsed += delta
	elif Input.is_action_just_pressed("lethal"):
		held_lethal = load("res://Assets/Weapons/Lethals/smoke_grenade.tscn").instantiate()
		add_child(held_lethal, true)
		held_lethal.thrown = false
	elif Input.is_action_just_released("lethal"):
		if held_lethal and is_instance_valid(held_lethal):
			held_lethal.queue_free()
		rpc("spawn_lethal", selected_lethal, self)
		lethal_cd_elapsed = 0

@rpc("reliable", "call_local")
func spawn_lethal(lethal: lethals, thrower):
	if lethal == lethals.SMOKE:
		var spawned_lethal = load("res://Assets/Weapons/Lethals/smoke_grenade.tscn").instantiate()
		$"../".add_child(spawned_lethal, true)
		spawned_lethal.position = thrower.position + Vector3(0, 0.8, 0)
		spawned_lethal.thrown = true
		print("Smoke!")
		var direction = -thrower.find_child("Head").global_transform.basis.z.normalized()
		spawned_lethal.starting_vel = direction.normalized() * lethal_speeds[lethal]
		spawned_lethal.update_vel = true

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		mouse_delta += event.relative
		
func mouseMovement():
	var rotateDelta = Vector2(0, 0)
	rotateDelta.y += -mouse_delta.x * sensitivity_x / 20000
	rotateDelta.x += -mouse_delta.y * sensitivity_y / 20000
	# Apply rotation to the head
	head.rotate_x(rotateDelta.x)
	head.rotation.x = clamp(head.rotation.x, -PI / 2, PI / 2)
	
	rotate_y(rotateDelta.y)
	
	mouse_delta = Vector2.ZERO

func movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("sneak") and not sneaking:
		Anim.play("Sneak")
		sneaking = true
	var releasedSneak = Input.is_action_just_released("sneak")
	var leftRoofCollision = just_exited and sneaking and not Input.is_action_pressed("sneak")
	if (releasedSneak or leftRoofCollision) and body_count == 0:
		Anim.play_backwards("Sneak")
		just_exited = false
		sneaking = false
	if Input.is_action_pressed("sneak"):
		speed = walk_speed - sneak_offset
	elif Input.is_action_pressed("sprint"):
		speed = walk_speed + sprint_offset
	else:
		speed = walk_speed
	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward") 
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else: 
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	# Move and slide.
	move_and_slide()


func _on_area_3d_body_entered(_body):
	body_count += 1


func _on_area_3d_body_exited(_body):
	body_count -= 1
	just_exited = true
