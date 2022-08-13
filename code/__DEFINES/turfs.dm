#define CHANGETURF_DEFER_CHANGE 1
#define CHANGETURF_IGNORE_AIR 2 // This flag prevents changeturf from gathering air from nearby turfs to fill the new turf with an approximation of local air
#define CHANGETURF_FORCEOP 4
#define CHANGETURF_SKIP 8 // A flag for PlaceOnTop to just instance the new turf instead of calling ChangeTurf. Used for uninitialized turfs NOTHING ELSE
#define CHANGETURF_INHERIT_AIR 16 // Inherit air from previous turf. Implies CHANGETURF_IGNORE_AIR
#define CHANGETURF_RECALC_ADJACENT 32 //Immediately recalc adjacent atmos turfs instead of queuing.

#define IS_OPAQUE_TURF(turf) (turf.directional_opacity == ALL_CARDINALS)

// Defines for turf rust resistance
#define RUST_RESISTANCE_BASIC 1
#define RUST_RESISTANCE_REINFORCED 2
#define RUST_RESISTANCE_TITANIUM 3
#define RUST_RESISTANCE_ORGANIC 4
#define RUST_RESISTANCE_ABSOLUTE 5
