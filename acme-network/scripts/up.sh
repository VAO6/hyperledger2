cd .. && docker-compose -f docker-compose-root-ca.yaml up -d
sleep 5
cd scripts && ./rootca.sh
cd .. && docker-compose -f docker-compose-int-ca.yaml up -d
sleep 5
cd scripts && ./intca.sh
./identities.sh
./msp.sh
