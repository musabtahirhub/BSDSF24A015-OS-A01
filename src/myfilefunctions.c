#define _GNU_SOURCE
#include "../include/myfilefunctions.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int wordCount(FILE* file, int* lines, int* words, int* chars) {
    if (!file || !lines || !words || !chars) return -1;

    *lines = 0;
    *words = 0;
    *chars = 0;

    int ch;
    int in_word = 0;

    while ((ch = fgetc(file)) != EOF) {
        (*chars)++;

        if (ch == '\n') {
            (*lines)++;
        }

        if (isspace(ch)) {
            in_word = 0;
        } else if (!in_word) {
            in_word = 1;
            (*words)++;
        }
    }

    return 0;
}

int mygrep(FILE* fp, const char* search_str, char*** matches) {
    if (!fp || !search_str || !matches) return -1;

    char* line = NULL;
    size_t len = 0;
    ssize_t read;
    int count = 0;
    int capacity = 10;

    *matches = malloc(sizeof(char*) * capacity);
    if (!(*matches)) return -1;

    while ((read = getline(&line, &len, fp)) != -1) {
        if (strstr(line, search_str) != NULL) {
            if (count >= capacity) {
                capacity *= 2;
                char** temp = realloc(*matches, sizeof(char*) * capacity);
                if (!temp) {
                    free(line);
                    return -1;
                }
                *matches = temp;
            }
            (*matches)[count] = strdup(line);
            count++;
        }
    }

    free(line);
    return count;
}