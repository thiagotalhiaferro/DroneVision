# DroneVision
Aplicação web de análise de imagens utilizando Azure AI Vision

# DroneVision — Análise Inteligente de Imagens

## 1. Sobre o projeto

O **DroneVision** é uma aplicação web desenvolvida como projeto acadêmico da Global Solution, com o objetivo de realizar análises inteligentes de imagens utilizando serviços de Inteligência Artificial da Microsoft Azure.

A solução permite que o usuário envie uma imagem pela interface web e receba automaticamente informações identificadas pelo serviço Azure AI Vision.

## 2. Objetivo

Demonstrar a aplicação de recursos de visão computacional em uma solução hospedada em nuvem, permitindo a identificação de elementos visuais e a geração de descrições automáticas de imagens.

## 3. Tecnologias utilizadas

- **Python 3.12:** linguagem de programação.
- **Flask:** framework para desenvolvimento da aplicação web.
- **Azure AI Vision:** serviço de inteligência artificial para análise de imagens.
- **Azure App Service:** hospedagem da aplicação na nuvem.
- **Gunicorn:** servidor de aplicação Python.
- **HTML5 e CSS3:** estrutura e estilização da interface.
- **GitHub:** versionamento e armazenamento do código-fonte.

## 4. Funcionalidades

- Envio de imagens nos formatos JPG, PNG, GIF e BMP.
- Limite de upload de 5 MB.
- Geração automática de descrição da imagem.
- Identificação de etiquetas (tags) relacionadas ao conteúdo visual.
- Identificação de objetos reconhecidos pelo serviço.
- Tratamento de erros durante o envio e processamento das imagens.

## 5. Arquitetura da solução

1. O usuário acessa a aplicação web.
2. Seleciona e envia uma imagem.
3. A aplicação recebe o arquivo.
4. A imagem é encaminhada ao Azure AI Vision por meio de uma requisição HTTP.
5. O serviço processa a imagem e retorna os resultados.
6. A aplicação apresenta a descrição, as etiquetas e os objetos identificados.

## 6. Recursos provisionados no Azure

| Recurso | Configuração |
|---|---|
| Grupo de recursos | Azure Resource Group |
| Serviço de visão computacional | Azure AI Vision |
| Região do Azure AI Vision | East US |
| SKU Azure AI Vision | F0 |
| Plano de hospedagem | Azure App Service Plan |
| Plano App Service | F1 — Linux |
| Aplicação web | Azure Web App |
| Runtime | Python 3.12 |

## 7. Estrutura do repositório

```text
DroneVision/
├── app.py
├── requirements.txt
├── implantar-rm93361.sh
├── README.md
├── templates/
│   └── index.html
└── static/
    └── style.css
```

## 8. Acesso à aplicação

A aplicação foi publicada utilizando o Azure App Service.

O endereço de acesso está disponível no ambiente de implantação.

## 9. Configuração e execução local

Para executar o projeto localmente, é necessário possuir Python 3.12 e as credenciais de um recurso Azure AI Vision.

Instale as dependências:

```bash
pip install -r requirements.txt
```

Configure as variáveis de ambiente:

```bash
export VISION_ENDPOINT="ENDPOINT_DO_AZURE"
export VISION_KEY="CHAVE_DO_AZURE"
```

No Windows PowerShell:

```powershell
$env:VISION_ENDPOINT="ENDPOINT_DO_AZURE"
$env:VISION_KEY="CHAVE_DO_AZURE"
```

Execute a aplicação:

```bash
python app.py
```

Acesse pelo navegador:

```text
http://127.0.0.1:5000
```

## 10. Considerações finais

O DroneVision demonstra a integração entre desenvolvimento web, inteligência artificial e computação em nuvem, utilizando serviços da Microsoft Azure para disponibilizar uma aplicação funcional de análise automatizada de imagens.
