# var
MODULE = $(notdir $(CURDIR))
REL    = $(shell git rev-parse --short=4    HEAD)
BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
NOW    = $(shell date +%d%m%y)

# version
DMD_VER    = 2.109.1

# dir
CWD   = $(CURDIR)
GZ    = $(HOME)/gz

# tool
CURL   = curl -L -o
CF     = clang-format -style=file -i
DUB    = /usr/bin/dub

# package
DMD_DEB   = dmd_$(DMD_VER)-0_amd64.deb
DMD_URL   = https://downloads.dlang.org/releases/2.x

# src
C += $(wildcard src/*.c*)
H += $(wildcard inc/*.h*) $(wildcard lib/*.h*)
D += $(wildcard src/*.d*)
J += lib/$(MODULE).ini $(wildcard lib/*.js)

# all
.PHONY: all run
all: bin/$(MODULE)
run: bin/$(MODULE) $(J)
	$(DUB) run -- $(J)

# format
.PHONY: format
format: tmp/format_cpp tmp/format_d
tmp/format_cpp: $(C) $(H)
	$(CF) $? && touch $@
tmp/format_d: $(D)
	$(DUB) run dfmt -- -i $? && touch $@

# rule
bin/$(MODULE): $(D) dub.json
	$(DUB) build

# doc
.PHONY: doc
doc: \
	doc/ECMA/ECMA-1.pdf

doc/ECMA/ECMA-1.pdf:
	$(CURL) $@ https://ecma-international.org/wp-content/uploads/ECMA-262_1st_edition_june_1997.pdf

# install
.PHONY: install update ref gz
install: doc ref gz $(DUB)
	$(MAKE) update
	$(DUB) build --build=release dfmt
update:
	sudo apt update
	sudo apt install -uy `cat apt.txt`
ref: \
	ref/Espruino/README.md
gz: \
	$(GZ)/$(DMD_DEB) $(SERVED)

$(DUB): $(GZ)/$(DMD_DEB)
	sudo dpkg -i $<
$(GZ)/$(DMD_DEB):
	$(CURL) $@ $(DMD_URL)/$(DMD_VER)/$(DMD_DEB)

ref/Espruino/README.md:
	git clone --depth 1 https://github.com/espruino/Espruino.git ref/Espruino

# merge
MERGE += README.md Makefile apt.txt
MERGE += .clang-format .doxygen .gitignore .editorconfig
MERGE += .vscode bin doc lib inc src tmp ref
MERGE += $(C) $(H) $(D) $(J) dub.json

.PHONY: dev
dev:
	git push -v
	git checkout $@
	git pull -v
	git checkout $(USER) -- $(MERGE)
# $(MAKE) doxy ; git add -f docs

.PHONY: $(USER)
$(USER):
	git push -v
	git checkout $(USER)
	git pull -v

.PHONY: release
release:
	git tag $(NOW)-$(REL)
	git push -v --tags
	$(MAKE) $(USER)

ZIP = tmp/$(MODULE)_$(NOW)_$(REL)_$(BRANCH).zip
zip: $(ZIP)
$(ZIP):
	git archive --format zip --output $(ZIP) HEAD
