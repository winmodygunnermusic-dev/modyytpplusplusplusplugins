# YTP+++ PowerShell plugin: Boom Effect
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Boom Effect'
        description = 'Boom Effect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Boom Effect'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Boom Effect YTP+++ plugin.'''
                type = 'label'
            }
        )
    }
}
