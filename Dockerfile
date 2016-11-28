FROM rudenkovk/java-docker

MAINTAINER "Konstantin Rudenkov" <rudenkovk@gmail.com>

ARG HUB_VERSION=2.5
ARG HUB_BUILD=399

ENV APP_NAME=hub \
    APP_PORT=8080 \
    APP_UID=500 \
    APP_PREFIX=/srv \
    APP_DISTNAME="hub-ring-bundle-${APP_VERSION}.${APP_BUILD}" \
    APP_USER=$APP_NAME \
    APP_DIR=$APP_PREFIX/$APP_NAME \
    APP_HOME=/var/lib/$APP_NAME \
    APP_DISTFILE="${APP_DISTNAME}.zip"

RUN useradd --system --user-group --uid $APP_UID --home $APP_HOME $APP_USER \ 
    && mkdir $APP_HOME \
    && chown -R $APP_USER:$APP_USER $APP_HOME

WORKDIR $APP_PREFIX

RUN wget -q https://download.jetbrains.com/hub/$APP_VERSION/$APP_DISTFILE && \
    unzip -q $APP_DISTFILE -x */internal/java/* && \
    mv $APP_DISTNAME $APP_NAME && \
    chown -R $APP_USER:$APP_USER $APP_DIR && \
    rm $APP_DISTFILE 

USER $APP_USER
WORKDIR $APP_DIR

RUN bin/hub.sh configure \
    --backups-dir $APP_HOME/backups \
    --data-dir    $APP_HOME/data \
    --logs-dir    $APP_HOME/log \
    --temp-dir    $APP_HOME/tmp \
    --listen-port $APP_PORT \
    --base-url    http://localhost/

ENTRYPOINT ["bin/hub.sh"]
CMD ["run"]
EXPOSE $APP_PORT
VOLUME ["$APP_HOME"]