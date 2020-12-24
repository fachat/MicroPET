
#include <stdio.h>

void main(void) {

	char buf[1024];

	size_t n;

	while ( (n = fread(buf, 1, 1024, stdin)) == sizeof(buf)) {

		fwrite(buf, 1, 1024, stdout);

		for (int i = 0; i < sizeof(buf); i++) {
			fputc(buf[i]^255, stdout);
		}
	}

	fflush(stdout);
}

