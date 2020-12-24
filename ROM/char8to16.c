
#include <stdio.h>

void main(void) {

	char buf[8];
	char nul[8] = { 0,0,0,0,0,0,0,0 };

	size_t n;

	while ( (n = fread(buf, 1, 8, stdin)) == sizeof(buf)) {

		fwrite(buf, 1, 8, stdout);
		fwrite(nul, 1, 8, stdout);
	}

	fflush(stdout);
}

