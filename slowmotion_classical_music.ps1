# YTP+++ PowerShell plugin: Slowmotion Classical Music
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Slowmotion Classical Music'
        description = 'Slowmotion Classical Music YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Slowmotion Classical Music'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Slowmotion Classical Music YTP+++ plugin.'''
                type = 'label'
            }
        )
    }
}
