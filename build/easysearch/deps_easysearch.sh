#!/bin/bash

echo "EasySearch - Build Docker Image"

echo $TOMCAT_VERSION
echo $JAVA_VERSION
echo $JDK_VERSION
echo $VERSION_MUPDF
echo $DOWNLOAD_USER
echo $DOWNLOAD_PASS
echo $MEM_XMS
echo $MEM_XMX
echo $MEM_MMSS
sleep 10

echo "Atualizando Sistema Operacional"
sleep 5
yum update -y
yum upgrade -y

# Create Install Dir
chmod 0777 /opt/install
cd /opt/install

# Create Config Dir
mkdir -p /opt/sistemas/dataeasy/easysearch/native

echo "TOMCAT DOWNLOAD"
STATS=`curl -s --head -u ${DOWNLOAD_USER}:${DOWNLOAD_PASS} https://download.dataeasy.com.br/well/instaladores/tomcat/tomcat8/${TOMCAT_VERSION}_docker.tar.gz  | grep HTTP |  awk -F " " '{print $3}'`

if [ ${STATS} == "Not" ]
    then
        echo "Download NOT exist!!"
        exit 0
    else
        echo "Download exists!!!"
        curl -# -O -u ${DOWNLOAD_USER}:${DOWNLOAD_PASS} https://download.dataeasy.com.br/well/instaladores/tomcat/tomcat8/${TOMCAT_VERSION}_docker.tar.gz
fi

echo "Download JAVA"
STATS=`curl -s --head -u ${DOWNLOAD_USER}:${DOWNLOAD_PASS} https://download.dataeasy.com.br/well/instaladores/java/java8/${JAVA_VERSION}.tar.gz  | grep HTTP |  awk -F " " '{print $3}'`
if [ ${STATS} == "Not" ]
    then
        echo "Download NOT exist!!"
        exit 0
    else
        echo "Download exists!!!"
        curl -# -u ${DOWNLOAD_USER}:${DOWNLOAD_PASS} -O https://download.dataeasy.com.br/well/instaladores/java/java8/${JAVA_VERSION}.tar.gz
fi

echo "Download PDF2HtmlEx - Config"
STATS=`curl -s --head -u ${DOWNLOAD_USER}:${DOWNLOAD_PASS} https://download.dataeasy.com.br/well/instaladores/easysearch/pdf2htmlEX/linux_x64/1.5/pdf2html.tar.gz  | grep HTTP |  awk -F " " '{print $3}'`
if [ ${STATS} == "Not" ]
    then
        echo "Download NOT exist!!"
        exit 0
    else
        echo "Download exists!!!"
        curl -# -u ${DOWNLOAD_USER}:${DOWNLOAD_PASS} -O https://download.dataeasy.com.br/well/instaladores/easysearch/pdf2htmlEX/linux_x64/1.5/pdf2html.tar.gz
fi

clear
echo "Instalado EasySearch"
sleep 5

# Install Deps
yum install unzip vim -y
yum remove *openjdk* -y

# EasySearch ConfigDir Create
mkdir -p /opt/sistemas/dataeasy/easysearch/native

# Instala Tomcat
cd /opt/install
tar -zxvf ${TOMCAT_VERSION}_docker.tar.gz
mv ${TOMCAT_VERSION}/ ../
ln -s /opt/${TOMCAT_VERSION}/ /opt/tomcat

# Instala Java
cd /opt/install
tar -zxvf ${JAVA_VERSION}.tar.gz
mv ${JDK_VERSION}/ ../
ln -s /opt/${JDK_VERSION}/ /opt/java

# Create file /etc/profile.d/easysearch.sh
echo "#!/bin/bash
# Tomcat
# Pasta: /etc/profile.d
# Arquivo: easysearch.sh
CATALINA_HOME=/opt/tomcat
JAVA_HOME=/opt/java
export CATALINA_HOME
export JAVA_HOME
# Exports to pdf2htmlEx
export PATH=\$PATH:/usr/local/bin
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/local/lib
export INCLUDE_PATH=/usr/local/include
# Atualizando a variaveis
export PATH=\$PATH:\$JAVA_HOME/bin:\$CATALINA_HOME
#alternatives --install /usr/bin/java java /opt/java/bin/java 1" | tee -a /etc/profile.d/easysearch.sh

chmod 0777 /etc/profile.d/easysearch.sh
source /etc/profile.d/easysearch.sh

# Java Version Test
/opt/java/bin/java -version
sleep 1

echo "Install Pdf2HtmlEx"
cd /opt/install
tar -zxvf pdf2html.tar.gz

# Deps PDF2HtmlEX
yum install -y \
            make \
            cmake \
            gcc \
            gcc-c++ \
            zlib-devel \
            fontconfig-devel \
            libjpeg-devel \
            automake \
            gettext \
            libtool \
            libtool-ltdl-devel \
            libxml2-devel \
            nasm \
            glib2-devel \
            pango-devel \
            libX11-devel.x86_64 \
            libXext-devel.x86_64 \
            gcc mesa-libGL-devel \
            libXcursor-devel \
            libXrandr-devel \
            libXinerama-devel \
            expect

export PATH=$PATH:/usr/local/bin
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
export INCLUDE_PATH=/usr/local/include

cd pdf2html/libpng-1.6.10/
chmod +x configure
./configure && make && make install

cd ../poppler-0.48.0/
./configure --enable-xpdf-headers && make && make install

cd ../poppler-data-0.4.7/
cmake . && make && make install

cd ../autoconf-2.69
./configure --prefix=/usr && make && make install

cd ../fontforge-20130820/
./autogen.sh && ./configure && make && make install

cd ../pdf2htmlEX/
cmake . && make && make install
cd ..

echo "Test PDF2THTMLEX"
sleep 1
pdf2htmlEX --help

echo "Installalando MUPDF"
cd /opt/install

STATS=`curl -s --head -u ${DOWNLOAD_USER}:${DOWNLOAD_PASS} https://mupdf.com/downloads/archive/${VERSION_MUPDF}.tar.gz  | grep HTTP |  awk -F " " '{print $3}'`
if [ ${STATS} == "Not" ]
    then
        echo "Download NOT exist!!"
        exit 0
    else
        echo "Download exists!!!"
        curl -# -u ${DOWNLOAD_USER}:${DOWNLOAD_PASS} -O https://mupdf.com/downloads/archive/${VERSION_MUPDF}.tar.gz
fi

tar -zxvf ${VERSION_MUPDF}.tar.gz
cd /opt/install/${VERSION_MUPDF}
make clean && make && make install

mkdir /var/run/tomcat/
chmod 0777 /var/run/tomcat/

# -- FIM --