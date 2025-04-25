
MIGRATIONS=/usr/local/libexec/mybatis-migrations-3.4.0

if [ -d "$MIGRATIONS" ]
then
  export MIGRATIONS
  path+=( $MIGRATIONS/bin )
fi
