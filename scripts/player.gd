extends CharacterBody2D

@export var gravity = 800.0
@export var walk_speed = 350
@export var jump_speed = -355
@export var dash_speed = 750
@export var dash_time = 0.2
@export var climb_speed := 220.0

var is_climbing := false
var can_dash: bool = true
var jump_num: int = 2
var dash_timer = 0.0
var direction : float = 0.0
var is_crouching: bool = false
var inside_ladder: bool = false

@onready var dashTimer: Timer = $DashTimer
@onready var anim_tree: AnimationTree = $PlayerAnimTree

func _ready():
	anim_tree.active = true

func _physics_process(delta):
	if inside_ladder:
		handle_ladder(delta)
		move_and_slide()
		update_animation_parameters()
		return

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jump_num = 2  
	direction = Input.get_axis("left", "right")
	velocity.x = direction * walk_speed
	
	if direction != 0:
		$PlayerAnimSprite.flip_h = direction < 0
	
	if Input.is_action_just_pressed("jump") and jump_num > 0 and not is_crouching:
		velocity.y = jump_speed
		jump_num -= 1
	
	if Input.is_action_just_pressed("dash") and not is_crouching and can_dash:
		walk_speed = dash_speed
		dashTimer.start()
		can_dash = false
		await get_tree().create_timer(dash_time).timeout
		walk_speed = 350
	
	move_and_slide()
	update_animation_parameters()

func update_animation_parameters():
	if inside_ladder:
		disable_anim(['idle', 'run', 'jump', 'crouch'])
		var v_input := Input.get_axis("up", "down")
		if is_climbing and v_input != 0:
			enable_anim('climb')
			disable_anim(['preclimb'])
		else:
			enable_anim('preclimb')
			disable_anim(['climb'])
		return

	if not is_on_floor():
		disable_anim(['idle', 'run', 'preclimb', 'crouch', 'climb'])
		enable_anim('jump')
		return
		
	if Input.is_action_pressed("crouch"):
		enable_anim('crouch')
		disable_anim(['idle', 'run', 'jump', 'preclimb', 'climb'])
		is_crouching = true
		return
	disable_anim(['idle', 'jump', 'preclimb', 'crouch'])
	is_crouching = false
	if velocity.x == 0:
		enable_anim('idle')
		disable_anim(['run'])
	else:
		enable_anim('run')
		disable_anim(['idle'])

func _on_dash_timer_timeout() -> void:
	can_dash = true

func _on_player_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == 'LadderArea':
		inside_ladder = true

func _on_player_area_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name == 'LadderArea':
		inside_ladder = false
		is_climbing = false

func enable_anim(anim_name):
	anim_tree["parameters/conditions/%s" % anim_name] = true

func disable_anim(anim_names):
	for anim in anim_names:
		anim_tree["parameters/conditions/%s" % anim] = false
		
func handle_ladder(delta):
	var v_input := Input.get_axis("up", "down")

	if not is_climbing:
		velocity = Vector2.ZERO
		if v_input != 0:
			is_climbing = true

	if is_climbing:
		velocity.x = 0
		velocity.y = v_input * climb_speed

		if Input.is_action_just_pressed("jump"):
			is_climbing = false
			inside_ladder = false
			velocity.y = jump_speed
