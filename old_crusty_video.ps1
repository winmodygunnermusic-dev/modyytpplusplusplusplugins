# YTP+++ PowerShell plugin: Old Crusty Video
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Old Crusty Video'
        description = 'Old Crusty Video YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Old Crusty Video'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Old Crusty Video YTP+++ plugin.'
                type = 'label'
            }
        )
    }
}
