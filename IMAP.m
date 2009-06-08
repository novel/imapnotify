#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <unistd.h>
#include <netdb.h>
#include <openssl/ssl.h>

#include "IMAP.h"

#define MAX_BUF 1024

@implementation IMAP

- (id) initWithServer:(char *)_server andUsername:(char *)_username andPassword:(char *)_password {
	server = _server;
	username = _username;
	password = _password;

	return self;
}

- (char*) server {
	return server;
}

- (void) setServer: (char*) _server {
	server = _server;
}

- (char*) username {
	return username;
}

- (void) setUsername: (char*) _username {
	username = _username;
}

- (char*) password {
	return password;
}

- (void) setPassword: (char*) _password {
	password = _password;
}

- (int) tcpConnect:(const char*)_server {
	const char *PORT = "993";
	int err, sd;
	struct sockaddr_in sa;
	struct hostent *hp;

	hp = gethostbyname(_server);
	sd = socket (AF_INET, SOCK_STREAM, 0);

	memset (&sa, '\0', sizeof (sa));
	sa.sin_family = AF_INET;
	sa.sin_port = htons (atoi (PORT));
	//  inet_pton (AF_INET, SERVER, &sa.sin_addr);
	bcopy(hp->h_addr, &(sa.sin_addr.s_addr), hp->h_length);

	err = connect (sd, (struct sockaddr *) & sa, sizeof (sa));
	if (err < 0) {
		fprintf (stderr, "Connect error\n");
		exit (1);
	}

	return sd;
}

- (int) parseStatusResponse:(const char *) response {
	int i, unseen, first_bracket, last_bracket;
	char *new_string;

	for (i = strlen(response) - 1; i > -1; i--) {
		if (response[i] == ')') {
			last_bracket = i;
		} else if (response[i] == '(') {
			first_bracket = i;
			break;
		}
	}

	new_string = (char *)malloc(last_bracket - first_bracket);

	strncpy(new_string, response + first_bracket + 1, last_bracket - first_bracket - 1);

	sscanf(new_string, "UNSEEN %d", &unseen);

	free(new_string);

	return unseen;
}

- (int) messagesCount {
	size_t login_len;
	int sockfd, ret;
	char buffer[MAX_BUF + 1];
	char *login_templ = "in01 login %s %s\r\n";
	char *msg;

	SSL_CTX *ctx;
	SSL *ssl;
	BIO *sbio;

	SSL_library_init();
	SSL_load_error_strings();

	ctx = SSL_CTX_new(SSLv23_method());

	sockfd = [self tcpConnect:[self server]];

	ssl = SSL_new(ctx);
	sbio = BIO_new_socket(sockfd,BIO_NOCLOSE);
	SSL_set_bio(ssl, sbio, sbio);

	if (SSL_connect(ssl) <= 0) {
		printf("fuck");
		exit(0);
	}

	ret = SSL_read(ssl, buffer, MAX_BUF);

	login_len = strlen(login_templ) - 1 - 1 + strlen([self username]) + strlen([self password]) + 1;
	msg = (char *)malloc(login_len);

	snprintf(msg, login_len, login_templ, [self username], [self password]);

	SSL_write(ssl, msg, strlen(msg));

	ret = SSL_read(ssl, buffer, MAX_BUF);

	free(msg);

	memset(buffer, '\0', MAX_BUF);

	msg = strdup("in02 status INBOX (unseen)\r\n");
	ret = SSL_write(ssl, msg, strlen(msg));
	ret = SSL_read(ssl, buffer, MAX_BUF);

	SSL_CTX_free(ctx);
	close(sockfd);

	return [self parseStatusResponse:buffer];
}


@end
