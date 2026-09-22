# YTP+++ PowerShell plugin: Random Speed
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Random Speed'
        description = 'Random Speed YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Random Speed'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Random Speed YTP+++ plugin.'''
                type = 'label'
            }
        )
    }
}
