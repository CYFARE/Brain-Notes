# IRC - Internet Relay Chat

* IRC is an open-source protocol for real-time text messaging and group communication developed by Jarkko Oikarinen in 1988.
* IRC resembles the modern day Discord (Which was actually inspired from IRC).
* IRC became one of the most used messaging system during the late 1990s and early 2000s. However with the advent of new proprietary and centralized messaging platforms IRC has lost most of it's userbase. 
* IRC is still prevalent among open-source and tech enthusiasts and certain other communities.

## Advantages of IRC over other platforms and technologies:

* It's **open-source**. Anybody can self host an IRC server for their community.
* Consumes far **less bandwidth** as compared to other platforms.
* **Privacy**. Generally most public IRC servers do not require registration and allows traffic from Tor.
* Very **low cost** self-hosted communication solution for companies, communities without compromising their privacy by relying on 3rd parties. 
* **Flexibility**. With various available clients, IRC can be accessed from every platform and in every form, even from the command line.

## Commonly used Terms:

* **Server**- On IRC, a server refers to a computer system that runs an IRC server software and provides a platform for users to connect and communicate with each other.
Example: _tantalum.libera.chat:6697_
*  **Network**- On IRC, network refers to a collection of IRC servers that are connected to each other, allowing users to communicate with each other across different servers.
Example: _Libera.Chat, DALnet_.
* **Client**- Clients are the softwares that help the users to connect and communicate with the IRC server. Examples- _irssi (cli), Hexchat(gui)_.
* **Channels**- Channels are rooms within the server dedicated to specific topics starting with a "#" symbol in their names. Example- _#gnu, #linux_.
* **Nick**- Nick is the identifier of an user in the IRC network.
* **DCC**- DCC stands for Direct Client-to-Client. It is an IRC-related sub-protocol that enables peers to interconnect using an IRC server for handshaking in order to exchange files or perform non-relayed chats. Once established, a typical DCC session runs independently from the IRC server.
* **Bouncer (BNC)**- Bouncers are softwares running 24×7 on some server, that act as a proxy between your client and the IRC server. It's purpose is to always keep you connected to the IRC server even when you quit the IRC client or turn off your computer, so that you don't loose any messages while you disconnected. Example- _ZNC_
* **Pastebin**- On IRC you may often need to share snippets of code, error messages, logs etc with other people. Pasting them directly on the chat isn't a good practice. Here comes pastebins where you can upload some text and share it via link. Examples- _bpa.st, privatebin.io_
* **Operators (ops)**- Operators or ops in short, are people within a channel who have special privileges such as kicking, banning, inviting users and changing the topic of the channel.
* **ASL**- ASL stands for "Age, Sex, Location". It's a commonly used abbreviation in the IRC community. You shall keep in mind that sharing such informationn may have negative consequences just like any other platforms.

## Setting Up:

### Installing an IRC client:

#### My suggested clients:

* irssi (cli)
* HexChat (gui)

You may choose a different client of your choice. But for this guide I will be uisng the two I mentioned.

#### Installing irssi:

* For Debian/Ubuntu based systems: ```$ sudo apt install irssi -y```
* For Fedora/RedHat based systems: ```$ sudo dnf install irssi -y```
* For Arch based systems:          ```$ sudo pacman -S irssi --noconfirm```

#### Installing Hexchat:

* For Debian/Ubuntu based systems: ```$ sudo apt install hexchat -y```
* For Fedora/RedHat based systems: ```$ sudo dnf install hexchat -y```
* For Arch based systems:          ```$ sudo pacman -S hexchat --noconfirm```
* Flatpak: ```sudo flatpak install io.github.Hexchat```

### Connecting to a Network:

(For HexChat see the next part)

A quick way to connect to an IRC network without setting up or configuring anything would be to use the cli client, **irssi**.
Here's how you can do that:

```$ irssi -n <nick> -c irc.libera.chat```

Replace **&lt;nick&gt;** with a nickname of your choice. 

In this case we are connecting to the **Libera.Chat** IRC network which is mostly dedicated to "free and open source software" and technology.

Wait for few moments till the connection is established. Type the following command into the shell to join the "#gnu" channel (in this case):

```/join #gnu```

You can do the same to join various other channels like ```#linux```,```#programming```,```#math```.

Press ```Ctrl + N``` on your keyboard to switch between joined channels.

There are various **other commands** for various different purposes which will be mentioned later in this guide.

For now if you want to quit irssi (the client), type the following command into the IRC shell:

```/exit```

### Configuring and Connecting via HexChat:

