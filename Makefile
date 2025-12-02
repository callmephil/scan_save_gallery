.PHONY: help fix analyze gen quality tr-extractor tr-insert

# Define help target
help: ## Show this help message
	@echo "Usage: make <target>"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z0-9_ -]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

fix: ## -> Run dart format and dart fix
	@echo "Running dart format..."
	@find lib -name "*.dart" ! -name "*.g.dart" ! -name "*.freezed.dart" ! -name "*.gr.dart" | xargs dart format
	@echo "Running dart fix..."
	@dart fix --apply
	@echo "Code formatting and fixes applied."
	@echo "Running dcm fix..."
	@dcm fix lib
	@echo "DCM fixes applied."

slang:
	@echo "Running slang for i18n..."
	@dart run slang
	@echo "Slang i18n generation completed."

analyze: ## -> Run DCM and Flutter Analyzer
	make fix
	@echo "Running Dart Analyzer..."
	dart analyze lib
	@echo "Running DCM Analyzer..."
	dcm analyze ./lib
	@echo "Analysis completed."

quality: ## -> Run all DCM quality checks
	@echo "Running DCM quality checks..."
	@echo "Analyzing Assets"
	@dcm analyze-assets ./assets
# 	@echo "Analyzing Structure"
# 	@dcm analyze-structure ./lib
	@echo "Analyzing Widgets"
	@dcm analyze-widgets ./lib
	@echo "Calculating Metrics"
	@dcm calculate-metrics  ./lib
	@echo "Checking Code Style"
	@dcm check-code-duplication  ./lib
	@echo "Checking Documentation"
	@dcm check-dependencies ./lib
	@echo "Checking Exports"
	@dcm check-exports-completeness ./lib
	@echo "Checking Parameters and Unused Code/Files"
	@dcm check-parameters --exclude="{**/*.g.dart,**/*.freezed.dart,**/*.mapper.dart}" ./lib 
	@echo "Checking for Unused Code, Files, and Localization"
	@dcm check-unused-code ./lib
	@echo "Checking for Unused Files"
	@dcm check-unused-files ./lib
	@echo "Checking for Deprecated Code"
	@echo "All DCM quality checks completed."

gen: ## -> Run code generation
	@echo "Running build runner..."
	@dart run build_runner build --delete-conflicting-outputs
	@echo "Running slang for i18n..."
	@dart run slang
	@echo "Code generation completed."