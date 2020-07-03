## init capi settings
cp yaml/_template/infrastructure-components-aws-template.yaml yaml/_install/4.infrastructure-components-aws.yaml

sed -i 's/${AWS_B64ENCODED_CREDENTIALS}/'${AWS_B64ENCODED_CREDENTIALS}'/g' yaml/_install/4.infrastructure-components-aws.yaml

echo ""
echo "== init information =="
echo "[system enviroments]"
echo "  AWS_B64ENCODED_CREDENTIALS:" $AWS_B64ENCODED_CREDENTIALS
