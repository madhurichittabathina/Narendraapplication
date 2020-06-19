
#!/bin/bash
isExistApp=`pgrep java`
if [[ -n  $isExistApp ]]; then
   sh /root/apache-tomcat-9.0.36/bin/shutdown.sh
fi
