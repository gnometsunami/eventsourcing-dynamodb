.EXPORT_ALL_VARIABLES:

POETRY_VERSION = 1.6.1
POETRY ?= poetry
POETRY_INSTALLER_URL ?= https://install.python-poetry.org
AWS_ACCESS_KEY_ID ?= AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY ?= wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_DEFAULT_REGION ?= us-east-1

-include $(DOTENV_BASE_FILE)
-include $(DOTENV_LOCAL_FILE)

.PHONY: install-poetry
install-poetry:
	curl -sSL $(POETRY_INSTALLER_URL) | python3
	$(POETRY) --version

.PHONY: install-packages
install-packages:
	$(POETRY) install -vv $(opts)

.PHONY: lock-packages
lock-packages:
	$(POETRY) lock -vv --no-update

.PHONY: update-packages
update-packages:
	$(POETRY) update -vv

.PHONY: lint-black
lint-black:
	$(POETRY) run black --check --diff .

.PHONY: lint-flake8
lint-flake8:
	$(POETRY) run flake8

.PHONY: lint-isort
lint-isort:
	$(POETRY) run isort --check-only --diff .

.PHONY: lint-mypy
lint-mypy:
	$(POETRY) run mypy

.PHONY: lint-python
lint-python: lint-black lint-flake8 lint-isort lint-mypy

.PHONY: lint
lint: lint-python

.PHONY: fmt-black
fmt-black:
	$(POETRY) run black .

.PHONY: fmt-isort
fmt-isort:
	$(POETRY) run isort .

.PHONY: fmt
fmt: fmt-black fmt-isort

.PHONY: test
test:
	$(POETRY) run python -m pytest $(opts) $(call tests,.)

.PHONY: build
build:
	$(POETRY) build

.PHONY: publish
publish:
	$(POETRY) publish

.PHONY: docker-up
docker-up:
	docker compose -f docker/docker-compose.yaml up -d
	docker compose -f docker/docker-compose.yaml ps

.PHONY: docker-down
docker-down:
	docker compose -f docker/docker-compose.yaml stop

.PHONY: docker-logs
docker-logs:
	docker compose -f docker/docker-compose.yaml logs --follow

.PHONY: docker-ps
docker-ps:
	docker compose -f docker/docker-compose.yaml ps

.PHONY: create-table
create-table:
	aws dynamodb create-table \
              --endpoint-url http://localhost:8000 \
              --table-name dynamo_events \
              --attribute-definitions \
                  AttributeName=originator_id,AttributeType=S \
                  AttributeName=originator_version,AttributeType=N \
              --key-schema AttributeName=originator_id,KeyType=HASH AttributeName=originator_version,KeyType=RANGE \
              --billing-mode PAY_PER_REQUEST \
#              --no-cli-pager
