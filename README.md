Note: The fork at https://github.com/itsjohncs/irssi-server-time is the
correct place to open up issues. The original repo seems to be unmaintained.

Summary
-------

irssi does not yet support the IRCv3 server-time extension (specified at
https://ircv3.net/specs/extensions/server-time-3.2.html), so this plugin fills
that hole. The plugin does not work for all kinds of messages, but query
messages and channel messages you receive with a servertime attached will show
the servertime properly (rather than the time you received the message).

How it works
------------

Irssi does not provide a nice way to change the timestamp of a message within
a script. So this script changes the "timestamp format" setting (normally set
to a value like "%h:%m") to the literal time the server sent us (ex: "10:23")
while the message is being processed, and then the script changes the
timestamp format back to whatever it was before.

Instructions
------------

You can most easily install this script from
[scripts.irssi.org](https://scripts.irssi.org/).

If you'd like to install from this repo. Add `server_time.pl` to your scripts
directory (likely at `~/.irssi/scripts/`). This script is intended to be loaded
before connecting to a server, so I'd recommend adding a symlink in your
autorun directory.

You can run `make` in the project directory to create a
`server_time.withcomments.pl` file that has this README and the License added
to the top as comments (this is the file that's published to
`scripts.irssi.org`).

Changelog
---------

0.1
  - Initial release

1.0
  - Forked by John Sullivan (without explicit cooperation from original
    author).
  - Removed dependency on DateTime::Format::ISO8601 because it is not shipped
    in Brew's Perl by default and it's overkill anyways.
  - Prepared it for inclusion in https://scripts.irssi.org.
