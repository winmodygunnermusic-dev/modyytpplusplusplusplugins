# YTP+++ PowerShell plugin: Trailing Reverses Effect
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Trailing Reverses Effect'
        description = 'Trailing Reverses Effect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Trailing Reverses Effect'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Trailing Reverses Effect YTP+++ plugin.'''
                type = 'label'
            }
        )
    }
}
