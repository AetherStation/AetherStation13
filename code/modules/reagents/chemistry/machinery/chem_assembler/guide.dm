/obj/item/paper/guides/chem_assembler
	name = "Guide to Chemical Assembler"
	info = @{"
		<h1>Guide to Chemical Assembler</h1>
		<h2>Introduction</h2>
		<p>The Chemical Assembler is a programmable machine for automating creation of different reagents. The machine can be upgraded to increase it's speed.</p>
		<h2>Slots and chemical holder</h2>
		<p>The chemical assembler has 14 "slots" and a chemical holder, slots are internal beakers with varying capacity and functionality.</p>
		The slots are as follows
		<pre>
		<code>
		+--+--+--+
		|I1|I2|I3|
		+--+--+--+--+--+
		|A1|A2|A3|  |  |
		+--+--+--+  |  |
		|B1|B2|B3|H |O |
		+--+--+--+  |  |
		|C1|C2|C3|  |  |
		+--+--+--+--+--+
		</code>
		</pre>
		The chemical holder has a reagent capacity of 100 units and is used for transfering reagents from slot to slot by using the `GET`, `PUT`, and `FLT` instructions.
		<h3>Main slots</h3>
		The slots A1, A2, A3, B1, B2, B3, C1, C2 and C3 are called main slots, these slots don't have any kind of special functionality.<br>
		Each main slot has a capacity of 100 units.
		<h3>Input slots</h3>
		The slots I1, I2, and I3 are called input slots, these slots can be used just like the main slots and have the same capacity, but they can also take reagents from the plumbing inputs in the machine. When rotated so the output side of the machine is up the inputs are I1, I2, and I3 from left to right.
		<h3>Heater slot</h3>
		The slot H is the heater, this slot has a capacity of 300 units and can be used to heat reagents inside it to the temperature set by the `TMP` instruction.
		<h3>Output slot</h3>
		The slot O is the output, this slot has a capacity of 300 units and can be extracted from via plumbing or by using a beaker or other reagent container on the machine.
		<h2>Language</h2>
		As mentioned the Chemical Assembler uses an assembly inspired language henceforth dubbed "chemical assembly".
		<h3>Syntax</h3>
		Chemical assembly's syntax is fairly simple, for example:
		<pre><code>
		.definition value
		label:
		    instruction definition    ; comment
		</code></pre>
		In this example we can see a .definition, a label, an instruction, and a comment.
		<h4><var>.definition</var></h4>
		Definitions replace the name of the definition with value in instruction arguments and ONLY in instruction arguments, you can't use these to change the name of instructions.<br>
		Example:
		<pre><code>
		.a b                ; Define a as b
		    instruction a   ; On this line the "a" will be replaced
		                    ; with "b" due to the definition
		                    ; which means this will be executed as if
		                    ; it was "instruction b"
		</code></pre>
		<h4><var>label:</var></h4>
		Labels are used with J* (JMP, JSF, JSE, etc) instructions to change the program execution position.<br>
		Example:
		<pre><code>
		    JMP a    ; JuMP to label "a".
		b:
		    JMP c    ; JuMP to label "c".
		a:
		    JMP b    ; JuMP to label "b".
		c:
		    INT      ; INTerrupt, stops execution.
		</code></pre>
		In the example the program will execute the first line `JMP a`, which causes it to change the execution position to where the `a:` label is, then it will continue to the next line `JMP b`, which changes the execution position to where the `b:` label is, and so forth.
		<h4><var>instruction</var></h4>
		Any word without the special characters `:` or `.` will be considered an instruction.<br>
		Ill leave the example as an exercise for the reader.
		<h2>Instructions</h2>
		The instructions you can use in the chemical assembly language are as follows:
		<pre><code>
		MOV [slot]                - Moves to the slot given as an argument
		SYN [chemical], [amount]  - Synthesises an amount of a chemical to the current slot
		GET [amount]              - Moves an amount of chemicals from current slot to holder tank
		PUT [amount]              - Moves an amount of chemicals from holding tank to current slot
		REM [amount]              - Removes amount of chemicals from current slot
		TMP [temperature]         - Sets wanted heater temperature
		FLT [chemical]            - Filters all of chemical into holding tank
		INT                       - Interrupts execution (stops the program)
		JMP [label]               - Unconditional jump to label
		JSF [label]               - Jumps to label if current slot is full
		JSE [label]               - Jumps to label if current slot is empty
		JTC [label]               - Jumps to label if heater is at wanted temperature (with an error margin of 0.15)
		</code></pre>
		<h2>Examples</h2>
		Oil production until output is full:
		<pre><code>
		.amount 25
		OIL:  MOV B2                  ; Set current slot to B2
		      SYN carbon, amount      ; Synthesise carbon to current slot (B2)
		      SYN hydrogen, amount    ; Synthesise hydrogen
		      SYN weldingfuel, amount ; Synthesise welding fuel
		      GET 100                 ; Take 100 units out of current slot to holding tank
		      MOV O                   ; Set current slot to O (Output)
		      PUT 100                 ; Take 100 units out of holding tank and put to current slot
		      JSF Q                   ; Jump to Q if current slot is full
		      JMP OIL                 ; Jump to OIL
		Q:    INT                     ; Interrupt/Exit program
		</code></pre>
	"}
