extends Node3D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene = load("res://Player/player.tscn")

func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	if Input.is_action_just_pressed("pause"):
		if $"GUI/Main Menu".visible == true:
			close_game()
		

func close_game():
	if multiplayer.is_server():
		1+1
		# close connection, and kick all players
	multiplayer.multiplayer_peer.close()
	get_tree().quit()

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		close_game()

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

func _on_join_pressed():
	var result = peer.create_client($"Server Menu/Panel/Address".text, $"Server Menu/Panel/Port".text.to_int())
	multiplayer.multiplayer_peer = peer
	if result != OK:
		print("Error joining game. Result code:", result)
		get_tree().quit(result)
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)
	$"Server Menu".hide()
