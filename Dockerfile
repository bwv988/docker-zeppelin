# Docker file to build docker image from Zeppelin binary distribution.
#
# Debugging:
#
# docker run --rm -it --entrypoint=bash bwv988/docker-zeppelin
#

FROM bwv988/ds-spark-base

MAINTAINER ralph.schlosser@gmail.com

# Environment variables.
ENV MAVEN_VERSION=3.3.9
ENV ZEPPELIN_VERSION=0.7.2
#ENV RSCALA_VERSION=2.2.2
ENV SCALA_BINARY_VERSION=2.10.6
ENV RSCALA_DL_URL=https://cran.r-project.org/src/contrib/rscala_${RSCALA_VERSION}.tar.gz
ENV ZEPPELIN_HOME=/opt/zeppelin
ENV ZEPPELIN_CONF_DIR=$ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR=$ZEPPELIN_HOME/notebook
ENV ZEPPELIN_PORT=9090
ENV ZEPPELIN=zeppelin-${ZEPPELIN_VERSION}
ENV ZEPPELIN_DL_URL=http://www-eu.apache.org/dist/zeppelin/${ZEPPELIN}/${ZEPPELIN}-bin-all.tgz
ENV SCALA_VERSION=$SCALA_BINARY_VERSION
ENV MAVEN_DL_URL=http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
ENV MAVEN_HOME=/opt/apache-maven-$MAVEN_VERSION
ENV SCALA_DL_URL=http://www.scala-lang.org/files/archive/scala-${SCALA_VERSION}.tgz
ENV SCALA_HOME=/opt/scala-$SCALA_VERSION
ENV PATH=$ZEPPELIN_HOME/bin:$MAVEN_HOME/bin:$SCALA_HOME/bin:$PATH

# Copy some scripts.
COPY files/zeppelin-entrypoint.sh files/inject_interpreter_cfg.py files/inject_zeppelin_cfg.sh \
     files/service_wait.sh /entrypoints/

# Download and install components.
RUN set -x \
  && curl -sL --retry 3 "$MAVEN_DL_URL"  \
  | gunzip \
  | tar x -C /opt/ \
  && ln -s $MAVEN_HOME /opt/maven \
  && curl -sL -k --retry 3 "$SCALA_DL_URL" \
  | gunzip \
  | tar x -C /opt/ \
  #&& curl -k ${RSCALA_DL_URL} -o /opt/rscala.tar.gz \
  #&& R CMD INSTALL /opt/rscala.tar.gz \
  #&& rm /opt/rscala.tar.gz \
  && curl -kfSL "$ZEPPELIN_DL_URL" -o /tmp/zeppelin.tar.gz \
  && tar -xvf /tmp/zeppelin.tar.gz -C /opt/ \
  && rm /tmp/zeppelin.tar.gz* \
  && mv /opt/${ZEPPELIN}-bin-all $ZEPPELIN_HOME \
  && mkdir $ZEPPELIN_HOME/logs \
  && mkdir $ZEPPELIN_HOME/run \
  && chmod a+x /entrypoints/zeppelin-entrypoint.sh \
  && chmod a+x /entrypoints/inject_interpreter_cfg.py \
  && rm -rf /root/.m2 \
  && rm -rf /root/.npm

WORKDIR /workdir

EXPOSE $ZEPPELIN_PORT

ENTRYPOINT ["/entrypoints/zeppelin-entrypoint.sh"]
