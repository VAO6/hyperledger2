# Caliper

## Prerrequisitos

Se requieren las siguientes herramientas para instalar el CLI desde NPM:

* node-gyp, python2, make, g ++ y git (para buscar y compilar algunos paquetes durante la instalación)
* Node.js v8.X LTS o v10.X LTS

## Instalación del Caliper CLI localmente con npm

```sh
npm init -y
npm install --only=prod @hyperledger/caliper-cli@0.4.0-unstable-20200918090458
```

## Lanzar Caliper master

```sh
npx caliper launch master \
    --caliper-bind-sut fabric:2.2.0 \
    --caliper-workspace . \
    --caliper-benchconfig benchmarks/scenario/currency-lifecycle/config.yaml \
    --caliper-networkconfig networks/acme-network-local.yaml \
    --caliper-flow-only-test \
    --caliper-fabric-gateway-usegateway \
     --caliper-fabric-gateway-discovery
```
