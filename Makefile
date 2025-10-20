    .PHONY: run test lint docker-build docker-run

    run:
	uvicorn app.main:app --reload --host 0.0.0.0 --port $${APP_PORT:-8000}

    test:
	pytest -q

    lint:
	pre-commit run --all-files

    docker-build:
	docker build -t myservice:dev .

    docker-run:
	docker run --env-file .env -p 8000:8000 myservice:dev
