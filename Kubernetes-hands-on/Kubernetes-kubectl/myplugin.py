from kubectl.commands import kubectl_command

@kubectl_command(name='my-plugin', help='This is my custom plugin')
def my_plugin(args):
    print('Hello from my plugin!')