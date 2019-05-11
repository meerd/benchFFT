#include "fastffts.h"

void tablesixstepfft(float *indata, long nn, int isign)

/*  This is a modified version of a six-step-FFT routine from the  */
/*  apfloat() package.  It is a standard complex FFT.              */
/*  It uses a split-radix, table-look-up, six-step FFT.            */
/*  It is VERY fast duw to high memory locality.                   */
/*  The forward transform (i.e. normal FFT) is isign=-1            */

{
    long n1, n2, twon2, j, k, kind;
    double wpr, wpi, wr, wi, wtemp, theta, tmp = 0.0;
    float *p1;
    rawtype *data;
    double *table;

    if (nn < 2)
	return;

    data = (rawtype *) indata;

    for (n1 = 1, n2 = 0; n1 < nn; n1 <<= 1, n2++);
    n1 = n2 >> 1;
    n2 -= n1;

    n1 = 1 << n1;
    n2 = 1 << n2;

    // n2 >= n1

    // treat the input data as a n1 x n2 matrix

    // first transpose the matrix

    transpose(data, n1, n2);

    // then do n2 transforms of length n1

    table = maketable(n1, 1);
    for (k = 0, p1 = indata; k < n2; k++, p1 += 2 * n1) {
	tablesplitfftraw(p1, table, n1, isign);
	scramble(p1, n1);
    }
    cleantable(table, n1);

    // transpose the matrix

    transpose(data, n2, n1);

    // then multiply the matrix A_jk by exp(isign * 2 pi i j k / nn)
    // Use recursion formulas from NR

    twon2 = 2 * n2;

    for (j = 1, p1 = indata + twon2; j < n1; j++, p1 += twon2) {
	theta = isign * j * 6.28318530717959 / nn;
	wtemp = sin(0.5 * theta);
	wpr = -2.0 * wtemp * wtemp;
	wpi = sin(theta);
	wr = 1.0 + wpr;
	wi = wpi;
	for (k = 1, kind = 2; k < n2; k++, kind += 2) {
	    p1[kind] = (tmp = p1[kind]) * wr - p1[kind + 1] * wi;
	    p1[kind + 1] = p1[kind + 1] * wr + tmp * wi;
	    wr = (wtemp = wr) * wpr - wi * wpi + wr;
	    wi = wi * wpr + wtemp * wpi + wi;
	}
    }

    // then do n1 transforms of length n2

    table = maketable(n2, 1);
    for (k = 0, p1 = indata; k < n1; k++, p1 += 2 * n2) {
	tablesplitfftraw(p1, table, n2, isign);
	scramble(p1, n2);
    }
    cleantable(table, n2);

    // last transpose the matrix

    transpose(data, n1, n2);
}



void realfft(float idata[], unsigned long n, int isign)

/*  This is a modified version of the NR routine with correct (-)  */
/*  exponent.  It uses the above tablesixstepfft making it very    */
/*  fast.  The forward transform (i.e. normal FFT) is isign=-1     */

{
    unsigned long i, i1, i2, i3, i4, np3;
    float c1 = 0.5, c2, h1r, h1i, h2r, h2i;
    double wr, wi, wpr, wpi, wtemp, theta;
    float *data;

    isign = -isign;
    data = idata-1;
    theta = 3.141592653589793 / (double) (n >> 1);
    if (isign == 1) {
	c2 = -0.5;
	tablesixstepfft(idata, n >> 1, -1);
	theta = -theta;
    } else {
	c2 = 0.5;
    }
    wtemp = sin(0.5 * theta);
    wpr = -2.0 * wtemp * wtemp;
    wpi = sin(theta);
    wr = 1.0 + wpr;
    wi = wpi;
    np3 = n + 3;
    for (i = 2; i <= (n >> 2); i++) {
	i4 = 1 + (i3 = np3 - (i2 = 1 + (i1 = i + i - 1)));
	h1r = c1 * (data[i1] + data[i3]);
	h1i = c1 * (data[i2] - data[i4]);
	h2r = -c2 * (data[i2] + data[i4]);
	h2i = c2 * (data[i1] - data[i3]);
	data[i1] = h1r + wr * h2r - wi * h2i;
	data[i2] = h1i + wr * h2i + wi * h2r;
	data[i3] = h1r - wr * h2r + wi * h2i;
	data[i4] = -h1i + wr * h2i + wi * h2r;
	wr = (wtemp = wr) * wpr - wi * wpi + wr;
	wi = wi * wpr + wtemp * wpi + wi;
    }
    if (isign == 1) {
	data[1] = (h1r = data[1]) + data[2];
	// This sets data[2]=0.0 (We don't use this...)
	// data[2] = 0.0;
	// This sets data[2]=Nyquist Freq value
	data[2] = h1r - data[2];

    } else {
	data[1] = c1 * ((h1r = data[1]) + data[2]);
	data[2] = c1 * (h1r - data[2]);
	tablesixstepfft(idata, n >> 1, -1);
    }
}


