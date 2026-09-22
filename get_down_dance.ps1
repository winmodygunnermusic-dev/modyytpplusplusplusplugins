# YTP+++ PowerShell plugin: Get Down Dance
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Get Down Dance'
        description = 'Get Down Dance YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Get Down Dance'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Get Down Dance YTP+++ plugin.'
                type = 'label'
            }
        )
    }
}
