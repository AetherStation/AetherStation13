/datum/reagent/reaction_agent
	name = "reaction agent"
	description = "Hello! I am a bugged reagent. Please report me for my crimes. Thank you!!"

/datum/reagent/reaction_agent/intercept_reagents_transfer(datum/reagents/target, amount)
	if(!target)
		return FALSE
	if(target.flags & NO_REACT)
		return FALSE
	if(target.has_reagent(/datum/reagent/stabilizing_agent))
		return FALSE
	if(LAZYLEN(target.reagent_list) == 0)
		return FALSE
	if(LAZYLEN(target.reagent_list) == 1)
		if(target.has_reagent(type)) //Allow dispensing into self
			return FALSE
	return TRUE

//purity testor/reaction agent prefactors

/datum/reagent/prefactor_a
	name = "Interim product alpha"
	description = "This reagent is a prefactor to the purity tester reagent, and will react with stable plasma to create it"
	color = "#bafa69"

/datum/reagent/prefactor_b
	name = "Interim product beta"
	description = "This reagent is a prefactor to the reaction speed agent reagent, and will react with stable plasma to create it"
	color = "#8a3aa9"

/datum/reagent/reaction_agent/purity_tester
	name = "Purity tester"
	description = "This reagent will consume itself and violently react if there is a highly impure reagent in the beaker."
	ph = 3
	color = "#ffffff"

/datum/reagent/reaction_agent/purity_tester/intercept_reagents_transfer(datum/reagents/target, amount)
	. = ..()
	if(!.)
		return
	var/is_inverse = FALSE
	for(var/_reagent in target.reagent_list)
		var/datum/reagent/reaction_agent/reagent = _reagent
		if(reagent.purity <= reagent.inverse_chem_val)
			is_inverse = TRUE
	if(is_inverse)
		target.my_atom.audible_message(span_warning("The beaker bubbles violently as the reagent is added!"))
		playsound(target.my_atom, 'sound/chemistry/bufferadd.ogg', 50, TRUE)
	else
		target.my_atom.audible_message(span_warning("The added reagent doesn't seem to do much."))
	holder.remove_reagent(type, amount)

/datum/reagent/reaction_agent/speed_agent
	name = "Tempomyocin"
	description = "This reagent will consume itself and speed up an ongoing reaction, modifying the current reaction's purity by it's own."
	ph = 10
	color = "#e61f82"
	///How much the reaction speed is sped up by - for 5u added to 100u, an additional step of 1 will be done up to a max of 2x
	var/strength = 20


/datum/reagent/reaction_agent/speed_agent/intercept_reagents_transfer(datum/reagents/target, amount)
	. = ..()
	if(!.)
		return FALSE
	if(!length(target.reaction_list))//you can add this reagent to a beaker with no ongoing reactions, so this prevents it from being used up.
		return FALSE
	amount /= target.reaction_list.len
	for(var/_reaction in target.reaction_list)
		var/datum/equilibrium/reaction = _reaction
		if(!reaction)
			CRASH("[_reaction] is in the reaction list, but is not an equilibrium")
		var/power = (amount/reaction.target_vol)*strength
		power *= creation_purity
		power = clamp(power, 0, 2)
		reaction.react_timestep(power, creation_purity)
	holder.remove_reagent(type, amount)
