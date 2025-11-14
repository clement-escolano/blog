+++
title = "Signal Web"
description = "My journey to access Signal (the messaging platform) through the web with Matrix."
date = 2025-02-01
updated = 2025-11-15
aliases = ["/blog/signal-on-web/"]

[taxonomies]
tags=["self-hosted", "privacy"]
+++

## Building a web version of Signal

[Signal](https://signal.org/) is a privacy-conscious[^1] messaging platform that has gained popularity in the past years.
It is available on mobile, desktop and... that's all.
There is no official web client of Signal, although this a [popular request from the community](https://community.signalusers.org/t/web-app-for-signal/1272), and this is [on purpose](https://old.reddit.com/r/privacy/comments/uwpoyb/is_anyone_here_using_signal/i9tj457/).

[^1]: There are some detractors, mainly about the fact that it requires a phone number to register, but as a mainstream messaging platform, I think it fulfills its goal pretty well.

Well, I understand the reasons behind their choice but a web version has a lot of benefits:
* lightweight (the desktop application weighs 250MB)
* available even on restricted computers
* no need to install an application

For all these reasons, I stayed home on a sunny Sunday afternoon to set up my version of Signal Web.

## The objectives

It should be **simple**. Although porting [`libsignal`](https://github.com/signalapp/libsignal), the underlying library powering all Signal clients, to the web with WebAssembly seems possible[^2], this was not my intention and I wanted to rely on existing tools to avoid transforming this busy Sunday afternoon into a whole month project.

[^2]: A [port of libsignal](https://github.com/Inria-Prosecco/libsignal-protocol-wasm-fstar) was achieved by some people from INRIA, but it has not been updated for 6 years.
More recently, an [issue on GitHub](https://github.com/signalapp/libsignal/issues/350) is optimistic about the current feasibility, but it would be considered as unofficial and no-one stepped up for this mission yet.

I also wanted to keep the solution as **secure** as possible as the "end-to-end encryption" feature of Signal is one of its core features.

Finally, the solution should be **user-friendly** (simple interface, easy to navigate) and have as much feature-parity as possible with the other Signal clients (messages, media, reactions, calls).

## Enter the matrix

[Matrix](https://matrix.org/) is a very powerful messaging protocol which allows federation, self-hosting and, most importantly, bridging with other applications (which means that you can receive and send messages that lives on another platform such as WhatsApp, Telegram or... Signal). 

This seems like the perfect solution for me.
Let's install Matrix and we are done. Easy no?
Well... You cannot *install* Matrix.
Matrix is just the protocol.
What you need is a Matrix server[^3], that will host the messages, a Matrix-Signal bridge that will connect the server to Signal, and a Matrix client that will display them to the user.
Thankfully, there is only one Signal bridge, but there a few possibilities for the Matrix server and a lot of them for the Matrix client.

[^3]: Public matrix servers are also available but the only existing Signal bridge (yes there can be [several](https://matrix.org/ecosystem/bridges/) depending on the service) requires being able to edit the home server configuration which means self-hosting. 

So here goes choosing the best Matrix server and client for our purpose.
For the client, I went with the most popular one, [Element](https://element.io/).
It supports most of the features and seems like a good fit.

For the server, I went with [Dendrite](https://github.com/element-hq/dendrite) first as it was advertised as the "second-generation" server by the creator of Matrix with a lightweight footprint which was important to me as it would be installed on a RaspberryPi in my home with limited resources.
The Signal Bridge does not support this home server however[^4], so I went with [Tuwunel](https://tuwunel.chat/)[^5] which seems to have the same purpose as dendrite.

**Note**: If I add to start again, I would have gone with [Synapse](https://element-hq.github.io/synapse/latest/), the oldest and most complete server. Tuwunel is still missing some features[^6] and even though Synapse was fairly heavy to run at the beginning, it seems fairly light now and should run on my Raspberry Pi.

[^4]: Well, apparently it can as described in this [issue](https://github.com/mautrix/signal/issues/457), but I only found out when writing this article.

[^5]: At the time of publication, I was using [Conduwuit](https://github.com/x86pup/conduwuit/), recommended by the Signal
bridge, but it was discontinued. Tuwunel is the continuation of Conduwuit work. 

[^6]: When a message is read on the Matrix client, the "read status" is not transmitted back to Signal so the message is still unread on the phone. [GitHub issue](https://github.com/girlbossceo/conduwuit/issues/584).

## Architecture

The architecture with the Signal application is simple, the application connects with end-to-end encryption to the Signal servers.

<figure>
<figcaption>Network architecture with the Signal application</figcaption>

```
  ═════════════  End-to-end encryption

╔═════════════╗               ╔═════════════╗
║   Signal    ╠═══════════════╣   Signal    ║
║   servers   ║               ║ application ║
╚═════════════╝               ╚═════════════╝
```
</figure>

In this case, the bridge acts as a Signal client so the messages are end-to-end encrypted between Signal servers and the bridge.
Then, the Matrix client talks to the Signal bridge through the Matrix server.
The messages are also end-to-end encrypted and the Matrix server does not see the content.

<figure>
<figcaption>Network architecture with Matrix</figcaption>

```
  ═════════════  End-to-end encryption     
  
                 ┌─────────────────────────────────────────┐
╔═════════════╗  │ ╔═══════════════╗    ┏━━━━━━━━━━━━━━━┓  │  ╔════════════╗
║   Signal    ╠══╪═╣ Matrix signal ╠═══════════════════════╪══╣   Matrix   ║
║   servers   ║  │ ║    bridge     ║    ┃ Matrix server ┃  │  ║   client   ║
╚═════════════╝  │ ╚═══════════════╝    ┗━━━━━━━━━━━━━━━┛  │  ╚════════════╝
                 │               Home server               │
                 └─────────────────────────────────────────┘
```
</figure>

## Wrap up

In the end, I am pretty satisfied with the result.
Element has a polished interface and I can read and send Signal messages seamlessly.
The security model is a bit weak as all messages are in clear text at some point on my server but this is acceptable for my threat model.

The big limitation compared to the initial objectives is calls are not supported.
This is not the primary usage of Signal I had in mind and other web clients (such as WhatsApp Web) do not support them either so I guess this was to be expected.

Happy messaging!
