/obj/item/paper/guides/mos6502_reference_sheet
	name = "MOS 6502 Instruction Reference Sheet"
	info = @{"
<style>
table, td, th {
	font-family: monospace;
	border: #888 1px solid;
	border-spacing: 2px;
}

td {
	background-color: lightyellow;
	text-align: center;
	padding-left: 0.5em;
	padding-right: 0.5em;
}

.row-header {
	background-color: lightblue;
}
</style>
<H2>MOS 6502 Instruction Reference Sheet</H2>
<table style='border-collapse: collapse;'>
		<tr style='background-color: lightgreen;'>
			<th></th>
			<th>-0</th>
			<th>-1</th>
			<th>-2</th>
			<th>-3</th>
			<th>-4</th>
			<th>-5</th>
			<th>-6</th>
			<th>-7</th>
			<th>-8</th>
			<th>-9</th>
			<th>-A</th>
			<th>-B</th>
			<th>-C</th>
			<th>-D</th>
			<th>-E</th>
			<th>-F</th>
		</tr>

		<tr>
			<th class='row-header'>0-</th>
			<td>BRK imp</td>
			<td>ORA idx</td>
			<td></td>
			<td></td>
			<td></td>
			<td>ORA zpg</td>
			<td>ASL zpg</td>
			<td></td>
			<td>PHP imp</td>
			<td>ORA imm</td>
			<td>ASL acc</td>
			<td></td>
			<td></td>
			<td>ORA abs</td>
			<td>ASL abs</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>1-</th>
			<td>BPL rel</td>
			<td>ORA idy</td>
			<td></td>
			<td></td>
			<td></td>
			<td>ORA zpx</td>
			<td>ASL zpx</td>
			<td></td>
			<td>CLC imp</td>
			<td>ORA aby</td>
			<td></td>
			<td></td>
			<td></td>
			<td>ORA abx</td>
			<td>ASL abx</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>2-</th>
			<td>JSR abs</td>
			<td>AND idx</td>
			<td></td>
			<td></td>
			<td>BIT zpg</td>
			<td>AND zpg</td>
			<td>ROL zpg</td>
			<td></td>
			<td>PLP imp</td>
			<td>AND imm</td>
			<td>ROL acc</td>
			<td></td>
			<td>BIT abs</td>
			<td>AND abs</td>
			<td>ROL abs</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>3-</th>
			<td>BMI rel</td>
			<td>AND idx</td>
			<td></td>
			<td></td>
			<td></td>
			<td>AND zpx</td>
			<td>ROL zpx</td>
			<td></td>
			<td>SEC imp</td>
			<td>AND aby</td>
			<td></td>
			<td></td>
			<td></td>
			<td>AND abx</td>
			<td>ROL abx</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>4-</th>
			<td>RTI imp</td>
			<td>EOR idx</td>
			<td></td>
			<td></td>
			<td></td>
			<td>EOR zpg</td>
			<td>LSR zpg</td>
			<td></td>
			<td>PHA imp</td>
			<td>EOR imm</td>
			<td>LSR acc</td>
			<td></td>
			<td>JMP abs</td>
			<td>EOR abs</td>
			<td>LSR abs</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>5-</th>
			<td>BVC rel</td>
			<td>EOR idy</td>
			<td></td>
			<td></td>
			<td></td>
			<td>EOR zpx</td>
			<td>LSR zpx</td>
			<td></td>
			<td>CLI imp</td>
			<td>EOR aby</td>
			<td></td>
			<td></td>
			<td></td>
			<td>EOR abx</td>
			<td>LSR abx</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>6-</th>
			<td>RTS imp</td>
			<td>ADC idx</td>
			<td></td>
			<td></td>
			<td></td>
			<td>ADC zpg</td>
			<td>ROR zpg</td>
			<td></td>
			<td>PLA imp</td>
			<td>ADC imm</td>
			<td>ROR acc</td>
			<td></td>
			<td>JMP ind</td>
			<td>ADC abs</td>
			<td>ROR abs</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>7-</th>
			<td>BVS rel</td>
			<td>ADC idy</td>
			<td></td>
			<td></td>
			<td></td>
			<td>ADC zpx</td>
			<td>ROR zpx</td>
			<td></td>
			<td>SEI imp</td>
			<td>ADC aby</td>
			<td></td>
			<td></td>
			<td></td>
			<td>ADC abx</td>
			<td>ROR abx</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>8-</th>
			<td></td>
			<td>STA idx</td>
			<td></td>
			<td></td>
			<td>STY zpg</td>
			<td>STA zpg</td>
			<td>STX zpg</td>
			<td></td>
			<td>DEY imp</td>
			<td></td>
			<td>TXA imp</td>
			<td></td>
			<td>STY abs</td>
			<td>STA abs</td>
			<td>STX abs</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>9-</th>
			<td>BCC rel</td>
			<td>STA idy</td>
			<td></td>
			<td></td>
			<td>STY zpx</td>
			<td>STA zpx</td>
			<td>STX zpy</td>
			<td></td>
			<td>TYA imp</td>
			<td>STA abx</td>
			<td>TXS imp</td>
			<td></td>
			<td></td>
			<td>STA abx</td>
			<td></td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>A-</th>
			<td>LDY imm</td>
			<td>LDX idx</td>
			<td>LDX imm</td>
			<td></td>
			<td>LDY zpg</td>
			<td>LDA zpg</td>
			<td>LDX zpg</td>
			<td></td>
			<td>TAY imp</td>
			<td>LDA imm</td>
			<td>TAX imp</td>
			<td></td>
			<td>LDY abs</td>
			<td>LDA abs</td>
			<td>LDX abs</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>B-</th>
			<td>BCS rel</td>
			<td>LDA idy</td>
			<td></td>
			<td></td>
			<td>LDY zpx</td>
			<td>LDA zpx</td>
			<td>LDX zpy</td>
			<td></td>
			<td>CLV imp</td>
			<td>LDA aby</td>
			<td>TSX imp</td>
			<td></td>
			<td>LDY abx</td>
			<td>LDA abx</td>
			<td>LDX aby</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>C-</th>
			<td>CPY imm</td>
			<td>CMP idx</td>
			<td></td>
			<td></td>
			<td>CPY zpg</td>
			<td>CMP zpg</td>
			<td>DEC zpg</td>
			<td></td>
			<td>INY imp</td>
			<td>CMP imm</td>
			<td>DEX imp</td>
			<td></td>
			<td>CPY abs</td>
			<td>CMP abs</td>
			<td>DEC abs</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>D-</th>
			<td>BNE rel</td>
			<td>CMP idy</td>
			<td></td>
			<td></td>
			<td></td>
			<td>CMP zpx</td>
			<td>DEC zpx</td>
			<td></td>
			<td>CLD imp</td>
			<td>CMP aby</td>
			<td></td>
			<td></td>
			<td></td>
			<td>CMP abx</td>
			<td>DEC abx</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>E-</th>
			<td>CPX imm</td>
			<td>SBC idx</td>
			<td></td>
			<td></td>
			<td>CPX zpg</td>
			<td>SBC zpg</td>
			<td>INC zpg</td>
			<td></td>
			<td>INX imp</td>
			<td>SBC imm</td>
			<td>NOP imp</td>
			<td></td>
			<td>CPX abs</td>
			<td>SBC abs</td>
			<td>INC abs</td>
			<td></td>
		</tr>
		<tr>
			<th class='row-header'>F-</th>
			<td>BEQ rel</td>
			<td>SBC idx</td>
			<td></td>
			<td></td>
			<td></td>
			<td>SBC zpx</td>
			<td>INC zpx</td>
			<td></td>
			<td>SED imp</td>
			<td>SBC aby</td>
			<td></td>
			<td></td>
			<td></td>
			<td>SBC abx</td>
			<td>INC abx</td>
			<td></td>
		</tr>
</table>

<H3>Addressing Modes</H3>
<div><i>
Note: The 6502 is little-endian, for example 0xBEEF is stored as 0xEF 0xBE in memory.<br>
LL means low byte, HH means high byte, for example the instruction JMP $FF00 would in memory be:<br>
<table>
<tr><td>JMP</td><td>LL</td><td>HH</td><tr>
<tr><td>4C</td><td>00</td><td>FF</td><tr>
</table>
</i></div>
<B>acc - Accumulator - 1 byte</B>
<div>Operand is register A.</div>
<B>abs - Absolute - 3 bytes</B>
<div>Operand is address HHLL.</div>
<B>abx - Absolute, X-indexed - 3 bytes</B>
<div>Operand is address HHLL, effective address is address incremented by X.</div>
<B>aby - Absolute, Y-indexed - 3 bytes</B>
<div>Operand is address HHLL, effective address is address incremented by Y.</div>
<B>imm - Immediate - 2 bytes</B>
<div>Operand is byte following instruction.</div>
<B>imp - Implied - 1 byte</B>
<div>Operand is implied.</div>
<B>ind - Indirect - 3 bytes</B>
<div>Operand is address, effective address is contents of word at address HHLL.</div>
<B>idx - X-indexed, indirect - 2 bytes</B>
<div>Operand is zero page address, effective address is the address word at $(LL + X) without carry.</div>
<B>idy - Indirect, Y-indexed - 2 bytes</B>
<div>Operand is zero page address, effective address is the address word at $(LL) + Y with carry.</div>
<B>rel - Relative - 2 bytes</B>
<div>Operand is signed offset from program counter.</div>
<B>zpg - Zeropage - 1 byte</B>
<div>Operand is zero page address (high byte is zero).</div>
<B>zpx - Zeropage, X-indexed - 1 Byte</B>
<div>Operand is zero page address, effective address is address incremented by X without carry.</div>
<B>zpy - Zeropage, Y-indexed - 1 Byte</B>
<div>Operand is zero page address, effective address is address incremented by Y without carry.</div>
<H3>Instructions</H3>
<B>ADC - add with carry</B><BR>
<i>Operation: A + M + carry -> A, carry.</i><BR>
<B>AND - and (with accumulator)</B><BR>
<i>Operation: A AND M -> A.</i><BR>
<B>ASL - arithmetic shift left</B><BR>
<i>Operation: carry <- [7...0] <- 0.</i><BR>
<B>BCC - branch on carry clear</B><BR>
<i>Operation: branch if carry = 0.</i><BR>
<B>BCS - branch on carry set</B><BR>
<i>Operation: branch if carry = 1.</i><BR>
<B>BEQ - branch on equal (zero set)</B><BR>
<i>Operation: branch if zero = 1.</i><BR>
<B>BIT - bit test</B><BR>
<i>Operation: A AND M, bit 7 -> sign, bit 6 -> overflow.</i><BR>
<B>BMI - branch on minus (negative set)</B><BR>
<i>Operation: branch if sign = 1.</i><BR>
<B>BNE - branch on not equal (zero clear)</B><BR>
<i>Operation: branch if zero = 0.</i><BR>
<B>BPL - branch on plus (negative clear)</B><BR>
<i>Operation: branch if sign = 0.</i><BR>
<B>BRK - break / interrupt</B><BR>
<i>Operation: interrupt, push PC+2, push status.</i><BR>
<B>BVC - branch on overflow clear</B><BR>
<i>Operation: branch if overflow = 0.</i><BR>
<B>BVS - branch on overflow set</B><BR>
<i>Operation: branch if overflow = 1.</i><BR>
<B>CLC - clear carry</B><BR>
<i>Operation: 0 -> carry.</i><BR>
<B>CLD - clear decimal</B><BR>
<i>Operation: 0 -> decimal.</i><BR>
<B>CLI - clear interrupt disable</B><BR>
<i>Operation: 0 -> interrupt.</i><BR>
<B>CLV - clear overflow</B><BR>
<i>Operation: 0 -> overflow.</i><BR>
<B>CMP - compare (with accumulator)</B><BR>
<i>Operation: A - M.</i><BR>
<B>CPX - compare with X</B><BR>
<i>Operation: X - M.</i><BR>
<B>CPY - compare with Y</B><BR>
<i>Operation: Y - M.</i><BR>
<B>DEC - decrement</B><BR>
<i>Operation: M - 1 -> M.</i><BR>
<B>DEX - decrement X</B><BR>
<i>Operation: X - 1 -> X.</i><BR>
<B>DEY - decrement Y</B><BR>
<i>Operation: Y - 1 -> Y.</i><BR>
<B>EOR - exclusive or (with accumulator)</B><BR>
<i>Operation: A EOR M -> A.</i><BR>
<B>INC - increment</B><BR>
<i>Operation: M + 1 -> M.</i><BR>
<B>INX - increment X</B><BR>
<i>Operation: X + 1 -> X.</i><BR>
<B>INY - increment Y</B><BR>
<i>Operation: Y + 1 -> Y.</i><BR>
<B>JMP - jump</B><BR>
<i>Operation: (PC+1) -> PCL, (PC+2) -> PCH.</i><BR>
<B>JSR - jump subroutine</B><BR>
<i>Operation: push (PC+2), (PC+1) -> PCL, (PC+2) -> PCH.</i><BR>
<B>LDA - load accumulator</B><BR>
<i>Operation: M -> A.</i><BR>
<B>LDX - load X</B><BR>
<i>Operation: M -> X.</i><BR>
<B>LDY - load Y</B><BR>
<i>Operation: M -> Y.</i><BR>
<B>LSR - logical shift right</B><BR>
<i>Operation: 0 -> [7...0] -> carry.</i><BR>
<B>NOP - no operation</B><BR>
<i>Operation: nothing.</i><BR>
<B>ORA - or with accumulator</B><BR>
<i>Operation: A OR M -> A.</i><BR>
<B>PHA - push accumulator</B><BR>
<i>Operation: push A.</i><BR>
<B>PHP - push processor status (SR)</B><BR>
<i>Operation: push (status OR break).</i><BR>
<B>PLA - pull accumulator</B><BR>
<i>Operation: pull A.</i><BR>
<B>PLP - pull processor status (SR)</B><BR>
<i>Operation: pull status.</i><BR>
<B>ROL - rotate left</B><BR>
<i>Operation: carry <- [7...0] <- carry.</i><BR>
<B>ROR - rotate right</B><BR>
<i>Operation: carry -> [7...0] -> carry.</i><BR>
<B>RTI - return from interrupt</B><BR>
<i>Operation: pull status, pull PC.</i><BR>
<B>RTS - return from subroutine</B><BR>
<i>Operation: pull PC, PC + 1 -> PC.</i><BR>
<B>SBC - subtract with carry</B><BR>
<i>Operation: A - M - (!carry) -> A.</i><BR>
<B>SEC - set carry</B><BR>
<i>Operation: 1 -> carry.</i><BR>
<B>SED - set decimal</B><BR>
<i>Operation: 1 -> decimal.</i><BR>
<B>SEI - set interrupt disable</B><BR>
<i>Operation: 1 -> interrupt.</i><BR>
<B>STA - store accumulator</B><BR>
<i>Operation: A -> M.</i><BR>
<B>STX - store X</B><BR>
<i>Operation: X -> M.</i><BR>
<B>STY - store Y</B><BR>
<i>Operation: Y -> M.</i><BR>
<B>TAX - transfer accumulator to X</B><BR>
<i>Operation: A -> X.</i><BR>
<B>TAY - transfer accumulator to Y</B><BR>
<i>Operation: A -> Y.</i><BR>
<B>TSX - transfer stack pointer to X</B><BR>
<i>Operation: SP -> X.</i><BR>
<B>TXA - transfer X to accumulator</B><BR>
<i>Operation: X -> A.</i><BR>
<B>TXS - transfer X to stack pointer</B><BR>
<i>Operation: X -> SP.</i><BR>
<B>TYA - transfer Y to accumulator</B><BR>
<i>Operation: Y -> A.</i><BR>"}
