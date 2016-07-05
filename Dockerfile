# Temporary docker file to build docker from Zeppelin binary distribution.
FROM centos:centos7

MAINTAINER ralph.schlosser@gmail.com

# Install some RPM packages.
RUN yum install -y vim git wget unzip curl \
    net-tools sysstat tar bzip2 \
    freetype fontconfig \
    python python-setuptools python-dev numpy python-pip python-matplotlib python-pandas python-pandasql ipython python-nose

# Configure versions and other settings.
ENV MAVEN_VERSION            3.3.1
ENV JAVA_VERSION             8u91
ENV JAVA_BUILD               b14
ENV ZEPPELIN_REPO_URL        https://github.com/apache/zeppelin.git
ENV ZEPPELIN_REPO_BRANCH     master
ENV ZEPPELIN_HOME            /opt/zeppelin
ENV ZEPPELIN_CONF_DIR        $ZEPPELIN_HOME/conf
ENV ZEPPELIN_NOTEBOOK_DIR    $ZEPPELIN_HOME/notebook
ENV ZEPPELIN_PORT            8080
ENV SCALA_BINARY_VERSION     2.10
ENV SCALA_VERSION            $SCALA_BINARY_VERSION.4
ENV SPARK_PROFILE            1.6
ENV SPARK_VERSION            1.6.1
ENV FLINK_VERSION            1.0.3
ENV HADOOP_PROFILE           2.6
ENV HADOOP_VERSION           2.7.1

# Maven
ENV MAVEN_DL_URL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz
ENV MAVEN_HOME /opt/apache-maven-$MAVEN_VERSION
ENV PATH $PATH:$MAVEN_HOME/bin
RUN curl -sL --retry 3 "$MAVEN_DL_URL"  \
  | gunzip \
  | tar x -C /opt/
RUN ln -s $MAVEN_HOME /opt/maven


# Scala
ENV SCALA_DL_URL http://www.scala-lang.org/files/archive/scala-$SCALA_VERSION.tgz
RUN curl -sL --retry 3 "$SCALA_DL_URL" \
    | gunzip \
    | tar x -C /opt/
ENV SCALA_HOME /opt/scala-$SCALA_VERSION
ENV PATH $SCALA_HOME/bin:$PATH

# Install R via EPEL.
RUN rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-7.noarch.rpm
RUN yum install -y R R-devel libcurl-devel openssl-devel

# RScala
RUN curl https://cran.r-project.org/src/contrib/Archive/rscala/rscala_1.0.6.tar.gz -o /opt/rscala_1.0.6.tar.gz
RUN R CMD INSTALL /opt/rscala_1.0.6.tar.gz

# Install R packages.
COPY provision/install.R /opt/install.R
RUN R CMD BATCH /opt/install.R /opt/install.R.out

# Spark
WORKDIR /opt
ENV SPARK_DL_URL http://archive.apache.org/dist/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE.tgz
RUN curl -sL --retry 3 \
  "$SPARK_DL_URL" \
  | gunzip \
  | tar x -C /opt/

RUN mv /opt/spark-$SPARK_VERSION-bin-hadoop$HADOOP_PROFILE /opt/spark
ENV SPARK_HOME /opt/spark

# Zeppelin
# FIXME: This a temporary workaround because of build issues in Zeppelin UI stage.
# when using a poor internet connection.
ADD https://www.dropbox.com/s/9x8vpfsjp1jrxda/zeppelin-0.6.0-SNAPSHOT.tar.gz?dl=0 /opt
RUN mv /opt/zeppelin-0.6.0-SNAPSHOT $ZEPPELIN_HOME
ENV PATH $ZEPPELIN_HOME/bin:$PATH

RUN mkdir $ZEPPELIN_HOME/logs
RUN mkdir $ZEPPELIN_HOME/run

# Compact container.
RUN rm -rf /root/.m2 &&\
    rm -rf /root/.npm &&
    rm -rf /opt/rscala_1.0.6.tar.gz \
    yum clean all

EXPOSE 4040
EXPOSE 8080

# Container entry point.
ENTRYPOINT ["$ZEPPELIN_HOME/bin/zeppelin.sh"]
