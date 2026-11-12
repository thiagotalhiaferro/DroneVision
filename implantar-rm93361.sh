
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

# Criar ou reutilizar o grupo de recursos
az group create \
  --name "$RG" \
  --location "brazilsouth" \
  --tags Projeto=DroneVision RM=93361 \
  --output none

# Validar serviço Azure AI Vision existente
az cognitiveservices account show \
  --name "$VISION" \
  --resource-group "$RG" \
  --output none

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

# Criar plano do App Service
az appservice plan create \
  --name "$PLAN" \
  --resource-group "$RG" \
  --location "$REGIAO_APP" \
  --sku F1 \
  --is-linux \
  --tags Projeto=DroneVision RM=93361 \
  --output none

# Criar aplicação Web
az webapp create \
  --name "$APP" \
  --resource-group "$RG" \
  --plan "$PLAN" \
  --runtime "PYTHON|3.12" \
  --tags Projeto=DroneVision RM=93361 \
  --output none

# Configurar variáveis de ambiente
az webapp config appsettings set \
  --name "$APP" \
  --resource-group "$RG" \
  --settings \
    VISION_ENDPOINT="$ENDPOINT" \
    VISION_KEY="$KEY" \
    SCM_DO_BUILD_DURING_DEPLOYMENT=true \
    WEBSITES_PORT=8000 \
  --output none

# Configurar inicialização da aplicação
az webapp config set \
  --name "$APP" \
  --resource-group "$RG" \
  --startup-file "gunicorn --bind=0.0.0.0:8000 app:app" \
  --output none

# Compactar arquivos da aplicação
echo "Compactando arquivos..."
zip -r dronevision.zip app.py requirements.txt templates static

# Enviar aplicação ao Azure
echo "Enviando aplicação ao Azure..."
az webapp deploy \
  --name "$APP" \
  --resource-group "$RG" \
  --src-path dronevision.zip \
  --type zip

echo "DEPLOY CONCLUIDO!"
echo "Acesse: https://app-dronevision-rm93361.azurewebsites.net"
