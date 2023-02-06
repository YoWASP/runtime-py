#include <stdio.h>

int main(int argc, char **argv)
{
	for (int i = 1; i < argc; i++)
	{
		FILE *f;
		
		printf("File '%s':\n", argv[i]);
		
		f = fopen(argv[i], "r");
		if (!f)
		{		
			fflush(stdout);
			perror("fopen");
		}
		else
		{
			while (!feof(f))
			{
				char buf[256];
				size_t count = fread(buf, 1, sizeof(buf), f);
				fwrite(buf, 1, count, stdout);
			}
			fclose(f);
		}
		
		printf("\n");
	}
}
