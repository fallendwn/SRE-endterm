

echo "=== Configuration Validation ==="
echo ""

ERRORS=0


echo ".env file"
if [ ! -f ".env" ]; then
    echo ".env file not found"
    ERRORS=$((ERRORS + 1))
else
    echo ".env file exists"
fi

echo ""
echo "environment variables"

ENDPOINT_VARS=(
    "FRONTEND_PORT"
    "CART_PORT"
    "CHECKOUT_PORT"
    "PRODUCTCATALOG_PORT"
    "GATEWAY_PORT"
)

for VAR in "${ENDPOINT_VARS[@]}"; do
    if grep -q "^${VAR}=" .env; then
        echo "$VAR is set"
    else
        echo "$VAR is missing"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "monitoring configs"

CONFIG_FILES=(
    "prometheus.yml"
    "alert_rules.yml"
    "promtail-config.yaml"
)

for FILE in "${CONFIG_FILES[@]}"; do
    if [ -f "$FILE" ]; then
        echo "$FILE exists"
    else
        echo "$FILE not found"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "Docker"
if docker info > /dev/null 2>&1; then
    echo "Docker is running"
else
    echo "Docker is not running"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "results"
if [ $ERRORS -eq 0 ]; then
    echo "All checks passed. Safe to deploy."
    exit 0
else
    echo "$ERRORS error(s) found. Fix before deploying."
    exit 1
fi