DIR=wtodo-1.1
FILES=\
	$(DIR)/data/todo.csv \
	$(DIR)/Changelog \
	$(DIR)/README \
	$(DIR)/utilities.pl \
	$(DIR)/wt_display.cgi \
	$(DIR)/wt_edit.cgi \
	$(DIR)/GUIDE.txt

tar:
	tar czvf wtodo-1.1.tar.gz $(FILES)

# to move to website:
# scp htdocs/index.html schaller@wtodo.sourceforge.net:/home/groups/w/wt/wtodo/htdocs
