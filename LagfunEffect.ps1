# YTP+++ PowerShell plugin: Lagfuneffect
# PowerShell-native metadata prevents plugin discovery from parsing Lua syntax.

function Query {
    param($localeName, $localizationTokens)

    return @{
        name = 'Lagfuneffect'
        description = 'Lagfuneffect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = '''Lagfuneffect'''
                type = 'label'
            },
            @{
                name = 'Description'
                value = '''Lagfuneffect YTP+++ plugin.'''
                type = 'label'
            }
        )
    }
}
