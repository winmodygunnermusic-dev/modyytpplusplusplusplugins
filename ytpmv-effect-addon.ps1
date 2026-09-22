# YTP+++ PowerShell plugin: Ytpmv Effect Addon
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Ytpmv Effect Addon'
        description = 'Ytpmv Effect Addon YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Ytpmv Effect Addon'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Ytpmv Effect Addon YTP+++ plugin.'
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
