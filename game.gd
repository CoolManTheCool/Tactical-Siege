extends Node3D

enum GameState { PAUSED, FIGHTING, MAIN_MENU }
signal server_closed
@export var current_state: GameState = GameState.MAIN_MENU
var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene = load("res://Player/player.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if current_state == GameState.PAUSED and Input.is_action_just_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		current_state = GameState.FIGHTING
	elif current_state == GameState.FIGHTING and Input.is_action_just_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		current_state = GameState.PAUSED

	if Input.is_action_pressed("quit"):
		close_game("close game button was pressed.")
	if Input.is_action_pressed("host_terminate") and multiplayer.is_server():
		rpc("_server_terminate", "Host's terminate button was pressed.")
		# print_tree_pretty()
		
	# push_warning($CanvasLayer.visible)
	# push_warning(current_state)

@rpc("reliable", "authority", "call_local")
func _server_terminate(why):
	$"Server Menu/Panel".show()
	current_state = GameState.MAIN_MENU
	server_closed.emit()
	print("Server terminated with code: ", why)
	multiplayer.multiplayer_peer.close()
	# go to return to main menu, if your not the server
	
	
func close_game(why):
	if multiplayer.is_server():
		rpc("_server_terminate", why)
	else:
		print("Game was closed because: ", why)
	multiplayer.multiplayer_peer.close()
	get_tree().quit()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		close_game("close button pressed.")

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


func _on_host_pressed():
	peer.create_server($"Server Menu/Panel/Port".text.to_int(), 100)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)
	add_player()
	$"Server Menu".hide()
	current_state = GameState.FIGHTING

func _on_join_pressed():
	var result = peer.create_client($"Server Menu/Panel/Address".text, $"Server Menu/Panel/Port".text.to_int())
	multiplayer.multiplayer_peer = peer
	if result != OK:
		print("Error joining game. Result code:", result)
		get_tree().quit(result)
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)
	$"Server Menu".hide()
	current_state = GameState.FIGHTING
