.PHONY: up down enc

up:
	@echo "Создаю сети и запускаю контейнеры..."
	docker network create --driver=bridge monitoring-net || echo "Сеть monitoring-net уже существует"
	docker network create --driver=bridge nginx || echo "Сеть nginx уже существует"
	cd ./monitoring && docker compose up -d
	cd ./app && docker compose up -d
	@echo "Все контейнеры запущены!"

down:
	@echo "Останавливаю контейнеры и удаляю сети..."
	cd ./monitoring && docker compose down -v
	cd ./app && docker compose down -v
	docker network rm monitoring-net || echo "Сеть monitoring-net не найдена"
	docker network rm nginx || echo "Сеть nginx не найдена"
	@echo "Все контейнеры остановлены и сети удалены!"

enc:
	docker run --rm -d --name ansible cytopia/ansible sleep infinity
	docker cp ./app/.env ansible:/data/app.env
	docker cp ./monitoring/.env ansible:/data/monitoring.env
	docker cp ./.key ansible:/data/.key
	docker exec -it ansible sh -c "ansible-vault encrypt app.env --vault-password-file .key"
	docker exec -it ansible sh -c "ansible-vault encrypt monitoring.env --vault-password-file .key"
	docker cp ansible:/data/app.env ./app/.env-crypt
	docker cp ansible:/data/monitoring.env ./monitoring/.env-crypt
	rm ./app/.env
	rm ./monitoring/.env
	docker kill ansible

dec:
	docker run --rm -d --name ansible cytopia/ansible sleep infinity
	docker cp ./app/.env-crypt ansible:/data/app.env
	docker cp ./monitoring/.env-crypt ansible:/data/monitoring.env
	docker cp ./.key ansible:/data/.key
	docker exec -it ansible sh -c "ansible-vault decrypt app.env --vault-password-file .key"
	docker exec -it ansible sh -c "ansible-vault decrypt monitoring.env --vault-password-file .key"
	docker cp ansible:/data/app.env ./app/.env
	docker cp ansible:/data/monitoring.env ./monitoring/.env
	rm ./app/.env-crypt
	rm ./monitoring/.env-crypt
	docker kill ansible