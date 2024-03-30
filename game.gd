extends Node3D
enum {KICK_UNKNOWN, KICK_BANNED, KICK_VOTED_OFF, KICK_ADMIN_KICK, KICK_HOST_DISCONNECTED, LEAVE_CLIENT_DISCONNECT}
enum { MIST }
var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene = load("res://Player/player.tscn")
var connected: bool = false


func _ready():
	pass

func _peer_kicked(id: int):
	if id == 1:
		print("Host was kicked from the lobby, ignoring")
		

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	if Input.is_action_just_pressed("pause"):
		if %"Main Menu".visible:
			close_game()
		elif %"Server Menu".visible:
			%"Main Menu".visible = true
			%"Server Menu".visible = false
		elif %"Pause Menu".visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			%"Pause Menu".visible = false

func close_game():
	if connected:
		if multiplayer.is_server():
			for peers in peer.host.get_peers():
				peers.peer_disconnect(KICK_HOST_DISCONNECTED)
		multiplayer.multiplayer_peer.close()
	get_tree().quit()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		close_game()

func host_left():
	%"Main Menu".visible = true

func unload_map():
	for children in $"Level".get_children():
		children.queue_free()
	
func load_map(map):
	if map == MIST:
		print("I got misty")
		$"Level".add_child(load("res://Assets/Maps/mist.tscn").instantiate())
		print_tree_pretty()

func add_player(id = 1):
	if not multiplayer.is_server():
		return
	if has_node(str(id)):
		print("A player with ID", id, "already exists.")
		return
	var player = player_scene.instantiate()
	player.name = str(id)  # Use the unique network ID
	add_child(player)
	print("Added player with ID", id)

func delete_player(id):
	var player_node = get_node(str(id))
	if player_node:
		player_node.queue_free()
		print("Deleted player with ID", id)
	else:
		print("Error: Attempted to delete non-existent player with ID", id)

func _on_host_pressed(attemp: int = 0):
	
	if attemp >= 5:
		pass
	
	var error = peer.create_server(%Port.text.to_int(), %"Max Players".value)
	if error == ERR_ALREADY_IN_USE:
		print("Cannot create server, peer already in use, trying again")
		_on_host_pressed(attemp+1)
		return
	load_map(MIST)
	peer_setup()

func _on_join_pressed():
	var error = peer.create_client(%Address.text, %Port.text.to_int())
	peer_setup()

func peer_setup():
	multiplayer.multiplayer_peer = peer
	connected = true
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)
	multiplayer.server_disconnected.connect(host_left)
	%"Server Menu".hide()
