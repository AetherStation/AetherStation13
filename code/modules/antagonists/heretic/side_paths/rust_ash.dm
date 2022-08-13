/datum/eldritch_knowledge/essence
	name = "Priest's Ritual"
	desc = "You can now transmute a tank of water and a glass shard into a bottle of eldritch water."
	gain_text = "This is an old recipe. The Owl whispered it to me."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/spell/ashen_shift)
	required_atoms = list(
		/obj/structure/reagent_dispensers/watertank,
		/obj/item/shard = 1,
		)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)
	route = PATH_SIDE

/datum/eldritch_knowledge/curse_item/corrosion
	name = "Curse of Corrosion"
	gain_text = "Cursed land, cursed man, cursed mind."
	desc = "Curse an item to inflict the curse of corrosion to whoever it touches it. The curse will inflict vomiting and major organ damage for 2 minutes. Using a wirecutter, a pool of blood, a heart and the item you want to curse."
	cost = 1
	required_atoms = list(
		/obj/item/wirecutters = 1,
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/organ/heart = 1,
		)
	next_knowledge = list(
		/datum/eldritch_knowledge/mad_mask,
		/datum/eldritch_knowledge/spell/area_conversion
	)
	timer = 2 MINUTES
	route = PATH_SIDE

/datum/eldritch_knowledge/curse_item/corrosion/curse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.apply_status_effect(/datum/status_effect/corrosion_curse)

/datum/eldritch_knowledge/curse_item/corrosion/uncurse(mob/living/chosen_mob)
	. = ..()
	chosen_mob.remove_status_effect(/datum/status_effect/corrosion_curse)

/datum/eldritch_knowledge/summon/rusty
	name = "Rusted Ritual"
	gain_text = "I combined my principle of hunger with my desire for corruption. And the Rusted Hills called my name."
	desc = "You can now summon a Rust Walker by transmutating a vomit pool, a severed head and a book."
	cost = 1
	required_atoms = list(
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/book = 1,
		/obj/item/bodypart/head = 1
		)
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/rust_spirit
	next_knowledge = list(/datum/eldritch_knowledge/spell/voidpull,/datum/eldritch_knowledge/spell/entropic_plume)
	route = PATH_SIDE

/datum/eldritch_knowledge/summon/rusty/cleanup_atoms(list/selected_atoms)
	var/obj/item/bodypart/head/ritual_head = locate() in selected_atoms
	if(!ritual_head)
		CRASH("[type] required a head bodypart, yet did not have one in selected_atoms when it reached cleanup_atoms.")

	// Spill out any brains or stuff before we delete it.
	ritual_head.drop_organs()
	return ..()
