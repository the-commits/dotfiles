#!/usr/bin/env bash

ARCH="$(uname -m)"
VERS="2.30.3"
if [[ $ARCH -eq "x86_64" ]];
  then
    ARCH="amd64"
fi

wget "https://cache.agilebits.com/dist/1P/op2/pkg/v${VERS}/op_linux_${ARCH}_v${VERS}.zip" -O op.zip && \
unzip -d op op.zip && \
sudo mv op/op /usr/local/bin/ && \
rm -r op.zip op && \
sudo groupadd -f onepassword-cli && \
sudo chgrp onepassword-cli /usr/local/bin/op && \
sudo chmod g+s /usr/local/bin/op
