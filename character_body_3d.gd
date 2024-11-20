class_name Player extends CharacterBody3D

@export var neck:Node3D
@export var camera:Camera3D
@export var play_coll:CollisionShape3D


const JUMP_VELOCITY = 4.5
const INERTIA = 0.2
var mouse_sensitiviy = 0.75
var h_mouse_sensitiviy = 0.5
var gravity:float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed:float = 4.0

func _input(event):
	# Look
	if event is InputEventMouseMotion:
		var h_sens:float = 0.5
		var h_flip:float = 1.0
		var v_sens:float = mouse_sensitiviy
		var v_flip:float = 1.0
		
		camera.rotate_x(deg_to_rad(-event.relative.y * h_mouse_sensitiviy * h_sens * h_flip))
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitiviy * v_sens * v_flip)) # should I accounting for aspect ratio here?
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)


func _physics_process(delta:float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir:Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction:Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	
	move_and_slide()
	
