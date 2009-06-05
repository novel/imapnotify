CC?=gcc

all:
	$(CC) -o imapnotify *.m -g  `pkg-config --cflags --libs libnotify` -lssl -lobjc

clean:
	rm imapnotify
