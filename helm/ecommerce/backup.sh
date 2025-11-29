#!/bin/bash

# ===========================
# Configuración
# ===========================
NAMESPACE="prod"
BACKUP_DIR="./backup"

# Lista de microservicios y label selector de cada pod de base de datos
declare -A DB_SELECTORS
DB_SELECTORS=(
  ["order-service"]="app=order-service-db"
  ["payment-service"]="app=payment-service-db"
  ["product-service"]="app=product-service-db"
  ["favourite-service"]="app=favourite-service-db"
  ["shipping-service"]="app=shipping-service-db"
  ["user-service"]="app=user-service-db"
)

# Base de datos correspondiente a cada microservicio
declare -A DB_NAMES
DB_NAMES=(
  ["order-service"]="order-service_db"
  ["payment-service"]="payment-service_db"
  ["product-service"]="product-service_db"
  ["favourite-service"]="favourite-service_db"
  ["shipping-service"]="shipping-service_db"
  ["user-service"]="user-service_db"
)

# Credenciales de MySQL
MYSQL_USER="user"
MYSQL_PASSWORD="12345"

# ===========================
# Funciones
# ===========================

# Obtener nombre del pod activo usando selector
function get_pod_name() {
  selector="$1"
  kubectl get pod -n "$NAMESPACE" -l "$selector" -o jsonpath='{.items[0].metadata.name}'
}

# Hacer backup de todos los microservicios
function backup_mysql() {
  echo "🚀 Iniciando backup de bases de datos MySQL..."
  mkdir -p "$BACKUP_DIR"

  for svc in "${!DB_SELECTORS[@]}"; do
    selector="${DB_SELECTORS[$svc]}"
    pod=$(get_pod_name "$selector")
    db_name="${DB_NAMES[$svc]}"

    if [ -z "$pod" ]; then
      echo "❌ No se encontró pod activo para $svc con selector $selector"
      continue
    fi

    echo "📦 Backup de $svc (base: $db_name) desde el pod $pod..."
    mkdir -p "$BACKUP_DIR/$svc"
    BACKUP_FILE="$BACKUP_DIR/$svc/${svc}_$(date +%F_%H%M%S).sql.gz"

    kubectl exec -i -n "$NAMESPACE" "$pod" -- mysqldump --single-transaction --no-tablespaces -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$db_name" | gzip > "$BACKUP_FILE"

    if [ $? -eq 0 ]; then
      echo "✅ Backup de $svc completado: $BACKUP_FILE"
    else
      echo "❌ Error haciendo backup de $svc"
    fi
  done
}

function restore_mysql() {
  echo "🔄 Iniciando restauración de bases de datos MySQL..."

  for svc in "${!DB_SELECTORS[@]}"; do
    selector="${DB_SELECTORS[$svc]}"
    pod=$(get_pod_name "$selector")
    db_name="${DB_NAMES[$svc]}"

    # Usamos el último backup disponible
    BACKUP_FILE=$(ls -1t "$BACKUP_DIR/$svc/"*.sql.gz 2>/dev/null | head -n1)

    if [ -z "$BACKUP_FILE" ]; then
      echo "No se encontró backup para $svc"
      continue
    fi

    if [ -z "$pod" ]; then
      echo "No se encontró pod activo para $svc con selector $selector"
      continue
    fi

    echo "Restaurando $svc (base: $db_name) desde $BACKUP_FILE al pod $pod..."
    gunzip < "$BACKUP_FILE" | kubectl exec -i -n "$NAMESPACE" "$pod" -- mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$db_name"

    if [ $? -eq 0 ]; then
      echo "Restauración de $svc completada."
    else
      echo "Error restaurando $svc"
    fi
  done
}

# ===========================
# Menú
# ===========================
echo "Seleccione una opción:"
echo "1) Backup de todas las bases de datos MySQL"
echo "2) Restaurar todas las bases de datos MySQL desde el backup"
read -p "Opción: " OPTION

case "$OPTION" in
  1)
    backup_mysql
    ;;
  2)
    restore_mysql
    ;;
  *)
    echo "Opción inválida"
    ;;
esac
