.PHONY: validate fmt fmt-check tf-validate lint

# Run the same checks CI runs.
validate: fmt-check tf-validate lint

fmt:
	terraform fmt -recursive

fmt-check:
	terraform fmt -check -recursive

tf-validate:
	terraform -chdir=terraform init -backend=false
	terraform -chdir=terraform validate

lint:
	tflint --init
	tflint --recursive
