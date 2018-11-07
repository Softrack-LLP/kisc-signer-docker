FROM centos:6.7

MAINTAINER Magzhan Abdibayev, magzhan.abdibayev@allpay.kz

######## ports
EXPOSE 5001

######### env
RUN echo started
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf ; echo "nameserver 8.8.4.4" >> /etc/resolv.conf
RUN mv /etc/localtime /etc/localtime.bak
RUN ln -s /usr/share/zoneinfo/Asia/Almaty /etc/localtime

######### TUMAR
# Install
ADD inst/tumar/TumarCSP_5.2_linux64.tgz /opt
WORKDIR /opt/TumarCSP5.2
RUN ./setup_csp.sh install
WORKDIR /opt
# https://unix.stackexchange.com/questions/195975/cannot-force-remove-directory-in-docker-build
# https://github.com/moby/moby/issues/783
RUN find /opt/TumarCSP5.2 -type f | xargs -L1 rm -f

# Links to shared objects
RUN ln -s /lib64/libcptumar.so.4.0 /lib64/libcptumar.so
RUN ln -s /lib64/libcptumar_r.so.4.0 /lib64/libcptumar_r.so

# Licenses
RUN mkdir /opt/tumar_lic
ADD inst/tumar/lic_linux64_level2.tgz /opt/tumar_lic
RUN cp /opt/tumar_lic/CLIENTKISC64.2.reg  /opt/tumar_lic/CLIENTKISC32.2.reg  /TumarCSP/etc/lic/
RUN cp /opt/tumar_lic/CLIENTKISC64_R.2.reg  /opt/tumar_lic/CLIENTKISC32_R.2.reg /TumarCSP/etc/lic_r/
# https://unix.stackexchange.com/questions/195975/cannot-force-remove-directory-in-docker-build
# https://github.com/moby/moby/issues/783
RUN find /opt/tumar_lic -type f | xargs -L1 rm -f

# Containers
RUN mkdir -p /allpay/Netinfo/extra/certificates/tumar/
# COPY extra/certificates/tumar/ /allpay/Netinfo/extra/certificates/tumar/ # must not copy certificates, must be mapped
RUN > /TumarCSP/etc/cptumar.conf
RUN echo "[profiles]" >> /TumarCSP/etc/cptumar.conf
RUN echo "userRsa=file://USER_RSA@//allpay/Netinfo/extra/certificates/tumar/RSA" >> /TumarCSP/etc/cptumar.conf
RUN echo "userGost=file://USER_GOST@//allpay/Netinfo/extra/certificates/tumar/GOST" >> /TumarCSP/etc/cptumar.conf


######### kisc signer

# copy uberjar
RUN mkdir -p /allpay/KiscSigner/extra
RUN mkdir -p /allpay/KiscSigner/jar
RUN yum install -y wget
RUN echo downloading KiscSignManager.jar
RUN wget -O /allpay/KiscSigner/jar/KiscSignManager.jar https://github.com/Softrack-LLP/kisc-signer/releases/download/v1.0.0/KiscSignManager-jar-with-dependencies.jar

######### java

RUN yum install -y java-1.8.0-openjdk ; yum clean all

######### CMD

CMD ["java","-jar","/allpay/KiscSigner/jar/KiscSignManager.jar"]
