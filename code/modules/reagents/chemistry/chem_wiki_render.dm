//Generates a wikitable txt file for use with the wiki - does not support productless reactions at the moment
/client/proc/generate_wikichem_list()
	set category = "Debug"
	set name = "Parse Wikichems"

	//If we're a reaction product
	var/prefix_reaction = {"{| class=\"wikitable sortable\" style=\"width:100%; text-align:left; border: 3px solid #FFDD66; cellspacing=0; cellpadding=2; background-color:white;\"
! scope=\"col\" style='width:150px; background-color:#FFDD66;'|Name
! scope=\"col\" class=\"unsortable\" style='background-color:#FFDD66;'|Formula
! scope=\"col\" class=\"unsortable\" style='background-color:#FFDD66; width:170px;'|Reaction conditions
! scope=\"col\" class=\"unsortable\" style='background-color:#FFDD66;'|Description
! scope=\"col\" class=\"unsortable\" style='background-color:#FFDD66;'|Chemical properties
|-
"}

	var/input_text = stripped_input(usr, "Input a name of a reagent, or a series of reagents split with a comma (no spaces) to get it's wiki table entry", "Recipe") //95% of the time, the reagent type is a lowercase, no spaces / underscored version of the name
	if(!input_text)
		to_chat(usr, "Input was blank!")
		return
	text2file(prefix_reaction, "[GLOB.log_directory]/chem_parse.txt")
	var/list/names = splittext("[input_text]", ",")

	for(var/name in names)
		var/datum/reagent/reagent = find_reagent_object_from_type(get_chem_id(name))
		if(!reagent)
			to_chat(usr, "Could not find [name]. Skipping.")
			continue
		//Get reaction
		var/list/reactions = GLOB.chemical_reactions_list_product_index[reagent.type]

		if(!length(reactions))
			to_chat(usr, "Could not find [name] reaction! Continuing anyways.")
			var/single_parse = generate_chemwiki_line(reagent, null)
			text2file(single_parse, "[GLOB.log_directory]/chem_parse.txt")
			continue

		for(var/datum/chemical_reaction/reaction as anything in reactions)
			var/single_parse = generate_chemwiki_line(reagent, reaction)
			text2file(single_parse, "[GLOB.log_directory]/chem_parse.txt")
	text2file("|}", "[GLOB.log_directory]/chem_parse.txt") //Cap off the table
	to_chat(usr, "Done! Saved file to (wherever your root folder is, i.e. where the DME is)/[GLOB.log_directory]/chem_parse.txt OR use the Get Current Logs verb under the Admin tab. (if you click Open, and it does nothing, that's because you've not set a .txt default program! Try downloading it instead, and use that file to set a default program! Have a nice day!")


/// Generate the big list of reagent based reactions.
/proc/generate_chemwiki_line(datum/reagent/reagent, datum/chemical_reaction/reaction)
	//name | Reagent pH | reagents | reaction temp | Overheat temp | pH range | Kinetics | description | OD level | Addiction level | Metabolism rate | impure chem | inverse chem

	//NAME
	//!style='background-color:#FFEE88;'|{{anchor|Synthetic-derived growth factor}}Synthetic-derived growth factor<span style="color:#A502E0;background-color:white">▮</span>
	var/outstring = "!style='background-color:#FFEE88;'|{{anchor|[reagent.name]}}[reagent.name]<span style=\"color:[reagent.color];background-color:white\">▮</span>"
	outstring += "\n|"

	//RECIPE
	//|{{RecursiveChem/Oil}}
	if(reaction)
		outstring += "{{RecursiveChem/[reagent.name]}}"
		outstring += "\n|"

		//Reaction conditions
		//min temp
		if(reaction.is_cold_recipe)
			outstring += "<b>Cold reaction</b>\n<br>"
		outstring += "<b>Min temp:</b> [reaction.required_temp]K"

		//container
		if(reaction.required_container)
			var/list/names = splittext("[reaction.required_container]", "/")
			var/container_name = "[names[names.len]] [names[names.len-1]]"
			container_name = replacetext(container_name, "_", " ")
			outstring += "\n<br>[container_name]"

	//Description
	outstring += "[reagent.description]"
	outstring += "\n|"

	//Chemical properties - *2 because 1 tick is every 2s
	outstring += "<b>Rate:</b> [reagent.metabolization_rate*2]u/tick\n<br>[(reagent.overdose_threshold ? "\n<br><b>OD:</b> [reagent.overdose_threshold]u" : "")]"

	if(length(reagent.addiction_types))
		outstring += "\n<br><b>Addictions:</b>"
	for(var/entry in reagent.addiction_types)
		var/datum/addiction/ref = SSaddiction.all_addictions[entry]
		switch(reagent.addiction_types[entry])
			if(-INFINITY to 0)
				continue
			if(0 to 5)
				outstring += "\n<br>Weak [ref.name]"
			if(5 to 10)
				outstring += "\n<br>[ref.name]"
			if(10 to 20)
				outstring += "\n<br>Strong [ref.name]"
			if(20 to INFINITY)
				outstring += "\n<br>Potent [ref.name]"

	if(reagent.chemical_flags & REAGENT_DEAD_PROCESS)
		outstring += "\n<br>Works on the dead"

	outstring += "\n|-"
	return outstring
