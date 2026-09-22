# YTP+++ PowerShell plugin: Sus
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Sus'
        description = 'Random sus-style visual distortion, zoom, shake, color chaos and audio weirdness.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Sus'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Random sus-style visual distortion, zoom, shake, color chaos and audio weirdness.'
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
