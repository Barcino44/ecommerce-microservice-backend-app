#!/bin/bash

echo "🔨 Compilar y Buildear Docker images para todos los servicios (v1.1.1)"
echo "===================================================================="

# 1. Compilar todos los servicios
echo ""
echo "📦 PASO 1: Compilando todos los servicios con Maven..."
echo "======================================================"

cd ~/ecommerce-microservice-backend-app

mvn clean package -DskipTests -q

if [ $? -eq 0 ]; then
  echo "✅ Compilación exitosa"
else
  echo "❌ Error en compilación"
  exit 1
fi

# 2. Configurar Minikube Docker
echo ""
echo "🐳 PASO 2: Configurando Minikube Docker..."
echo "=========================================="

eval $(minikube docker-env)
echo "✅ Minikube Docker configurado"

# 3. Buildear imágenes Docker
echo ""
echo "🔨 PASO 3: Buildear imágenes Docker..."
echo "======================================"

SERVICES=(
  "api-gateway"
  "order-service"
  "payment-service"
  "product-service"
  "favourite-service"
  "shipping-service"
  "user-service"
  "service-discovery"
  "cloud-config"
  "proxy-client"
)

for service in "${SERVICES[@]}"; do
  echo ""
  echo "📦 Building $service:1.1.1..."
  
  if [ -d "$service" ]; then
    docker build -t barcino/$service:1.1.1 $service/
    
    if [ $? -eq 0 ]; then
      echo "✅ $service:1.1.1 buildado exitosamente"
    else
      echo "❌ Error buildando $service"
    fi
  else
    echo "⚠️  Carpeta no encontrada: $service"
  fi
done

# 4. Verificar imágenes creadas
echo ""
echo "📋 PASO 4: Imágenes creadas:"
echo "============================"

docker images | grep "barcino" | grep "1.1.1"

echo ""
echo "===================================================================="
echo "✅ Todos los builds completados"
echo ""
echo "Próximos pasos:"
echo "1. Actualizar values.yaml con tag: 1.1.1"
echo "2. helm upgrade my-ecommerce ./helm/ecommerce -n dev"
echo "3. kubectl delete pods -n dev --all"
echo "4. Verificar logs"
