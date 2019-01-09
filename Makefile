

DIR=$(PWD)
DATE:=$(shell date +%Y-%m-%d)
TIME:=$(shell date +%H:%M:%S)
DRAFT?=0
TITLE?=

# Which Pygments stylesheet to adapt?
HIGHLIGHT_STYLE:=github

DOCKER_IMAGE?=bbries-github-pages:local
DOCKER_IMAGE_FILE?=$(subst :,_,$(DOCKER_IMAGE))
DOCKER_NAME?=bbries_github_pages
CACHE?=./cache
GEMFILES:=$(shell ls -1 Gemfile*)
FILEMOUNT:=$(PWD):/srv/jekyll:rw

ifeq ($(shell uname -s),Darwin)
FILEMOUNT:=$(FILEMOUNT),delegated
endif


all: serve


.PHONY: serve
serve:
	@echo $(notdir $(shell which docker))
ifeq ($(notdir $(shell which docker)),docker)
	$(MAKE) docker-up
else
	jekyll serve $(DRAFT) --watch --incremental --host=0.0.0.0
endif


.PHONY: docker-up
docker-up:  DOCKER_ENV.local | docker-build
ifeq ($(DRAFT),1)
	$(eval DRAFT_ARG := --drafts --unpublished)
else
	$(eval DRAFT_ARG := )
endif
	$(MAKE) docker-clean
	docker ps  --format="{{.ID}}" -f "name=$(DOCKER_NAME)" -f "status=running" | grep -q '^[0-9a-f]+$$' || \
		docker run -it --env-file $^ --rm -p 4000:4000 --name $(DOCKER_NAME) -v "$(FILEMOUNT)" $(DOCKER_IMAGE) \
			bundle exec jekyll serve $(DRAFT_ARG) --watch --force_polling --incremental --host=0.0.0.0

.PHONY: docker-run-test
docker-run-test:  DOCKER_ENV.local
	docker run -it --env-file $^ --rm --name test-$(DOCKER_NAME) -v "$(FILEMOUNT)" $(DOCKER_IMAGE) \
		/bin/bash


.PHONY: clean
clean:
	$(MAKE) docker-stop && sleep 5 && $(MAKE) docker-clean


$(CACHE):
	mkdir -p $@

.PHONY: docker-build
docker-build: $(CACHE)/$(DOCKER_IMAGE_FILE)
$(CACHE)/$(DOCKER_IMAGE_FILE): Dockerfile $(GEMFILES) | $(CACHE)
	test -f Gemfile.lock || touch Gemfile.lock
	chmod a+w Gemfile.lock
	docker build -t "$(DOCKER_IMAGE)" -f $< .
	touch $@

.PHONY: docker-stop
docker-stop:
	docker ps  --format="{{.ID}}" -f "name=$(DOCKER_NAME)" -f "status=running" | xargs -t docker kill

.PHONY: docker-clean
docker-clean:
	docker ps  --format="{{.ID}}" -f "name=$(DOCKER_NAME)" -f "status=exited" | xargs -t docker rm 




