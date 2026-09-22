# YTP+++ PowerShell plugin: Pitch Shift
#
# This script uses PowerShell-native functions and hashtables so the plugin host
# can query its metadata without parsing Lua syntax.

function Query {
    param(
        $localeName,
        $localizationTokens
    )

    return @{
        name = 'Pitch Shift'
        description = 'Shifts the pitch of the audio up or down.'
        settings = @(
            @{
                name = 'Display Name'
                value = 'Pitch Shift'
                type = 'label'
            },
            @{
                name = 'Description'
                value = 'Shifts the pitch of the audio up or down.'
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
