#!/bin/bash
mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} << EOF
USE Universe;
INSERT INTO Heroes(HeroId, HeroName) VALUES(4, "Bob");
EOF