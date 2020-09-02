cd .. && docker-compose -f docker-compose-root-ca.yaml -f docker-compose-int-ca.yaml down
cd scripts && ./cleancerts.sh
