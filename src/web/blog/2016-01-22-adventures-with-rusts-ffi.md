---
title: Adventures with Rust's FFI.
author: Bheesham Persaud
date: 2016-01-22T23:49:00-05:00
---

This past week I've been working on
[generating Rust bindings to the GnuTLS library][gnutls]. At first, I tried
doing things manually, but ultimately gave up after a few hours. I didn't want
to do any work, I just wanted quick bindings dammit.

I then stumbled across [rust-bindgen], a project that automagically generates
Rust FFI code given an input file. Too good to be true? Almost.

The first thing I discovered after generating FFI code was: there's a bug with
representing univariant enums in Rust. This is a well documented bug and the
issue on GitHub can be found [here].

Example:

```rust
    enum Foo {
        BAR
    }
```

This can be remedied by adding a dummy enum item.

The second thing is type aliasing between enums is not as straight forward
as I thought it was. For example, the following would not work:

```rust
    enum Foo {
       HELLO,
       WORLD
    }

    type Bar = Foo;
    assert_eq!(Foo::HELLO, Bar::WORLD)

```

The fix to this problem involved a whole lot of massaging generated output to
get rid of the aliases. Fun.

Regardless, rust-bindgen saved me hours of work and I learned a few things along
the way.

[gnutls]: https://github.com/bheesham/gnutls-rs "GnuTLS bindings for Rust"
[rust-bindgen]: https://github.com/crabtw/rust-bindgen "crabtw/rust-bindgen"
[here]: https://github.com/rust-lang/rust/issues/10292 "Univariant enums cannot have repr set #10292 - rust-lang/rust"
