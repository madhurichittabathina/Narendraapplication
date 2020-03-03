FROM sdorra/oracle-java-8 
#RUN apk update && apk add bash
RUN mkdir -p /opt/WhatsupDOC

COPY . /opt/WhatsupDOC/

WORKDIR /opt/WhatsupDOC/

EXPOSE 8443


CMD ./gradlew WhatsupDOC
