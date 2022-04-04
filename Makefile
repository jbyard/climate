SQL := $(sort $(wildcard sql/*.sql))
WWW := /var/www/html

.PHONY: cards install sql

install: sql 

sql: $(SQL)
	for file in $^; do \
		psql -qX postgresql://${PGUSER}@localhost/${PGDATABASE} < $${file}; \
	done;

cards: example/cards.php example/cards.css
	for file in $^; do \
		sudo cp $${file} $(WWW)/; \
	done;
