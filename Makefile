.PHONY: up down

up:
	@echo "Создаю сети и запускаю контейнеры..."
	docker network create --driver=bridge monitoring-net || echo "Сеть monitoring-net уже существует"
	docker network create --driver=bridge nginx || echo "Сеть nginx уже существует"
	cd ./monitoring && docker compose up -d
	cd ./app && docker compose up -d
	@echo "Все контейнеры запущены!"

down:
	@echo "Останавливаю контейнеры и удаляю сети..."
	cd ./monitoring && docker compose down
	cd ./app && docker compose down
	docker network rm monitoring-net || echo "Сеть monitoring-net не найдена"
	docker network rm nginx || echo "Сеть nginx не найдена"
	@echo "Все контейнеры остановлены и сети удалены!"
