#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <math.h>

//#define FORCE_GNU_EXCEPTIONS

#if __STDC_VERSION__ >= 199901L
#ifndef FORCE_GNU_EXCEPTIONS
#warning "Using C99 FP exceptions."
#define USE_C99_FP_EXCP
#else /* FORCE_GNU_EXCEPTIONS */
#warning "Using non-standard GNU FP exceptions. (1)"
#define __USE_GNU
#endif /* FORCE_GNU_EXCEPTIONS */
#else /* __STDC_VERSION__ >= 199901L */
#warning "Using non-standard GNU FP exceptions. (2)"
#define __USE_GNU
#endif

#include <signal.h>
#include <fenv.h>
#include <float.h>

#define UNUSED(a) (void) (a)
#define STRINGIZE(x) #x
#define SVAL(x) STRINGIZE(x)

static FILE *dump = NULL;

void fpe_exception_dump(int code)
{
    if (0 == dump) return;

#ifdef USE_C99_FP_EXCP
    code = 0;

    if(fetestexcept(FE_DIVBYZERO)) code |= FE_DIVBYZERO;
    /* if(fetestexcept(FE_INEXACT))   code |= FE_INEXACT; */
    if(fetestexcept(FE_INVALID))   code |= FE_INVALID;
    if(fetestexcept(FE_OVERFLOW))  code |= FE_OVERFLOW;
    if(fetestexcept(FE_UNDERFLOW)) code |= FE_UNDERFLOW;

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

    fprintf(dump, " | (Code: 0x%04x) | (File: %s)\n", code, __FILE__);
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

#ifndef USE_C99_FP_EXCP
    struct sigaction a;
    feenableexcept(FE_ALL_EXCEPT & ~FE_INEXACT);

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
#ifdef USE_C99_FP_EXCP
    fpe_exception_dump(0);
    if (dump) fclose(dump);
#endif
}

void test_fp_exceptions(void)
{
    float f1 = 1.0;
    float f2 = 0.0;
    float f3 = -1;
    double d;

    int i1 = 1;
    int i2 = 0;

    UNUSED(f1); UNUSED(f2); UNUSED(f3);
    UNUSED(i1); UNUSED(i2); UNUSED(d);

#if 0
    f3 =  f2 / f2;
#endif

#if 1
    f3 = f1 / f2;
#endif

#if 0
    f3 = f1 / 10;
#endif

#if 0     
    sqrt(f3);
#endif

#if 0
    d = DBL_MAX*2.0;
#endif

#if 0
    f3 = FLT_MAX*2.0;
#endif

#if 0
    d = nextafter(DBL_MIN/pow(2.0,52),0.0);
#endif

#if 0
    i1 = i1 / i2;
#endif

#if 0
    d = DBL_MIN / 3.0;
#endif
}

