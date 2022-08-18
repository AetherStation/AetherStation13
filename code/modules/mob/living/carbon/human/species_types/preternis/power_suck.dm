/mob/living/carbon/AltClickOn(atom/A)
	dna?.species.spec_AltClickOn(A,src)
	return ..()

/datum/species/preternis/spec_AltClickOn(atom/A,H)
	return drain_power_from(H, A)

/datum/species/preternis/proc/drain_power_from(mob/living/carbon/human/H, atom/A)
	if(!istype(H) || !A)
		return FALSE

	if(draining)
		to_chat(H,"<span class='info'>CONSUME protocols can only be used on one object at any single time.</span>")
		return FALSE
	if(!A.can_consume_power_from())
		return FALSE //if it returns text, we want it to continue so we can get the error message later.

	draining = TRUE

	var/siemens_coefficient = 1

	if(H.reagents.has_reagent("teslium"))
		siemens_coefficient *= 1.5

	if (charge >= PRETERNIS_LEVEL_FULL - 25) //just to prevent spam a bit
		to_chat(H,"<span class='notice'>CONSUME protocol reports no need for additional power at this time.</span>")
		draining = FALSE
		return TRUE

	if(H.gloves)
		if(!H.gloves.siemens_coefficient)
			to_chat(H,"<span class='info'>NOTICE: [H.gloves] prevent electrical contact - CONSUME protocol aborted.</span>")
			draining = FALSE
			return TRUE
		else
			if(H.gloves.siemens_coefficient < 1)
				to_chat(H,"<span class='info'>NOTICE: [H.gloves] are interfering with electrical contact - advise removal before activating CONSUME protocol.</span>")
			siemens_coefficient *= H.gloves.siemens_coefficient

	H.face_atom(A)
	H.visible_message("<span class='warning'>[H] starts placing their hands on [A]...</span>", "<span class='warning'>You start placing your hands on [A]...</span>")
	if(!do_after(H, 20, target = A))
		to_chat(H,"<span class='info'>CONSUME protocol aborted.</span>")
		draining = FALSE
		return TRUE

	to_chat(H,"<span class='info'>Extracutaneous implants detect viable power source. Initiating CONSUME protocol.</span>")

	var/done = FALSE
	var/drain = 150 * siemens_coefficient

	var/cycle = 0
	var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread()
	spark_system.attach(A)
	spark_system.set_up(5, 0, A)



	while(!done)
		cycle++
		var/nutritionIncrease = drain * ELECTRICITY_TO_NUTRIMENT_FACTOR

		if(charge + nutritionIncrease > PRETERNIS_LEVEL_FULL)
			nutritionIncrease = clamp(PRETERNIS_LEVEL_FULL - charge, PRETERNIS_LEVEL_NONE,PRETERNIS_LEVEL_FULL) //if their nutrition goes up from some other source, this could be negative, which would cause bad things to happen.
			drain = nutritionIncrease/ELECTRICITY_TO_NUTRIMENT_FACTOR

		if (do_after(H,5, target = A))
			var/can_drain = A.can_consume_power_from()
			if(!can_drain || istext(can_drain))
				if(istext(can_drain))
					to_chat(H,can_drain)
				done = TRUE
			else
				playsound(A.loc, "sparks", 50, 1)
				if(prob(75))
					spark_system.start()
				var/drained = A.consume_power_from(drain)
				if(drained < drain)
					to_chat(H,"<span class='info'>[A]'s power has been depleted, CONSUME protocol halted.</span>")
					done = TRUE
				charge = clamp(charge + (drained * ELECTRICITY_TO_NUTRIMENT_FACTOR),PRETERNIS_LEVEL_NONE,PRETERNIS_LEVEL_FULL)

				if(!done)
					if(charge > (PRETERNIS_LEVEL_FULL - 25))
						to_chat(H,"<span class='info'>CONSUME protocol complete. Physical nourishment refreshed.</span>")
						done = TRUE
					else if(!(cycle % 4))
						var/nutperc = round((charge / PRETERNIS_LEVEL_FULL) * 100)
						to_chat(H,"<span class='info'>CONSUME protocol continues. Current satiety level: [nutperc]%.</span>")
		else
			done = TRUE
	qdel(spark_system)
	draining = FALSE
	return TRUE

