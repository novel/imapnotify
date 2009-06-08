CC?=gcc
CFLAGS?=-Wall -g -D_GNU_SOURCE

all:
	$(CC) $(CFLAGS) -o imapnotify *.m -g  `pkg-config --cflags --libs libnotify` -lssl -lobjc

clean:
	rm imapnotify
