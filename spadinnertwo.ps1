# YTP+++ PowerShell plugin: Spadinnertwo
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Spadinnertwo'
        description = 'Spadinnertwo YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Spadinnertwo'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Spadinnertwo YTP+++ plugin.'
                type = 'label'
            }
        )
    }
}
