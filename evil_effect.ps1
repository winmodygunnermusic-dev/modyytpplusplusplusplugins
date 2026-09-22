# YTP+++ PowerShell plugin: Evil
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Evil'
        description = 'Turns the video into a sinister evil-themed effect with dark colors, red highlights, contrast, distortion, and unsettling audio.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Evil'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Turns the video into a sinister evil-themed effect with dark colors, red highlights, contrast, distortion, and unsettling audio.'
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
