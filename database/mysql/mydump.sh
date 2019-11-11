#!/usr/bin/env bash
# version 20180720
# USAGE: 0 3 * * * sh "/docker/mydump.sh -h 10.114.0.12 -u root -p toor"
HOST="10.114.0.11"
USER="root"
PASSWORD=""
# 选项后面的冒号表示该选项需要参数
while getopts ':h:u:p:' args
do
    case $args in
        h)  HOST=$OPTARG ;;
        u)  USER=$OPTARG ;;
        p)  PASSWORD=$OPTARG ;;
        ?)  echo $args 'not matched' 
            exit 1  ;;
        :)  echo "Option -$OPTARG requires an argument." >&2
            exit 1 ;;
        *)  printf "Usage: %s\n" $0
          exit ;;
    esac
done

if [ -z "$databases" ] ;then
databases=`/usr/bin/mysql -h$HOST -u$USER -p$PASSWORD --execute='show databases' --skip-column-names --batch | grep -v 'mysql\|Database\|performance_schema\|information_schema'`
fi

COMMAND="/usr/bin/mysqldump -h$HOST -u$USER -p$PASSWORD --routines --events --hex-blob --master-data=2 --single-transaction --force"
# check mysql connect 
/usr/bin/mysql -h$HOST -u$USER -p$PASSWORD -e "show variables where Variable_name='max_connections'" 2>/dev/null || return

BACKDIR=/docker/backup

# clean db
/usr/bin/find $BACKDIR -name '*.sql' -ctime +0 -exec rm -f {} \;
/usr/bin/find $BACKDIR -name '*.zip' -ctime +60 -exec rm -f {} \;
/usr/bin/find $BACKDIR -name '*.tar.gz' -ctime +1 -exec rm -f {} \;

# backup db
t=$(date +%F_%H%M)

mkdir -p $BACKDIR/rollback/
echo "#! /usr/bin/env sh">$BACKDIR/rollback/${t}.sh
echo "dump"
for db in $databases ;do
    echo Dump $db ...
    mkdir -p $BACKDIR/$db
    name=${db}_${t}
    $COMMAND $db > $BACKDIR/$db/${name}.sql
    
    sed -i '1i SET NAMES utf8;' $BACKDIR/$db/${name}.sql
    sed -i -E -e 's:\/\*!50017 DEFINER=.* \*\/::g' \
        -e 's/\/\*\!50020 DEFINER=`.*`@`localhost`\*\/ //g' \
        -e 's/CREATE DEFINER=.+ (FUNCTION|PROCEDURE)/CREATE \1/g' \
        -e '/^\/\*\!50013 DEFINER/d' \
        -e 's/!50001 VIEW/!50001 CREATE VIEW/g' $BACKDIR/$db/${name}.sql
    # gen rollback
    echo "# /usr/bin/mysql -h$HOST -u$USER -p$PASSWORD $db < $BACKDIR/$db/${name}.sql">>$BACKDIR/rollback/${t}.sh
    zip -j $BACKDIR/$db/${name}.zip $BACKDIR/$db/${name}.sql
    rm -f $BACKDIR/$db/${name}.sql

    # tar 
    # echo tar -zcf $BACKDIR/${name}.tar.gz -C $BACKDIR/$db/ ${name}.sql
    # tar -zcf $BACKDIR/${name}.tar.gz -C $BACKDIR/$db/  ${name}.sql

    #echo zip -j $BACKDIR/${name}.zip $BACKDIR/$db/${name}.sql
    #zip -j $BACKDIR/${name}.zip $BACKDIR/$db/${name}.sql
done
