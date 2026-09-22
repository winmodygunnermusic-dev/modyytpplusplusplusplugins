# YTP+++ PowerShell plugin: Boom Effect
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Boom Effect'
        description = 'Boom Effect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Boom Effect'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Boom Effect YTP+++ plugin.'
                type = 'label'
            }
        )
    }
}
