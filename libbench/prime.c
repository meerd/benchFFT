/*
 * Copyright (c) 2001 Matteo Frigo
 * Copyright (c) 2001 Steven G. Johnson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

/* $Id: prime.c,v 1.5 2002/09/01 04:00:35 stevenj Exp $ */

#include "bench.h"

int check_prime_factors(unsigned int n, unsigned int maxprime)
/* returns #factors if the maximum prime factor of n is <= maxprime, and 0
   otherwise. */
{
     static const unsigned int primes[] = {
	  2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 
	  37, 41, 43, 47, 53, 59, 61, 67, 71, 73,
	  79, 83, 89, 97, 101, 103, 107, 109, 113 
     };

     int i, num_facts = 0;
     int nprimes = sizeof(primes) / sizeof(unsigned int);

     BENCH_ASSERT(maxprime <= primes[nprimes - 1]);

     if (n == 0)
	  return 1;

     for (i = 0; n > 1 && i < nprimes && primes[i] <= maxprime; ++i) {
	  while (n % primes[i] == 0) {
	       ++num_facts;
	       n /= primes[i];
	  }
     }

     return (n == 1 ? num_facts : 0);
}
