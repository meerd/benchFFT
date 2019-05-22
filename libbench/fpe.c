#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#if (FP_EXCEPTIONS + 0) != 0

#if __STDC_VERSION__ >= 199901L
#if (USE_GNU_FP_EXCEPTIONS+ 0) == 0
/* #warning "Using C99 FP exceptions." */
#define USE_C99_FP_EXCP
#else /* USE_GNU_FP_EXCEPTIONS*/
/* #warning "Using non-standard GNU FP exceptions. (1)" */
#define __USE_GNU
#endif /* USE_GNU_FP_EXCEPTIONS*/
#else /* __STDC_VERSION__ >= 199901L */
/* #warning "Using non-standard GNU FP exceptions. (2)" */
#define __USE_GNU
#endif

#include <signal.h>
#include <fenv.h>
#include <float.h>
#include <limits.h>

#define UNUSED(a) (void) (a)
#define STRINGIZE(x) #x
#define SVAL(x) STRINGIZE(x)

static FILE *dump = NULL;

static float f1 = 1.0;
static float f2 = 0.0;
static float f3 = -1;
static double d = 0.0;

static int i1 = 1;
static int i2 = 0;

#pragma GCC push_options
#pragma GCC optimize ("O0")

void test_fp_exceptions(int excp_index)
{
	switch (excp_index) {
	case 1: f3 = f2 / f2;              break;
	case 2: f3 = f1 / f2;              break;
	case 3: sqrt(f3);                  break;
	case 4: d = DBL_MAX * DBL_MAX;     break;
	case 5: f3 = FLT_MAX * FLT_MAX;    break;
	case 6: i1 = i1 / i2;              break;
	case 7: i2 = INT_MAX; i2 *= i2;    break;
	case 8: d = DBL_MIN / DBL_MAX;     break;
	case 9: d = FLT_MIN / FLT_MAX;     break;
		break;
	default:
		break;
	}
}

#pragma GCC pop_options

void fpe_exception_dump(int code)
{
    if (0 == dump) return;

#ifdef USE_C99_FP_EXCP
    code = 0;

    if (fetestexcept(FE_DIVBYZERO)) code |= FE_DIVBYZERO;
    if (fetestexcept(FE_INVALID))   code |= FE_INVALID;
    if (fetestexcept(FE_OVERFLOW))  code |= FE_OVERFLOW;
    if (fetestexcept(FE_UNDERFLOW)) code |= FE_UNDERFLOW;

    if (0 == code) {
        return;
    }
#endif

    fprintf(dump, "| F P  E X C E P T I O N | Reason: ");

    switch (code) {
#ifndef USE_C99_FP_EXCP
    case FPE_INTDIV:
        fprintf(dump, "Integer divide by zero.");
        break;

    case FPE_INTOVF:
        fprintf(dump, "Integer overflow.");
        break;

    case FPE_FLTDIV:
        fprintf(dump, "Divide by zero.");
        break;

    case FPE_FLTOVF:
        fprintf(dump, "Overflow.");
        break;

    case FPE_FLTUND:
        fprintf(dump, "Underflow.");
        break;

    case FPE_FLTRES:
        fprintf(dump, "Inexact result.");
        break;

    case FPE_FLTINV:
        fprintf(dump, "Invalid operation.");
        break;

    case FPE_FLTSUB:
        fprintf(dump, "Subscript out of range.");
        break;
#else
    case FE_DIVBYZERO:
        fprintf(dump, "Divide by zero. (C99)");
        break;

    case FE_INEXACT:
        fprintf(dump, "Inexact result. (C99)");
        break;

    case FE_INVALID:
        fprintf(dump, "Invalid operation. (C99)");
        break;

    case FE_OVERFLOW:
        fprintf(dump, "Overflow. (C99)");
        break;

    case FE_UNDERFLOW:
        fprintf(dump, "Underflow. (C99)");
        break;

#endif
    default:
        fprintf(dump, "Unknown.");
        break;
    }

    fprintf(dump, " | (Code: 0x%04x)\n", code);
}

#ifndef USE_C99_FP_EXCP
static void sigfpe_handler(int sig, siginfo_t *info, void *context)
{
    UNUSED(sig); UNUSED(info); UNUSED(context);
    fpe_exception_dump(info->si_code);
    if (info->si_code) {
        if (dump) {
            fclose(dump);
        }
        exit(EXIT_FAILURE);
    }
}
#endif

void enable_fp_exceptions(void)
{
    const char *out = SVAL(ROOT_DIR) "/exceptions.txt";
    dump = fopen(out, "a+");

	/* srand(time(0)); */
#ifndef USE_C99_FP_EXCP
    struct sigaction a;
	/* In some implementations underflow may lead to misleading results. */ 
	/* Ignore inexact exceptions. */ 
    feenableexcept(FE_ALL_EXCEPT & ~(FE_UNDERFLOW | FE_INEXACT));

    memset(&a, 0, sizeof(a));
    a.sa_sigaction = sigfpe_handler;
    a.sa_flags = SA_SIGINFO;

    if (-1 == sigaction(SIGFPE, &a, NULL)) {
        fprintf(stderr, "Error while registering sigfpe handler\n");
        exit(EXIT_FAILURE);
    }
#else
    feclearexcept(FE_ALL_EXCEPT);
#endif
}

void save_fp_exceptions(void)
{
	/* test_fp_exceptions(rand() % 9 + 1); */
#ifdef USE_C99_FP_EXCP
    fpe_exception_dump(0);
    if (dump) fclose(dump);
#endif
}

#endif
