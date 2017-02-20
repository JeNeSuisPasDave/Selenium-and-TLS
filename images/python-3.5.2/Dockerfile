# Changed to get GPG keys from local files
# Changed to remove PORTS and CMD from end of Dockerfile
#

FROM datihein/alpine-3.4:1.0.0

MAINTAINER  Dave Hein <jenesuispasdave@gmail.com>

ENV PYTHON3_AND_FLASK_TO_BUILD_AT_ 2017-02-08T21:32:37-0600
# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# install ca-certificates so that HTTPS works consistently
# the other runtime dependencies for Python are installed later
RUN apk add --no-cache ca-certificates

ENV GPG_KEYS 97FC712E4C024BBEA48A61ED3A5CA953F73C700D
ENV PYTHON_VERSION 3.5.2

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 9.0.1

COPY tmp/python-3.5.2.tar.xz /tmp/delme/python.tar.xz
COPY tmp/python-3.5.2.tar.xz.asc /tmp/delme/python.tar.xz.asc
COPY tmp/python3-gpg.key /tmp/delme/
COPY tmp/gpg-trust.sh /tmp/delme/
RUN chmod +x /tmp/delme/gpg-trust.sh
COPY requirements.txt /tmp/delme/

RUN set -ex \
	&& apk add --no-cache --virtual .fetch-deps \
		expect \
		gnupg \
		openssl \
		tar \
		xz \
	\
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --import /tmp/delme/python3-gpg.key \
	&& /tmp/delme/gpg-trust.sh "$GPG_KEYS" \
	&& gpg --batch --verify /tmp/delme/python.tar.xz.asc /tmp/delme/python.tar.xz \
	&& rm -r "$GNUPGHOME" \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f /tmp/delme/python.tar.xz \
	\
	&& apk add --no-cache --virtual .build-deps  \
		bzip2-dev \
		gcc \
		gdbm-dev \
		libc-dev \
		linux-headers \
		make \
		ncurses-dev \
		openssl \
		openssl-dev \
		pax-utils \
		readline-dev \
		sqlite-dev \
		tcl-dev \
		tk \
		tk-dev \
		xz-dev \
		zlib-dev \
# add build deps before removing fetch deps in case there's overlap
	&& apk del .fetch-deps \
	\
	&& cd /usr/src/python \
	&& ./configure \
		--enable-loadable-sqlite-extensions \
		--enable-shared \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	\
# explicit path to "pip3" to ensure distribution-provided "pip3" cannot interfere
	&& if [ ! -e /usr/local/bin/pip3 ]; then : \
		&& wget -O /tmp/get-pip.py 'https://bootstrap.pypa.io/get-pip.py' \
		&& python3 /tmp/get-pip.py "pip==$PYTHON_PIP_VERSION" \
		&& rm /tmp/get-pip.py \
	; fi \
# we use "--force-reinstall" for the case where the version of pip we're trying to install is the same as the version bundled with Python
# ("Requirement already up-to-date: pip==8.1.2 in /usr/local/lib/python3.6/site-packages")
# https://github.com/docker-library/python/pull/143#issuecomment-241032683
	&& pip3 install --no-cache-dir --upgrade --force-reinstall "pip==$PYTHON_PIP_VERSION" \
# then we use "pip list" to ensure we don't have more than one pip version installed
# https://github.com/docker-library/python/pull/100
	&& [ "$(pip list |tac|tac| awk -F '[ ()]+' '$1 == "pip" { print $2; exit }')" = "$PYTHON_PIP_VERSION" ] \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a -name test -o -name tests \) \
			-o \
			\( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		\) -exec rm -rf '{}' + \
	&& runDeps="$( \
		scanelf --needed --nobanner --recursive /usr/local \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --virtual .python-rundeps $runDeps \
	&& pip install -r /tmp/delme/requirements.txt \
	&& apk del .build-deps \
	&& rm -rf /usr/src/python ~/.cache

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& { [ -e easy_install ] || ln -s easy_install-* easy_install; } \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

ENV REMOVE_DELME_AT_ 2017-01-01T10:20:33-0600
RUN rm -r /tmp/delme

ENV LABEL_IMAGE_AT_ 2017-01-01T10:20:40-0600
LABEL net.develves.python="3.5.2"
