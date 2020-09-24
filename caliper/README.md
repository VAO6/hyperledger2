# Caliper

En esta carpeta pueden encontrar unas configuraciones y codigo de un benchmark para empezar a trabajar con Caliper.

## Prerrequisitos

Se requieren las siguientes herramientas para instalar el CLI desde NPM:

* node-gyp, python2, make, g ++ y git (para buscar y compilar algunos paquetes durante la instalación)
* Node.js v8.X LTS o v10.X LTS

## Instalación del Caliper CLI localmente con npm

```sh
npm init -y
npm install --only=prod @hyperledger/caliper-cli@0.3.2
npx caliper bind --caliper-bind-sut fabric:latest-v2 --caliper-bind-sdk latest-v2 --caliper-fabric-gateway-usegateway --caliper-flow-only-test
```

## Lanzar Caliper master

```sh
npx caliper launch master \
    --caliper-workspace . \
    --caliper-benchconfig benchmarks/scenario/currency-lifecycle/config.yaml \
    --caliper-networkconfig networks/acme-network-local.yaml \
    --caliper-flow-only-test \
    --caliper-fabric-gateway-usegateway \
     --caliper-fabric-gateway-discovery
```
