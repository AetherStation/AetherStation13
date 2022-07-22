/obj/machinery/mainframe/external/peripheral
	var/peripheral_address_start = 0
	var/peripheral_address_end = 4

/obj/machinery/mainframe/external/peripheral/set_parent(p)
	. = ..()
	parent.peripherals += src

/obj/machinery/mainframe/external/peripheral/proc/mem_write(address, value)

/obj/machinery/mainframe/external/peripheral/proc/mem_read(address)

/obj/machinery/mainframe/external/peripheral/terminal
	name = "mainframe terminal"
	desc = "Text mode only, I am afraid it is terminal."
	icon_state = "terminal"
	var/current_line = 0
	var/current_text[20] // 20 lines
	var/input_queue = ""

/obj/machinery/mainframe/external/peripheral/terminal/Initialize()
	. = ..()
	for (var/i in 1 to 20)
		current_text[i] = ""

/obj/machinery/mainframe/external/peripheral/terminal/mem_write(address, value)
	switch (address)
		if (0) display_character(value)

/obj/machinery/mainframe/external/peripheral/terminal/mem_read(address, value)
	switch (address)
		if (1)
			if (!input_queue)
				return 0
			var/C = input_queue[1]
			input_queue = copytext(input_queue, 2)
			return text2ascii(C)

/obj/machinery/mainframe/external/peripheral/terminal/proc/display_character(ascii)
	switch (ascii)
		if (0) return
		if (10, 13)
			current_line = (current_line + 1) % 20
			current_text[current_line + 1] = ""
		if (8)
			var/C = current_text[current_line + 1]
			current_text[current_line + 1] = copytext(C, 1, length(C))
		if (20) // XOFF is used as clear in this.
			for (var/i in 1 to 20)
				current_text[i] = ""
			current_line = 0
		else current_text[current_line + 1] += ascii2text(ascii)
	if (length(current_text[current_line + 1]) >= 40)
		current_line = (current_line + 1) % 20
		current_text[current_line + 1] = ""

/obj/machinery/mainframe/external/peripheral/terminal/ui_data(mob/user)
	var/list/data = list()
	data["text"] = current_text
	data["queue_length"] = length(input_queue)
	return data

/obj/machinery/mainframe/external/peripheral/terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MainframeTerminal")
		ui.open()

/obj/machinery/mainframe/external/peripheral/terminal/ui_act(action, params)
	. = ..()
	if(.)
		return
	if (action == "send")
		var/M = params["data"]
		if (length(input_queue) + length(M) >= 256)
			return FALSE
		input_queue += M

/obj/machinery/mainframe/external/peripheral/printer
	name = "mainframe printer"
	desc = "Likely the most advanced component of the entire system due to it not using ink."
	icon_state = "printer"
	peripheral_address_start = 4
	peripheral_address_end = 8
	var/paper_count = 6
	var/current_text = ""

/obj/machinery/mainframe/external/peripheral/printer/mem_write(address, value)
	switch (address)
		if (0) print_character(value)

/obj/machinery/mainframe/external/peripheral/printer/proc/print_character(ascii)
	if (ascii == 0)
		print_paper()
		return
	if (length(current_text) >= 1000) // lets just keep the max at 1000 characters.
		print_paper()
	current_text += ascii2text(ascii)

/obj/machinery/mainframe/external/peripheral/printer/proc/print_paper()
	if (paper_count)
		var/obj/item/paper/P = new(get_turf(src))
		P.setText(html_encode(current_text))
		paper_count--
	current_text = ""
