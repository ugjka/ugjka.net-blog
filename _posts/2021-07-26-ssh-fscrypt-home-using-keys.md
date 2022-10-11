---
layout:     post
title:      SSH, keys and fscrypt
date:       2021-07-26
summary:    How to SSH into Fscrypt encrypted $HOME using public key cryptography without exposing password login to brute force attacks.
categories: linux
---

## The problem

You have set up [Fscrypt](https://wiki.archlinux.org/title/Fscrypt#Encrypt_a_home_directory) encrypted `$HOME` and you have set up PAM to decrypt your `$HOME` with your user login password. Now you want to SSH into your user with SSH keys but the problem is that `.ssh/authorized_keys` sitting in your `$HOME` is encrypted too and the sshd daemon can't access it to verify your identity. Password authentication would work though with PAM but you don't want that because of prevalence of brute-force attacks. So what do we do?

## Solution

The solution is to put your public keys outside your `$HOME` with restrictive permissions and set up sshd to require both key and password authorisation (password auth does the decryption with PAM).

First, as root we create some folder outside of `$HOME` to hold our public keys for each `$USER`. I went for `/ssh/`. Set permissions for that folder to 500 with `chmod` and make sure it is owned by root.

Now, create a file inside that folder named with your username. My username is ugjka so it would be `/ssh/ugjka` and then put your public key inside that file like you would with `.ssh/authorized_keys`. Make sure the owner is root, and permissions are 400

Now we need to configure the sshd daemon to search for our public keys inside `/ssh/` instead of `$HOME`. To do that we edit `/etc/ssh/sshd_config` and add the following changes

```
AuthenticationMethods publickey,password
AuthorizedKeysCommand /usr/bin/cat /ssh/%u
AuthorizedKeysCommandUser root
```

Also make sure `PasswordAuthentication` and `PubkeyAuthentication` is set to `Yes`

Restart the sshd daemon and you are set :)

So now when the user `ugjka` tries to login, the `AuthorizedKeysCommand` directive will call `cat /ssh/ugjka` (because `%u` expands to the username) and will return the public key inside that file to the sshd daemon and authorisation will proceed. Then, next, according to the `AuthenticationMethods` directive, the password authentication will be invoked and, if PAM is configured correctly, it will decrypt your `$HOME`. 