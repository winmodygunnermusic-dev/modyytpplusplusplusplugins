# YTP+++ PowerShell plugin: Spadinner
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Spadinner'
        description = 'Spadinner YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Spadinner'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Spadinner YTP+++ plugin.'''
                type = 'label'
            }
        )
    }
}
