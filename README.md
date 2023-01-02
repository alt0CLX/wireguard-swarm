# Wireguard-swarm
Helper tool for generating large amounts of server and/or client configuration files

## Why
I needed to create a vast amount of servers hostings many peers and usefull data were scattered in a bunch of xls files. So after gathering everything in the same datasheet i thought about something that would help me not wasting hours in a cute and paste death march.

Servers were Debian based and 95% of the clients where running Windows 10.

## What it does
It helps when you have many server and clients to put online.

If you have one server with a few peers to create, it's faster to use your text editor. 

## What it does not
It doesn't check for configuration errors.

It doesn't do all the work. When you will import peers (as an example) into one server configuration file you will have to edit the list.csv to meet your needs.

## Requirements
Wireguard tools to generate the keys.

## CSV
I was unable to handle the ; in Pre/Post/Up-Down scripts so i changed the IFS to µ and no " were used to delimit strings.

## How to use
Auto completion works when file name are asked. By default the script will use the examples files or generate 1 key.

### Session settings

Select an existing batch, create a new one with a custom name or with the defaults settings. A folder will be created to store the session output.

### Generating keys and psk

Piece of cake, no tricks. You will be asked how many keys.

### Create servers or clients configurations

Use clients-example.csv and servers-example.csv to gather your data. You can change the names in the header but not the columns order. Remember to set field delimiter to µ and do not use string delimiter.

Field list and value expected :
+ address : Wireguard address.
+ allowedip : 0.0.0.0/0 or any values that fit the needs.
+ conf_name : name of the configuration.
+ clprivkey : client private key.
+ clpubip : client public ip if needed.
+ clpubkey : client public key.
+ dns : leave blank or or any values that fit the needs.
+ keepalive : leave blank or give a value.
+ listen : Wireguard listening port.
+ mtu : leave blank or or any valid value.
+ port : endpoint port
+ postdown : leave blank or command(s) string.
+ postup : leave blank or command(s) string.
+ predown : leave blank or command(s) string.
+ preup : leave blank or command(s) string.
+ psk : leave blank or put the pre shared key here.
+ saveconf : empty or any value for the script to set it on True.
+ srvprivkey : server private key.
+ srvpubip : server public ip.
+ srvpubkey : server public key.
+ table : leave blank or give the table name.

Client configuration will produce files that can be loaded in the Windows Wireguard client.

Peer files generated are ment to be loaded in the server configuration file. A list is generated and can be tailored to import required peers into the right server.

Server configuration files wiil be produced without peers. Peer must be imported using list.

A full generation sequence is roughly :
+ gather data and populate csv.
+ generate keys if needed and add them to the csv.
+ generate servers configuration files.
+ generate clients configuration files and peer files.
+ split the list.csv into sub lists.
+ import peers into servers.

## Support
Well... maybe not. I can't say when i will have time to improve this script and my skill is taher low, so answering questions could take time.

## Contibuting/Forking
Feel free to fork and improve this script (just keep me posted).

## Credits/Thanks/Links
Thanks to all the people who wrote man/tutorials/examples and those who shared their questions and answers on scripting with bash.

Thanks to Nick Sweeting https://github.com/pirate/wireguard-docs.

Thanks to Nao who did not answer any of my questions but instead asked me the questions i should have asked myself.
