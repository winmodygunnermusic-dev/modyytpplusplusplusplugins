# YTP+++ PowerShell plugin: Scratches And Freezes
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Scratches And Freezes'
        description = 'Scratches And Freezes YTP+++ plugin.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Scratches And Freezes'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Scratches And Freezes YTP+++ plugin.'
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
