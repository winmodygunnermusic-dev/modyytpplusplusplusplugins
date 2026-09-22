# YTP+++ PowerShell plugin: Speed Loop Boost
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Speed Loop Boost'
        description = 'Speed Loop Boost YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Speed Loop Boost'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Speed Loop Boost YTP+++ plugin.'
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
