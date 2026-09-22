# YTP+++ PowerShell plugin: Repeatedly Slow Down
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Repeatedly Slow Down'
        description = 'Repeatedly slows the video down through multiple passes.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Repeatedly Slow Down'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Repeatedly slows the video down through multiple passes.'
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
