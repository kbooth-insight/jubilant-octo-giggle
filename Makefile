
build :
	@./build.sh

prepare :
	@terraform init
	@terraform plan \
		-lock=true \
		-input=false \
		-refresh=true \
		-var-file="terraform.tfvars"

deploy :
	@terraform apply \
		-lock=true \
		-input=false \
		-refresh=true \
		-var-file="terraform.tfvars"
