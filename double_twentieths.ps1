# YTP+++ PowerShell plugin: Double Twentieths
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Double Twentieths'
        description = 'Duplicates tiny 1/20-second sections of the video to create a rapid doubled micro-stutter effect.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Double Twentieths'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Duplicates tiny 1/20-second sections of the video to create a rapid doubled micro-stutter effect.'
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
