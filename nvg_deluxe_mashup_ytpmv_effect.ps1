# YTP+++ PowerShell plugin: Nvg Deluxe Mashup Ytpmv Effect
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Nvg Deluxe Mashup Ytpmv Effect'
        description = 'Nvg Deluxe Mashup Ytpmv Effect YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Nvg Deluxe Mashup Ytpmv Effect'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Nvg Deluxe Mashup Ytpmv Effect YTP+++ plugin.'
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
