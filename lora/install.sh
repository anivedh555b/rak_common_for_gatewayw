#!/bin/bash

# Stop on the first sign of trouble
set -e

SCRIPT_COMMON_FILE=$(pwd)/../rak/rak/shell_script/rak_common.sh

if [ $UID != 0 ]; then
    echo_error "Operation not permitted. Forgot sudo?"
    exit 1
fi

source $SCRIPT_COMMON_FILE

mkdir -p /usr/local/rak/lora

RAK_GW_MODEL=`do_get_gw_model`

mkdir /opt/ttn-gateway -p

if [ "${RAK_GW_MODEL}" = "RAK7243" ]; then
    pushd rak7243
    ./install.sh
    LORA_DIR_TMP=rak7243
    popd
elif [ "${RAK_GW_MODEL}" = "RAK2245" ] || [ "${RAK_GW_MODEL}" = "RAK831" ]; then
    pushd rak2245
    ./install.sh
    LORA_DIR_TMP=rak2245
    popd
elif [ "${RAK_GW_MODEL}" = "RAK2247" ] || [ "${RAK_GW_MODEL}" = "RAK833" ]; then
    pushd rak2247
    ./install.sh
    LORA_DIR_TMP=rak2247
    popd
else
    :
fi

cp $LORA_DIR_TMP/lora_gateway /opt/ttn-gateway/ -rf
cp $LORA_DIR_TMP/packet_forwarder /opt/ttn-gateway/ -rf


cp ./update_gwid.sh /opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/update_gwid.sh
cp ./start.sh  /opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/start.sh
cp ./set_eui.sh  /opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/set_eui.sh
cp ttn-gateway.service /lib/systemd/system/ttn-gateway.service
cp /opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/global_conf/global_conf.eu_863_870.json \
	/opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/global_conf.json
sed -i "s/^.*server_address.*$/\t\"server_address\": \"127.0.0.1\",/" \
	/opt/ttn-gateway/packet_forwarder/lora_pkt_fwd/global_conf.json

systemctl enable ttn-gateway.service

