# YTP+++ PowerShell plugin: Lagfuneffect
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Lagfuneffect'
        description = 'Lagfuneffect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Lagfuneffect'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Lagfuneffect YTP+++ plugin.'
                type = 'label'
            }
        )
    }
}
