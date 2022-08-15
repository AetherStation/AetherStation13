/obj/effect/proc_holder/spell/targeted/shapeshift/eldritch
	invocation = "SH'PE"
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	possible_shapes = list(/mob/living/simple_animal/mouse,\
		/mob/living/simple_animal/pet/dog/corgi,\
		/mob/living/simple_animal/hostile/carp,\
		/mob/living/simple_animal/bot/secbot, \
		/mob/living/simple_animal/pet/fox,\
		/mob/living/simple_animal/pet/cat )

/obj/effect/proc_holder/spell/targeted/emplosion/eldritch
	name = "Energetic Pulse"
	invocation = "E'P"
	school = SCHOOL_FORBIDDEN
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"
	range = -1
	include_user = TRUE
	charge_max = 300
	emp_heavy = 6
	emp_light = 10

/obj/effect/proc_holder/spell/targeted/telepathy/eldritch
	invocation = ""
	invocation_type = INVOCATION_WHISPER
	clothes_req = FALSE
	action_background_icon_state = "bg_ecult"

/obj/effect/proc_holder/spell/pointed/trigger/blind/eldritch
	range = 10
	invocation = "E'E'S"
	action_background_icon_state = "bg_ecult"