* Open HexChat
* If you have installed it for the first time, it would open up a Network List on startup. On the bottom of the network list **check** the **"Skip network list on startup"** option.
* Click the **+ Add** option in the Networks section of the Network List.
* You will be prompted to enter a network **name**. In this case I will be naming it **Libera Chat**. 
* Click on the **Edit** option to configure the network.
* In the **servers** tab you shall find **newserver/6697**. Double click it to edit it. Replace it with **irc.libera.chat** and press enter.
* Click on the **Autojoin Channels** tab, click **+ Add**, type the **channel names** (that you want to autoconnect to on starting HexChat) and press enter. Example channels: _#gnu, #fsf, #linux, #programming, #python_.
* Check the **Connect to this network automatically** option to connect to the Libera network automatically everytime you start HexChat.
* Check **Use SSL for all servers on this network** option.
* Uncheck **Use global user information**.
* Type a **Nick name**(display name), **Second choice** (of the nick name incase the first one is already used by someone else), **Real name** (displayed only in whois info) and the **User name** (not displayed to others).
* Leave everything else default.
* Click on **× Close**.
* Click on **Libera Chat** from the **Networks** list (if not selected already).
* Click **Connect**.
* Autojoin channels entered by you gets auto-joined.
* On the left side there is the **channel list** where you have to select the channels you want communiacte in. On the right you have the **list of people** who are connected to the paricular channel at the moment.
* Commands are mentioned in the next section of the guide.

## Commands Cheatsheet:

* Search a channel: ```/msg alis list *term*```. Replace term with your search term. Example: "python"
* Join a channel: ```/join #<channel name>```. Example: /join #python.
* Leave a channel: ```/part #<channel name>```. Example: /part #windows.
* Mention an user: Start typing the first few letters of the user's nick and press the **TAB** key.
* Know about a certain user: ```/whois <nick>```. Example: /whois fury999io
* Know about an user who has disconnected: ```/whowas <nick>```.
* Ping an user: ``/ping <nick>``.
* Know the IRC client/version of an user: ```/version <nick>```. Warning: They would be alerted about your request.
* Change your nick: ```/nick <new nick>```.
* Register your nick on libera: ```/msg NickServ register <password> <your email address>```.
* Identify (login) your nick on reconnect: ```/msg NickServ identify <password>```
* Hide your ip address / setup user cloak (On Libera) (Requires registering nick first): First ```/join #libera-cloak ```then ```!cloakme```.
* Open up **Direct Message** for someone: ```/query <nick>```.
* Clear the messages in the current channel: ```/clear```.
* Block/Ignore someone's messages: ```/ignore <nick>```. ```/unignore <nick>``` to revert.
* Set yourself away: ```/away <away message>```. To revert again use ```/away```.


### Common Commands

| Command               | Description                                   |
|-----------------------|-----------------------------------------------|
| /join #channel        | Join a channel                               |
| /part #channel        | Leave a channel                              |
| /msg nickname message| Send a private message to a user              |
| /nick new_nickname    | Change your nickname                         |
| /me action            | Send an action or emote message              |
| /away [message]       | Set an away message or remove away status    |
| /whois nickname       | Get information about a user                 |
| /list                | List all available channels                  |
| /invite nickname #channel | Invite a user to a channel               |
| /quit [message]       | Quit the IRC server with an optional message |
| /topic #channel topic | Set or view the topic of a channel           |
| /ignore nickname      | Ignore messages from a user                  |
| /unignore nickname    | Stop ignoring messages from a user           |
| /kick #channel user [reason] | Kick a user from a channel            |
| /mode #channel +m     | Set the channel to moderated mode            |
| /mode #channel +i     | Set the channel to invite-only mode          |
| /mode #channel +s     | Set the channel to secret mode               |
| /mode #channel +t     | Set the channel to topic-only mode           |
| /mode #channel +n     | Set the channel to no external messages mode |
| /mode #channel +p     | Set the channel to private mode              |
| /mode #channel +k key | Set a key to join the channel                |
| /mode #channel +l limit | Set a user limit for the channel           |
| /mode #channel -m     | Remove moderated mode from the channel       |
| /mode #channel -i     | Remove invite-only mode from the channel     |
| /mode #channel -s     | Remove secret mode from the channel          |
| /mode #channel -t     | Remove topic-only mode from the channel      |
| /mode #channel -n     | Remove no external messages mode from channel|
| /mode #channel -p     | Remove private mode from the channel         |
| /mode #channel -k     | Remove the key from the channel              |
| /mode #channel -l     | Remove the user limit from the channel       |
| /op #channel user     | Give operator status to a user in a channel  |
| /deop #channel user   | Remove operator status from a user           |
| /voice #channel user  | Give voice status to a user in a channel     |
| /devoice #channel user| Remove voice status from a user              |
| /ban #channel user    | Ban a user from a channel                    |
| /unban #channel user  | Unban a user from a channel                  |
| /mute #channel user   | Mute a user in a channel                     |
| /unmute #channel user | Remove mute from a user in a channel          |
| /query nickname       | Open a private message window with a user    |
| /names #channel       | List users in a channel                      |
| /away                | Set your status as away                      |
| /clear                | Clear the chat window                        |
| /help or /?           | Get help on available commands               |
| /connect server port  | Connect to a specific server and port        |
| /disconnect           | Disconnect from the server                   |
| /quit                | Quit the IRC client                          |
| /raw raw_command     | Send a raw command to the server             |
| /who channel          | List users in a channel                      |
| /query nickname       | Start a private chat with a user             |
| /notice nickname message| Send a notice message to a user          |
| /ping nickname        | Send a PING message to check user's presence |
| /pong nickname        | Send a PONG response to a PING message      |


# Contributor / Thanks To

- [fury999io](https://github.com/fury999io)
