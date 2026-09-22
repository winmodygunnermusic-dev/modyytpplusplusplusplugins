# YTP+++ PowerShell plugin: Spadinner
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Spadinner'
        description = 'Spadinner YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Spadinner'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Spadinner YTP+++ plugin.'
                type = 'label'
            }
        )
    }
}
