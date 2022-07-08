/datum/mos6502

#define imm 0
#define rel 1
#define zpg 2
#define zpx 3
#define zpy 4
#define abo 5
#define abx 6
#define aby 7
#define ind 8
#define idx 9
#define idy 10
#define acc 11
#define imp 12

	var/static/addressing = list(
		/*	0    1    2    3    4    5    6    7    8    9    A    B    C    D    E    F   */
	/* 0 */ imp, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, acc, imp, abo, abo, abo, imp,
	/* 1 */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, abx, imp,
	/* 2 */ abo, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, acc, imp, abo, abo, abo, imp,
	/* 3 */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, abx, imp,
	/* 4 */ imp, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, acc, imp, abo, abo, abo, imp,
	/* 5 */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, abx, imp,
	/* 6 */ imp, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, acc, imp, ind, abo, abo, imp,
	/* 7 */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, abx, imp,
	/* 8 */ imm, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, imp, imp, abo, abo, abo, imp,
	/* 9 */ rel, idy, imp, imp, zpx, zpx, zpy, imp, imp, aby, imp, imp, abx, abx, aby, imp,
	/* A */ imm, idx, imm, imp, zpg, zpg, zpg, imp, imp, imm, imp, imp, abo, abo, abo, imp,
	/* B */ rel, idy, imp, imp, zpx, zpx, zpy, imp, imp, aby, imp, imp, abx, abx, aby, imp,
	/* C */ imm, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, imp, imp, abo, abo, abo, imp,
	/* D */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, abx, imp,
	/* E */ imm, idx, imp, imp, zpg, zpg, zpg, imp, imp, imm, imp, imp, abo, abo, abo, imp,
	/* F */ rel, idy, imp, imp, zpx, zpx, zpx, imp, imp, aby, imp, imp, abx, abx, aby, imp,
	)

#undef imm
#undef rel
#undef zpg
#undef zpx
#undef zpy
#undef abo
#undef abx
#undef aby
#undef ind
#undef idx
#undef idy
#undef acc
#undef imp