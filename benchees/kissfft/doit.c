/* this program is in the public domain */

#include "bench-user.h"
#include <math.h>
#include "kiss_fft.h"
#include "./tools/kiss_fftnd.h"
#include "./tools/kiss_fftr.h"
#include "./tools/kiss_fftndr.h"
BEGIN_BENCH_DOC
BENCH_DOC("name", "kissfft")
BENCH_DOC("version", "1.3")
BENCH_DOC("year", "2019")
BENCH_DOC("author", "Mark Borgerding")
BENCH_DOC("language", "C")
BENCH_DOC("url", "http://sourceforge.net/projects/kissfft/")
BENCH_DOC("copyright",
"Copyright (c) 2003, Mark Borgerding\n"
"\n"
"All rights reserved.\n"
"\n"
"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n"
"\n"
"    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n"
"    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n"
"    * Neither the author nor the names of any contributors may be used to endorse or promote products derived from this software without specific prior written permission.\n"
"\n"
	  "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.\n")
END_BENCH_DOC

int can_do(struct problem *p)
{
	if (p->kind != PROBLEM_COMPLEX) {
		return (p->size % 2 == 0) && (0 == p->in_place);
	}

	return 0 == p->in_place;
}

static void *WORK;

void copy_h2c(struct problem *p, bench_complex *out)
{
     copy_h2c_unpacked(p, out, -1.0);
}

void copy_c2h(struct problem *p, bench_complex *in)
{
     copy_c2h_unpacked(p, in, -1.0);
}

void copy_r2c(struct problem *p, bench_complex *out)
{
     if (problem_in_place(p))
	  copy_r2c_unpacked(p, out);	  
     else
	  copy_r2c_packed(p, out);
}

void copy_c2r(struct problem *p, bench_complex *in)
{
     if (problem_in_place(p))
	  copy_c2r_unpacked(p, in);
     else
	  copy_c2r_packed(p, in);
}

void setup(struct problem *p)
{
    if (p->kind == PROBLEM_COMPLEX) {
		if (p->rank == 1) { 
			WORK = kiss_fft_alloc(p->n[0], (p->sign == 1), 0, 0);
		} else {
			WORK = kiss_fftnd_alloc((const int *) p->n, p->rank, (p->sign == 1), 0, 0);
		}
	} else {
		if (p->rank == 1) { 
			WORK = kiss_fftr_alloc(p->n[0], (p->sign == 1), 0, 0);
		} else {
			WORK = kiss_fftndr_alloc((const int *) p->n, p->rank, (p->sign == 1), 0, 0);
		}
	}
}

void doit(int iter, struct problem *p)
{
     int i;
     void *in = p->in;
     void *work = WORK;
     
     if (0 == p->in_place) {
	   void *out = p->out;

		if (p->kind == PROBLEM_COMPLEX) {
			if (p->rank == 1) { 
				for (i = 0; i < iter; ++i) 
					kiss_fft(work, in, out);
			} else {
				for (i = 0; i < iter; ++i)
					kiss_fftnd(work, in, out);
			}
		} else {
			if (p->rank == 1) { 
				for (i = 0; i < iter; ++i) {
					if (p->sign == 1) 
						kiss_fftri(work, in, out);
					else
						kiss_fftr(work, in, out);
				}
			} else {
				for (i = 0; i < iter; ++i) {
					if (p->sign == 1) 
						kiss_fftndri(work, in, out);
					else
						kiss_fftndr(work, in, out);
				} 
			}
		}
     }
}

void done(struct problem *p)
{
     free(WORK);
     UNUSED(p);
}