// Various FFT routines and aux. routines


void tablesplitfft(float data[], unsigned long nn, int isign)
{

//  This is a split-radix Decimation in Frequency FFT

    double *table;

    table = maketable(nn, 1);
    tablesplitfftraw(data, table, nn, isign);
    scramble(data, nn);
    cleantable(table, nn);
}


void tablefft(float data[], unsigned long nn, int isign)
{

//  This is a radix-2 Gentleman-Sande or Decimation in Frequency FFT

    double *table;

    table = maketable(nn, isign);
    tablefftraw(data, table, nn);
    scramble(data, nn);
    cleantable(table, nn);
}


double *
 maketable(unsigned long nn, int isign)
{
    long i, n;
    double wtemp, wr, wpr, wpi, wi, theta;
    double *table;

    n = (nn << 1);
    table = dvect(0, n - 1);
    table[0] = 1.0;
    table[1] = 0.0;
    theta = isign * (6.28318530717959 / nn);
    wtemp = sin(0.5 * theta);
    wpr = -2.0 * wtemp * wtemp;
    wpi = sin(theta);
    wr = 1 + wpr;
    wi = wpi;
    for (i = 2; i < n; i += 2) {
 	table[i] = wr;
 	table[i + 1] = wi;
 	wr = (wtemp = wr) * wpr - wi * wpi + wr;
 	wi = wi * wpr + wtemp * wpi + wi;
    }
    /* To check trig recursion above...
    for (i = 0; i < n; i += 2) {
        theta = isign*i*(3.14159265358979324/nn);
	table[i] = cos(theta);
	table[i + 1] = sin(theta);
    }
    */
    return table;
}


void cleantable(double table[], unsigned long nn)
{
    free_dvect(table, 0, nn * 2 - 1);
}


void scramble(float data[], unsigned long nn)
{
    long i, j, m, n;
    float tempr;

    data--;
    n = nn << 1;
    j = 1;
    for (i = 1; i < n; i += 2) {
	if (j > i) {
	    SWAP(data[j], data[i]);
	    SWAP(data[j + 1], data[i + 1]);
	}
	m = n >> 1;
	while (m >= 2 && j > m) {
	    j -= m;
	    m >>= 1;
	}
	j += m;
    }
}


void tablefftraw(float data[], double table[], unsigned long n)
{

//  This is a radix-2 Gentleman-Sande or Decimation in Frequency FFT

    register long j, m = 2, p, q, k, n2 = n, n1, nn;
    register double c, s, rtmp, itmp;

    nn = (n << 1);
    while (m < nn) {
	n1 = n2;
	n2 >>= 1;
	for (j = 0, q = 0; j < n1; j += 2) {
	    c = table[q];
	    s = table[q + 1];
	    q += m;
	    for (k = j; k < nn; k += n1 * 2) {
		p = (k + n1);
		rtmp = data[k] - data[p];
		itmp = data[k + 1] - data[p + 1];
		data[k] += data[p];
		data[k + 1] += data[p + 1];
		data[p] = c * rtmp - s * itmp;
		data[p + 1] = c * itmp + s * rtmp;
	    }
	}
	m <<= 1;
    }
}


