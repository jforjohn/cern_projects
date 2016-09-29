#!/usr/bin/python

from jinja2 import Environment, FileSystemLoader
from subprocess import check_call

import hashlib
import os
import signal
import sys

def pgpool_get_configuration():
    configuration = { }
    # Get the port pcp should listen on.
    value = os.getenv('PCP_PORT', 9898)
    configuration.update({ 'pcp_port': value })

    # Get the PCP user.
    value = os.getenv('PCP_USER', 'pcpuser')
    configuration.update({ 'pcp_user': value })
    
    # Get the PCP user password.
    value = os.getenv('PCP_USER_PASSWORD', 'mypass')
    hashpass = hashlib.md5(value)
    configuration.update({ 'pcp_user_password': hashpass.hexdigest() })

    # Get the Recovery user
    value = os.getenv('RECOVERY_USER', 'duper')
    configuration.update({ 'recovery_user': value })
    recovery_user = value

    # Get the Recovery user's password
    value = os.getenv('RECOVERY_USER_PASSWORD', 'superduper')
    hashpass = hashlib.md5(value + recovery_user)
    configuration.update({ 'recovery_user_password': value })
    #configuration.update({ 'recovery_user_password_md5': 'md5' + hashpass.hexdigest() })

    # Get the Streming Replication (sr) check user
    value = os.getenv('SR_CHECK_USER', 'checker')
    configuration.update({ 'sr_check_user': value })

    # Get the Streming Replication (sr) check password
    value = os.getenv('SR_CHECK_PASSWORD', 'test')
    configuration.update({ 'sr_check_password': value }) 

    # Get the Streming Replication (sr) check database
    value = os.getenv('SR_CHECK_DATABASE', 'checker')
    configuration.update({ 'sr_check_database': value })

    # Get the health check user
    value = os.getenv('HEALTH_CHECK_USER', 'checker')
    configuration.update({ 'health_check_user': value })

    # Get the health check password
    value = os.getenv('HEALTH_CHECK_PASSWORD', 'test')
    configuration.update({ 'health_check_password': value })  

    # Get the health check database
    value = os.getenv('HEALTH_CHECK_DATABASE', 'checker')
    configuration.update({ 'health_check_database': value })
    
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

def set_env(configuration, hostsNo, host):
    home = os.environ['HOME']
    fenv = open(home + '/environment.sh','w+')
    #os.environ["PCP_PORT"] = str(configuration['pcp_port'])
    fenv.write("export PCP_PORT=%s\n" %(configuration['pcp_port']))
    #os.environ["PCP_USER"] = configuration['pcp_user']
    fenv.write("export PCP_USER=%s\n" %(configuration['pcp_user']))
    #os.environ["POOL_USER"] = configuration['pool_user']
    fenv.write("export POOL_USER=%s\n" %(configuration['pool_user']))
    #os.environ["PGPOOL_PORT"] = str(configuration['pgpool_port'])
    fenv.write("export PGPOOL_PORT=%s\n" %(configuration['pgpool_port']))
    #os.environ["PGPOOL_BACKENDS"] = ','.join(configuration['pgpool_backends'])
    #fenv.write("export PGPOOL_BACKENDS=%s\n" %(str(configuration['pgpool_backends']).strip('[]')))
    if host:
        #os.environ["HOSTS_NO"] = str(hostsNo)
        fenv.write("export HOSTS_NO=%s\n" %(hostsNo))
        for num in range(hostsNo):
            #os.environ["HOST%s"%(num)] = host[num] 
            fenv.write("export HOST%s=%s\n" %(num,host[num]))
    fenv.close()

'''
def setting_env():
    ssh_config=u'GSSAPIAuthentication yes\nGSSAPIDelegateCredentials yes\nGSSAPITrustDNS yes\nStrictHostKeyChecking no\nForwardAgent yes'
    run('mkdir', '-p', '/root/.ssh')
    run('touch', '/root/.ssh/config')
    write(ssh_config,'/root/.ssh/config')
    run('mkdir', '-p', '/var/run/pgpool')
    run('touch','/var/run/pgpool/pgpool.pid')
    run('echo', '42', '>', '/var/run/pgpool/pgpool.pid')
    run('mkdir', '-p', '/var/log/pgpool')
    run('touch', '/var/log/pgpool/pgpool_status')
    run('chown','-R', 'pgpool:pgpool', '/var/run/pgpool', '/var/log/pgpool', '/usr/local/etc')
    run('ln', '-sf', '/usr/bin/start-pgpool2', '/start-pgpool2')
'''    

if __name__ == "__main__":
    # Initialize Jinja2
    #setting_env()
    if os.path.isfile('/etc/krb5.keytab'):
        print 'INFO - Initialize Kerberos session'
        run('kinit', '-kt', '/etc/krb5.keytab', 'dbod')
    else:
        print 'WARNING - No keytab file available, no failover possible'
    loader = FileSystemLoader('/usr/local/etc')
    templates = Environment(loader = loader)
    
    # Load the configuration into a dictionary.
    configuration = pgpool_get_configuration()
    
    backends = configuration['pgpool_backends']
    hostsNo = 0 
    host = []
    for backend in backends:
        if len(backend.split(':')) < 3:
            print 'ERROR - The right format is: <ID>:<HOST>:PORT[:<DATADIR>]'
            raise ValueError('Invalid Backend: %s' % backend)
        print backend 
        try:
            host.append(backend.split(':')[1].split('-')[1].split('.')[0])
            print 'INFO - Cern specific host'
        except IndexError:
            host.append(backend.split(':')[1])
            print 'INFO - General host format'
        except:
            print sys.exc_info()[0]
            print 'WARNING - Host name must be in this format: [<label>-]<hostname>[.<domain>]'
            print 'WARNING - No host related environment variables can be exported'
            #sys.exit(1)
        hostsNo += 1

    set_env(configuration, hostsNo, host)

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
        run('pgpool', '-n')
    except:
        print "signal trap"
