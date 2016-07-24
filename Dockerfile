# Docker file to build docker image from Zeppelin binary distribution.
#
# Starting the container:
#
# docker run --rm -p 9090:9090 analytics/docker-zeppelin
#
# Debugging:
#
# docker run --rm -it --entrypoint=bash analytics/docker-zeppelin
#

FROM analytics/hadoop-spark

MAINTAINER ralph.schlosser@gmail.com

# Install R, SciPy...
RUN set -ex \
 && buildDeps=' \
    libpython3-dev \
    build-essential \
    pkg-config \
    gfortran \
    python3-pip \
 ' \
 && apt-get update && apt-get install -y --no-install-recommends \
    $buildDeps \
    ca-certificates \
    liblapack-dev \
    libopenblas-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    r-base \
    r-base-dev \
    r-recommended \
 && packages=' \
    numpy \
    scipy \
 ' \
 && pip3 install $packages \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Configure versions and other settings.
ENV MAVEN_VERSION            3.3.1
ENV JAVA_VERSION             8u91
ENV JAVA_BUILD               b14
ENV ZEPPELIN_REPO_URL        https://github.com/apache/zeppelin.git
ENV ZEPPELIN_REPO_BRANCH     master
ENV ZEPPELIN_HOME            /opt/zeppelin
ENV ZEPPELIN_CONF_DIR        $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR    $ZEPPELIN_HOME/notebook
ENV ZEPPELIN_PORT            9090
ENV SCALA_BINARY_VERSION     2.10
ENV SCALA_VERSION            $SCALA_BINARY_VERSION.4
ENV SPARK_PROFILE            1.6
ENV SPARK_VERSION            1.6.2
ENV FLINK_VERSION            1.0.3
ENV HADOOP_PROFILE           2.6
ENV HADOOP_VERSION           2.7.2

# Maven
ENV MAVEN_DL_URL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
ENV MAVEN_HOME /opt/apache-maven-$MAVEN_VERSION
ENV PATH $PATH:$MAVEN_HOME/bin
RUN curl -sL --retry 3 "$MAVEN_DL_URL"  \
  | gunzip \
  | tar x -C /opt/ && \
  ln -s $MAVEN_HOME /opt/maven

# Scala
ENV SCALA_DL_URL http://www.scala-lang.org/files/archive/scala-$SCALA_VERSION.tgz
RUN curl -sL --retry 3 "$SCALA_DL_URL" \
    | gunzip \
    | tar x -C /opt/
ENV SCALA_HOME /opt/scala-$SCALA_VERSION
ENV PATH $SCALA_HOME/bin:$PATH

# RScala
RUN curl https://cran.r-project.org/src/contrib/Archive/rscala/rscala_1.0.6.tar.gz -o /opt/rscala_1.0.6.tar.gz && \
    R CMD INSTALL /opt/rscala_1.0.6.tar.gz

# Install R packages.
COPY provision/install.R /opt/inst.R
RUN R CMD BATCH /opt/inst.R /tmp/inst.R.out

# Zeppelin
# FIXME: This a temporary workaround because of build issues in Zeppelin UI stage.
# when using a poor internet connection.
ENV PATH $ZEPPELIN_HOME/bin:$PATH
ADD zeppelin-0.6.0-bin-all.tgz /opt

COPY zeppelin-entrypoint.sh /entrypoints/zeppelin-entrypoint.sh
COPY hadoop_config.sh /hadoop_config.sh
COPY service_wait.sh /service_wait.sh

RUN mv /opt/zeppelin-0.6.0-bin-all $ZEPPELIN_HOME && \
    mkdir $ZEPPELIN_HOME/logs && \
    mkdir $ZEPPELIN_HOME/run && \
    chmod a+x /entrypoints/zeppelin-entrypoint.sh && \
    chmod a+x /hadoop_config.sh && \
    chmod a+x /service_wait.sh
    
# Compact container.
RUN rm -rf /root/.m2 && \
    rm -rf /root/.npm && \
    rm -rf /opt/rscala_1.0.6.tar.gz

EXPOSE 4040
EXPOSE $ZEPPELIN_PORT

# Container entry point.
ENTRYPOINT ["/entrypoints/zeppelin-entrypoint.sh"]