void tablesplitfftraw(float data[], double table[], unsigned long n, int isign)
{

//  This is a split-radix Decimation in Frequency FFT

    int m, n2, j, is, id;
    register int i0, n4, n3;
    register int i0i, i1i, i2i, i3i;
    double r1, r2, s1, s2, s3, cc1, ss1, cc3, ss3;
    int a, a3, ai, a3i, ndec = n - 1;
    float *x;

    // The following is a total HACK.  See below also.
    if (isign == 1) for (j = 1; j < n*2; j+=2) data[j]=-data[j];
    x = data - 2;
    n2 = n << 1;
    m = 1;
    while (m < n / 2) {
	n2 >>= 1;
	n4 = n2 >> 2;
	n3 = n2 >> 1;
	a = 0;
	for (j = 1; j <= n4; j++) {
	    ai = a << 1;
	    a3 = (a + (a << 1)) & ndec;
	    a3i = a3 << 1;
	    cc1 = table[ai];
	    ss1 = table[ai + 1];
	    cc3 = table[a3i];
	    ss3 = table[a3i + 1];
	    a = (a + m) & ndec;
	    is = j;
	    id = n2 << 1;
	    do {
		for (i0 = is; i0 <= n - 1; i0 += id) {
		    i0i = i0 << 1;
		    i1i = i0i + n3;
		    i2i = i1i + n3;
		    i3i = i2i + n3;
		    r1 = x[i0i] - x[i2i];
		    x[i0i] += x[i2i];
		    r2 = x[i1i] - x[i3i];
		    x[i1i] += x[i3i];
		    s1 = x[i0i + 1] - x[i2i + 1];
		    x[i0i + 1] += x[i2i + 1];
		    s2 = x[i1i + 1] - x[i3i + 1];
		    x[i1i + 1] += x[i3i + 1];
		    s3 = r1 - s2;
		    r1 += s2;
		    s2 = r2 - s1;
		    r2 += s1;
		    x[i2i] = r1 * cc1 - s2 * ss1;
		    x[i2i + 1] = -s2 * cc1 - r1 * ss1;
		    x[i3i] = s3 * cc3 + r2 * ss3;
		    x[i3i + 1] = r2 * cc3 - s3 * ss3;
		}
		is = (id << 1) - n2 + j;
		id <<= 2;
	    }
	    while (is < n);
	}
	m <<= 1;
    }
    is = 1;
    id = 4;
    do {
	for (i0 = is; i0 <= n; i0 += id) {
	    i0i = i0 << 1;
	    i1i = i0i + 2;
	    r1 = x[i0i];
	    x[i0i] = r1 + x[i1i];
	    x[i1i] = r1 - x[i1i];
	    r1 = x[i0i + 1];
	    x[i0i + 1] = r1 + x[i1i + 1];
	    x[i1i + 1] = r1 - x[i1i + 1];
	}
	is = (id << 1) - 1;
	id <<= 2;
    }
    while (is < n);
    // The following is a total HACK.
    if (isign == 1) for (j = 1; j < n*2; j+=2) data[j]=-data[j];
}


// Optimized transposition routines
// Work for n1=n2, n1=2*n2 and n2=2*n1 only

// Move a b x b block from s to d, d width = nd , s width = ns
void moveblock(rawtype d[], rawtype s[], int b, int nd, int ns)
{
    int j, k;

    for (j = 0; j < b; j++) {
	for (k = 0; k < b; k++)
	    d[k] = s[k];

	d += nd;
	s += ns;
    }
}

// Transpose two b x b blocks of matrix with width nn
// data1 is accessed in columns, data2 in rows
void transpose2blocks(rawtype data1[], rawtype data2[], int b, int nn)
{
    int j, k;
    rawtype tmp, *p1, *p2;

    for (j = 0, p1 = data2; j < b; j++, p1 += nn)
	for (k = 0, p2 = data1 + j; k < b; k++, p2 += nn) {
	    tmp = p1[k];
	    p1[k] = *p2;
	    *p2 = tmp;
	}
}

