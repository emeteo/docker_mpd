# docker_mpd
FROM alpine:latest as build_base

LABEL version="0.23.10"
LABEL maintainers="[John Sing Dao Siu](https://github.com/J-Siu)"
LABEL name="mpd"
LABEL usage="https://github.com/J-Siu/docker_mpd_lite/blob/master/README.md"
LABEL description="Docker - MPD Lite with UID/GID + audio GID handling."

RUN wget https://www.musicpd.org/download/mpd/0.23/mpd-0.23.10.tar.xz \
	&& tar xf mpd-0.23.10.tar.xz
WORKDIR /mpd-0.23.10

RUN apk --no-cache add \
		alsa-lib-dev \
		boost \
		boost-dev \
		build-base \
		ffmpeg-dev \
		meson \
		ninja \
		sqlite-dev \
		libnfs-dev \
		mpg123-dev \
		libid3tag-dev \
		flac-dev \ 
		libvorbis-dev \
		curl-dev \
	&& meson . output/release \
		--prefix=/usr \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--localstatedir=/var \
		--buildtype=release \
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
		-Dipv6=disabled \
		-Dsqlite=enabled \
		-Ddaemon=false \
		-Dsyslog=disabled \
		-Dlocal_socket=false \
		-Ddocumentation=disabled \
		-Ddsd=false \
		-Dhttpd=false \
		-Dneighbor=false \
		-Drecorder=false \
		-Dsnapcast=false \
		-Dtest=false \
		-Dwave_encoder=false \
		-Dadplug=disabled \
		-Dao=disabled \
		-Daudiofile=disabled \
		-Dbzip2=disabled \
		-Dcdio_paranoia=disabled \
		-Dchromaprint=disabled \
		-Dcurl=enabled \
		-Ddbus=disabled \
		-Dexpat=disabled \
		-Dfaad=disabled \
		-Dflac=enabled \
		-Dfluidsynth=disabled \
		-Dgme=disabled \
		-Diconv=disabled \
		-Dicu=disabled \
		-Did3tag=enabled\
		-Diso9660=disabled \
		-Djack=disabled \
		-Dlame=disabled \
		-Dlibmpdclient=disabled \
		-Dlibsamplerate=disabled \
		-Dmad=disabled \
		-Dmikmod=disabled \
		-Dmms=disabled \
		-Dmodplug=disabled \
		-Dmpcdec=disabled \
		-Dmpg123=enabled \
		-Dnfs=enabled \
		-Dopenal=disabled \
		-Dopus=disabled \
		-Doss=disabled \
		-Dpcre=disabled \
		-Dpulse=disabled \
		-Dqobuz=disabled \
		-Dshine=disabled \
		-Dshout=disabled \
		-Dsidplay=disabled \
		-Dsmbclient=disabled \
		-Dsndfile=disabled \
		-Dsndio=disabled \
		-Dsolaris_output=disabled \
		-Dsoundcloud=disabled \
		-Dsoxr=disabled \
		-Dsystemd=disabled \
		-Dtremor=disabled \
		-Dtwolame=disabled \
		-Dudisks=disabled \
		-Dupnp=disabled \
		-Dvorbis=enabled \
		-Dvorbisenc=disabled \
		-Dwavpack=disabled \
		-Dwebdav=disabled \
		-Dwildmidi=disabled \
		-Dyajl=disabled \
		-Dzeroconf=disabled \
		-Dzlib=disabled \
		-Dzzip=disabled \
	&& meson configure output/release \
	&& ninja -j 4 -C output/release

FROM alpine:latest

LABEL version="0.23.10"
LABEL maintainers="[John Sing Dao Siu](https://github.com/J-Siu)"
LABEL name="mpd"
LABEL usage="https://github.com/J-Siu/docker_mpd_lite/blob/master/README.md"
LABEL description="Docker - MPD Lite with UID/GID + audio GID handling."

COPY --from=build_base /mpd-0.23.10/output/release/mpd /usr/bin/
RUN apk --no-cache add alsa-lib sqlite-libs ffmpeg-libs libnfs mpg123-libs libid3tag flac libvorbis curl 

COPY docker-compose.yml env start.sh mpd.conf /
RUN chmod u+x /start.sh \
	&& chmod ugo+x /usr/bin/mpd \
	&& mkdir /mpd

CMD ["/start.sh"]
