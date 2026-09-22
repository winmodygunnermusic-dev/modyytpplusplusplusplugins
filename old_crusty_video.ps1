# YTP+++ PowerShell plugin: Old Crusty Video
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Old Crusty Video'
        description = 'Old Crusty Video YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Old Crusty Video'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Old Crusty Video YTP+++ plugin.'''
                type = 'label'
            }
        )
    }
}
