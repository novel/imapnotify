#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "Config.h"

#define MAX_LINE_LEN	256

@implementation Config

- (id) init {
	const char *home = getenv("HOME");
	const char *config_file_templ = "%s/.imapnotifyrc";
	size_t config_file_path_len = strlen(config_file_templ) - 2 + strlen(home) + 1;
       	char *config_file_path = (char *)malloc(config_file_path_len);
	FILE *fp;
	char content[MAX_LINE_LEN];

	snprintf(config_file_path, config_file_path_len, config_file_templ, home);

	fp = fopen(config_file_path, "r");

	if (fp == NULL) {
		fprintf(stderr, "Cannot open file: %s\n", config_file_path);
		exit(1);
	}


	if (fgets(content, sizeof(content), fp) == NULL) {
		perror("fgets");
		exit(1);
	}

	[self parseConfigLine: content];	

	fclose(fp);
	free(config_file_path);

	return self;
}

- (void) parseConfigLine:(const char *)config_line {
	char *line, *token, *tofree;
	char **config_settings = (char **)malloc(3 * sizeof(char *));
	int i;

	tofree = line = strdup(config_line);
	line[strlen(line) - 1] = '\0';

	i = 0;
	while (((token = strsep(&line, " ")) != NULL) && i < 3)
		config_settings[i++] = strdup(token);

	free(tofree);

	self->server = config_settings[0];
	self->username = config_settings[1];
	self->password = config_settings[2];

	free(config_settings);
}

- (char *) server {
	return server;
}

- (char *) username {
	return username;
}

- (char *) password {
	return password;
}

@end
