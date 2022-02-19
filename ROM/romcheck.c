
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <stdlib.h>


void usage() {

	printf("romcheck - calculate and fix Commodore ROM checksums\n" 
		"Usage:\n" 
		"  romcheck <options>\n"
		"calculate ROM checksum for stdin\n"
		"  romcheck <options> inputfile\n" 
		"calculate ROM checksum for inputfile.\n"
		"Options:\n"
		" -s <checksum>\n"
		"     define expected checksum, e.g. '-e 0xe0' or '-e12'\n"
		" -i <injectaddr>\n"
		"     define address (relative to start of file) where\n"
		"     byte is modified to fix checksum, like '-i0x3ff'\n"
		"     or '-i 1234'. Fixed file is written to stdout\n"
		"     or filename given by '-o'\n"
		" -o <outputfile>\n"
		"     define where to write the fixed ROM image\n"
		"     (only if -i is given). If not used, file is\n"
		"     written to stdout\n"
		" -l <len>\n"
		"     define the length over which the checksum\n"
		"     is computed.\n");

}

int main(int argc, char *argv[]) {

	char *fname_in = NULL;
	char *fname_out = NULL;

	FILE *fin = NULL;
	FILE *fout = stdout;

	unsigned char *buf = NULL;
	unsigned int size = 4096;	// initial buffer size
	unsigned int p = 0;
	unsigned int sum = 0;

	int c = 0;

	int diff = 0;
	unsigned char lastnonzero = 0;

	char *expected_s = NULL;
	int expected = 0;
	char *injectaddr_s = NULL;
	int injectaddr = 0;
	char *len_s = NULL;
	int len = 0;

	/* PARSE OPTIONS */

	p = 1;
	while (p < argc) {
		if (argv[p][0] != '-') {
			break;
		}

		switch(argv[p][1]) {
		case 'o':
			/* output file name */
			if (argv[p][2] != 0) {
				fname_out = &(argv[p][2]);
			} else
			if (p+1 < argc) {
				fname_out = &(argv[p+1][0]);
				p++;
			} else {
				fprintf(stderr, "Output file not given for '-o'\n");
				return(-1);
			}
			break;
		case 'l':
			/* this is the expected checksum */
			if (argv[p][2] != 0) {
				len_s = &(argv[p][2]);
			} else
			if (p+1 < argc) {
				len_s = &(argv[p+1][0]);
				p++;
			} else {
				fprintf(stderr, "Value missing for '-s'\n");
				return(-1);
			}
			break;
		case 's':
			/* this is the expected checksum */
			if (argv[p][2] != 0) {
				expected_s = &(argv[p][2]);
			} else
			if (p+1 < argc) {
				expected_s = &(argv[p+1][0]);
				p++;
			} else {
				fprintf(stderr, "Value missing for '-s'\n");
				return(-1);
			}
			break;
		case 'i':
			/* inject byte to correct checksum, specify address here */
			/* as relative offset to start */
			if (argv[p][2] != 0) {
				injectaddr_s = &(argv[p][2]);
			} else
			if (p+1 < argc) {
				injectaddr_s = &(argv[p+1][0]);
				p++;
			} else {
				fprintf(stderr, "Value missing for '-i'\n");
				return(-1);
			}
			break;
		case 'h':
		case '?':
			usage();
			return 0;
		default:
			fprintf(stderr, "Unknown option '%c'\n", argv[p][1]);
			return -1;
		}
		p++;
	}

	if (p < argc) {
		fname_in = &(argv[p][0]);
		p++;
	}

	if (p < argc) {
		fprintf(stderr, "Extra parameters '%s ...'\n", argv[p] );
		return -1;
	}

	/* EVALUATE OPTIONS */

	if (expected_s != NULL) {
		sscanf(expected_s, "%i", &expected);
		
		if (expected == 0) {
			fprintf(stderr, "Warning: checksum zero can only be had with an all-zero file!\n");
		}
	}
	if (injectaddr_s != NULL) {
		sscanf(injectaddr_s, "%i", &injectaddr);
	}	
	if (len_s != NULL) {
		sscanf(len_s, "%i", &len);
	}	

	/* OPEN INPUT/OUTPUT FILES */

	if (fname_in == NULL) {
		// we assume stdin
		fin = stdin;
	} else {
		fin = fopen(fname_in, "rb");
		if (fin == NULL) {
			fprintf(stderr, "Could not open file for reading '%s': %s\n", fname_in, strerror(errno));
			return(-1);
		}
	}

	buf = malloc(size);
	if (buf == NULL) {
		fprintf(stderr, "Could not allocate memory\n");
		return(-1);
	}

	p = 0;
	sum = 0;

	/* READ INPUT FILE */
	
	while ( (c = fgetc(fin)) != EOF) {

		if (p >= size) {
			size *= 2;
			buf = realloc(buf, size);
			if (buf == NULL) {
				fprintf(stderr, "Could not re-allocate memory of size %d\n", size);
				return(-1);
			}
		}

		if (c != 0) {
			lastnonzero = c;
		}

		buf[p] = (unsigned char) c;

		if (len == 0 || p < len) {
			sum = sum + c;
			if (sum > 255) {
				// overflow
				sum = sum - 256 + 1;
			}
			//printf("p=%d, len=%d, c=%d, sum=%d\n", p, len, c, sum);
		}

		p++;
	}

	/* CLEAN UP INPUT */

	fclose(fin);

	/* OUTPUT RESULT */

	printf("ROM checksum of %d (out of %d) bytes is %d (hex $%02x)\n", (len == 0)? p : len, p, sum, sum);

	if (expected_s != NULL) {
		if (sum == expected) {
			printf("ROM checksum OK\n");
		} else {
			printf("ROM checksum NOT OK - expected %d (hex $%02x)\n", expected, expected);
		}
	}

	if (injectaddr_s != NULL) {
		/* we have to "fix" the ROM and output it */
	
		if (expected_s == NULL) {
			fprintf(stderr, "To fix the checksum, the expected value is needed\n");
			return -1;
		}
	
		if (injectaddr >= p)  {
			fprintf(stderr,"Inject address %d larger than file size %d\n", injectaddr, p);
			return -1;
		}

		if (expected == 0 && lastnonzero != 0) {
			fprintf(stderr,"Error: Checksum zero is only possible with all-zero files; no output written!\n");
			return -1;
		}

		/* difference between is and should be checksum */

		c = buf[injectaddr];

		// determine the difference between the expected and calculated checksum
		diff = expected - sum;

		printf("Detected diff %d, current value at position %d is %d\n", diff, injectaddr, c);

		if (c + diff < 0) {
			c = c + diff - 1;
		} else if (c + diff > 255) {
			c = c + diff + 1;
		} else {
			c = c + diff;
		}

		c &= 0xff;

		printf("Setting value to %d ($%02x)\n", c, c);

		buf[injectaddr] = c;
		


		/* WRITE OUT FIXED ROM */

		if (fname_out != NULL) {
			fout = fopen(fname_out, "wb");
		} else {
			fout = stdout;
		}
		if (fout == NULL) {
			fprintf(stderr, "Could not open file for writing '%s': %s\n", fname_out, strerror(errno));
			return -1;
		}
		
		if (fwrite(buf, p, 1, fout) != 1) {
			fprintf(stderr, "Short write! Fix code!\n");
			fclose(fout);
			return -1;
		}

		fclose(fout);
	}

	return(0);
}


