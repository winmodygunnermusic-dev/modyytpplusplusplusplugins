# YTP+++ PowerShell plugin: Rotating Gradient Overlay
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Rotating Gradient Overlay'
        description = 'Adds a continuously rotating colored gradient overlay.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Rotating Gradient Overlay'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Adds a continuously rotating colored gradient overlay.'
                type = 'label'
            }
        )
    }
}
