# -*- mode: makefile; tab-width: 8; indent-tabs-mode: 1 -*-
# vim: ts=8 sw=8 ft=make noet

VERSIONS=latest
SERVICE=code
DEPENDS=hoarder unfs logvac mist

default: all

.PHONY: all

all: stable

.PHONY: test

test: $(addprefix test-,${VERSIONS})

.PHONY: test-%

test-%: mubox/${SERVICE}-%
	stdbuf -oL test/run_all.sh $(subst test-,,$@)

.PHONY: mubox/${SERVICE}-%

mubox/${SERVICE}-%:
	for i in ${DEPENDS}; do \
		docker pull mubox/$${i} || (docker pull mubox/$${i}-beta; docker tag mubox/$${i}-beta mubox/$${i}); \
	done
	docker pull $(subst -,:,$@) || (docker pull $(subst -,:,$@)-beta; docker tag $(subst -,:,$@)-beta $(subst -,:,$@))

.PHONY: stable beta alpha

stable:
	@./util/publish.sh stable

beta:
	@./util/publish.sh beta

alpha:
	@./util/publish.sh alpha
