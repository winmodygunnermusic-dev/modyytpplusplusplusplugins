# YTP+++ PowerShell plugin: Short Commercial Overlay
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Short Commercial Overlay'
        description = 'Short Commercial Overlay YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Short Commercial Overlay'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Short Commercial Overlay YTP+++ plugin.'
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
