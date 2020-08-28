# Spin up root CA services
docker-compose -f ../docker-compose-root-ca.yaml up -d
sleep 5s

# ORG 1
export CSR_NAMES_ORG1=C=CO,ST=Antioquia,L=Medellin,O=Org1,OU="Hyperledger Fabric"
# Enroll bootstrap identity of root CA
export FABRIC_CA_CLIENT_HOME=../fabric-ca/org1.acme.org/root/clients/admin
fabric-ca-client enroll -u http://admin:adminpw@localhost:7054 --csr.names $CSR_NAMES_ORG1
# Register intermediate CA in the root CA
fabric-ca-client register --id.name int.ca.org1.acme.org --id.secret password --id.attrs 'hf.IntermediateCA=true' -u http://admin:adminpw@localhost:7054
# Enroll bootstrap identity of tls root CA
export FABRIC_CA_CLIENT_HOME=../fabric-ca/org1.acme.org/tls-root/clients/admin
fabric-ca-client enroll -u http://admin:adminpw@localhost:7055 --csr.names $CSR_NAMES_ORG1
# Register intermediate CA in the tls root CA
fabric-ca-client register --id.name tls.int.ca.org1.acme.org --id.secret password --id.attrs 'hf.IntermediateCA=true' -u http://admin:adminpw@localhost:7055

# ORG 2
export CSR_NAMES_ORG2=C=CL,ST=Santiago,L=Santiago,O=Org2,OU="Hyperledger Fabric"
# Enroll bootstrap identity of root CA
export FABRIC_CA_CLIENT_HOME=../fabric-ca/org2.acme.org/root/clients/admin
fabric-ca-client enroll -u http://admin:adminpw@localhost:8054 --csr.names $CSR_NAMES_ORG2
# Register intermediate CA in the root CA
fabric-ca-client register --id.name int.ca.org2.acme.org --id.secret password --id.attrs 'hf.IntermediateCA=true' -u http://admin:adminpw@localhost:8054
# Enroll bootstrap identity of tls root CA
export FABRIC_CA_CLIENT_HOME=../fabric-ca/org2.acme.org/tls-root/clients/admin
fabric-ca-client enroll -u http://admin:adminpw@localhost:8055 --csr.names $CSR_NAMES_ORG2
# Register intermediate CA in the tls root CA
fabric-ca-client register --id.name tls.int.ca.org2.acme.org --id.secret password --id.attrs 'hf.IntermediateCA=true' -u http://admin:adminpw@localhost:8055

# ORG 3
export CSR_NAMES_ORG2=C=MX,ST="Mexico City",L="Mexico City",O=Org3,OU="Hyperledger Fabric"
# Enroll bootstrap identity of root CA
export FABRIC_CA_CLIENT_HOME=../fabric-ca/org3.acme.org/root/clients/admin
fabric-ca-client enroll -u http://admin:adminpw@localhost:9054 --csr.names $CSR_NAMES_ORG3
# Register intermediate CA in the root CA
fabric-ca-client register --id.name int.ca.org3.acme.org --id.secret password --id.attrs 'hf.IntermediateCA=true' -u http://admin:adminpw@localhost:9054
# Enroll bootstrap identity of tls root CA
export FABRIC_CA_CLIENT_HOME=../fabric-ca/org3.acme.org/tls-root/clients/admin
fabric-ca-client enroll -u http://admin:adminpw@localhost:9055 --csr.names $CSR_NAMES_ORG3
# Register intermediate CA in the tls root CA
fabric-ca-client register --id.name tls.int.ca.org3.acme.org --id.secret password --id.attrs 'hf.IntermediateCA=true' -u http://admin:adminpw@localhost:9055

# ORG ACME
export CSR_NAMES_ACME=C=BE,ST="Flemish Brabant",L=Louvain,O=Acme,OU="Hyperledger Fabric"
# Enroll bootstrap identity of root CA
export FABRIC_CA_CLIENT_HOME=../fabric-ca/acme.org/root/clients/admin
fabric-ca-client enroll -u http://admin:adminpw@localhost:10054 --csr.names $CSR_NAMES_ACME
# Register intermediate CA in the root CA
fabric-ca-client register --id.name int.ca.acme.org --id.secret password --id.attrs 'hf.IntermediateCA=true' -u http://admin:adminpw@localhost:10054
# Enroll bootstrap identity of tls root CA
export FABRIC_CA_CLIENT_HOME=../fabric-ca/acme.org/tls-root/clients/admin
fabric-ca-client enroll -u http://admin:adminpw@localhost:10055 --csr.names $CSR_NAMES_ACME
# Register intermediate CA in the tls root CA
fabric-ca-client register --id.name tls.int.ca.acme.org --id.secret password --id.attrs 'hf.IntermediateCA=true' -u http://admin:adminpw@localhost:10055

# Spin up intermediate CA services
docker-compose -f ../docker-compose-int-ca.yaml up -d
