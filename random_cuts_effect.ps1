# YTP+++ PowerShell plugin: Random Cuts Effect
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Random Cuts Effect'
        description = 'Random Cuts Effect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Random Cuts Effect'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Random Cuts Effect YTP+++ plugin.'''
                type = 'label'
            }
        )
    }
}
