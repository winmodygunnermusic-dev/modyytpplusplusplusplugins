# YTP+++ PowerShell plugin: Transition Overlay
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Transition Overlay'
        description = 'Overlays a random transition video on top of the current video.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Transition Overlay'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Overlays a random transition video on top of the current video.'
                type = 'label'
            }
        )
    }
}

function StartGeneration {
    param($options, $pluginSettings, $functions)
    return $true
}

function PostCommand {
    param($commandIndex, $outputResult, $errorResult, $options, $pluginSettings, $functions)
}

function StopGeneration {
    param($options, $pluginSettings, $functions)
    return $true
}
