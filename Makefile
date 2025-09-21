NAME = inception

COMPOSE_FILE = ./srcs/docker-compose.yml

DATA_DIR = /home/$(USER)/data
WP_DATA = $(DATA_DIR)/wordpress
DB_DATA = $(DATA_DIR)/mariadb
REDIS_DATA = $(DATA_DIR)/redis
SECRETS_DIR = ./secrets

GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
BLUE = \033[0;34m
NC = \033[0m

all: up

up: setup start
	@echo "$(GREEN)✅ All services are up and running!$(NC)"

secrets:
	@echo "$(BLUE)🔐 Generating secrets...$(NC)"
	@mkdir -p $(SECRETS_DIR)
	@if [ ! -f "$(SECRETS_DIR)/db_root_password.txt" ]; then \
		openssl rand -base64 32 | tr -d "=+/" | cut -c1-25 > $(SECRETS_DIR)/db_root_password.txt; \
		echo "$(GREEN)✅ Generated db_root_password.txt$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  db_root_password.txt already exists$(NC)"; \
	fi
	@if [ ! -f "$(SECRETS_DIR)/db_password.txt" ]; then \
		openssl rand -base64 32 | tr -d "=+/" | cut -c1-25 > $(SECRETS_DIR)/db_password.txt; \
		echo "$(GREEN)✅ Generated db_password.txt$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  db_password.txt already exists$(NC)"; \
	fi

setup: secrets
	@echo "$(BLUE)📁 Setting up data directories...$(NC)"
	@mkdir -p $(WP_DATA)
	@mkdir -p $(DB_DATA)
	@mkdir -p $(REDIS_DATA)
	@echo "$(GREEN)✅ Data directories created successfully$(NC)"

build:
	@echo "$(BLUE)🔨 Building Docker images...$(NC)"
	@docker compose -f $(COMPOSE_FILE) build
	@echo "$(GREEN)✅ Docker images built successfully$(NC)"

start:
	@echo "$(BLUE)🚀 Starting services...$(NC)"
	@docker compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✅ Services started successfully$(NC)"

down:
	@echo "$(YELLOW)⏹️  Stopping and removing containers...$(NC)"
	@docker compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✅ Containers stopped and removed$(NC)"

clean: down
	@echo "$(YELLOW)🧹 Cleaning up containers and project images...$(NC)"
	@docker compose -f $(COMPOSE_FILE) down --rmi all 2>/dev/null || true
	@docker image prune -f
	@echo "$(GREEN)✅ Cleanup completed$(NC)"

fclean: down
	@echo "$(RED)🗑️  Performing complete cleanup...$(NC)"
	@docker compose -f $(COMPOSE_FILE) down -v --rmi all --remove-orphans 2>/dev/null || true
	@docker system prune -f 2>/dev/null || true
	@echo "$(YELLOW)🗑️  Removing data directories...$(NC)"
	@if [ -d "$(DATA_DIR)" ]; then \
		docker run --rm -v $(DATA_DIR):/data alpine:3.21 sh -c "rm -rf /data/*" 2>/dev/null || true; \
		rmdir $(DATA_DIR) 2>/dev/null || true; \
	fi
	@echo "$(GREEN)✅ Complete cleanup finished$(NC)"

re: clean up
	@echo "$(GREEN)🔄 Rebuild completed!$(NC)"

logs:
	@echo "$(BLUE)📋 Showing container logs...$(NC)"
	@docker compose -f $(COMPOSE_FILE) logs

status:
	@echo "$(BLUE)📊 Container status:$(NC)"
	@docker compose -f $(COMPOSE_FILE) ps

stop:
	@echo "$(YELLOW)⏸️  Stopping services...$(NC)"
	@docker compose -f $(COMPOSE_FILE) stop
	@echo "$(GREEN)✅ Services stopped$(NC)"

restart: stop start
	@echo "$(GREEN)🔄 Services restarted!$(NC)"

images:
	@echo "$(BLUE)🖼️  Project images:$(NC)"
	@docker images | grep -E "(inception_|IMAGE)" || echo "$(YELLOW)No project images found$(NC)"

volumes:
	@echo "$(BLUE)💾 Project volumes:$(NC)"
	@docker volume ls | grep -E "(inception_|srcs_|DRIVER)" || echo "$(YELLOW)No project volumes found$(NC)"

networks:
	@echo "$(BLUE)🌐 Project networks:$(NC)"
	@docker network ls | grep -E "(inception|srcs_|NETWORK)" || echo "$(YELLOW)No project networks found$(NC)"

fix-perm:
	@echo "$(BLUE)🔧 Fixing data directory permissions...$(NC)"
	@if [ -d "$(DATA_DIR)" ]; then \
		docker run --rm -v $(DATA_DIR):/data alpine sh -c "chown -R $(shell id -u):$(shell id -g) /data"; \
		echo "$(GREEN)✅ Permissions fixed$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Data directory doesn't exist$(NC)"; \
	fi

help:
	@echo "$(BLUE)📖 Available targets:$(NC)"
	@echo "  $(GREEN)make$(NC) or $(GREEN)make up$(NC)     - Build and start all services"
	@echo "  $(GREEN)make down$(NC)           - Stop and remove containers"
	@echo "  $(GREEN)make clean$(NC)          - Remove containers and images"
	@echo "  $(GREEN)make fclean$(NC)         - Complete cleanup including volumes"
	@echo "  $(GREEN)make re$(NC)             - Rebuild everything from scratch"
	@echo "  $(GREEN)make logs$(NC)           - View container logs"
	@echo "  $(GREEN)make status$(NC)         - Show container status"
	@echo "  $(GREEN)make stop$(NC)           - Stop services without removing"
	@echo "  $(GREEN)make restart$(NC)        - Restart services"
	@echo "  $(GREEN)make build$(NC)          - Build Docker images only"
	@echo "  $(GREEN)make setup$(NC)          - Create data directories only"
	@echo "  $(GREEN)make secrets$(NC)        - Generate password files if not exist"
	@echo "  $(GREEN)make images$(NC)         - Show project images"
	@echo "  $(GREEN)make volumes$(NC)        - Show project volumes"
	@echo "  $(GREEN)make networks$(NC)       - Show project networks"
	@echo "  $(GREEN)make fix-perm$(NC)       - Fix data directory permissions (! that can broke the application !)"
	@echo "  $(GREEN)make help$(NC)           - Show this help message"

.PHONY: all up setup secrets build start down clean fclean re logs status stop restart images volumes networks fix-perm help
