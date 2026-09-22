# YTP+++ PowerShell plugin: Random Speed
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Random Speed'
        description = 'Random Speed YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Random Speed'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Random Speed YTP+++ plugin.'
                type = 'label'
            }
        )
    }
}
