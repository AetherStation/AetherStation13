// So we want to have compile time guarantees these procs exist on local type, unfortunately 515 killed the PROC_REF(procname) syntax so we have to use nameof()
#if DM_VERSION < 515
/// Call by name proc reference, checks if the proc exists on this type or as a global proc
#define PROC_REF(X) (.proc/##X)
/// Call by name proc reference, checks if the proc exists on given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (##TYPE.proc/##X)
/// Call by name proc reference, checks if the proc is existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)
#else
/// Call by name proc reference, checks if the proc exists on this type or as a global proc
#define PROC_REF(X) (nameof(.proc/##X))
/// Call by name proc reference, checks if the proc exists on given type or as a global proc
#define TYPE_PROC_REF(TYPE, X) (nameof(##TYPE.proc/##X))
/// Call by name proc reference, checks if the proc is existing global proc
#define GLOBAL_PROC_REF(X) (/proc/##X)
#endif
