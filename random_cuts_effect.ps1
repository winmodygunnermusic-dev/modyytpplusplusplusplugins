# YTP+++ PowerShell plugin: Random Cuts Effect
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Random Cuts Effect'
        description = 'Random Cuts Effect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Random Cuts Effect'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Random Cuts Effect YTP+++ plugin.'
                type = 'label'
            }
        )
    }
}
