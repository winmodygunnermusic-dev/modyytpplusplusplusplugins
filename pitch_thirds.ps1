# YTP+++ PowerShell plugin: Pitch Thirds
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Pitch Thirds'
        description = 'Shifts the video''s audio by a musical third while keeping the original duration.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Pitch Thirds'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Shifts the video''s audio by a musical third while keeping the original duration.'
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
