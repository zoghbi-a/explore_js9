

c.ServerProxy.servers = {
    
    # Server side helpers to support external communication with JS9 
    # (via the shell and Python) and handle the display of large files.
    # See: https://js9.si.edu/js9/help/helper.html
    'js9Helper': {
        'command': ['bash', '-c', 'cd /opt/js9-web/; node js9Helper.js'],
        'port': 2718,
        'launcher_entry': {
           'enabled': False,
        }
    },
    
    # Main js9 server to serve the html page
    'js9': {
        'command': ['python', '-m', 'http.server', '-d', '/opt/js9-web', '{port}'],
        'launcher_entry': {
            'enabled': True,
            'title': 'JS9'
        }
    }
}