// Transpose a b x b block of matrix with width nn
void transposeblock(rawtype data[], int b, int nn)
{
    int j, k;
    rawtype tmp, *p1, *p2;

    for (j = 0, p1 = data; j < b; j++, p1 += nn)
	for (k = j + 1, p2 = data + k * nn + j; k < b; k++, p2 += nn) {
	    tmp = p1[k];
	    p1[k] = *p2;
	    *p2 = tmp;
	}
}

// Transpose a _square_ n1 x n1 block of n1 x n2 matrix in b x b blocks
void transposesquare(rawtype data[], int n1, int n2)
{
    int j, k, b;
    rawtype *p1, *p2;
    rawtype *tmp1, *tmp2;

    if (n1 <= Cacheburstblocksize || n1 <= Cacheblocksize)
	transposeblock(data, n1, n2);
    else if (n1 * n2 <= Cachetreshold) {
	b = Cacheburstblocksize;

	for (j = 0, p1 = data; j < n1; j += b, p1 += b * n2) {
	    transposeblock(p1 + j, b, n2);
	    for (k = j + b, p2 = data + k * n2 + j; k < n1; k += b, p2 += b * n2)
		transpose2blocks(p1 + k, p2, b, n2);
	}
    } else {
	b = Cacheblocksize;

	tmp1 = raw_vect(0, b * b - 1);
	tmp2 = raw_vect(0, b * b - 1);

	for (j = 0, p1 = data; j < n1; j += b, p1 += b * n2) {
	    moveblock(tmp1, p1 + j, b, b, n2);
	    transposeblock(tmp1, b, b);
	    moveblock(p1 + j, tmp1, b, n2, b);

	    for (k = j + b, p2 = data + k * n2 + j; k < n1; k += b, p2 += b * n2) {
		moveblock(tmp1, p1 + k, b, b, n2);
		transposeblock(tmp1, b, b);

		moveblock(tmp2, p2, b, b, n2);
		transposeblock(tmp2, b, b);

		moveblock(p1 + k, tmp2, b, n2, b);
		moveblock(p2, tmp1, b, n2, b);
	    }
	}

	free_raw_vect(tmp1, 0, b * b - 1);
	free_raw_vect(tmp2, 0, b * b - 1);
    }
}


// Permute the rows of matrix to correct order, must be n2 = 2*n1
void permutewidetotall(rawtype data[], int n1, int n2)
{
    int j, o, m;
    int *r;
    rawtype *d;

    if (n2 < 4)
	return;

    d = raw_vect(0, n1 - 1);
    r = ivect(0, n2 - 1);

    for (j = 0; j < n2; j++)
	r[j] = 0;

    j = 1;
    do {
	o = m = j;

	moveraw(d, data + n1 * m, n1);

	r[m] = 1;

	m = (m < n1 ? 2 * m : 2 * (m - n1) + 1);

	while (m != j) {
	    r[m] = 1;

	    moveraw(data + n1 * o, data + n1 * m, n1);

	    o = m;
	    m = (m < n1 ? 2 * m : 2 * (m - n1) + 1);
	};

	moveraw(data + n1 * o, d, n1);

	while (r[j])
	    j++;
    }
    while (j < n2 - 1);

    free_raw_vect(d, 0, n1 - 1);
    free_ivect(r, 0, n2 - 1);
}


// Permute the rows of matrix to correct order, must be n1 = 2*n2
void permutetalltowide(rawtype data[], int n1, int n2)
{
    int j, o, m;
    int *r;
    rawtype *d;

    if (n1 < 4)
	return;

    d = raw_vect(0, n2 - 1);
    r = ivect(0, n1 - 1);

    for (j = 0; j < n1; j++)
	r[j] = 0;

    j = 1;
    do {
	o = m = j;

	moveraw(d, data + n2 * m, n2);

	r[m] = 1;

	m = (m & 1 ? m / 2 + n2 : m / 2);

	while (m != j) {
	    r[m] = 1;

	    moveraw(data + n2 * o, data + n2 * m, n2);

	    o = m;
	    m = (m & 1 ? m / 2 + n2 : m / 2);
	};

	moveraw(data + n2 * o, d, n2);

	while (r[j])
	    j++;
    }
    while (j < n1 - 1);

    free_raw_vect(d, 0, n2 - 1);
    free_ivect(r, 0, n1 - 1);
}


