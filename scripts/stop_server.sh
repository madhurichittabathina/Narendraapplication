
#!/bin/bash
isExistApp=`pgrep java`
if [[ -n  $isExistApp ]]; then
   sh /root/apache-tomcat-8.5.56/bin/shutdown.sh
fi
