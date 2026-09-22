# YTP+++ PowerShell plugin: Get Down Dance Effect Updated
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Get Down Dance Effect Updated'
        description = 'Adds a rhythmic get-down dance effect with bouncing zoom, camera movement, rotation, shake and optional audio punch.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Get Down Dance Effect Updated'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Adds a rhythmic get-down dance effect with bouncing zoom, camera movement, rotation, shake and optional audio punch.'
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