// Transpose a n1 x n2 matrix. Must be n1 = n2, n1 = 2*n2 or n2 = 2*n1
void transpose(rawtype data[], int n1, int n2)
{
    if (n1 == n2) {
	// simply transpose

	transposesquare(data, n1, n1);
    } else if (n2 == 2 * n1) {
	// first transpose two n1 x n1 blocks
	transposesquare(data, n1, n2);
	transposesquare(data + n1, n1, n2);

	// then permute the rows to correct order
	permutewidetotall(data, n1, n2);
    } else if (n1 == 2 * n2) {
	// first permute the rows to correct order
	permutetalltowide(data, n1, n2);

	// then transpose two n2 x n2 blocks
	transposesquare(data, n2, n1);
	transposesquare(data + n2, n2, n1);
    }
}


// Optimized routines for moving big blocks of data

void moveraw(void *d, void *s, int n)
{
    rawtype *dd, *ss;

    dd = (rawtype *) d;
    ss = (rawtype *) s;

    while (n--)
	*(dd++) = *(ss++);
}

void swapraw(void *d, void *s, int n)
{
    rawtype tmp, *dd, *ss;

    dd = (rawtype *) d;
    ss = (rawtype *) s;

    while (n--) {
	tmp = *dd;
	*(dd++) = *ss;
	*(ss++) = tmp;
    }
}


//  Vector allocation and de-allocation routines

int *ivect(long nl, long nh)
/* allocate an int vector with subscript range v[nl..nh] */
{
    int *v;

    v = (int *) malloc((size_t) ((nh - nl + 1 + ARR_END) * sizeof(int)));
    if (!v) {
	printf("allocation failure in ivect()");
	exit(1);
    }
    return v - nl + ARR_END;
}


float *vect(long nl, long nh)
/* allocate a float vector with subscript range v[nl..nh] */
{
    float *v;

    v = (float *) malloc((size_t) ((nh - nl + 1 + ARR_END) * sizeof(float)));
    if (!v) {
	printf("allocation failure in vect()");
	exit(1);
    }
    return v - nl + ARR_END;
}


double *dvect(long nl, long nh)
/* allocate a double vector with subscript range v[nl..nh] */
{
    double *v;

    v = (double *) malloc((size_t) ((nh - nl + 1 + ARR_END) * sizeof(double)));
    if (!v) {
	printf("allocation failure in dvect()");
	exit(1);
    }
    return v - nl + ARR_END;
}


rawtype *raw_vect(long nl, long nh)
/* allocate a float vector with subscript range v[nl..nh] */
{
    rawtype *v;

    v = (rawtype *) malloc((size_t) ((nh - nl + 1 + ARR_END) * sizeof(rawtype)));
    if (!v) {
	printf("allocation failure in raw_vect()");
	exit(1);
    }
    return v - nl + ARR_END;
}


void free_ivect(int *v, long nl, long nh)
/* free an int vector allocated with ivect() */
{
    free((FREE_ARG) (v + nl - ARR_END));
}


void free_vect(float *v, long nl, long nh)
/* free a float vector allocated with vect() */
{
    free((FREE_ARG) (v + nl - ARR_END));
}


void free_dvect(double *v, long nl, long nh)
/* free a double vector allocated with dvect() */
{
    free((FREE_ARG) (v + nl - ARR_END));
}


void free_raw_vect(rawtype * v, long nl, long nh)
/* free a rawtype vector allocated with raw_vector() */
{
    free((FREE_ARG) (v + nl - ARR_END));
}


