Title: SMTP
Date: 2016-02-29T15:08:00-05:00
Category: notes
Summary: Notes on SMTP.

Sources: [Main RFC][rfc5321], [Message Submission][rfc6409],
[Authentication][rfc4954], and [GSSAPI][rfc2743].

[rfc5321]: https://tools.ietf.org/html/rfc5321
[rfc6409]: https://tools.ietf.org/html/rfc6409
[rfc4954]: https://tools.ietf.org/html/rfc4954
[rfc2743]: https://tools.ietf.org/html/rfc2743

  * Servers must support the original commands in [rfc821].
  * Servers be able to deliver mail to a final destination
    (must act as a relay or gateway if needed).
  * Connections may be reused to submit more than one email.
  * Mailbox local-part is case sensitive.
  * Accept case-insensitive commands, send uppercase commands.
  * End lines with `<CRLF>`.

[rfc821]: https://tools.ietf.org/html/rfc821

## Reply Codes

  * 220: Service ready.
  * 250: Okay.
  * 354: Start input.
  * 500: Syntax error: unrecognized command.
  * 501: Syntax error: malformed parameters or arguments.
  * 503: Bad sequence of commands -- DATA before MAIL, EHLO before server sends
    220.
  * 550: Mailbox unavailable -- not found, no access, policy error.
  * 553: Mailbox name not allowed -- syntax error, policy error.
  * 554: Transaction failed -- a vague message.

## States

### Session Initiation (on init session)

If the server replies with code 554, all subsequent commands must be responded
to with reply code 503. The client must send the QUIT command to end the
session.

*Max timeout:* 5 mins.

*Possible reply codes:* 220, 554.

### Client Initiation (on init client)

The client sends a HELO or, if the client supports extensions, a EHLO message.
Ideally, the client sends a list of extensions it supports in the EHLO message.

The HELO message must contain the FQDN of the client.

*Receive:*

```
    ehlo = "EHLO" SP ( Domain / address-literal ) CRLF
    helo = "HELO" SP Domain CRLF
```

*Possible reply codes:* 250, 500, 501, 502, 503 (server didn't send 220), 550.

*Send:*

```
    ehlo-ok-rsp = ( "250" SP Domain [ SP ehlo-greet ] CRLF ) /
                  ( "250-" Domain [ SP ehlo-greet ] CRLF
                    *( "250-" ehlo-line CRLF )
                       "250" SP ehlo-line CRLF )

    ehlo-greet = 1*(%d0-9 / %d11-12 / %d14-127)
                 ; string of any characters other than CR or LF

    ehlo-line = ehlo-keyword *( SP ehlo-param )

    ehlo-keyword = (ALPHA / DIGIT) *(ALPHA / DIGIT / "-")
                   ; additional syntax of ehlo-params depends on
                   ; ehlo-keyword

    ehlo-param = 1*(%d33-126)
                 ; any CHAR excluding <SP> and all
                 ; control characters (US-ASCII 0-31 and 127
                 ; inclusive)
```

### Mail Transactions (on mail)

#### MAIL (on mail)

Can only be sent if there are no other mail transactions in progress from the
current session, that is, only one MAIL at a time per session.

*Receive:*

```MAIL FROM:<reverse-path> [SP <mail-parameters> ] <CRLF>```

*Max timeout:* 5 mins.

*Possible reply codes:* 250, 501, 503, 550, 553.

#### RCPT (on rcpt)

Spaces are not allowed on either side of the colon.

*Receive:* `RCPT TO:<forward-path> [ SP <rcpt-parameters> ] <CRLF>`

*Max timeout:* 5 mins.

*Possible reply codes:* 250, 550 (no such user), 503.

#### DATA (on data)

The substance of the email.

*Max timeout:* Initiation: 2 mins; Block: 3 mins; Termination: 10 mins.

*Possible reply codes:* 354 (on successful initiation), 250 (on successful
transaction), 554 (no valid recipients).
