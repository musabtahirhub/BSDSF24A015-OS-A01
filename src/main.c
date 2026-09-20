#include "../include/myfilefunctions.h"
#include "../include/mystrfunctions.h"
#include <stdio.h>
#include <stdlib.h>


int main() {
  printf("======================================\n");
  printf("    Testing String Functions\n");
  printf("======================================\n");

  char str1[100] = "Operating";
  char str2[] = " Systems";
  char buffer[100];

  printf("Original str1: %s\n", str1);
  printf("mystrlen(str1): %d\n", mystrlen(str1));

  mystrcpy(buffer, str1);
  printf("mystrcpy(buffer, str1): %s\n", buffer);

  mystrcat(buffer, str2);
  printf("mystrcat(buffer, str2): %s\n", buffer);

  char dest[20];
  mystrncpy(dest, "LinuxKernel", 5);
  dest[5] = '\0';
  printf("mystrncpy(dest, \"LinuxKernel\", 5): %s\n", dest);

  printf("\n======================================\n");
  printf("     Testing File Functions\n");
  printf("======================================\n");

  FILE *test_file = fopen("sample_test.txt", "w+");
  if (!test_file) {
    perror("Failed to create temporary file");
    return 1;
  }

  fprintf(test_file,
          "Hello Unix\nThis is an OS assignment\nUnix is powerful\nGoodbye\n");
  rewind(test_file);

  int lines = 0, words = 0, chars = 0;
  if (wordCount(test_file, &lines, &words, &chars) == 0) {
    printf("wordCount -> Lines: %d, Words: %d, Chars: %d\n", lines, words,
           chars);
  }

  rewind(test_file);
  char **matches = NULL;
  int match_count = mygrep(test_file, "Unix", &matches);
  printf("\nmygrep searching for 'Unix' found %d line(s):\n", match_count);
  for (int i = 0; i < match_count; i++) {
    printf("  [%d] %s", i + 1, matches[i]);
    free(matches[i]);
  }
  free(matches);
  fclose(test_file);
  remove("sample_test.txt");

  return 0;
}