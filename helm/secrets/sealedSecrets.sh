#!/bin/bash

# ================================================
# CONFIGURACIÓN
# ================================================
MICROS=("user-service" "product-service" "order-service" "payment-service" "favourite-service" "shipping-service")
ENVIRONMENTS=("qa" "prod")

# Ruta donde quedarán los SealedSecrets
BASE_DIR="secrets/sealedsecrets"

# Archivo temporal para crear Secret en texto plano
TMP_SECRET="tmp-secret.yaml"

# ================================================
# CREAR CARPETAS POR AMBIENTE
# ================================================
echo "Creando estructura de carpetas..."
for ENV in "${ENVIRONMENTS[@]}"; do
  mkdir -p "$BASE_DIR/$ENV"
done

# ================================================
# GENERAR SEALED SECRETS
# ================================================
echo "Generando SealedSecrets por micro por ambiente..."

for MICRO in "${MICROS[@]}"; do
  for ENV in "${ENVIRONMENTS[@]}"; do

    SECRET_NAME="${MICRO}-db-credentials"
    OUTPUT_FILE="$BASE_DIR/$ENV/${MICRO}-db.yaml"

    echo "➡️  $MICRO ($ENV)"

cat > "$TMP_SECRET" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $SECRET_NAME
  namespace: $ENV
type: Opaque
stringData:
  DB_USER: "user"
  DB_PASSWORD: "12345"
EOF

    kubeseal \
      --format yaml \
      --cert secrets/mycert.pem \
      --namespace "$ENV" \
      --name "$SECRET_NAME" \
      < "$TMP_SECRET" \
      > "$OUTPUT_FILE"

    echo "   ✔ Guardado en: $OUTPUT_FILE"

  done
done

# Limpieza
rm "$TMP_SECRET"

echo ""
echo "🎉 SealedSecrets generados correctamente."
echo "📁 Carpeta final: $BASE_DIR"
