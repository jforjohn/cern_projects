#!/bin/sh

chown -R postgres $PGCONF
gosu postgres cp $PGCONF/* $PGDATA
