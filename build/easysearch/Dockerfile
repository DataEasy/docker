ARG VERSION_CENTOS=centos7.5.1804

FROM centos:${VERSION_CENTOS}

LABEL maintainer="devops@dataeasy.com.br"

# Set the env variables
ENV TOMCAT_VERSION=apache-tomcat-8.0.53
ENV JAVA_VERSION=jdk-8u172-linux-x64
ENV JDK_VERSION=jdk1.8.0_172
ENV VERSION_MUPDF=mupdf-1.11-source
ENV DOWNLOAD_USER=well
ENV DOWNLOAD_PASS=well
# XMS
ENV MEM_XMS=1024
# XMX
ENV MEM_XMX=1024
# MaxMetaspaceSize
ENV MEM_MMSS=384

RUN mkdir /opt/install
COPY deps_easysearch.sh /opt/install
RUN cd /opt/install \
    && chmod +x deps_easysearch.sh \
    && ./deps_easysearch.sh
RUN rm -rf /opt/install \
    && yum clean all \
    && rm -rf /var/cache/yum

WORKDIR /opt/tomcat
EXPOSE 8080
CMD ["/opt/tomcat/bin/catalina.sh", "run"]