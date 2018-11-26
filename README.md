[![Build Status](https://travis-ci.org/Softrack-LLP/kisc-signer.svg?branch=master)](https://travis-ci.org/Softrack-LLP/kisc-signer)

### About the image

Docker image for easier tumar setup

This docker image makes it easier to setup tumar to use with your application.
The image uses an application that you can find on [github](https://github.com/Softrack-LLP/kisc-signer)

The following files used:

```
inst/tumar/lic_linux64_level2.tgz
inst/tumar/TumarCSP_5.2_linux64.tgz
```

These files are provided provided by [kisc](https://ca.kisc.kz/webra/res-open/tumar_others.htm)

### Usage(local build)

1. To build image run:

```bash
docker build . -t test
```

2. create property file in "$(pwd)/extra" folder

```properties
signKeyPath=/allpay/KiscSigner/extra/pkcs12_sign.p12
signKeyPassword=XXXXXXX
```

3. add your pk12 key in "$(pwd)/extra" folder

4. create docker compose file:

```yml
version: '2'
services:
    kisc-sign:
        image: test:latest
        volumes:
             - /path/to/extra:/allpay/KiscSigner/extra
        ports:
            - 5001:5001
```

5. run docker compose:
```bash
docker-compose -f service.yml down
docker-compose -f service.yml up -d
```

5. run to test

```bash

curl -d'<request>
    <body id="signedContent">
        <payments>
            <payment>
                <ct>
                    <id>7000353</id>
                    <date>2018-11-07T00:00:05.208+0600</date>
                </ct>
                <service>
                    <id>8</id>
                    <accountId>6100872</accountId>
                    <amount>109.0000000</amount>
                    <commission>0</commission>
                    <parameters>
                        <parameter>
                            <name>cr</name>
                            <value>KZT</value>
                        </parameter>
                    </parameters>
                </service>
            </payment>
        </payments>
    </body>
</request>' \
http://localhost:5001/KiscSignManager/sign

```

### Usage(dockerhub image)

The same as local build but you can skip the first step and use image softrackkz/kisc-signer-docker instead

### Troubleshooting

```bash
docker exec -it $(docker ps | grep test:latest | awk '{print $1}') /bin/bash
docker logs $(docker ps | grep test:latest | awk '{print $1}')
```
