# Features

* Remote desktop connection (RDP) into the container.
* Audio redirection
* Text Clipboard redirection
* Wine runtime (w/ `wine-mono` and `wine-gecko`)

## Not working

* File clipboard redirection (I think)
* Drive redirection

# How to use the image

To use this image, we recommend you to use this image as a base to create your own image.
This will allow you to include custom scripts, packages, shortcut, etc.

Once you have built your image, you can use a command similar to the following to start a container.
Make sure to adapt the command to fit your needs.

```sh
docker run \
  -p 3389:3389 \
  --shm-size 2g \
  -v {local user-sync.json file}:/etc/user-sync.json \
  {your image name or hash}
```

The `--shm-size` option is required (tough you might want to play around with the size), because XRDP won't operate properly otherwise.

# Users and groups

This container uses the [user-sync project](https://github.com/lunix33/user-sync) to synchronize the system users and groups with
the content of a synchronization file located in `/etc/user-sync.json`.

The synchronization occur on container start as part of the docker entry point, but you can run it manually
by invoking the binary (`/opt/user-sync/bin/user-sync`).

```ts
{
  "local": {
    /** True when the passwords are encrypted, otherwise false. */
    "encrypted": boolean,
    /** The list of users. */
    "users": [{
      /** The name of the user. */
      "username": string,
      /**
       * The password of the user.
       * If `local.encrypted` is `true`, this fields should be encrypted.
       * `openssl passwd -6 'userPassword'` can be used to create an encrypted password.
       */
      "password": string,
      /**
       * A list of group the user should be a member of.
       * The first group of the list will be considered their primary group and must be defined.
       */
      "groups": string[]
      /** An optional forced UID for the user. */
      "uid"?: number,
    }],
    /** The list of groups */
    "groups": [{
      /** The name of the group. */
      "name": string,
      /** An optional forced GID for the group. */
      "gid"?: number
    }]
  }
}
```
