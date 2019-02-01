
build :
	@./build.sh
	@terraform init

plan :
	@terraform plan \
		-lock=true \
		-input=false \
		-refresh=true \
		-var-file="terraform.tfvars"

deploy : plan
	@terraform apply \
		-lock=true \
		-input=false \
		-refresh=true \
		-var-file="terraform.tfvars"
