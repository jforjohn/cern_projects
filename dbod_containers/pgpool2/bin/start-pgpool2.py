#!/usr/bin/python

from jinja2 import Environment, FileSystemLoader
from subprocess import check_call

import hashlib
import os
import signal

def pgpool_get_configuration():
        configuration = { }
        # Get the port pcp should listen on.
        value = os.getenv('PCP_PORT', 9898)
        configuration.update({ 'pcp_port': value })
        # Get the PCP user.
        value = os.getenv('PCP_USER', 'postgres')
        configuration.update({ 'pcp_user': value })
        # Get the PCP user password.
        value = os.getenv('PCP_USER_PASSWORD', 'mypass')
        hashpass = hashlib.md5(value)
        configuration.update({ 'pcp_user_password': hashpass.hexdigest() })
        # Get the pgpool user which corresponds to the one in Postgres
        value = os.getenv('POOL_USER','admin')
        configuration.update({ 'pool_user': value })
        pool_user = value
        # Get the pgpool user password which corresponds to the one in Postgres
        value = os.getenv('POOL_USER_PASSWORD','dbod-postgres-test')
        hashpass = hashlib.md5(value + pool_user)
        configuration.update({ 'pool_user_password': 'md5' + hashpass.hexdigest() })
        # Get the port pgpool should listen on.
        value = os.getenv('PGPOOL_PORT', 5432)
        configuration.update({ 'pgpool_port': value })
        # Get the configuration for the backends.
        # FORMAT - INDEX:HOST:PORT
        value = os.getenv('PGPOOL_BACKENDS', '1:localhost:5432').split(',')
        for item in value:
                if not len(item.split(':')) == 3:
                        raise ValueError('Invalid Backend: %s' % item)
        configuration.update({ 'pgpool_backends': value })
        return configuration

def run(app, *args):
        check_call([app] + list(args))

def exit_gracefully(signum, frame):
    #if (signum == 15):
    print '\nExiting forcefully with signal:%s...\n' %(signum)
    run('gosu','pgpool','pgpool','-m','fast','stop')
    #else:
    #    print '\nExiting gracefully with signal:%s...\n' %(signum)
    #    run('gosu','pgpool','pgpool','stop')

def write(template, path):
        with open(path, "wb") as output:
                output.write(template)

if __name__ == "__main__":
        # Initialize Jinja2
        loader = FileSystemLoader('/usr/local/etc')
        templates = Environment(loader = loader)
        # Load the configuration into a dictionary.
        configuration = pgpool_get_configuration()
        # Write PCP user credentials.
        pcp = templates.get_template('pcp.conf.template').render(configuration)
        write(pcp, '/usr/local/etc/pcp.conf')
        pgpoolConf = templates.get_template('pgpool.conf.template').render(configuration)
        write(pgpoolConf, '/usr/local/etc/pgpool.conf')
        pool = templates.get_template('pool_md5.template').render(configuration)
        write(pool, '/usr/local/etc/pool_md5')
        pgpool_hba = templates.get_template('pool_hba.conf.template').render(configuration)
        write(pgpool_hba, '/usr/local/etc/pool_hba.conf')

        # Start the container.
        signal.signal(signal.SIGINT, exit_gracefully)
        signal.signal(signal.SIGTERM, exit_gracefully)
        #signal.signal(signal.SIGKILL, exit_gracefully)
        
        try:
            run('gosu', 'pgpool', 'pgpool', '-dn')
        except:
            print "signal trap"
