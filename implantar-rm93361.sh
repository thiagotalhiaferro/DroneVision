#!/bin/bash

set -e

# Identificação dos recursos
RG="rg-dronevision-rm93361"
VISION="aiv-dronevision-rm93361"
PLAN="plan-dronevision-rm93361"
APP="app-dronevision-rm93361"

REGIAO_APP="eastus"
REGIAO_VISION="eastus"

echo "Iniciando implantação do DroneVision..."

# 1. Criar ou reutilizar o Resource Group
if ! az group show --name "$RG" --output none 2>/dev/null; then
    echo "Criando Resource Group..."
    az group create \
        --name "$RG" \
        --location "brazilsouth" \
        --tags Projeto=DroneVision RM=93361 \
        --output none
else
    echo "Resource Group já existe."
fi

# 2. Criar ou reutilizar o Azure AI Vision
if ! az cognitiveservices account show \
    --name "$VISION" \
    --resource-group "$RG" \
    --output none 2>/dev/null; then

    echo "Criando Azure AI Vision..."
    az cognitiveservices account create \
        --name "$VISION" \
        --resource-group "$RG" \
        --kind ComputerVision \
        --sku F0 \
        --location "$REGIAO_VISION" \
        --yes \
        --output none
else
    echo "Azure AI Vision já existe. Reutilizando recurso."
fi

# Obter endpoint e chave do Azure AI Vision
ENDPOINT=$(az cognitiveservices account show \
    --name "$VISION" \
    --resource-group "$RG" \
    --query properties.endpoint \
    --output tsv)

KEY=$(az cognitiveservices account keys list \
    --name "$VISION" \
    --resource-group "$RG" \
    --query key1 \
    --output tsv)

# 3. Criar ou reutilizar o App Service Plan
if ! az appservice plan show \
    --name "$PLAN" \
    --resource-group "$RG" \
    --output none 2>/dev/null; then

    echo "Criando App Service Plan..."
    az appservice plan create \
        --name "$PLAN" \
        --resource-group "$RG" \
        --location "$REGIAO_APP" \
        --sku F1 \
        --is-linux \
        --tags Projeto=DroneVision RM=93361 \
        --output none
else
    echo "App Service Plan já existe."
fi

# 4. Criar ou reutilizar o Web App
if ! az webapp show \
    --name "$APP" \
    --resource-group "$RG" \
    --output none 2>/dev/null; then

    echo "Criando Web App..."
    az webapp create \
        --name "$APP" \
        --resource-group "$RG" \
        --plan "$PLAN" \
        --runtime "PYTHON|3.12" \
        --tags Projeto=DroneVision RM=93361 \
        --output none
else
    echo "Web App já existe."
fi

# 5. Configurar variáveis de ambiente
az webapp config appsettings set \
    --name "$APP" \
    --resource-group "$RG" \
    --settings \
        VISION_ENDPOINT="$ENDPOINT" \
        VISION_KEY="$KEY" \
        SCM_DO_BUILD_DURING_DEPLOYMENT=true \
        WEBSITES_PORT=8000 \
    --output none

# 6. Configurar inicialização da aplicação
az webapp config set \
    --name "$APP" \
    --resource-group "$RG" \
    --startup-file "gunicorn --bind=0.0.0.0:8000 app:app" \
    --output none

# 7. Compactar arquivos da aplicação
echo "Compactando arquivos..."
rm -f dronevision.zip
zip -r dronevision.zip app.py requirements.txt templates static

# 8. Publicar aplicação pelo Azure CLI
echo "Enviando aplicação ao Azure..."
az webapp deploy \
    --name "$APP" \
    --resource-group "$RG" \
    --src-path dronevision.zip \
    --type zip

echo "DEPLOY CONCLUIDO!"
echo "Acesse: https://app-dronevision-rm93361.azurewebsites.net"
