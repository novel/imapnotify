#include <stdio.h>
#include <unistd.h>
#include <libnotify/notify.h>

#include "IMAP.h"
#include "Config.h"

int main(int argc, char** argv) {
	unsigned int prev_count = 0;
	Config *config = [[Config alloc] init];

	NotifyNotification *notify;

	notify_init("imapnotify");

	IMAP* imap = [[IMAP alloc] initWithServer:[config server] 
		andUsername:[config username] andPassword:[config password]];
	
	while (1) {
		int messages_count = [imap messagesCount];

		if ((prev_count != messages_count) && (messages_count > 0)) {
			char *body;

			asprintf(&body, "%d new messages", messages_count);

			notify = notify_notification_new([imap username], 
					body, NULL, NULL);
			notify_notification_show(notify, NULL);

			free(body);
		}

		prev_count = messages_count;

		sleep(30);
	}

	return 0;
}
