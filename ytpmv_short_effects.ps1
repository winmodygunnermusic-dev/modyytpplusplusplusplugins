# YTP+++ PowerShell plugin: Ytpmv Short Effects
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Ytpmv Short Effects'
        description = 'Ytpmv Short Effects YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Ytpmv Short Effects'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Ytpmv Short Effects YTP+++ plugin.'
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
