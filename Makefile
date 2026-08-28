.PHONY: up down restart logs ps status bootstrap client clean

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f --tail=200

ps:
	docker compose ps

status:
	./scripts/status.sh

bootstrap:
	./scripts/bootstrap.sh

client:
	docker compose exec clickhouse-01 clickhouse-client --port 9027

clean:
	docker compose down --volumes --remove-orphans