/atom/proc/can_consume_power_from()
	return FALSE //if a string is returned, it will evaluate as false and be output to the person draining.

/atom/proc/consume_power_from(amount)
	return FALSE //return the amount that was drained.

#define MIN_DRAINABLE_POWER 10

//CELL//
/obj/item/stock_parts/cell/can_consume_power_from()
	if(charge < MIN_DRAINABLE_POWER)
		return "<span class='info'>Power cell depleted, cannot consume power.</span>"
	return TRUE

/obj/item/stock_parts/cell/consume_power_from(amount)
	if((charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(charge - MIN_DRAINABLE_POWER, 0)
	use(amount)
	return amount

//APC//
/obj/machinery/power/apc/can_consume_power_from()
	if(!cell)
		return "<span class='info'>APC cell absent, cannot consume power.</span>"
	if(machine_stat & BROKEN)
		return "<span class='info'>APC is damaged, cannot consume power.</span>"
	if(!operating || shorted)
		return "<span class='info'>APC main breaker is off, cannot consume power.</span>"
	if(cell.charge < MIN_DRAINABLE_POWER)
		return "<span class='info'>APC cell depleted, cannot consume power.</span>"
	return TRUE

/obj/machinery/power/apc/consume_power_from(amount)
	if((cell.charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(cell.charge - MIN_DRAINABLE_POWER, 0)
	cell.use(amount)
	if(charging == 2)
		charging = 0 //if we do not do this here, the APC can get stuck thinking it is fully charged.
	update()
	return amount

//SMES//
/obj/machinery/power/smes/can_consume_power_from()
	if(machine_stat & BROKEN)
		return "<span class='info'>SMES is damaged, cannot consume power.</span>"
	if(!output_attempt)
		return "<span class='info'>SMES is not outputting power, cannot consume power.</span>"
	if(charge < MIN_DRAINABLE_POWER)
		return "<span class='info'>SMES cells depleted, cannot consume power.</span>"
	return TRUE

/obj/machinery/power/smes/consume_power_from(amount)
	if((charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(charge - MIN_DRAINABLE_POWER, 0)
	charge -= amount
	return amount

//MECH//
/obj/vehicle/sealed/mecha/can_consume_power_from()
	if(!cell)
		return "<span class='info'>Mech power cell absent, cannot consume power.</span>"
	if(cell.charge < MIN_DRAINABLE_POWER)
		return "<span class='info'>Mech power cell depleted, cannot consume power.</span>"
	return TRUE

/obj/vehicle/sealed/mecha/consume_power_from(amount)
	to_chat(occupants,"<span class='danger'>Warning: Unauthorized access through sub-route 4, block H, detected.</span>")
	if((cell.charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(cell.charge - MIN_DRAINABLE_POWER, 0)
	cell.use(amount)
	return amount

//BORG//
/mob/living/silicon/robot/can_consume_power_from()
	if(!cell)
		return "<span class='info'>Cyborg power cell absent, cannot consume power.</span>"
	if(cell.charge < MIN_DRAINABLE_POWER)
		return "<span class='info'>Cyborg power cell depleted, cannot consume power.</span>"
	return TRUE

/mob/living/silicon/robot/consume_power_from(amount)
	src << "<span class='danger'>Warning: Unauthorized access through sub-route 12, block C, detected.</span>"
	if((cell.charge - amount) < MIN_DRAINABLE_POWER)
		amount = max(cell.charge - MIN_DRAINABLE_POWER, 0)
	cell.use(amount)
	return amount

#undef MIN_DRAINABLE_POWER

