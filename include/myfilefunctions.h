#ifndef MYFILEFUNCTIONS_H
#define MYFILEFUNCTIONS_H

#include <stdio.h>

// Count lines, words, and characters. Return 0 on success, -1 on failure.
int wordCount(FILE* file, int* lines, int* words, int* chars);

// Search lines containing search_str and fill matches array. Return match count, -1 on failure.
int mygrep(FILE* fp, const char* search_str, char*** matches);

#endif