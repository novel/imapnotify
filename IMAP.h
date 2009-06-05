#include <objc/Object.h>

@interface IMAP : Object
{
	char *server;
	char *username;
	char *password;
}

- (id) initWithServer:(char *)server andUsername:(char *)username andPassword:(char *)password;

- (char *) server;
- (void) setServer:(char *) _server;

- (char *) username;
- (void) setUsername:(char *) _username;

- (char *) password;
- (void) setPassword:(char *) _password;

- (int) parseStatusResponse:(const char *) response;

- (int) tcpConnect:(const char*)_server;

- (int) messagesCount;
@end
