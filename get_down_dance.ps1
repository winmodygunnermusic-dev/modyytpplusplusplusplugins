# YTP+++ PowerShell plugin: Get Down Dance
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Get Down Dance'
        description = 'Get Down Dance YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Get Down Dance'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Get Down Dance YTP+++ plugin.'''
                type = 'label'
            }
        )
    }
}
