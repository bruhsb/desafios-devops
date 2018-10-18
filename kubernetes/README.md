# Desafio 02: Kubernetes

## Motivação

Kubernetes atualmente é a principal ferramenta de orquestração e _deployment_ de _containers_ utilizado no mundo, práticamente tornando-se um padrão para abstração de recursos de infraestrutura.

Na IDWall todos nossos serviços são containerizados e distribuídos em _clusters_ para cada ambiente, sendo assim é importante que as aplicações sejam adaptáveis para cada ambiente e haja controle via código dos recursos kubernetes através de seus manifestos.

## Objetivo
Dentro deste repositório existe um subdiretório **app** e um **Dockerfile** que constrói essa imagem, seu objetivo é:

- Construir a imagem docker da aplicação
- Criar os manifestos de recursos kubernetes para rodar a aplicação (_deployments, services, ingresses, configmap_ e qualquer outro que você considere necessário)
- Criar um _script_ para a execução do _deploy_ em uma única execução.
- A aplicação deve ter seu _deploy_ realizado com uma única linha de comando em um cluster kubernetes **local**
- Todos os _pods_ devem estar rodando
- A aplicação deve responder à uma URL específica configurada no _ingress_


## Extras
- Utilizar Helm [HELM](https://helm.sh)
- Divisão de recursos por _namespaces_
- Utilização de _health check_ na aplicação
- Fazer com que a aplicação exiba seu nome ao invés de **"Olá, candidato!"**

## Notas

* Pode se utilizar o [Minikube](https://github.com/kubernetes/minikube) ou [Docker for Mac/Windows](https://docs.docker.com/docker-for-mac/) para execução do desafio e realização de testes.

* A aplicação sobe por _default_ utilizando a porta **3000** e utiliza uma variável de ambiente **$NAME**

* Não é necessário realizar o _upload_ da imagem Docker para um registro público, você pode construir a imagem localmente e utilizá-la diretamente.


# Resolução do Desafio

Abaixo segue a documentação quanto a Resolução do desafio proposto.

## Arquivos & Diretórios

* helm/ - Contém o Chart para uso com o Helm
* k8s/  - Contém os manifestos (./*.yaml) para implementação diretamente com o Kubernetes

## Pré Requisitos

* Docker 1.13.1
* Kubernetes +1.10
  - kubectl +1.10
  - minikube v0.30.0

* Helm v2.9.1

## Instalação

### Build da Imagem Localmente

> Presupondo que já exista o serviço instalado e ativo do Docker

O processo de build da imagem normalmente é feito para um registy local. Nesse caso, como foi a solução será implantada no Minikube, é necessário criar usando o mesmo host do Docker que a máquina virtual Minikube utiliza. Para que isso aconteça, é necessário utilizar o daemon do Docker do Minikube. Também é importante lembrar que o minikube não vem com o recurso de Ingress habilitado por _default_, sendo necessária a ativação.

Basta executar o comamndo abaixo para configurar o docker e o minikube:

```bash
eval $(minikube docker-env) && minikube addons enable ingress
```

É possível validar executando o comando abaixo, ele deve retornar a lista de imagem que o Minikube utilizou para a criação do cluster.

```bash
minikube ssh docker images
```

Execute a linha de comando abaixo, dentro do diretório desse desafio, para realizar o build da imagem:

```bash
docker build -t node-app:0.2 .
```
> Esse comando pode tomar alguns minutos para terminar

### Implementação Diretamente pelo Kubernetes

> Presupondo que já exista um cluster kubernetes instalado e configurado localmente.
> Testado em um cluster construido seguindo as orientações dessa fonte: [Running Kubernetes Locally via Minikube](https://kubernetes.io/docs/setup/minikube/)

Execute a linha de comando abaixo, dentro do diretório desse desafio, para fazer o Deploy da Aplicação no Cluster do k8s:

```bash
kubectl -n desafio-devops create -Rf ./k8s
```
Aguarde cerca de 5 minutos para que o Ingress disponibilize um IP.
A aplicação responde a um DNS específico (**app-node.meusite.com.br**). Utilizando o comando abaixo é possível configurar o acesso da aplicação no DNS local.

```bash
sudo echo "$(kubectl -n desafio-devops get ing -o jsonpath='{.items[*].spec.rules[0].host}') $(kubectl -n desafio-devops get ing -o jsonpath='{.items[*].status.loadBalancer.ingress[0].ip}')" >> /etc/hosts
```

A aplicação pode ser acessada pelo comando abaixo:

```bash
curl $(kubectl -n desafio-devops get ing -o jsonpath='{.items[*].spec.rules[0].host}')
```

#### Desinstalação

Basta execultar o comando abaixo, que todos os recursos serão desalocados:

```bash
kubectl delete ns desafio-devops
```

### Implementação pelo Chart Helm

> Presupondo que o helm já está instalado.
> Presupondo que já exista um cluster kubernetes instalado e configurado localmente.

Para fazer a instalação pelo Helm, basta executar o comando abaixo no diretório desse desafio:

```bash
helm init && helm install --namespace desafio-devops --name proj ./helm/app-desafio-devops
```

Feito isso a aplicação será entregue em alguns segundos. Será exibido em tela orientações de comando para conseguir o IP e a URL da aplicação.

#### Desinstalação

Basta execultar o comando abaixo, que todos os recursos serão desalocados:

```bash
helm delete --purge proj
```

## Configuração do Chart

É possível configurar a aplicação editando as variaveis abaixo, no arquivo _values.yaml_

| Parametro                 | Definição                                              | _default_               |
| ------------------------- | ------------------------------------------------------ | ----------------------- |
| replicaCount              | Quantidades de Replicas da aplicação                   | 3                       |
| namespace                 | Define em qual namespace a aplicação sera implementada | desafio-devops          |
| image.repository          | Indica o caminho da Imagem a ser utilizada             | node-app                |
| image.tag                 | Tag da imagem                                          | 0.2                     |
| image.pullPolicy          | Comportamento quanto ao Pull da Aplicação              | Never*                  |
| env.NAME                  | Modifica a variavel de ambiente NAME                   | Bruno                   |
| resources.limits.cpu      | limite de uso da cpu                                   | 100m                    |
| resources.limits.memory   | limite de uso da memória RAM                           | 128Mi                   |
| resources.requests.cpu    | indica o quanto de CPU a aplicação requer              | 100m                    |
| resources.requests.memory | indica o quanto de memória a aplicação requer          | 128Mi                   |
| ports.name                | nome da porta do containerPort                         | nodejs                  |
| ports.containerPort       | número da porta do container                           | 3000                    |
| ports.protocol            | protocolo de rede a ser utilizado                      | TCP                     |
| service.type              | tipo de serviço **                                     | NodePort                |
| service.port              | porta do service                                       | 3000                    |
| ingress.namePort          | nome da porta do container                             | nodejs                  |
| ingress.hosts             | URL da Aplicação                                       | app-node.meusite.com.br |
