# Docker - MPD Lite with UID/GID + audio GID handling 

Custom compile of MPD which trim down all functions except audio playing.

### Table Of Content
<!-- TOC -->

- [Table Of Content](#table-of-content)
- [Minimal Compilation](#minimal-compilation)
- [Libraries](#libraries)
- [Build](#build)
- [Usage](#usage)
  - [Host Directories and Volume Mapping](#host-directories-and-volume-mapping)
  - [MPD_UID / MPD_GID](#mpd_uid--mpd_gid)
  - [Run](#run)
  - [Debug / Custom Config](#debug--custom-config)
  - [Compose](#compose)
- [Repository](#repository)
- [Contributors](#contributors)
- [Change Log](#change-log)
- [License](#license)

<!-- /TOC -->
<!--more-->

### Minimal Compilation

Only following MPD build options are enabled in Dockerfile:

```sh
-Dcue=true \
-Ddatabase=true \
-Depoll=true \
-Deventfd=true \
-Dfifo=true \
-Dinotify=true \
-Dpipe=true \
-Dsignalfd=true \
-Dtcp=true \
-Dalsa=enabled \
-Dffmpeg=enabled \
-Dipv6=enabled \
-Dsqlite=enabled
```

All other options are explicitly set to false or disabled.

### Libraries

Only use following libraries in container.

Library|Usage
---|---
`alsa-lib`|Linux ALSA sound system. This is for sound output.
`ffmpeg-libs`|This take care of 99% of audio file playback.
`sqlite-libs`|For mpd song database.
`curl`|For http streaming
`flac`|For flac playback
`id3tag`|For id3 tagging
`mpg123`|For mpg123 playback
`nfs`|For nfs sources
`vorbis`|For vorbis playback


> ffmpeg-libs does pull in other decoders.

### Build

```sh
git clone https://github.com/emeteo/docker_mpd.git
cd docker_mpd
docker build -t emeteo/mpd .
```

### Usage

#### Host Directories and Volume Mapping

Host|Inside Container|Mapping Required|Usage
---|---|---|---
${MPD_PATH_CONF}|/mpd.conf|Optional|MPD configuration file
${MPD_PATH_MPD}|/mpd/.mpd|Yes|Contain playlists folder, state file, database file
${MPD_PATH_MUSIC}|/mpd/music|Yes|MPD audio file folder
${MPD_PORT}|6000/tcp|Yes|MPD listening port
${MPD_SND}||Yes|MPD output device

Create playlists director inside ${MPD_PATH_MPD} if not exist yet.

```sh
mkdir -p ${MPD_PATH_MPD}/playlists
```

#### MPD_UID / MPD_GID

ENV VAR|Usage
---|---
MPD_UID|UID of ${MPD_PATH_MPD},${MPD_PATH_MUSIC} owner
MPD_GID|GID of ${MPD_PATH_MPD},${MPD_PATH_MUSIC} owner

#### Run

```sh
docker run \
-d \
-e PUID=${MPD_UID} \
-e PGID=${MPD_GID} \
-p ${MPD_PORT}:6600/tcp \
-v ${MPD_PATH_MPD}:/mpd/.mpd \
-v ${MPD_PATH_MUSIC}:/mpd/music \
--device ${MPD_SND} \
--cap-add sys_nice \
emeteo/docker_mpd
```

Example:

If ${MPD_PATH_MPD} and ${MPD_PATH_MUSIC} owner's UID=1001 and GID=1002:

```sh
docker run \
-d \
-e PUID=1001 \
-e PGID=1002 \
-p 6600:6600/tcp \
-v /home/emeteo/MPD:/mpd/.mpd \
-v /home/emeteo/Music:/mpd/music \
--device /dev/snd \
--cap-add sys_nice \
emeteo/docker_mpd
```

If using `/etc/asound.conf`:

```sh
docker run \
-d \
-e PUID=1001 \
-e PGID=1002 \
-p 6600:6600/tcp \
-v /home/emeteo/MPD:/mpd/.mpd \
-v /home/emeteo/Music:/mpd/music \
-v /etc/asound.conf:/etc/asound.conf \
--device /dev/snd \
--cap-add sys_nice \
emeteo/docker_mpd
```

#### Debug / Custom Config

Get config from image:

```sh
docker run --rm emeteo/docker_mpd cat /mpd.conf > mpd.conf
```

Change mpd.conf log_level to verbose:

```conf
log_level  "verbose"
```

Run with mpd.conf mapping:

```sh
docker run \
-e PUID=1001 \
-e PGID=1002 \
-p 6600:6600/tcp \
-v /home/emeteo/mpd.conf:/mpd.conf \ # Map mpd.conf into container
-v /home/emeteo/MPD:/mpd/.mpd \
-v /home/emeteo/Music:/mpd/music \
--device /dev/snd \
emeteo/docker_mpd
```

#### Compose

Get docker-compose template from image:

```sh
docker run --rm emeteo/mpd cat /docker-compose.yml > docker-compose.yml
docker run --rm emeteo/mpd cat /env > .env
```

Fill in `.env` according to your environment.

```sh
docker-compose up
```

### Repository

- [docker_mpd_lite](https://github.com/emeteo/docker_mpd)

### Contributors

- [John Sing Dao Siu](https://github.com/J-Siu)
- [Mario Teijeiro](https://github.com/emeteo)

### Change Log

- 0.21.14
  - Matching mpd version number
  - Base image: alpine:edge
  - mpd version: 0.21.14
- 0.21.19
  - Matching mpd version number
  - Base image: alpine:edge
  - mpd version: 0.21.19
- 0.21.23
  - mpd version: 0.21.23
- 0.21.24
  - mpd version: 0.21.24
  - Fix base image: alpine:edge
  - start.sh
    - Use exec so start.sh can exit
    - Add exit code 1
    - Remove delgroup/deluser ${PUSR}
- 0.21.25
  - mpd version: 0.21.25
- 0.22
  - mpd version: 0.22
- 0.22.3
  - mpd version: 0.22.3
- 0.22.6
  - mpd version: 0.22.6
- 0.23.6
  - mpd version: 0.23.6
- 0.23.6-p1
  - Add docker push github workflow
<!--CHANGE-LOG-END-->

### License

The MIT License

Copyright (c) 2022

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
