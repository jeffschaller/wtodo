DIR=wtodo-$(VER)

dist:
	mkdir $(DIR)
	mkdir $(DIR)/docs $(DIR)/data
	cp src/data/todo.csv $(DIR)/data
	cp docs/guide/guide.html docs/guide.ps docs/guide.tex $(DIR)/docs
	cp src/wt* src/utilities.pl $(DIR)
	tar cvf $(DIR).tar $(DIR)
	gzip -9 $(DIR).tar
