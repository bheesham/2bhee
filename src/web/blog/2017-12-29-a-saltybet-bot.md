% That time I wrote a Salty Bet bot.
% Bheesham Persaud
% 2017-12-29T21:54:00-05:00

Over the holiday break I finished off [a
bot](https://gitlab.com/bheesham/waifu) a friend and I worked on and managed to
make some major improvements. Over all this was a pretty fun exercise in
reverse engineering a web application.

Reverse engineering the web app was fairly straight forward: comb through the
network requests the browser makes and when in doubt look at the source code.
The endpoints I ended up caring about were:

  * HTTP GET `/status.json`: match state;
  * HTTPS POST `/authenticate?signin=1`: used to log in;
  * HTTP POST `/ajax_place_bet.php`: place a bet; and
  * Websocket `www-cdn-twitch.saltybet.com:1337`: receive messages when the match state
    changes.

There are some peculiarities in some of the responses though. The first of many
peculiarities is, all responses are `200 OK`, this includes failed log in
attempts and failed bet submissions.

"Luckily" for us, Salty Bet will redirect us to a URL Java's URL Parser will
throw a `java.net.URISyntaxException` when we fail to log in. The URL you get
redirected to is:

```
/authenticate?signin=1&error=Invalid Email or Password
```

The second strange API is the one to place bets. To place a bet you submit a
POST request to `ajax_place_bet.php` with form data that looks like:

```
selectedplayer=player<player>&wager=<wager>
```

Where `player` is the 1 or 2 for teams Red and Blue, respectively; and
`wager` is the amount of monies you want to bet. The response is `200 OK`,
regardless of if the bet was placed or not. The last digit in the response will
be a `1` if the bet was successfully placed, otherwise it will be blank.
Except for when the game is in tournament mode.

When the game is in tournament mode the amount of money you have is prepended
to the response. Weird, right?  Luckily for us, getting the current balance is
pretty easy: load the index page then parse a number from a specific tag.
Except, that the HTML returned isn't valid.

The doctype specifier has a quote in it, which makes Java's XML parser freak
out. Fortunately, the tag which contains our balance doesn't change, so we can
use a RegEx matcher and ignore trying to parse the entire page completely.
I think that about does it for the HTTP GET/POST requests.

We can get quite a bit of info by only using HTTP GET and POST requests. In
fact, if we wanted to, we could poll `status.json` every few seconds for the
current match state and call it a day. I avoided doing this because I thought
it might look suspicious that someone was polling at a fixed interval,
especially since inspecting the network requests revealed our browser fires off
requests only when the match state updates.

Our client gets notified of match changes over a websocket. Messages come in
multiples, so the function which takes care of updating our model has to check
that we only transition if our new state does not equal our old state.

I think that about does it for peculiarities in the API encountered when
building this bot. I have yet to find out what a tie looks like, it doesn't
seem to ever come up.
