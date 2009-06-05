#include <objc/Object.h>

@interface Config : Object
{
	char *server;
	char *username;
	char *password;
}

- (id) init;

- (void) parseConfigLine:(const char *)config_line;

- (char *) server;

- (char *) username;

- (char *) password;

@end
