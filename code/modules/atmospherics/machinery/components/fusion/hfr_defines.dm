///Speed of light, in m/s
#define LIGHT_SPEED 299792458
///Calculation between the plank constant and the lambda of the lightwave
#define PLANCK_LIGHT_CONSTANT 2e-16
///Radius of the h2 calculated based on the amount of number of atom in a mole (and some addition for balancing issues)
#define CALCULATED_H2RADIUS 120e-4
///Radius of the trit calculated based on the amount of number of atom in a mole (and some addition for balancing issues)
#define CALCULATED_TRITRADIUS 230e-3
///Power conduction in the void, used to calculate the efficiency of the reaction
#define VOID_CONDUCTION 1e-2
///Max reaction point per reaction cycle
#define MAX_FUSION_RESEARCH 1000
///Min amount of allowed heat change
#define MIN_HEAT_VARIATION -1e5
///Max amount of allowed heat change
#define MAX_HEAT_VARIATION 1e5
///Max mole consumption per reaction cycle
#define MAX_FUEL_USAGE 36
///Conduction of heat inside the fusion reactor
#define METALLIC_VOID_CONDUCTIVITY 0.15
///Conduction of heat near the external cooling loop
#define HIGH_EFFICIENCY_CONDUCTIVITY 0.95
///Sets the minimum amount of power the machine uses
#define MIN_POWER_USAGE 50000
///Sets the multiplier for the damage
#define DAMAGE_CAP_MULTIPLIER 0.005
///Sets the range of the hallucinations
#define HALLUCINATION_HFR(P) (min(7, round(abs(P) ** 0.25)))

//If integrity percent remaining is less than these values, the monitor sets off the relevant alarm.
#define HYPERTORUS_MELTING_PERCENT 5
#define HYPERTORUS_EMERGENCY_PERCENT 25
#define HYPERTORUS_DANGER_PERCENT 50
#define HYPERTORUS_WARNING_PERCENT 100

#define WARNING_TIME_DELAY 60
///to prevent accent sounds from layering
#define HYPERTORUS_ACCENT_SOUND_MIN_COOLDOWN 3 SECONDS

#define HYPERTORUS_COUNTDOWN_TIME 30 SECONDS

#define HYPERTORUS_SUBCRITICAL_MOLES 2000
#define HYPERTORUS_HYPERCRITICAL_MOLES 10000
#define HYPERTORUS_MAX_MOLE_DAMAGE 10
